// 当有 url 加载失败时自动重试
import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';

/// 当有 url 加载失败时通知其他控制器重试
class ErrorHandler {
  final ExtraVideoController controller;

  final List<StreamSubscription> _subscriptions = [];

  ErrorHandler({required this.controller}) {
    _subscriptions.addAll([
      controller.stream.error.listen(_onError),
    ]);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void _onError(String event) {
    // 先尝试找出加载失败的是视频还是音频，找到就只滚动对应的 url
    // 否则视频和音频一起滚动
  }
}
