import 'dart:async';

import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/services/bilibili/bili_video_api_service.dart';
import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/ambient_light_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/quality_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/video_player_panel.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class BiliVideoPlayer extends StatefulWidget {
  final BiliVideoPlayerController controller;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final BiliVideoApiService videoService;
  final Widget? title;
  final double aspectRatio;
  final BorderRadius? borderRadius;
  final List<Widget> layers;
  final ValueChanged<bool>? onToggleWindowFullscreen;
  final ValueChanged<bool>? onToggleFullscreen;

  const BiliVideoPlayer({
    super.key,
    required this.controller,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.videoService,
    this.title,
    required this.aspectRatio,
    this.borderRadius,
    this.layers = const [],
    this.onToggleWindowFullscreen,
    this.onToggleFullscreen,
  });

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  BiliVideoPlayerController get controller => widget.controller;

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    _subscriptions.addAll([
      controller.stream.volume.listen((event) => widget.playerConfig.setVolume(event)),
      appRouteObserver.events.listen(_onRouteChanged),
      controller.stream.windowFullscreen.listen(_onWindowFullscreen),
    ]);
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }

    super.dispose();
  }

  int _depth = 0;

  void _onRouteChanged(AppRouteEvent event) {
    if (event is AppRoutePushEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth++;
      debugPrint('_depth++: $_depth');

      if (_depth > 0) {
        controller.pause();
      }
    } else if (event is AppRoutePopEvent) {
      final name = event.route.settings.name;
      if (name == null) return;

      _depth--;
      debugPrint('_depth--: $_depth');
    }

    /// dispose 会慢半拍, 正好这里 pop 不会慢半拍
    /// 在这里解决离开页面时仍然会播放一点点的问题
    if (_depth == -1) controller.pause();
  }

  Future<void> _enterFullscreen() async {
    controller.emitFullscreen(true);
    // await defaultEnterNativeFullscreen();
    _onFullscreen(true);
  }

  Future<void> _exitFullscreen() async {
    controller.emitFullscreen(false);
    // await defaultExitNativeFullscreen();
    _onFullscreen(false);
  }

  void _putVideoToNewRoute() {
    Navigator.of(context).push(
      PageRouteBuilder(
        fullscreenDialog: true,
        transitionDuration: .zero,
        reverseTransitionDuration: .zero,
        pageBuilder: (context, animation, secondaryAnimation) {
          return Video(
            controller: controller.controller,
            controls: (_) => _PlayerOverlay(
              controller: controller,
              title: widget.title,
              layers: widget.layers,
              playerConfig: widget.playerConfig,
              danmakuConfig: widget.danmakuConfig,
              onEnterFullscreen: _enterFullscreen,
              onExitFullscreen: _exitFullscreen,
            ),
          );
        },
      ),
    );
  }

  void _onWindowFullscreen(bool event) {
    widget.onToggleWindowFullscreen?.call(event);

    if (event) {
      _putVideoToNewRoute();
    } else {
      context.pop();
    }
  }

  void _onFullscreen(bool event) {
    widget.onToggleFullscreen?.call(event);

    if (event) {
      _putVideoToNewRoute();
    } else {
      context.pop();
    }

    windowManager.setFullScreen(event);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * (9 / 16);

        return SizedBox(
          width: width,
          height: height,
          child: ListenableBuilder(
            listenable: controller.init,
            builder: (context, child) {
              if (controller.init.running) {
                return const Center(child: CircularProgressIndicator());
              }

              return StreamBuilder(
                stream: controller.stream.fullscreen,
                builder: (context, asyncSnapshot) {
                  final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
                  return StreamBuilder(
                    stream: controller.stream.windowFullscreen,
                    builder: (context, asyncSnapshot) {
                      final isWindowFullscreen = asyncSnapshot.data ?? controller.state.windowFullscreen;
                      if (isFullscreen || isWindowFullscreen) {
                        return const Placeholder();
                      }

                      return _buildVideoSurface();
                    },
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildVideoSurface() {
    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? .zero,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Selector<PlayerConfig, bool>(
                  selector: (context, config) => config.ambientLight,
                  builder: (context, ambientLight, _) {
                    final isDarkMode = Theme.of(context).brightness == .dark;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      opacity: isDarkMode && ambientLight ? 1.0 : 0.0,
                      child: AmbientLightLayer(
                        controller: controller.controller,
                        width: constraints.maxWidth,
                        height: constraints.maxHeight,
                      ),
                    );
                  },
                ),
                Video(
                  controller: controller.controller,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  controls: (_) => _PlayerOverlay(
                    controller: controller,
                    title: widget.title,
                    layers: widget.layers,
                    playerConfig: widget.playerConfig,
                    danmakuConfig: widget.danmakuConfig,
                    onEnterFullscreen: _enterFullscreen,
                    onExitFullscreen: _exitFullscreen,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PlayerOverlay extends StatefulWidget {
  final BiliVideoPlayerController controller;
  final Widget? title;
  final List<Widget> layers;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final VoidCallback onEnterFullscreen;
  final VoidCallback onExitFullscreen;

  const _PlayerOverlay({
    required this.controller,
    this.title,
    this.layers = const [],
    required this.playerConfig,
    required this.danmakuConfig,
    required this.onEnterFullscreen,
    required this.onExitFullscreen,
  });

  @override
  State<_PlayerOverlay> createState() => _PlayerOverlayState();
}

class _PlayerOverlayState extends State<_PlayerOverlay> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'PlayerOverlay'));

  BiliVideoPlayerController get controller => widget.controller;
  PlayerConfig get playerConfig => widget.playerConfig;
  DanmakuConfig get danmakuConfig => widget.danmakuConfig;

  final Duration controlsTransitionDuration = const Duration(milliseconds: 200);
  final Duration controlsHoverDuration = const Duration(seconds: 5);
  final double buttonBarHeight = 42;
  final EdgeInsets topBarMargin = EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);
  final EdgeInsets bottomBarMargin = EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0);
  final double seekBarContainerHeight = 28.0;
  final FocusNode focusNode = FocusNode();

  bool visible = false;
  Timer? visibleTimer;

  String? activePanel;

  @override
  void dispose() {
    visibleTimer?.cancel();
    focusNode.dispose();

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

  void openPanel(String id) {
    setState(() => activePanel = id);
  }

  void closePanel() {
    setState(() => activePanel = null);
  }

  String _getQualityDisplayName(int id) => switch (id) {
    // video
    129 => 'HDR Vivid',
    127 => '4320P',
    126 => 'DolbyVision',
    125 => 'HDR',
    120 => '2160P',
    116 => '1080P60',
    112 => '1080P+',
    100 => 'AI修复',
    80 => '1080P',
    74 => '720P+',
    64 => '720P',
    32 => '480P',
    16 => '360P',
    6 => '240P',
    // audio
    40251 => 'Hi-Res',
    40250 => 'DolbyAtmos',
    // ??? => '320K', // 疑似有 320K 的音频流，但我始终没找到测试视频
    30280 => '192K',
    30232 => '132K',
    30216 => '64K',
    _ => throw Exception('Unknown quality id: $id'),
  };

  String? _getQualityDisplaySubtitle(int id) => switch (id) {
    // video
    127 => '8K',
    120 => '4K',
    112 => '更高码率',
    116 => '更高帧率',
    // audio
    40251 => '无损',
    40250 => '无损',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          _log.i('onKeyEvent KeyDownEvent: $event');
        } else if (event is KeyUpEvent) {
          _log.i('onKeyEvent KeyUpEvent: $event');
        } else if (event is KeyRepeatEvent) {
          _log.i('onKeyEvent KeyRepeatEvent: $event');
        }
      },
      // bindings: {
      //   const SingleActivator(LogicalKeyboardKey.space): () => viewModel.playOrPause(),
      //   const SingleActivator(LogicalKeyboardKey.arrowLeft): () => viewModel.seek(viewModel.state.position - Duration(seconds: 5)),
      //   const SingleActivator(LogicalKeyboardKey.arrowRight): () => viewModel.seek(viewModel.state.position + Duration(seconds: 5)),
      //   const SingleActivator(LogicalKeyboardKey.arrowUp): () => viewModel.setVolume(viewModel.state.volume + 5),
      //   const SingleActivator(LogicalKeyboardKey.arrowDown): () => viewModel.setVolume(viewModel.state.volume - 5),
      //   const SingleActivator(LogicalKeyboardKey.keyM): () => viewModel.setVolume(viewModel.state.volume == 0 ? 40.0 : 0.0),
      // },
      child: Material(
        elevation: 0.0,
        borderOnForeground: false,
        animationDuration: Duration.zero,
        color: const Color(0x00000000),
        shadowColor: const Color(0x00000000),
        surfaceTintColor: const Color(0x00000000),
        child: GestureDetector(
          onTapDown: (TapDownDetails details) {
            if (activePanel != null) return;

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
                ...widget.layers,
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

                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // 顶栏
                          Container(
                            height: buttonBarHeight,
                            margin: topBarMargin,
                            child: Row(
                              spacing: 8.0,
                              children: [
                                Expanded(
                                  child: DefaultTextStyle.merge(
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20.0,
                                      fontWeight: .w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    child: widget.title ?? SizedBox.shrink(),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => openPanel(settingsPanel),
                                  icon: const Icon(Icons.settings_sharp, color: Colors.white),
                                  tooltip: '设置',
                                ),
                                IconButton(
                                  onPressed: () => openPanel(danmakuSettingsPanel),
                                  icon: const Icon(CustomIcons.danmaku_settings, color: Colors.white),
                                  tooltip: '弹幕设置',
                                ),
                              ],
                            ),
                          ),

                          const Spacer(),

                          _SeekBar(
                            seekBarContainerHeight: seekBarContainerHeight,
                            onSeekStart: (newPosition) {
                              controller.emitSeekStart(newPosition);
                              visibleTimer?.cancel();
                            },
                            onSeekEnd: (newPosition) {
                              controller.emitSeekEnd(newPosition);
                              _onMouseEnter();
                            },
                          ),
                          // 底栏
                          Container(
                            height: buttonBarHeight,
                            margin: bottomBarMargin,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const MaterialDesktopSkipPreviousButton(),
                                const MaterialDesktopPlayOrPauseButton(),
                                const MaterialDesktopSkipNextButton(),
                                const MaterialDesktopVolumeButton(),
                                const Spacer(),
                                _ControlButton(
                                  label: '剧集',
                                  onPressed: () => {},
                                ),
                                _ControlButton(
                                  label: '列表',
                                  onPressed: () => {},
                                ),
                                _ControlButton(
                                  label: '合集',
                                  onPressed: () => {},
                                ),
                                _ControlIconButton(
                                  onPressed: () => {},
                                  icon: Icons.closed_caption_outlined,
                                  tooltip: '字幕',
                                ),
                                // playback rate
                                StreamBuilder(
                                  stream: controller.stream.rate,
                                  builder: (context, asyncSnapshot) {
                                    final rate = asyncSnapshot.data ?? controller.state.rate;
                                    return _ControlButton(
                                      label: '${rate}x',
                                      onPressed: () => openPanel(playbackRatePanel),
                                    );
                                  },
                                ),
                                // quality
                                StreamBuilder(
                                  stream: controller.stream.videoTrack,
                                  builder: (context, asyncSnapshot) {
                                    final videoTrack = asyncSnapshot.data ?? controller.state.videoTrack;
                                    if (videoTrack == null) {
                                      return _ControlButton(
                                        label: '画质',
                                        onPressed: () => openPanel(qualityPanel),
                                      );
                                    }

                                    return _ControlButton(
                                      label: _getQualityDisplayName(videoTrack.id),
                                      onPressed: () => openPanel(qualityPanel),
                                    );
                                  },
                                ),
                                StreamBuilder(
                                  stream: controller.stream.windowFullscreen,
                                  builder: (context, snapshot) {
                                    final state = snapshot.data ?? controller.state.windowFullscreen;
                                    return _ControlIconButton(
                                      onPressed: () => controller.emitWindowFullscreen(!state),
                                      icon: state ? Icons.close_fullscreen : Icons.fit_screen_outlined,
                                      tooltip: state ? '退出窗口全屏' : '窗口全屏',
                                    );
                                  },
                                ),
                                StreamBuilder(
                                  stream: controller.stream.fullscreen,
                                  builder: (context, asyncSnapshot) {
                                    final isFullscreen = asyncSnapshot.data ?? controller.state.fullscreen;
                                    return _ControlIconButton(
                                      onPressed: () {
                                        if (isFullscreen) {
                                          widget.onExitFullscreen();
                                        } else {
                                          widget.onEnterFullscreen();
                                        }
                                      },
                                      icon: isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                                      tooltip: isFullscreen ? '退出全屏' : '全屏',
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
                VideoPlayerPanel(
                  controller: controller,
                  playerConfig: playerConfig,
                  danmakuConfig: danmakuConfig,
                  activePanel: activePanel,
                  onClose: closePanel,
                  onPlaybackRateChanged: controller.setPlaybackRate,
                  availableVideoQuality: controller.videoTracks.map(
                    (v) {
                      return QualityPanelLabel(
                        id: v.id,
                        title: _getQualityDisplayName(v.id),
                        subtitle: _getQualityDisplaySubtitle(v.id),
                      );
                    },
                  ).toList(),
                  availableAudioQuality: controller.audioTracks.map(
                    (v) {
                      return QualityPanelLabel(
                        id: v.id,
                        title: _getQualityDisplayName(v.id),
                        subtitle: _getQualityDisplaySubtitle(v.id),
                      );
                    },
                  ).toList(),
                  onQualityChanged: controller.setQuality,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SeekBar extends StatefulWidget {
  final double seekBarContainerHeight;
  final ValueChanged<Duration>? onSeekStart;
  final ValueChanged<Duration>? onSeekEnd;

  const _SeekBar({
    required this.seekBarContainerHeight,
    this.onSeekStart,
    this.onSeekEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  bool hover = false;
  bool click = false;
  double slider = 0.0;

  late bool playing = controller(context).player.state.playing;
  late Duration position = controller(context).player.state.position;
  late Duration duration = controller(context).player.state.duration;
  late Duration buffer = controller(context).player.state.buffer;

  final List<StreamSubscription> subscriptions = [];

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playing.listen((event) {
            setState(() {
              playing = event;
            });
          }),
          controller(context).player.stream.completed.listen((event) {
            setState(() {
              position = Duration.zero;
            });
          }),
          controller(context).player.stream.position.listen((event) {
            setState(() {
              if (!click) position = event;
            });
          }),
          controller(context).player.stream.duration.listen((event) {
            setState(() {
              duration = event;
            });
          }),
          controller(context).player.stream.buffer.listen((event) {
            setState(() {
              buffer = event;
            });
          }),
        ],
      );
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void onPointerMove(PointerMoveEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
    controller(context).player.seek(duration * slider);
  }

  void onPointerDown() {
    widget.onSeekStart?.call(duration * slider);
    setState(() {
      click = true;
    });
  }

  void onPointerUp() {
    widget.onSeekEnd?.call(duration * slider);
    setState(() {
      // Explicitly set the position to prevent the slider from jumping.
      click = false;
      position = duration * slider;
    });
    controller(context).player.seek(duration * slider);
  }

  void onHover(PointerHoverEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onEnter(PointerEnterEvent e, BoxConstraints constraints) {
    final percent = e.localPosition.dx / constraints.maxWidth;
    setState(() {
      hover = true;
      slider = percent.clamp(0.0, 1.0);
    });
  }

  void onExit(PointerExitEvent e, BoxConstraints constraints) {
    setState(() {
      hover = false;
      slider = 0.0;
    });
  }

  /// Returns the current playback position in percentage.
  double get positionPercent {
    if (position == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = position.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  /// Returns the current playback buffer position in percentage.
  double get bufferPercent {
    if (buffer == Duration.zero || duration == Duration.zero) {
      return 0.0;
    } else {
      final value = buffer.inMilliseconds / duration.inMilliseconds;
      return value.clamp(0.0, 1.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double seekBarThumbSize = 12.0;
    final Duration seekBarThumbTransitionDuration = const Duration(milliseconds: 150);
    final colorScheme = Theme.of(context).colorScheme;
    final double seekBarHoverHeight = 5.6;
    final double seekBarHeight = 3.2;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 12.0),
        Text(
          position.label(reference: position),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        SizedBox(width: 8.0),
        Expanded(
          child: Transform.translate(
            offset: const Offset(0.0, 5.0),
            child: Container(
              clipBehavior: Clip.none,
              // margin: _theme(context).seekBarMargin,
              child: LayoutBuilder(
                builder: (context, constraints) => MouseRegion(
                  cursor: SystemMouseCursors.click,
                  onHover: (e) => onHover(e, constraints),
                  onEnter: (e) => onEnter(e, constraints),
                  onExit: (e) => onExit(e, constraints),
                  child: Listener(
                    onPointerMove: (e) => onPointerMove(e, constraints),
                    onPointerDown: (e) => onPointerDown(),
                    onPointerUp: (e) => onPointerUp(),
                    child: Container(
                      color: Colors.transparent,
                      width: constraints.maxWidth,
                      height: widget.seekBarContainerHeight,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.centerLeft,
                        children: [
                          AnimatedContainer(
                            width: constraints.maxWidth,
                            height: hover ? seekBarHoverHeight : seekBarHeight,
                            alignment: Alignment.centerLeft,
                            duration: seekBarThumbTransitionDuration,
                            color: colorScheme.outline.withAlpha(100),
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.centerLeft,
                              children: [
                                // hover
                                Container(
                                  width: constraints.maxWidth * slider,
                                  color: const Color(0x3DFFFFFF),
                                ),
                                // buffered
                                Container(
                                  width: constraints.maxWidth * bufferPercent,
                                  color: const Color(0x3DFFFFFF),
                                ),
                                // position
                                Container(
                                  width: click ? constraints.maxWidth * slider : constraints.maxWidth * positionPercent,
                                  color: colorScheme.primary,
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            left: click
                                ? (constraints.maxWidth - seekBarThumbSize / 2) * slider
                                : (constraints.maxWidth - seekBarThumbSize / 2) * positionPercent,
                            child: AnimatedContainer(
                              width: hover || click ? seekBarThumbSize : 0.0,
                              height: hover || click ? seekBarThumbSize : 0.0,
                              duration: seekBarThumbTransitionDuration,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(seekBarThumbSize / 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Text(
          duration.label(reference: duration),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        SizedBox(width: 12.0),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _ControlButton({
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

class _ControlIconButton extends StatelessWidget {
  final String? tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _ControlIconButton({
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

class _PlaybackRateButton extends StatefulWidget {
  const _PlaybackRateButton();

  @override
  State<_PlaybackRateButton> createState() => _PlaybackRateButtonState();
}

class _PlaybackRateButtonState extends State<_PlaybackRateButton> {
  static const _playbackRates = [0.5, 1.0, 1.25, 1.5, 2.0, 3.0];

  late double rate = controller(context).player.state.rate;

  StreamSubscription? subscription;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (subscription == null) {
      controller(context).player.stream.rate.listen((event) {
        setState(() => rate = event);
      });
    }
  }

  @override
  void dispose() {
    subscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   behavior: HitTestBehavior.opaque,
    //   onTapDown: _onTapDown,
    //   child: Tooltip(
    //     message: '播放速度',
    //     child: _ControlsTextButton(
    //       child: Text(
    //         _buildSpeedLabel(rate),
    //         style: const TextStyle(
    //           color: Colors.white,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
    return PopupMenuButton<double>(
      itemBuilder: (context) => _playbackRates
          .map(
            (speed) => PopupMenuItem<double>(
              value: speed,
              child: Text(_buildSpeedLabel(speed)),
            ),
          )
          .toList(),
      onSelected: (value) => controller(context).player.setRate(value),
      tooltip: '播放速度',
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        child: Text(
          _buildSpeedLabel(rate),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
    // return TextButton(
    //   onPressed: _onTapDown,
    //   child: Text(
    //     _buildSpeedLabel(rate),
    //     style: const TextStyle(
    //       color: Colors.white,
    //       fontWeight: FontWeight.w500,
    //     ),
    //   ),
    // );
    // return GestureDetector(
    //   behavior: HitTestBehavior.opaque,
    //   onTapDown: _onTapDown,
    //   child: Tooltip(
    //     message: '播放速度',
    //     child: _ControlsTextButton(
    //       child: Text(
    //         _buildSpeedLabel(rate),
    //         style: const TextStyle(
    //           color: Colors.white,
    //           fontWeight: FontWeight.w500,
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }

  String _buildSpeedLabel(double speed) {
    return speed == speed.roundToDouble()
        ? '${speed.toStringAsFixed(0)}.0x'
        : '${speed.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '')}x';
  }
}
