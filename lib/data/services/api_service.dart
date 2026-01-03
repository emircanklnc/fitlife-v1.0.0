import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
import 'token_service.dart';

class ApiService {
  static const String baseUrl = AppConstants.backendBaseUrl;

  static Future<Map<String, dynamic>> get(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('API GET Request: $uri');
      
      final headers = await _getHeaders(requiresAuth);

      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('API GET Timeout: $uri');
          throw Exception('Sunucuya bağlanılamadı. İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
        },
      );

      debugPrint('API GET Response Status: ${response.statusCode}');
      debugPrint('API GET Response Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('API GET Network Error: $e');
      debugPrint('API GET Network Error Details: ${e.toString()}');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on SocketException catch (e) {
      debugPrint('API GET Socket Error: $e');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on TlsException catch (e) {
      debugPrint('API GET SSL/TLS Error: $e');
      throw Exception('SSL bağlantı hatası. Lütfen daha sonra tekrar deneyin.');
    } on Exception catch (e) {
      debugPrint('API GET Error: $e');
      debugPrint('API GET Error Type: ${e.runtimeType}');
      rethrow;
    } catch (e) {
      debugPrint('API GET Unknown Error: $e');
      debugPrint('API GET Unknown Error Type: ${e.runtimeType}');
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('API POST Request: $uri');
      debugPrint('API POST Body: ${jsonEncode(body)}');
      
      final headers = await _getHeaders(requiresAuth);

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('API POST Timeout: $uri');
          throw Exception('Sunucuya bağlanılamadı. İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
        },
      );

      debugPrint('API POST Response Status: ${response.statusCode}');
      debugPrint('API POST Response Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('API POST Network Error: $e');
      debugPrint('API POST Network Error Details: ${e.toString()}');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on SocketException catch (e) {
      debugPrint('API POST Socket Error: $e');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on TlsException catch (e) {
      debugPrint('API POST SSL/TLS Error: $e');
      throw Exception('SSL bağlantı hatası. Lütfen daha sonra tekrar deneyin.');
    } on Exception catch (e) {
      debugPrint('API POST Error: $e');
      debugPrint('API POST Error Type: ${e.runtimeType}');
      rethrow;
    } catch (e) {
      debugPrint('API POST Unknown Error: $e');
      debugPrint('API POST Unknown Error Type: ${e.runtimeType}');
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      debugPrint('API PUT Request: $uri');
      debugPrint('API PUT Body: ${jsonEncode(body)}');
      
      final headers = await _getHeaders(requiresAuth);

      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('API PUT Timeout: $uri');
          throw Exception('Sunucuya bağlanılamadı. İstek zaman aşımına uğradı. Lütfen internet bağlantınızı kontrol edin.');
        },
      );

      debugPrint('API PUT Response Status: ${response.statusCode}');
      debugPrint('API PUT Response Body: ${response.body}');

      return _handleResponse(response);
    } on http.ClientException catch (e) {
      debugPrint('API PUT Network Error: $e');
      debugPrint('API PUT Network Error Details: ${e.toString()}');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on SocketException catch (e) {
      debugPrint('API PUT Socket Error: $e');
      throw Exception('Sunucuya bağlanılamadı. İnternet bağlantınızı kontrol edin.');
    } on TlsException catch (e) {
      debugPrint('API PUT SSL/TLS Error: $e');
      throw Exception('SSL bağlantı hatası. Lütfen daha sonra tekrar deneyin.');
    } on Exception catch (e) {
      debugPrint('API PUT Error: $e');
      debugPrint('API PUT Error Type: ${e.runtimeType}');
      rethrow;
    } catch (e) {
      debugPrint('API PUT Unknown Error: $e');
      debugPrint('API PUT Unknown Error Type: ${e.runtimeType}');
      throw Exception('Beklenmeyen bir hata oluştu: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final headers = await _getHeaders(requiresAuth);

      final response = await http.delete(uri, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('API Error: $e');
    }
  }

  static Future<Map<String, String>> _getHeaders(bool requiresAuth) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (requiresAuth) {
      final token = await TokenService.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        debugPrint('API Request: Token gönderiliyor (${token.substring(0, 10)}...)');
      } else {
        debugPrint('API Error: Token not found');
        throw Exception('Invalid or expired token');
      }
    }

    return headers;
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    
    try {
      dynamic decodedBody;
      try {
        decodedBody = jsonDecode(response.body);
      } catch (e) {
        debugPrint('JSON Parse Error: ${response.body}');
        throw Exception('Sunucudan geçersiz yanıt alındı. Status: $statusCode');
      }

      if (decodedBody is! Map<String, dynamic>) {
        debugPrint('Response is not a Map: $decodedBody');
        throw Exception('Sunucudan beklenmeyen yanıt formatı alındı');
      }

      final body = decodedBody as Map<String, dynamic>;

      if (statusCode >= 200 && statusCode < 300) {
        return body;
      } else {
        final errorMessage = body['error'] ?? 'API Error: $statusCode';
        debugPrint('API Error Response: $errorMessage (Status: $statusCode)');

        if (statusCode == 401 || 
            (errorMessage.toString().toLowerCase().contains('token') && 
             (errorMessage.toString().toLowerCase().contains('invalid') || 
              errorMessage.toString().toLowerCase().contains('expired')))) {
          debugPrint('Token hatası tespit edildi, token temizleniyor');
          TokenService.deleteToken().catchError((e) {
            debugPrint('Token silme hatası: $e');
          });
        }
        
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      debugPrint('Response handling error: $e');
      throw Exception('Yanıt işleme hatası: $e');
    }
  }
}

