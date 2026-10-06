import 'package:dio/dio.dart';

class FallbackBaseUrlInterceptor extends Interceptor {
  FallbackBaseUrlInterceptor({
    required this.dio,
    required List<String> baseUrls,
  }) : baseUrls = List.unmodifiable(
         baseUrls.where((e) => e.trim().isNotEmpty),
       );

  final Dio dio;
  final List<String> baseUrls;

  static const _retryKey = '_fallback_base_url_retry';

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;

    if (options.extra[_retryKey] == true) {
      handler.next(err);
      return;
    }

    if (baseUrls.isEmpty) {
      handler.next(err);
      return;
    }

    final currentBaseUrl = options.baseUrl;

    final currentIndex = baseUrls.indexOf(currentBaseUrl);
    final startIndex = currentIndex + 1;

    DioException lastError = err;

    for (var i = startIndex; i < baseUrls.length; i++) {
      final baseUrl = baseUrls[i];

      final retryOptions = options.copyWith(
        baseUrl: baseUrl,
        extra: {
          ...options.extra,
          _retryKey: true,
        },
      );

      try {
        final response = await dio.fetch<dynamic>(retryOptions);

        handler.resolve(response);
        return;
      } on DioException catch (e) {
        lastError = e;
      }
    }

    handler.next(lastError);
  }
}
