import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:flutter/material.dart';

/// 超过此时间触发重载，单位毫秒
const _kRefreshThreshold = 115 * 60 * 1000; // 1h55m

/// b站的 playUrl 有效时间为 2h，该处理器负责在届时发出重载通知
class BiliRefreshHandler {
  final ExtraVideoController controller;
  final VoidCallback onRefresh;

  int startTime;
  final List<StreamSubscription> _subscriptions = [];

  BiliRefreshHandler({required this.controller, required this.onRefresh}) : startTime = DateTime.now().millisecondsSinceEpoch {
    _subscriptions.addAll([
      controller.stream.position.listen(_onPosition),
    ]);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void _onPosition(Duration event) {
    final ts = DateTime.now().millisecondsSinceEpoch;

    if (ts > startTime + _kRefreshThreshold) {
      startTime = ts;
      onRefresh();
    }
  }
}
