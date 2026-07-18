import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../constants/app_constants.dart';
import '../models/currency.dart';

/// Global, mutable references updated by the app so Dio can read them
/// without a BuildContext. Locale/currency providers set these on init/change.
class DioContext {
  static Locale locale = const Locale(AppConstants.defaultLanguage);
  static Currency? currency;
}

class DioClient {
  static Dio? _dio;
  static final Logger _logger = Logger();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
  }

  static void reset() {
    _dio = null;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: true,
        responseBody: true,
        error: true,
        logPrint: (object) => _logger.d(object.toString()),
      ),
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Dynamic language header based on current app locale.
          options.headers['Accept-Language'] = DioContext.locale.languageCode;
          if (DioContext.currency != null) {
            options.headers['X-Selected-Currency'] = DioContext.currency!.code;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          _logger.e('DioError: ${e.message}');
          return handler.next(e);
        },
      ),
    ]);

    return dio;
  }

  static bool isExpiredStoreError(dynamic e) {
    if (e is! DioException) return false;
    if (e.response?.statusCode != 403) return false;
    final data = e.response?.data;
    return data is Map && data['isExpired'] == true;
  }
}
