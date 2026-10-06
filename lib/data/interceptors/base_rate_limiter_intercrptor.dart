import 'package:dio/dio.dart';

/// 基于滑动时间窗口的简易限速器实现
class BaseRateLimiterInterceptor extends Interceptor {
  final int maxRequests;
  final Duration duration;
  final bool dropExcess;

  /// host + path
  /// 例如 https://example.com/api/video?id=123 -> example.com/api/video
  final List<String> whiteList;

  BaseRateLimiterInterceptor({
    this.maxRequests = 10,
    this.duration = const Duration(seconds: 1),
    this.dropExcess = false,
    this.whiteList = const [],
  }) : assert(maxRequests > 0),
       assert(duration > .zero);

  final List<DateTime> _requestTimes = [];

  bool _tryAcquire() {
    final now = DateTime.now();

    _requestTimes.removeWhere(
      (time) => now.difference(time) >= duration,
    );

    if (_requestTimes.length < maxRequests) {
      _requestTimes.add(now);
      return true;
    }

    return false;
  }

  Future<void> _waitForPermission() async {
    while (!_tryAcquire()) {
      final now = DateTime.now();

      final waitUntil = _requestTimes.first.add(duration);
      final waitDuration = waitUntil.difference(now);

      if (waitDuration > .zero) {
        await Future<void>.delayed(waitDuration);
      }
    }
  }

  bool _isWhitelisted(RequestOptions options) {
    final uri = options.uri;

    var target = '${uri.host}${uri.path}';

    // 去掉末尾斜线
    if (target.length > uri.host.length && target.endsWith('/')) {
      target = target.substring(0, target.length - 1);
    }

    return whiteList.any((v) => v == target);
  }

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (_isWhitelisted(options)) {
      handler.next(options);
      return;
    }

    if (dropExcess) {
      if (!_tryAcquire()) {
        handler.reject(
          DioException(
            requestOptions: options,
            type: .unknown,
            message: 'Request rate limit exceeded.',
          ),
        );
        return;
      }
    } else {
      await _waitForPermission();
    }

    handler.next(options);
  }
}
