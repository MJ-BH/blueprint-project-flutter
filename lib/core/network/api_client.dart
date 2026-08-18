import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../errors/failures.dart';

class ApiClient {
  final String baseUrl;
  final http.Client client;
  String? _authToken;

  ApiClient({
    required this.baseUrl,
    http.Client? client,
  }) : client = client ?? http.Client();

  void setAuthToken(String token) {
    _authToken = token;
  }

  Map<String, String> _buildHeaders([Map<String, String>? customHeaders]) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    if (customHeaders != null) {
      headers.addAll(customHeaders);
    }
    return headers;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client.get(uri, headers: _buildHeaders(headers)).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw const NetworkFailure();
    }
  }

  Future<dynamic> post(String endpoint, {dynamic body, Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client
          .post(uri, headers: _buildHeaders(headers), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw const NetworkFailure();
    }
  }

  Future<dynamic> delete(String endpoint, {Map<String, String>? headers}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await client.delete(uri, headers: _buildHeaders(headers)).timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw const NetworkFailure();
    }
  }

  dynamic _processResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      case 401:
        throw const AuthFailure('Session expired or unauthorized');
      case 404:
        throw const ServerFailure('Requested resource not found', statusCode: 404);
      case 500:
      default:
        throw ServerFailure('Server returned status code ${response.statusCode}', statusCode: response.statusCode);
    }
  }
}
