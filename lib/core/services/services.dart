import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

enum ServiceError {
  unknownError,
  unknownResponseError,
  clientError,
  serverError,
  timeoutError,
  socketError,
}

abstract class Services {}

class HttpServices extends Services {
  late final Dio _dio;

  HttpServices({Dio? dio}) {
    _dio = dio ?? Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
        },
      ),
    );

    // Common Interceptors for Logging and Global Lifecycle Handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: Uncomment and adapt to dynamically inject your Bearer Auth Token
          /*
          final token = await getIt<AuthLocalStorageService>().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          */

          debugPrint('--> ${options.method} ${options.uri}');
          debugPrint('Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('Body: ${options.data}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
          if (response.data != null) {
            debugPrint('Response: ${response.data}');
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          debugPrint('<-- ERROR: ${e.message} for ${e.requestOptions.uri}');
          if (e.response != null) {
            debugPrint('Error Status: ${e.response?.statusCode}');
            debugPrint('Error Data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  // Map DioExceptions to our standard ServiceError
  dynamic _handleError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ServiceError.timeoutError;
      case DioExceptionType.connectionError:
        return ServiceError.socketError;
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 400 || statusCode == 404) {
          return ServiceError.clientError;
        } else if (statusCode == 500) {
          return ServiceError.serverError;
        }
        return ServiceError.unknownResponseError;
      default:
        // Handle SocketException wrapped inside other error types
        if (e.error != null && e.error.toString().contains('SocketException')) {
          return ServiceError.socketError;
        }
        return ServiceError.unknownError;
    }
  }

  Future postMethod(
    String url,
    dynamic body, {
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }

  Future putMethod(
    String url,
    dynamic body, {
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: body,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }

  Future deleteMethod(
    String url, {
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }

  Future getMethod(
    String url, {
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.get(
        url,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }

  /// Downloads a file from the server with progress tracking.
  Future downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }

  /// Uploads a file using multipart form-data with progress tracking.
  Future uploadFile(
    String url,
    String filePath, {
    String fileKey = 'file',
    Map<String, dynamic>? additionalFields,
    ProgressCallback? onSendProgress,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        fileKey: await MultipartFile.fromFile(filePath, filename: fileName),
        if (additionalFields != null) ...additionalFields,
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } on DioException catch (e) {
      return _handleError(e);
    } catch (_) {
      return ServiceError.unknownError;
    }
  }
}


