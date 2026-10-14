import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/preview/timeline_preview_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/timeline.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/timeline_waveform_controller.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class ExtraVideoPlayer extends StatefulWidget {
  final ExtraVideoController controller;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final VideoRepository videoRepository;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final List<ExtraVideoPlayerLayer> layers;
  final List<Widget> topItems;
  final List<Widget> bottomItems;
  final Widget? background;
  final TimelinePreviewController previewController;
  final TimelineWaveformController waveformController;
  final TimelineSegmentController segmentController;
  final ValueChanged<Duration>? onSeekStart;
  final ValueChanged<Duration>? onSeekEnd;
  final VoidCallback? onFrontend;
  final VoidCallback? onBackend;
  final PanelController panelController;
  final PlaylistController? playlistController;

  const ExtraVideoPlayer({
    super.key,
    required this.controller,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.videoRepository,
    required this.aspectRatio,
    this.borderRadius,
    this.layers = const [],
    this.topItems = const [],
    this.bottomItems = const [],
    this.background,
    required this.previewController,
    required this.waveformController,
    required this.segmentController,
    this.onSeekStart,
    this.onSeekEnd,
    this.onFrontend,
    this.onBackend,
    required this.panelController,
    this.playlistController,
  });

  @override
  State<ExtraVideoPlayer> createState() => _ExtraVideoPlayerState();
}

class _ExtraVideoPlayerState extends State<ExtraVideoPlayer> {
  ExtraVideoController get controller => widget.controller;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _subscriptions.addAll([
      appRouteObserver.events.listen(_onRouteChanged),
      controller.stream.fullscreen.listen(_onFullscreen),
      controller.stream.windowFullscreen.listen(_onWindowFullscreen),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  int _depth = 0;

  void _onRouteChanged(AppRouteEvent event) {
    if (event is AppRoutePushEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth++;

      if (_depth == 1) {
        controller.pause();
        widget.onBackend?.call();
      }
    } else if (event is AppRoutePopEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth--;

      if (_depth == 0) {
        widget.onFrontend?.call();
      }
    }

    /// dispose 会慢半拍, 正好这里 pop 不会慢半拍
    /// 在这里解决离开页面时仍然会播放一点点的问题
    if (_depth == -1) {
      controller.pause();
    }
  }

  void _pushToNewRoute({bool forWindowFullscreen = false}) {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: .zero,
        reverseTransitionDuration: .zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return StreamBuilder(
            stream: controller.stream.fullscreen,
            builder: (context, asyncSnapshot) {
              final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
              if (forWindowFullscreen && isFullscreen) {
                return const Placeholder();
              }

              return _buildVideoSurface();
            },
          );
        },
      ),
    );
  }

  void _onWindowFullscreen(bool event) {
    // 全屏时不能窗口全屏，但窗口全屏时可以全屏
    assert(!controller.state.fullscreen);

    if (event) {
      _pushToNewRoute(forWindowFullscreen: true);
    } else {
      context.pop();
    }
  }

  void _onFullscreen(bool event) {
    if (event) {
      _pushToNewRoute();
    } else {
      context.pop();
    }

    windowManager.setFullScreen(event);
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: StreamBuilder(
        stream: controller.stream.fullscreen,
        initialData: controller.state.fullscreen,
        builder: (context, asyncSnapshot) {
          final isFullscreen = asyncSnapshot.data!;
          return StreamBuilder(
            stream: controller.stream.windowFullscreen,
            initialData: controller.state.windowFullscreen,
            builder: (context, asyncSnapshot) {
              final isWindowFullscreen = asyncSnapshot.data!;
              if (isFullscreen || isWindowFullscreen) {
                return const Placeholder();
              }

              return _buildVideoSurface(widget.borderRadius ?? .zero);
            },
          );
        },
      ),
    );
  }

  Widget _buildVideoSurface([BorderRadiusGeometry? borderRadius]) {
    Widget video = Video(
      controller: controller,
      controls: (_) => _PlayerOverlay(
        controller: controller,
        layers: widget.layers,
        playerConfig: widget.playerConfig,
        danmakuConfig: widget.danmakuConfig,
        onEnterFullscreen: controller.enterFullscreen,
        onExitFullscreen: controller.exitFullscreen,
        videoRepository: widget.videoRepository,
        topItems: widget.topItems,
        bottomItems: widget.bottomItems,
        previewController: widget.previewController,
        waveformController: widget.waveformController,
        segmentController: widget.segmentController,
        onSeekStart: widget.onSeekStart,
        onSeekEnd: widget.onSeekEnd,
        panelController: widget.panelController,
        playlistController: widget.playlistController,
      ),
      subtitleViewConfiguration: const SubtitleViewConfiguration(
        style: TextStyle(
          height: 1.4,
          fontSize: 24.0,
          letterSpacing: 0.0,
          wordSpacing: 0.0,
          color: Color(0xffffffff),
          fontWeight: FontWeight.normal,
          backgroundColor: Color(0xaa000000),
        ),
        textAlign: TextAlign.center,
        padding: EdgeInsets.all(24.0),
      ),
    );

    if (borderRadius != null) {
      video = ClipRRect(
        borderRadius: widget.borderRadius ?? .zero,
        child: video,
      );
    }

    return RepaintBoundary(
      child: widget.background == null
          ? video
          : Stack(
              fit: .expand,
              children: [widget.background!, video],
            ),
    );
  }
}

