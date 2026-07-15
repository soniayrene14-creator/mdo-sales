import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/params/no_param.dart';
import '../../../domain/usecases/user_usecases.dart';
import '../auth/auth_notifier.dart';
import 'account_state.dart';

final accountNotifierProvider = NotifierProvider.autoDispose<AccountNotifier, AccountFormState>(
  AccountNotifier.new,
);

class AccountNotifier extends AutoDisposeNotifier<AccountFormState> {
  @override
  AccountFormState build() {
    return const AccountFormState();
  }

  String _requireUserId() {
    final authState = ref.read(authNotifierProvider);
    if (authState.isAuthenticated) return authState.user!.id;
    throw 'Non authentifié !';
  }

  Future<void> initProfileForm() async {
    _requireUserId();
    final userRepository = ref.read(userRepositoryProvider);

    var res = await GetMeUsecase(userRepository).call(NoParam());

    if (res.isSuccess) {
      state = state.copyWith(
        imageUrl: res.data?.imageUrl,
        name: res.data?.name,
        email: res.data?.email,
        phone: res.data?.phone,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Échec du chargement des données';
    }
  }

  Future<Result<void>> updatedUser() async {
    try {
      final userId = _requireUserId();
      final userRepository = ref.read(userRepositoryProvider);

      var user = UserEntity(
        id: userId,
        email: state.email,
        phone: state.phone,
        name: state.name!,
        imageUrl: state.imageUrl ?? '',
      );

      var res = await UpdateMeUsecase(userRepository).call((user: user, imageFilePath: state.imageFile?.path));

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedImage(File value) {
    state = state.copyWith(imageFile: value);
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedEmail(String value) {
    state = state.copyWith(email: value);
  }

  void onChangedPhone(String value) {
    state = state.copyWith(phone: value);
  }
}
