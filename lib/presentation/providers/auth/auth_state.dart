import '../../../domain/entities/user_entity.dart';

class AuthState {
  final bool isChecking;
  final UserEntity? user;
  final String? accessToken;
  final String? refreshToken;

  const AuthState({
    this.isChecking = false,
    this.user,
    this.accessToken,
    this.refreshToken,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isChecking,
    UserEntity? user,
    String? accessToken,
    String? refreshToken,
  }) {
    return AuthState(
      isChecking: isChecking ?? this.isChecking,
      user: user ?? this.user,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }
}
