import 'package:dio/dio.dart';
import '../constants/app_constants.dart';
import '../utils/logger.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio _dio;

  Dio get dio => _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        responseType: ResponseType.json,
        contentType: 'application/json',
      ),
    );

    // Add interceptors
    if (AppConstants.isDebug) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => AppLogger.debug(object.toString()),
        ),
      );
    }

    // Add auth interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add API key to headers
          if (AppConstants.dalleApiKey.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer ${AppConstants.dalleApiKey}';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          AppLogger.error(
            'API Error: ${error.message}',
            error.error,
            error.stackTrace,
          );
          handler.next(error);
        },
      ),
    );

    // Add retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: AppConstants.maxRetryAttempts,
        retryDelays: List.generate(
          AppConstants.maxRetryAttempts,
          (index) => AppConstants.retryDelay * (index + 1),
        ),
      ),
    );
  }
}

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int retries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    required this.retries,
    required this.retryDelays,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final retryAttempt = extra['retry_attempt'] as int? ?? 0;

    if (retryAttempt < retries && _shouldRetry(err)) {
      AppLogger.warning('Retrying request (attempt ${retryAttempt + 1}/$retries)');
      
      final delay = retryDelays.length > retryAttempt 
          ? retryDelays[retryAttempt] 
          : retryDelays.last;
      
      await Future.delayed(delay);

      err.requestOptions.extra['retry_attempt'] = retryAttempt + 1;

      try {
        final response = await dio.request(
          err.requestOptions.path,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
        );
        return handler.resolve(response);
      } catch (e) {
        return handler.next(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && 
         err.response!.statusCode! >= 500);
  }
}