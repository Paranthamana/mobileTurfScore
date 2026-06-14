import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:turfscore/core/utils/util_method.dart';

import '../storage/session_manager.dart';

class ApiInterface {
  late final Dio _dio;
  final SessionManager sessionManager;

  ApiInterface({required this.sessionManager}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://192.168.0.109:5000',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = sessionManager.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );

    // Add interceptor for logging in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          request: true,
          requestHeader: true,
          requestBody: true,
          responseHeader: true,
          responseBody: true,
          error: true,
        ),
      );
    }
  }

  /// Common GET request method
  Future<Response?> get({
    required String endpoint,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      UtilMethod.debugLog('Unexpected error occurred: $e');
      rethrow;
    }
  }

  /// Common POST request method
  Future<Response?> post({
    required String endpoint,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      UtilMethod.debugLog('Unexpected error occurred: $e');
      rethrow;
    }
  }

  /// Handle DioException cases
  void _handleError(DioException error) {
    String errorDescription = "";
    switch (error.type) {
      case DioExceptionType.cancel:
        errorDescription = "Request to API server was cancelled";
        break;
      case DioExceptionType.connectionTimeout:
        errorDescription = "Connection timeout with API server";
        break;
      case DioExceptionType.connectionError:
        errorDescription =
            "Connection to API server failed due to internet connection";
        break;
      case DioExceptionType.receiveTimeout:
        errorDescription = "Receive timeout in connection with API server";
        break;
      case DioExceptionType.badResponse:
        errorDescription =
            "Received invalid status code: ${error.response?.statusCode}. Message: ${error.response?.data}";
        break;
      case DioExceptionType.sendTimeout:
        errorDescription = "Send timeout in connection with API server";
        break;
      case DioExceptionType.badCertificate:
        errorDescription = "Bad certificate from API server";
        break;
      case DioExceptionType.unknown:
        errorDescription = "Unexpected error occurred";
        break;
    }
    UtilMethod.debugLog("API Error: $errorDescription");
  }
}
