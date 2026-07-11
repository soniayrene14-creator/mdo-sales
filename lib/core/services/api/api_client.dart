import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../common/result.dart';

class ApiClient {
  final String baseUrl;
  String? _token;
  Future<String?> Function()? _onUnauthorized;

  static const Duration _timeout = Duration(seconds: 15);

  ApiClient({
    required this.baseUrl,
    String? token,
  }) : _token = token;

  void setToken(String? token) {
    _token = token;
  }

  /// Registers a callback invoked when a request comes back with 401.
  /// It must return a fresh access token on success, or null if the session
  /// could not be renewed (the original 401 result is then returned as-is).
  void setUnauthorizedHandler(Future<String?> Function()? handler) {
    _onUnauthorized = handler;
  }

  Map<String, String> _getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }

    return headers;
  }

  Future<Result<T>> _executeWithRefresh<T>(
    Future<http.Response> Function() request, {
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) async {
    var response = await request().timeout(_timeout);

    if (response.statusCode == 401 && !skipAuthRetry && _onUnauthorized != null) {
      final newToken = await _onUnauthorized!();

      if (newToken != null) {
        setToken(newToken);
        response = await request().timeout(_timeout);
      }
    }

    return Result.fromHttpResponse(response: response, parser: parser);
  }

  Future<Result<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path, queryParameters: query);

    return _executeWithRefresh(
      () => http.get(uri, headers: _getHeaders()),
      parser: parser,
      skipAuthRetry: skipAuthRetry,
    );
  }

  /// Downloads a binary response (e.g. a generated PDF) instead of parsing
  /// it as JSON. Reuses the same auth/refresh flow as [get].
  Future<Result<List<int>>> getBytes(String path) async {
    final uri = Uri.parse(baseUrl).replace(path: path);

    var response = await http.get(uri, headers: _getHeaders()).timeout(_timeout);

    if (response.statusCode == 401 && _onUnauthorized != null) {
      final newToken = await _onUnauthorized!();

      if (newToken != null) {
        setToken(newToken);
        response = await http.get(uri, headers: _getHeaders()).timeout(_timeout);
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return Result.failure(
        title: 'HTTP Error',
        message: response.reasonPhrase,
        state: response.statusCode.toString(),
        error: 'HTTP Error with status code: ${response.statusCode}',
      );
    }

    return Result.success(data: response.bodyBytes);
  }

  Future<Result<T>> post<T>(
    String path,
    Map<String, dynamic>? body, {
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path);

    return _executeWithRefresh(
      () => http.post(uri, headers: _getHeaders(), body: body != null ? json.encode(body) : null),
      parser: parser,
      skipAuthRetry: skipAuthRetry,
    );
  }

  Future<Result<T>> put<T>(
    String path,
    Map<String, dynamic>? body, {
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path);

    return _executeWithRefresh(
      () => http.put(uri, headers: _getHeaders(), body: body != null ? json.encode(body) : null),
      parser: parser,
      skipAuthRetry: skipAuthRetry,
    );
  }

  Future<Result<T>> delete<T>(
    String path, {
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path);

    return _executeWithRefresh(
      () => http.delete(uri, headers: _getHeaders()),
      parser: parser,
      skipAuthRetry: skipAuthRetry,
    );
  }

  /// Sends [fields] as a multipart/form-data request, attaching the file at
  /// [filePath] (if any) under [fileField]. Required for endpoints backed by
  /// a Django ImageField/FileField: those don't accept a JSON string for the
  /// file, only an actual uploaded file part.
  Future<Result<T>> postMultipart<T>(
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = 'image',
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) => _sendMultipart(
    'POST',
    path,
    fields: fields,
    filePath: filePath,
    fileField: fileField,
    parser: parser,
    skipAuthRetry: skipAuthRetry,
  );

  /// Same as [postMultipart], for endpoints updated with PUT.
  Future<Result<T>> putMultipart<T>(
    String path, {
    required Map<String, String> fields,
    String? filePath,
    String fileField = 'image',
    T Function(dynamic)? parser,
    bool skipAuthRetry = false,
  }) => _sendMultipart(
    'PUT',
    path,
    fields: fields,
    filePath: filePath,
    fileField: fileField,
    parser: parser,
    skipAuthRetry: skipAuthRetry,
  );

  Future<Result<T>> _sendMultipart<T>(
    String method,
    String path, {
    required Map<String, String> fields,
    String? filePath,
    required String fileField,
    T Function(dynamic)? parser,
    required bool skipAuthRetry,
  }) async {
    final uri = Uri.parse(baseUrl).replace(path: path);

    Future<http.Response> request() async {
      final multipartRequest = http.MultipartRequest(method, uri);

      if (_token != null) {
        multipartRequest.headers['Authorization'] = 'Bearer $_token';
      }

      multipartRequest.fields.addAll(fields);

      if (filePath != null) {
        multipartRequest.files.add(await http.MultipartFile.fromPath(fileField, filePath));
      }

      final streamedResponse = await multipartRequest.send();
      return http.Response.fromStream(streamedResponse);
    }

    return _executeWithRefresh(request, parser: parser, skipAuthRetry: skipAuthRetry);
  }
}
