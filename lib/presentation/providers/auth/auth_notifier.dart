import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../domain/usecases/auth_usecases.dart';
import '../../../domain/usecases/params/login_params.dart';
import '../../../domain/usecases/params/no_param.dart';
import 'auth_state.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _initialize();
    return const AuthState(isChecking: true);
  }

  Future<void> _initialize() async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final res = await GetCurrentUserUsecase(authRepository).call(NoParam());

      final user = res.data;
      cl('isAuthenticated: ${user != null}');

      state = AuthState(user: user);
    } catch (_) {
      state = const AuthState();
    }
  }

  Future<Result<String>> signInWith({
    required String email,
    required String password,
  }) async {
    return _authenticate(
      LoginParams(email: email, password: password),
    );
  }

  Future<Result<String>> _authenticate(LoginParams params) async {
    final authRepository = ref.read(authRepositoryProvider);

    final res = await LoginUsecase(authRepository).call(params);
    if (res.isFailure) return Result.failure(error: res.error!);

    try {
      state = state.copyWith(
        user: res.data!,
        accessToken: authRepository.accessToken,
        refreshToken: authRepository.refreshToken,
      );
    } catch (e) {
      // Surface anything thrown by listeners reacting to this state change
      // (e.g. the router's redirect logic) instead of letting it vanish
      // silently past signInWith's caller.
      return Result.failure(error: e);
    }

    return Result.success(data: res.data!.id);
  }

  Future<Result<void>> signOut() async {
    final authRepository = ref.read(authRepositoryProvider);

    final res = await SignOutUsecase(authRepository).call(NoParam());
    if (res.isFailure) return Result.failure(error: res.error!);

    state = const AuthState();

    return Result.success(data: null);
  }
}
