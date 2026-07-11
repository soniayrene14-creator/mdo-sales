import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/usecases/auth_usecases.dart';
import 'change_password_state.dart';

final changePasswordNotifierProvider = NotifierProvider.autoDispose<ChangePasswordNotifier, ChangePasswordState>(
  ChangePasswordNotifier.new,
);

class ChangePasswordNotifier extends AutoDisposeNotifier<ChangePasswordState> {
  @override
  ChangePasswordState build() {
    return const ChangePasswordState();
  }

  Future<Result<void>> changePassword(String oldPassword, String newPassword) async {
    state = state.copyWith(isLoading: true, error: null);
    final repository = ref.read(authRepositoryProvider);
    final result = await ChangePasswordUsecase(repository).call(
      ChangePasswordParams(oldPassword: oldPassword, newPassword: newPassword),
    );
    if (result.isSuccess) {
      state = state.copyWith(isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: result.error?.toString());
    }
    return result;
  }
}
