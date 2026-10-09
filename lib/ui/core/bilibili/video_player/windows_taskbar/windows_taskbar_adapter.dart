import 'dart:async';

import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist_controller.dart';
import 'package:windows_taskbar/windows_taskbar.dart';

import 'package:flutter/material.dart';

class WindowsTaskbarAdapter extends StatefulWidget {
  final ExtraVideoController controller;
  final PlaylistController? playlistController;

  const WindowsTaskbarAdapter({super.key, required this.controller, this.playlistController});

  @override
  State<WindowsTaskbarAdapter> createState() => _WindowsTaskbarAdapterState();
}

class _WindowsTaskbarAdapterState extends State<WindowsTaskbarAdapter> {
  ExtraVideoController get controller => widget.controller;
  PlaylistController? get playlistController => widget.playlistController;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _subscriptions.addAll([
      controller.stream.playing.listen(_onPlaying),
      controller.stream.duration.listen((_) => _updateInfo()),
      controller.stream.position.listen((_) => _updateInfo()),
      controller.stream.buffering.listen((_) => _updateBoth()),
      controller.stream.completed.listen(_onCompleted),
    ]);

    playlistController?.addListener(_updateButtons);
  }

  @override
  void didUpdateWidget(covariant WindowsTaskbarAdapter oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playlistController != playlistController) {
      oldWidget.playlistController?.removeListener(_updateButtons);
      playlistController?.addListener(_updateButtons);
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    playlistController?.removeListener(_updateButtons);

    WindowsTaskbar.resetThumbnailToolbar();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateBoth();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }

  void _updateButtons() {
    final brightness = Theme.brightnessOf(context);

    // 一旦确定 toolbar 列表的长度就不可以改变了，一旦长度变化就会导致 explorer 崩溃
    WindowsTaskbar.setThumbnailToolbar([
      ThumbnailToolbarButton(
        ThumbnailToolbarAssetIcon('assets/images/taskbar_previous_icon_${brightness == .dark ? 'dark' : 'light'}.ico'),
        '上一个',
        () => playlistController?.previous(),
        mode: playlistController != null && playlistController!.hasPrevious ? 0x0 : ThumbnailToolbarButtonMode.disabled,
      ),
      if (controller.state.playing)
        ThumbnailToolbarButton(
          ThumbnailToolbarAssetIcon('assets/images/taskbar_pause_icon_${brightness == .dark ? 'dark' : 'light'}.ico'),
          '暂停',
          controller.pause,
        )
      else
        ThumbnailToolbarButton(
          ThumbnailToolbarAssetIcon('assets/images/taskbar_play_icon_${brightness == .dark ? 'dark' : 'light'}.ico'),
          '播放',
          controller.play,
        ),
      ThumbnailToolbarButton(
        ThumbnailToolbarAssetIcon('assets/images/taskbar_next_icon_${brightness == .dark ? 'dark' : 'light'}.ico'),
        '下一个',
        () => playlistController?.next(),
        mode: playlistController != null && playlistController!.hasNext ? 0x0 : ThumbnailToolbarButtonMode.disabled,
      ),
    ]);
  }

  void _updateInfo() {
    if (controller.state.buffering) {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.indeterminate);
    } else if (controller.state.playing) {
      final progress = controller.state.duration == .zero
          ? 0
          : (controller.state.position.inMilliseconds / controller.state.duration.inMilliseconds * 100).clamp(0, 100).toInt();
      WindowsTaskbar.setProgress(progress, 100);
    }
  }

  void _updateBoth() {
    _updateButtons();
    _updateInfo();
  }

  void _onPlaying(bool playing) {
    if (controller.state.playing) {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.normal);
    } else {
      WindowsTaskbar.setProgressMode(TaskbarProgressMode.paused);
    }

    _updateButtons();
  }

  void _onCompleted(bool event) {
    if (!event) return;

    WindowsTaskbar.resetThumbnailToolbar();
    WindowsTaskbar.setProgressMode(TaskbarProgressMode.noProgress);
  }
}
