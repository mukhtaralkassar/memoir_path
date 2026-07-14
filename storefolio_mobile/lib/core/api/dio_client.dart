import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

class DioClient {
  static Dio? _dio;
  static final Logger _logger = Logger();

  static Dio get instance {
    _dio ??= _createDio();
    return _dio!;
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
          // Add language header
          options.headers['Accept-Language'] = 'ar'; // TODO: Get from locale provider
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
