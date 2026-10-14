import 'package:dio/dio.dart';

class BaseUrlFallbackInterceptor extends Interceptor {
  final Dio dio;
  final List<String> baseUrls;

  BaseUrlFallbackInterceptor({
    required this.dio,
    required List<String> baseUrls,
  }) : assert(baseUrls.isNotEmpty),
       baseUrls = List.unmodifiable(baseUrls);

  static const _indexKey = '_base_url_fallback_index';

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.uri.hasScheme) {
      return handler.next(options);
    }

    final index = options.extra[_indexKey] as int? ?? 0;
    handler.next(options.copyWith(baseUrl: baseUrls[index]));
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final currentIndex = options.extra[_indexKey] as int?;

    if (currentIndex == null) {
      return handler.next(err);
    }
    final nextIndex = currentIndex + 1;

    if (nextIndex >= baseUrls.length || err.type == .cancel) {
      return handler.next(err);
    }

    final retryOptions = options.copyWith(
      baseUrl: baseUrls[nextIndex],
      extra: {
        ...options.extra,
        _indexKey: nextIndex,
      },
    );

    try {
      final response = await dio.fetch<dynamic>(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }
}
