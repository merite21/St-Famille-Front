import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'api_exception.dart';

/// Client HTTP générique pour l'API REST PHP : ajoute l'en-tête
/// d'authentification, sérialise/désérialise le JSON, et transforme
/// toute erreur (réseau ou renvoyée par l'API) en [ApiException] avec
/// un message déjà prêt à afficher à l'utilisateur.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  bool get isAuthenticated => _token != null;

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanedQuery = query == null
        ? null
        : query.map((key, value) => MapEntry(key, value?.toString()))
          ..removeWhere((key, value) => value == null);

    return Uri.parse('${ApiConfig.baseUrl}$path').replace(
      queryParameters: (cleanedQuery == null || cleanedQuery.isEmpty)
          ? null
          : cleanedQuery.cast<String, String>(),
    );
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json; charset=utf-8',
        'Accept': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) {
    return _send(() => http.get(_uri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, [Map<String, dynamic>? body]) {
    return _send(
      () => http.post(_uri(path), headers: _headers, body: jsonEncode(body ?? {})),
    );
  }

  Future<dynamic> put(String path, [Map<String, dynamic>? body]) {
    return _send(
      () => http.put(_uri(path), headers: _headers, body: jsonEncode(body ?? {})),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() request) async {
    late final http.Response response;

    try {
      response = await request().timeout(const Duration(seconds: 20));
    } on TimeoutException {
      throw const ApiException(
        'Le serveur met trop de temps à répondre. Réessaie dans un instant.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifie ta connexion et que l’API est démarrée.',
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Impossible de joindre le serveur. Vérifie ta connexion et que l’API est démarrée.',
      );
    }

    if (response.statusCode == 204 || response.body.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return null;
      }
      throw ApiException(
        'Le serveur a répondu une erreur inattendue (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException(
        'Réponse du serveur illisible (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    throw _errorFrom(decoded, response.statusCode);
  }

  ApiException _errorFrom(dynamic decoded, int statusCode) {
    if (decoded is Map<String, dynamic>) {
      final errorCode = decoded['error']?.toString();
      final fields = decoded['fields'];

      if (fields is Map && fields.isNotEmpty) {
        final messages = fields.values
            .expand((value) => value is List ? value : [value])
            .map((value) => value.toString())
            .join(' ');
        return ApiException(messages, statusCode: statusCode, errorCode: errorCode);
      }

      final message = decoded['message']?.toString();
      if (message != null && message.isNotEmpty) {
        return ApiException(message, statusCode: statusCode, errorCode: errorCode);
      }
    }

    return ApiException(
      'Une erreur est survenue ($statusCode).',
      statusCode: statusCode,
    );
  }
}
