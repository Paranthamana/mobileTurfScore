import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio(BaseOptions(
    baseUrl: 'https://api.turfscore.example.com',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token here
        if (kDebugMode) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        if (kDebugMode) {
          print('ERROR[${e.response?.statusCode}] => PATH: ${e.requestOptions.path}');
        }
        return handler.next(e);
      },
    ));
  }

  Future<Response> get(String url, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(url, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.post(url, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> put(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.put(url, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> delete(String url, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.delete(url, data: data, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
