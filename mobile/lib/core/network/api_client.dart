import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();
typedef UnauthorizedHandler = Future<void> Function();

/// Thin HTTP wrapper around the Spring Boot REST API.
///
/// Every backend response is wrapped in an envelope:
/// `{ "success": bool, "message": String?, "data": T?, "timestamp": String }`
/// This client unwraps it and throws [ApiException] on failure, so repositories
/// only ever deal with the payload.
class ApiClient {
  ApiClient({
    http.Client? client,
    TokenProvider? tokenProvider,
    this.onUnauthorized,
  })  : _client = client ?? http.Client(),
        _tokenProvider = tokenProvider;

  final http.Client _client;
  final TokenProvider? _tokenProvider;
  final UnauthorizedHandler? onUnauthorized;

  String get baseUrl => AppConfig.apiBaseUrl;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) =>
      _send('GET', path, query: query, authenticated: authenticated);

  Future<dynamic> post(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) =>
      _send('POST', path,
          body: body, query: query, authenticated: authenticated);

  Future<dynamic> put(
    String path, {
    Object? body,
    bool authenticated = true,
  }) =>
      _send('PUT', path, body: body, authenticated: authenticated);

  Future<dynamic> patch(
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) =>
      _send('PATCH', path,
          body: body, query: query, authenticated: authenticated);

  Future<dynamic> delete(
    String path, {
    bool authenticated = true,
  }) =>
      _send('DELETE', path, authenticated: authenticated);

  /// Uploads a single file as `multipart/form-data`.
  Future<dynamic> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, String> fields = const <String, String>{},
  }) async {
    final Uri uri = _buildUri(path, null);
    final http.MultipartRequest request = http.MultipartRequest('POST', uri);
    request.fields.addAll(fields);
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final String? token = await _tokenProvider?.call();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final http.StreamedResponse streamed =
          await _client.send(request).timeout(AppConfig.requestTimeout);
      final http.Response response =
          await http.Response.fromStream(streamed);
      return await _handleResponse(response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException {
      throw ApiException.network();
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    }
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Object? body,
    Map<String, dynamic>? query,
    bool authenticated = true,
  }) async {
    final Uri uri = _buildUri(path, query);
    final Map<String, String> headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
      'Accept': 'application/json',
    };

    if (authenticated) {
      final String? token = await _tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    final String? encoded = body == null ? null : jsonEncode(body);

    try {
      late http.Response response;
      final Future<http.Response> future;
      switch (method) {
        case 'GET':
          future = _client.get(uri, headers: headers);
          break;
        case 'POST':
          future = _client.post(uri, headers: headers, body: encoded);
          break;
        case 'PUT':
          future = _client.put(uri, headers: headers, body: encoded);
          break;
        case 'PATCH':
          future = _client.patch(uri, headers: headers, body: encoded);
          break;
        case 'DELETE':
          future = _client.delete(uri, headers: headers, body: encoded);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }
      response = await future.timeout(AppConfig.requestTimeout);
      return await _handleResponse(response);
    } on TimeoutException {
      throw ApiException.timeout();
    } on SocketException {
      throw ApiException.network();
    } on HandshakeException {
      throw ApiException.network(
        'Secure connection to the server failed. Check the API URL.',
      );
    } on http.ClientException catch (e) {
      throw ApiException.network(e.message);
    } on FormatException {
      throw ApiException('The server returned an unexpected response.');
    }
  }

  Uri _buildUri(String path, Map<String, dynamic>? query) {
    final String normalised = path.startsWith('/') ? path : '/$path';
    final Uri base = Uri.parse('$baseUrl$normalised');
    if (query == null || query.isEmpty) {
      return base;
    }
    final Map<String, String> params = <String, String>{};
    query.forEach((String key, dynamic value) {
      if (value != null) {
        params[key] = value.toString();
      }
    });
    return base.replace(queryParameters: params);
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    final int status = response.statusCode;
    dynamic decoded;

    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(utf8.decode(response.bodyBytes));
      } catch (_) {
        decoded = null;
      }
    }

    String? envelopeMessage;
    dynamic payload = decoded;

    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('success') || decoded.containsKey('data')) {
        envelopeMessage = decoded['message'] as String?;
        payload = decoded['data'];
      }
      // Spring validation errors arrive as { "errors": { field: message } }.
      if (decoded['errors'] is Map) {
        final Map<dynamic, dynamic> errors =
            decoded['errors'] as Map<dynamic, dynamic>;
        if (errors.isNotEmpty) {
          envelopeMessage = errors.values.first.toString();
        }
      }
    }

    if (status >= 200 && status < 300) {
      return payload;
    }

    if (status == 401 || status == 403) {
      await onUnauthorized?.call();
    }

    throw ApiException(
      envelopeMessage ?? _defaultMessageFor(status),
      statusCode: status,
    );
  }

  String _defaultMessageFor(int status) {
    switch (status) {
      case 400:
        return 'That request was not valid. Please check the details and retry.';
      case 401:
        return 'Your session has expired. Please sign in again.';
      case 403:
        return 'You do not have permission to do that.';
      case 404:
        return 'We could not find what you were looking for.';
      case 409:
        return 'That action conflicts with existing data.';
      case 429:
        return 'Too many requests. Please slow down and try again.';
      case 500:
      case 502:
      case 503:
        return 'The Bright Future server is having trouble. Try again shortly.';
      default:
        return 'Something went wrong (error $status).';
    }
  }

  void dispose() => _client.close();
}
