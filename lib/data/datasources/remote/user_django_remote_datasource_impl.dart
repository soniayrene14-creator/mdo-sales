import '../../../core/common/result.dart';
import '../../../core/services/api/api_client.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserDjangoRemoteDataSourceImpl implements UserDatasource {
  final ApiClient apiClient;

  UserDjangoRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Result<String>> createUser(UserModel user, {String? imageFilePath}) async {
    try {
      final (firstName, lastName) = _splitName(user.name);

      final result = await apiClient.postMultipart<Map<String, dynamic>>(
        '/api/v1/users/',
        fields: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (user.email != null) 'email': user.email!,
          if (user.phone != null) 'phone': user.phone!,
        },
        filePath: imageFilePath,
        fileField: 'photo',
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final id = result.data!['id'];
      return Result.success(data: id?.toString() ?? user.id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user, {String? imageFilePath}) async {
    try {
      final (firstName, lastName) = _splitName(user.name);

      final fields = <String, String>{
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
        if (user.email != null) 'email': user.email!,
        if (user.phone != null) 'phone': user.phone!,
      };

      // Only touched by the admin employee-management flow: the own-profile
      // edit flow never sets these, so omitting them there avoids
      // accidentally clearing role/active status.
      if (user.role != null) fields['role'] = user.role!;
      if (user.isActive != null) fields['is_active'] = user.isActive!.toString();

      final result = await apiClient.putMultipart<Map<String, dynamic>>(
        '/api/v1/users/${user.id}/',
        fields: fields,
        filePath: imageFilePath,
        fileField: 'photo',
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

  @override
  Future<Result<({String id, String generatedPassword})>> createEmployee(UserModel user) async {
    try {
      final (firstName, lastName) = _splitName(user.name);

      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/users/',
        {
          'username': user.username,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          'email': user.email,
          if (user.phone != null) 'phone': user.phone!,
          'role': user.role,
        },
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final data = result.data!;
      final id = data['id']?.toString();
      final generatedPassword = data['generated_password'] as String?;

      if (id == null || generatedPassword == null) {
        return Result.failure(error: 'Id or generated password is missing from response.');
      }

      return Result.success(data: (id: id, generatedPassword: generatedPassword));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(String id) async {
    try {
      final result = await apiClient.delete<Map<String, dynamic>>(
        '/api/v1/users/$id/',
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

  @override
  Future<Result<UserModel?>> getUser(String id) async {
    try {
      final result = await apiClient.get<Map<String, dynamic>>(
        '/api/v1/users/$id/',
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
  Future<Result<List<UserModel>>> getUsers({String? search}) async {
    try {
      final query = <String, dynamic>{};
      if (search != null && search.isNotEmpty) {
        query['search'] = search;
      }

      final result = await apiClient.get<List<UserModel>>(
        '/api/v1/users/',
        query: query,
        parser: _parseList,
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      return Result.success(data: result.data ?? <UserModel>[]);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<String>> resetPassword(String id) async {
    try {
      final result = await apiClient.post<Map<String, dynamic>>(
        '/api/v1/users/$id/reset-password/',
        null,
        parser: (json) => json ?? <String, dynamic>{},
      );

      if (result.isFailure) {
        return Result.failure(error: result.error!);
      }

      final generatedPassword = result.data!['generated_password'] as String?;
      if (generatedPassword == null) {
        return Result.failure(error: 'Generated password is missing from response.');
      }

      return Result.success(data: generatedPassword);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  List<UserModel> _parseList(dynamic json) {
    final results = json?['results'];
    if (results is List) {
      return results.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    return <UserModel>[];
  }

  (String?, String?) _splitName(String? name) {
    final trimmed = name?.trim();
    if (trimmed == null || trimmed.isEmpty) return (null, null);

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, null);

    return (parts.first, parts.sublist(1).join(' '));
  }
}
