import 'dart:async';

import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';

/// 由于 better 将 appbar 置于 router 之外，
/// 所以在播放器推入全屏路由时仍会显示标题栏，此模块负责正确处理标题栏行为
class TitlebarHandler {
  final ExtraVideoController controller;
  final AppController appController;

  final List<StreamSubscription> _subscriptions = [];

  TitlebarHandler({required this.controller, required this.appController}) {
    _subscriptions.addAll([
      controller.stream.fullscreen.listen(onToggleFullscreen),
      controller.stream.windowFullscreen.listen(onToggleWindowFullscreen),
    ]);
  }

  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }

  void onToggleWindowFullscreen(bool event) {
    if (event) {
      appController.setTitleBarVisible(false);
    } else if (!controller.state.fullscreen) {
      appController.setTitleBarVisible(true);
    }
  }

  void onToggleFullscreen(bool event) {
    if (event) {
      appController.setTitleBarVisible(false);
    } else if (!controller.state.windowFullscreen) {
      appController.setTitleBarVisible(true);
    }
  }
}
