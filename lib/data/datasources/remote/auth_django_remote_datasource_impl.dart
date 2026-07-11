import '../../../core/common/result.dart';
import '../../../core/services/api/api_client.dart';
import '../../../core/services/auth/token_storage_service.dart';
import '../../models/user_model.dart';
import '../interfaces/auth_datasource.dart';

class AuthDjangoRemoteDataSourceImpl implements AuthDataSource {
  final ApiClient apiClient;
  final TokenStorageService tokenStorage;

  AuthDjangoRemoteDataSourceImpl({
    required this.apiClient,
    required this.tokenStorage,
  }) {
    apiClient.setToken(tokenStorage.accessToken);
    apiClient.setUnauthorizedHandler(_handleUnauthorized);
  }

  @override
  String? get accessToken => tokenStorage.accessToken;

  @override
  String? get refreshToken => tokenStorage.refreshToken;

  Future<String?> _handleUnauthorized() async {
    final result = await refreshAccessToken();
    return result.isSuccess ? result.data : null;
  }

  @override
  Future<Result<UserModel>> login(String email, String password) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/login/',
        {
          'email': email,
          'password': password,
        },
        parser: (json) => json ?? <String, dynamic>{},
        skipAuthRetry: true,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      final access = data['access'] as String?;
      final refresh = data['refresh'] as String?;

      if (access == null || refresh == null) {
        return Result.failure(error: 'Access or refresh token is missing from login response.');
      }

      await tokenStorage.saveTokens(accessToken: access, refreshToken: refresh);
      apiClient.setToken(access);

      final userJson = data['user'] as Map<String, dynamic>?;
      if (userJson == null) {
        return Result.failure(error: 'User data is missing from login response.');
      }

      return Result.success(data: UserModel.fromJson(userJson));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> refreshAccessToken() async {
    try {
      final refresh = tokenStorage.refreshToken;
      if (refresh == null) {
        return Result.failure(error: 'No refresh token available.');
      }

      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh/',
        {'refresh': refresh},
        parser: (json) => json ?? <String, dynamic>{},
        skipAuthRetry: true,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      final newAccess = data['access'] as String?;
      final newRefresh = data['refresh'] as String?;

      if (newAccess == null) {
        return Result.failure(error: 'Access token is missing from refresh response.');
      }

      await tokenStorage.saveTokens(accessToken: newAccess, refreshToken: newRefresh ?? refresh);
      apiClient.setToken(newAccess);

      return Result.success(data: newAccess);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> _logout(String refreshToken) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/logout/',
        {'refresh': refreshToken},
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      await tokenStorage.clear();
      apiClient.setToken(null);

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> signOut() async {
    final token = tokenStorage.refreshToken;

    if (token == null) {
      return Result<void>.success(data: null);
    }

    return _logout(token);
  }

  @override
  Future<Result<UserModel?>> getCurrentUser() async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/auth/me/',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      if (data.isEmpty) {
        return Result.success(data: null);
      }

      return Result.success(data: UserModel.fromJson(data));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> changePassword(String oldPassword, String newPassword) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/auth/change-password/',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result<void>.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
