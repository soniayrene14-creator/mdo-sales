// lib/features/auth/domain/repositories/auth_repository.dart

import '../../../../core/common/result.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Authenticates a user against the Django backend using username/password
  /// credentials and returns the JWT-authenticated user entity.
  Future<Result<UserEntity>> login(String username, String password);

  /// Signs the current user out and revokes the stored refresh token.
  Future<Result<void>> signOut();

  /// Returns the currently authenticated user, or null when signed out.
  Future<Result<UserEntity?>> getCurrentUser();

  /// Changes the current user's password.
  Future<Result<void>> changePassword(String oldPassword, String newPassword);

  /// Access token issued by the last successful login, if any.
  String? get accessToken;

  /// Refresh token issued by the last successful login, if any.
  String? get refreshToken;
}
