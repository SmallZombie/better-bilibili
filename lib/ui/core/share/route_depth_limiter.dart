import 'dart:async';

import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

/// 路由深度限制器，当所在页面路由深度到达阈值时，销毁内部的组件，直到页面重新可见
class RouteDepthLimiter extends StatefulWidget {
  final int maxDepth;
  final Widget child;

  const RouteDepthLimiter({super.key, this.maxDepth = 2, required this.child});

  @override
  State<RouteDepthLimiter> createState() => _RouteDepthLimiterState();
}

class _RouteDepthLimiterState extends State<RouteDepthLimiter> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'RouteDepthLimiter'));

  late final StreamSubscription subscription;

  @override
  void initState() {
    super.initState();

    subscription = appRouteObserver.events.listen(_onRouteChanged);
  }

  @override
  void dispose() {
    subscription.cancel();

    super.dispose();
  }

  bool _disposed = false;
  int _depth = 0;

  void _onRouteChanged(AppRouteEvent event) {
    if (event is AppRoutePushEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth++;

      if (_depth >= widget.maxDepth && !_disposed) {
        _log.i('dispose $hashCode');
        setState(() => _disposed = true);
      }
    } else if (event is AppRoutePopEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth--;

      if (_depth == 0 && _disposed) {
        _log.i('restore $hashCode');
        setState(() => _disposed = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_disposed) return SizedBox.shrink();

    return widget.child;
  }
}
