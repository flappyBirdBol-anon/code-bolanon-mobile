// api_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  final String baseUrl = 'http://143.198.197.240/api';
  late Dio _dio;
  Dio get dio => _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService() {
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

  // Add this to your ApiService class
  Future<Response> uploadFile(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, XFile> files,
    String method = 'POST',
  }) async {
    try {
      // Create form data
      FormData formData = FormData();

      // Add all text fields
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value.toString()));
      });

      // Add all files
      for (var entry in files.entries) {
        String fileName = entry.value.name;
        if (fileName.isEmpty) {
          fileName = entry.value.path.split('/').last;
        }

        formData.files.add(MapEntry(
          entry.key,
          await MultipartFile.fromFile(
            entry.value.path,
            filename: fileName,
            contentType: _getContentType(fileName),
          ),
        ));
      }

      // If method spoofing is needed (for PUT/PATCH/DELETE with file uploads)
      if (method != 'POST' && !fields.containsKey('_method')) {
        formData.fields.add(MapEntry('_method', method));
      }

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          method: 'POST', // Always use POST for multipart
        ),
      );

      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  MediaType? _getContentType(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return MediaType.parse('image/jpeg');
      case 'png':
        return MediaType.parse('image/png');
      case 'gif':
        return MediaType.parse('image/gif');
      case 'webp':
        return MediaType.parse('image/webp');
      default:
        return null;
    }
  }
}
