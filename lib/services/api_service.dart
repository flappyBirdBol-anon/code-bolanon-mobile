import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/transaction_model.dart';

class ApiService {
  static ApiService? _instance;
  final String baseUrl = 'http://codebolanon.commesr.io/api';
  late Dio _dio;
  Dio get dio => _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Simulated transactions database
  final List<Map<String, dynamic>> _transactions = [];

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

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
      );
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

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      final response = await _dio.delete(path, data: data);
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

  Future<Response> uploadLessonFile(
    String path, {
    required Map<String, dynamic> fields,
    required Map<String, PlatformFile> files,
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

        // Check if the file has bytes or a path
        if (entry.value.bytes != null) {
          // Use bytes if available
          formData.files.add(MapEntry(
            entry.key,
            MultipartFile.fromBytes(
              entry.value.bytes!,
              filename: fileName,
              contentType: _getContentType(fileName),
            ),
          ));
        } else if (entry.value.path != null) {
          // Use path as fallback
          formData.files.add(MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              entry.value.path!,
              filename: fileName,
              contentType: _getContentType(fileName),
            ),
          ));
        }
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

  // PAYMENT RELATED METHODS

  // Create payment intent
  Future<Map<String, dynamic>> createPaymentIntent({
    required int amount,
    required String currency,
    required String courseId,
    String? paymentMethodId,
  }) async {
    try {
      final response = await post('/create-payment-intent', data: {
        'amount': amount,
        'currency': currency,
        'course_id': courseId,
        if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
      });

      if (response.statusCode == 200) {
        return response.data;
      }

      return {
        'success': false,
        'error': response.data['error'] ?? 'Failed to create payment intent',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to create payment intent: $e',
      };
    }
  }

  // Save transaction to the database
  Future<Map<String, dynamic>> saveTransaction(Transaction transaction) async {
    try {
      final response = await post('/save-transaction', data: {
        'id': transaction.id,
        'amount': (transaction.amount * 100).toInt(), // Convert to cents
        'currency': 'usd', // Hardcoded for now, could be made dynamic
        'status': transaction.status,
        'payment_method': transaction.paymentMethod,
        'course_id': transaction.courseId,
        'user_id':
            transaction.userId, // This will come from auth()->id() on backend
        'created_at': transaction.timestamp.toIso8601String(),
      });

      if (response.statusCode == 200) {
        return {
          'success': true,
          'transaction': response.data['transaction'],
        };
      }

      return {
        'success': false,
        'error': response.data['error'] ?? 'Failed to save transaction',
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'Failed to save transaction: $e',
      };
    }
  }

  // Get all transactions
  Future<List<Transaction>> getTransactions() async {
    try {
      final response = await get('/transactions');

      if (response.statusCode == 200) {
        return (response.data as List)
            .map((json) => Transaction.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching transactions: $e');
      return [];
    }
  }

  // Get transaction by ID
  Future<Transaction?> getTransactionById(String id) async {
    try {
      final response = await get('/transactions/$id');

      if (response.statusCode == 200) {
        return Transaction.fromJson(response.data);
      }

      return null;
    } catch (e) {
      print('Error fetching transaction: $e');
      return null;
    }
  }

  // Helper method to generate random string
  String _generateRandomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return String.fromCharCodes(List.generate(
        length, (index) => chars.codeUnitAt(random.nextInt(chars.length))));
  }
}
