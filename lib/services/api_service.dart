// api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static ApiService? _instance;
  final String baseUrl = 'http://143.198.197.240/api';
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Private constructor
  ApiService._() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      responseType: ResponseType.json,
      contentType: 'application/json',
      validateStatus: (status) {
        return status! < 500; // Accept all status codes less than 500
      },
      headers: {
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'auth_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        print('Request: ${options.method} ${options.path}');
        print('Headers: ${options.headers}');
        print('Data: ${options.data}');
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('Response: ${response.statusCode}');
        print('Response Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('Error: ${error.message}');
        print('Error Response: ${error.response?.data}');
        return handler.next(error);
      },
    ));
  }

  // Factory constructor
  factory ApiService() {
    _instance ??= ApiService._();
    return _instance!;
  }

  Future<Response> get(String path) async {
    try {
      final response = await _dio.get(path);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data}) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null) {
      print('Status Code: ${e.response?.statusCode}');
      print('Error Response: ${e.response?.data}');

      // Handle specific status codes
      switch (e.response?.statusCode) {
        case 401:
          return Exception('Unauthorized: Please login again');
        case 422:
          final errors = e.response?.data['errors'];
          return Exception(
              'Validation error: ${errors ?? e.response?.data['message']}');
        case 404:
          return Exception('Resource not found');
        default:
          return Exception(
              'Server error: ${e.response?.data['message'] ?? e.message}');
      }
    }

    // Handle network errors
    if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection');
    }

    return Exception('An unexpected error occurred: ${e.message}');
  }

  Future<void> setAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  Future<void> clearAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }
}