class _PlayerOverlay extends StatefulWidget {
  final ExtraVideoController controller;
  final List<ExtraVideoPlayerLayer> layers;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final VoidCallback onEnterFullscreen;
  final VoidCallback onExitFullscreen;
  final VideoRepository videoRepository;
  final List<Widget> topItems;
  final List<Widget> bottomItems;
  final TimelinePreviewController previewController;
  final TimelineWaveformController waveformController;
  final TimelineSegmentController segmentController;
  final ValueChanged<Duration>? onSeekStart;
  final ValueChanged<Duration>? onSeekEnd;
  final PanelController panelController;
  final PlaylistController? playlistController;

  const _PlayerOverlay({
    required this.controller,
    this.layers = const [],
    required this.playerConfig,
    required this.danmakuConfig,
    required this.onEnterFullscreen,
    required this.onExitFullscreen,
    required this.videoRepository,
    this.topItems = const [],
    this.bottomItems = const [],
    required this.previewController,
    required this.waveformController,
    required this.segmentController,
    this.onSeekStart,
    this.onSeekEnd,
    required this.panelController,
    this.playlistController,
  });

  @override
  State<_PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<_PlayerOverlay> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'PlayerOverlay'));

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  ExtraVideoController get controller => widget.controller;
  PlayerConfig get playerConfig => widget.playerConfig;
  DanmakuConfig get danmakuConfig => widget.danmakuConfig;

  final Duration controlsTransitionDuration = const Duration(milliseconds: 200);
  final Duration controlsHoverDuration = const Duration(seconds: 5);
  final double buttonBarHeight = 42;
  final EdgeInsets topBarMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final EdgeInsets bottomBarMargin = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  final double seekBarContainerHeight = 28.0;

  bool visible = false;
  Timer? visibleTimer;

  @override
  void dispose() {
    visibleTimer?.cancel();
    _longPressSpeedUpTimer?.cancel();
    _focusScopeNode.dispose();

    super.dispose();
  }

  void _onMouseEnter() {
    setState(() => visible = true);
    visibleTimer = Timer(controlsHoverDuration, () {
      if (mounted) {
        setState(() => visible = false);
      }
    });
  }

  void _onMouseHover() {
    if (!visible) {
      setState(() => visible = true);
    }

    visibleTimer?.cancel();
    visibleTimer = Timer(controlsHoverDuration, () {
      setState(() => visible = false);
    });
  }

  void _onMouseExit() {
    setState(() => visible = false);
    visibleTimer?.cancel();
  }

  Timer? _longPressSpeedUpTimer;

  double? _restoreRate;
  LogicalKeyboardKey? _currentPressedKey;

  void _onKeyDown(KeyDownEvent event) {
    _log.i('onKeyEvent KeyDownEvent: $event');

    _currentPressedKey = event.logicalKey;

    switch (event.logicalKey) {
      case .escape:
        if (controller.state.fullscreen) {
          controller.exitFullscreen();
          return;
        }
        if (controller.state.windowFullscreen) {
          controller.exitWindowFullscreen();
        }
      case .keyF:
        if (controller.state.fullscreen) {
          controller.exitFullscreen();
        } else {
          controller.enterFullscreen();
        }
      case .keyW:
        if (controller.state.fullscreen) {
          return;
        }
        if (controller.state.windowFullscreen) {
          controller.exitWindowFullscreen();
        } else {
          controller.enterWindowFullscreen();
        }
      case .space:
        controller.playOrPause();
      case .arrowLeft:
        controller.seek(controller.state.position - const Duration(seconds: 5));
      case .arrowRight:
        if (controller.state.rate >= 3.0) {
          return;
        }
        _longPressSpeedUpTimer = Timer(const Duration(milliseconds: 300), () {
          if (_currentPressedKey != .arrowRight) {
            return;
          }
          _restoreRate = controller.state.rate;
          controller.setPlaybackRate(3.0);
        });
      case .arrowUp:
        controller.setVolume(controller.state.volume + 5);
      case .arrowDown:
        controller.setVolume(controller.state.volume - 5);
      case .keyM:
        controller.setMuted(!controller.muted);
    }
  }

  void _onKeyUp(KeyUpEvent event) {
    _log.i('onKeyEvent KeyUpEvent: $event');

    _currentPressedKey = null;
    _longPressSpeedUpTimer?.cancel();

    switch (event.logicalKey) {
      case .arrowRight:
        if (_restoreRate != null) {
          controller.setPlaybackRate(_restoreRate!);
          _restoreRate = null;
        } else {
          controller.seek(controller.state.position + const Duration(seconds: 5));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final foregroundLayers = widget.layers.where((v) => v.inForeground);
    final backgroundLayers = widget.layers.where((v) => !v.inForeground);

    return FocusScope(
      node: _focusScopeNode,
      autofocus: true,
      // Esc: 退出全屏/退出无边框全屏
      // F: 全屏/退出全屏
      // W: 窗口全屏/退出窗口全屏
      // Space: 播放/暂停
      // Left: 后退 5 秒
      // Right: 前进 5 秒
      // 长按 Right: 开始 3 倍速播放，松开停止
      // Up: 提高 5% 音量
      // Down: 降低 5% 音量
      // M: 静音/取消静音
      // [: 上一章节 TODO
      // ]: 下一章节 TODO
      onKeyEvent: (_, event) {
        if (event is KeyDownEvent) {
          _onKeyDown(event);
        } else if (event is KeyUpEvent) {
          _onKeyUp(event);
        }

        return .handled;
      },
      child: Material(
        elevation: 0.0,
        borderOnForeground: false,
        animationDuration: .zero,
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        surfaceTintColor: const Color(0x00000000),
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            _focusScopeNode.requestFocus();

            if (widget.panelController.activePanel != null) return;

            final RenderBox box = context.findRenderObject() as RenderBox;
            final Offset localPosition = box.globalToLocal(details.globalPosition);
            const double seekBarOffset = 5.0;

            final topHeight = buttonBarHeight + topBarMargin.vertical;
            final bottomHeight = box.size.height - bottomBarMargin.vertical - buttonBarHeight - seekBarContainerHeight + seekBarOffset;
            if (!visible || (localPosition.dy > topHeight && localPosition.dy < bottomHeight)) {
              controller.playOrPause();
            }
          },
          child: MouseRegion(
            cursor: !visible ? SystemMouseCursors.none : SystemMouseCursors.basic,
            onEnter: (_) => _onMouseEnter(),
            onHover: (_) => _onMouseHover(),
            onExit: (_) => _onMouseExit(),
            child: Stack(
              children: [
                ...backgroundLayers.map((v) => v.child),
                AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: visible ? 1.0 : 0.0,
                  duration: controlsTransitionDuration,
                  onEnd: () {
                    if (!visible) _onMouseExit();
                  },
                  child: Stack(
                    clipBehavior: .none,
                    alignment: .bottomCenter,
                    children: [
                      // 顶部阴影
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: .topCenter,
                            end: .bottomCenter,
                            stops: [0.0, 0.2],
                            colors: [Color(0x61000000), Color(0x00000000)],
                          ),
                        ),
                      ),

                      // 底部阴影
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: .topCenter,
                            end: .bottomCenter,
                            stops: [0.5, 1.0],
                            colors: [Color(0x00000000), Color(0x61000000)],
                          ),
                        ),
                      ),

                      // 控件
                      Column(
                        mainAxisSize: .min,
                        mainAxisAlignment: .start,
                        crossAxisAlignment: .end,
                        children: [
                          // 顶栏
                          Container(
                            height: buttonBarHeight,
                            margin: topBarMargin,
                            child: Row(
                              spacing: 8.0,
                              children: widget.topItems,
                            ),
                          ),

                          const Spacer(),

                          Timeline(
                            controller: controller,
                            previewController: widget.previewController,
                            waveformController: widget.waveformController,
                            segmentController: widget.segmentController,
                            height: seekBarContainerHeight,
                            onSeekStart: (newPosition) {
                              widget.onSeekStart?.call(newPosition);
                              visibleTimer?.cancel();
                            },
                            onSeekEnd: (newPosition) {
                              widget.onSeekEnd?.call(newPosition);
                              _onMouseEnter();
                            },
                            videoRepository: widget.videoRepository,
                          ),

                          // 底栏
                          Container(
                            height: buttonBarHeight,
                            margin: bottomBarMargin,
                            child: Row(
                              mainAxisSize: .max,
                              mainAxisAlignment: .start,
                              crossAxisAlignment: .center,
                              spacing: 2.0,
                              children: [
                                const MaterialDesktopPlayOrPauseButton(),
                                if (widget.playlistController != null) _PreviousAndNextButton(controller: widget.playlistController!),
                                _VolumeButton(controller: controller),
                                Expanded(child: Row(children: widget.bottomItems)),
                                StreamBuilder(
                                  stream: controller.stream.fullscreen,
                                  builder: (context, asyncSnapshot) {
                                    final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
                                    if (isFullscreen) {
                                      return const SizedBox.shrink();
                                    }

                                    return StreamBuilder(
                                      stream: controller.stream.windowFullscreen,
                                      builder: (context, snapshot) {
                                        final state = snapshot.data ?? controller.state.windowFullscreen;
                                        return ControlIconButton(
                                          onPressed: () {
                                            if (controller.state.windowFullscreen) {
                                              controller.exitWindowFullscreen();
                                            } else {
                                              controller.enterWindowFullscreen();
                                            }
                                          },
                                          icon: state ? Icons.close_fullscreen : Icons.fit_screen_outlined,
                                          tooltip: state ? '退出窗口全屏(W)' : '窗口全屏(W)',
                                        );
                                      },
                                    );
                                  },
                                ),
                                StreamBuilder(
                                  stream: controller.stream.fullscreen,
                                  builder: (context, asyncSnapshot) {
                                    final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
                                    return ControlIconButton(
                                      onPressed: () {
                                        if (isFullscreen) {
                                          widget.onExitFullscreen();
                                        } else {
                                          widget.onEnterFullscreen();
                                        }
                                      },
                                      icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                      tooltip: isFullscreen ? '退出全屏(F)' : '全屏(F)',
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: StreamBuilder(
                      stream: controller.stream.buffering,
                      builder: (context, snapshot) => TweenAnimationBuilder<double>(
                        tween: Tween<double>(
                          begin: 0.0,
                          end: snapshot.data ?? false ? 1.0 : 0.0,
                        ),
                        duration: const Duration(milliseconds: 150),
                        builder: (context, value, child) {
                          // Only mount the buffering indicator if the opacity is greater than 0.0.
                          // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
                          if (value > 0.0) {
                            return Opacity(opacity: value, child: child!);
                          }
                          return const SizedBox.shrink();
                        },
                        child: CircularProgressIndicator(color: colorScheme.primary),
                      ),
                    ),
                  ),
                ),
                ...foregroundLayers.map((v) => v.child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ControlButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const ControlButton({
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        padding: const .symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class ControlIconButton extends StatelessWidget {
  final String? tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const ControlIconButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 24,
      color: Colors.white,
      tooltip: tooltip,
    );
  }
}

class _VolumeButton extends StatefulWidget {
  final ExtraVideoController controller;

  const _VolumeButton({required this.controller});

  @override
  _VolumeButtonState createState() => _VolumeButtonState();
}

class _VolumeButtonState extends State<_VolumeButton> with SingleTickerProviderStateMixin {
  ExtraVideoController get controller => widget.controller;

  late double volume = controller.state.volume;
  StreamSubscription<double>? subscription;
  bool hover = false;

  @override
  void initState() {
    super.initState();

    subscription ??= controller.stream.volume.listen((event) {
      setState(() => volume = event);
    });
  }

  @override
  void dispose() {
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonBarButtonSize = 28.0;
    final buttonBarButtonColor = const Color(0xFFFFFFFF);
    final volumeBarTransitionDuration = const Duration(milliseconds: 150);
    final volumeBarColor = const Color(0x3DFFFFFF);
    final volumeBarActiveColor = const Color(0xFFFFFFFF);
    final volumeBarThumbSize = 12.0;
    final volumeBarThumbColor = const Color(0xFFFFFFFF);
    final sliderWidth = 52.0;
    final gap = 4.0;

    return MouseRegion(
      onEnter: (e) {
        setState(() => hover = true);
      },
      onExit: (e) {
        setState(() => hover = false);
      },
      child: Listener(
        onPointerSignal: (event) {
          if (event is PointerScrollEvent) {
            debugPrint(event.scrollDelta.toString());
            if (event.scrollDelta.dy < 0) {
              controller.setVolume((volume + 5.0).clamp(0.0, 100.0));
            }
            if (event.scrollDelta.dy > 0) {
              controller.setVolume((volume - 5.0).clamp(0.0, 100.0));
            }
          }
        },
        child: AnimatedContainer(
          duration: volumeBarTransitionDuration,
          decoration: BoxDecoration(
            color: hover ? Colors.black26 : const Color(0x00000000),
            borderRadius: .circular(20.0),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  controller.setMuted(!controller.muted);
                },
                iconSize: buttonBarButtonSize * 0.8,
                color: buttonBarButtonColor,
                hoverColor: const Color(0x00000000),
                icon: AnimatedSwitcher(
                  duration: volumeBarTransitionDuration,
                  child: controller.muted
                      ? const Icon(
                          Icons.volume_off,
                          key: ValueKey(Icons.volume_off),
                        )
                      : volume < 50.0
                      ? const Icon(
                          Icons.volume_down,
                          key: ValueKey(Icons.volume_down),
                        )
                      : const Icon(
                          Icons.volume_up,
                          key: ValueKey(Icons.volume_up),
                        ),
                ),
                tooltip: controller.muted ? '取消静音 (M)' : '静音 (M)',
              ),
              AnimatedOpacity(
                opacity: hover ? 1.0 : 0.0,
                duration: volumeBarTransitionDuration,
                child: AnimatedContainer(
                  width: hover ? sliderWidth + gap + 18.0 : 0,
                  duration: volumeBarTransitionDuration,
                  child: SingleChildScrollView(
                    scrollDirection: .horizontal,
                    child: Row(
                      children: [
                        SizedBox(width: gap),
                        SizedBox(
                          width: sliderWidth,
                          child: SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 1.2,
                              inactiveTrackColor: volumeBarColor,
                              activeTrackColor: volumeBarActiveColor,
                              thumbColor: volumeBarThumbColor,
                              thumbShape: RoundSliderThumbShape(
                                enabledThumbRadius: volumeBarThumbSize / 2,
                                elevation: 0.0,
                                pressedElevation: 0.0,
                              ),
                              trackShape: _VolumeTrackShape(),
                              overlayColor: const Color(0x00000000),
                            ),
                            child: Slider(
                              value: volume.clamp(0.0, 100.0),
                              min: 0.0,
                              max: 100.0,
                              onChanged: (value) {
                                controller.setVolume(value);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolumeTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final height = sliderTheme.trackHeight;
    final left = offset.dx;
    final top = offset.dy + (parentBox.size.height - height!) / 2;
    final width = parentBox.size.width;
    return Rect.fromLTWH(
      left,
      top,
      width,
      height,
    );
  }
}

class ExtraVideoPlayerLayer {
  final bool inForeground;
  final Widget child;

  const ExtraVideoPlayerLayer({this.inForeground = true, required this.child});
}

class _PreviousAndNextButton extends StatelessWidget {
  final PlaylistController controller;

  const _PreviousAndNextButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: .min,
          spacing: 4.0,
          children: [
            if (controller.hasPrevious)
              ControlIconButton(
                icon: Icons.skip_previous,
                tooltip: '上一个',
                onPressed: controller.previous,
              ),
            if (controller.hasNext)
              ControlIconButton(
                icon: Icons.skip_next,
                tooltip: '下一个',
                onPressed: controller.next,
              ),
          ],
        );
      },
    );
  }
}
