import 'dart:async';
import 'dart:io';

import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/app/media_session_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/ambient_light/ambient_light_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_history_reporter/bili_history_reporter.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_history_reporter/bili_history_reporter_debug_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bsbsb/bsbsb_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bsbsb/bsbsb_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/handler/bili_refresh_handler.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/bili_danmaku_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku/danmaku_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/media_session/extra_video_player_media_session_adapter.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/media_session/media_session_data.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/danmaku_settings/danmaku_settings_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/extra_video_player.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/handler/titlebar_handler.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_layer.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playback_rate/playback_rate_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/bili_playlist_coordinator.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/collection/collection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/episode/episode_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/playlist/playlist/playlist_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/quality/bili_quality_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/quality/quality_button.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/settings/settings_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/preview/bili_timeline_preview_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/waveform/bili_timeline_waveform_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/windows_taskbar/windows_taskbar_adapter.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/router_helper.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:window_manager/window_manager.dart';

class BiliVideoPlayer extends StatefulWidget {
  final ExtraVideoController controller;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final VideoRepository videoRepository;
  final double aspectRatio;
  final BorderRadius borderRadius;
  final AppController appController;
  final PlayInfo playInfo;
  final MediaSessionData mediaSessionData;
  final MediaSessionController mediaSessionController;
  final AuthRepository authRepository;
  final BiliPlaylistCoordinator? playlistController;
  final NoticeController noticeController;
  final VoidCallback onRefresh;
  final BsbsbRepository bsbsbRepository;
  final BsbsbConfig bsbsbConfig;

  const BiliVideoPlayer({
    super.key,
    required this.controller,
    required this.playerConfig,
    required this.danmakuConfig,
    required this.videoRepository,
    required this.aspectRatio,
    required this.borderRadius,
    required this.appController,
    required this.playInfo,
    required this.mediaSessionData,
    required this.mediaSessionController,
    required this.authRepository,
    this.playlistController,
    required this.noticeController,
    required this.onRefresh,
    required this.bsbsbRepository,
    required this.bsbsbConfig,
  });

  @override
  State<BiliVideoPlayer> createState() => _BiliVideoPlayerState();
}

class _BiliVideoPlayerState extends State<BiliVideoPlayer> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'BiliVideoPlayer'));

  ExtraVideoController get controller => widget.controller;
  NoticeController get noticeController => widget.noticeController;
  PlayerConfig get config => widget.playerConfig;

  final PanelController panelController = PanelController();
  late TitlebarHandler titlebarHandler;
  late BiliQualityController qualityController;
  late BiliTimelinePreviewController previewController;
  late BiliTimelineWaveformController waveformController;
  late TimelineSegmentController segmentController;
  late BiliDanmakuController danmakuController;
  late BiliHistoryReporter historyReporter;
  late BiliRefreshHandler refreshHandler;

  final List<StreamSubscription> _subscriptions = [];

  MediaSession? _mediaSession;
  BsbsbController? bsbsbController;

  @override
  void initState() {
    super.initState();

    titlebarHandler = TitlebarHandler(
      controller: controller,
      appController: widget.appController,
    );
    _createWithPlayInfo();

    if (config.mediaControl.value) {
      _onMediaControl(true);
    }

    if (widget.bsbsbConfig.enable.value) {
      bsbsbController = BsbsbController(
        config: widget.bsbsbConfig,
        bsbsbRepository: widget.bsbsbRepository,
        videoId: widget.playInfo.videoId,
      );
    }

    controller.setVolume(config.volume.value);
    if (config.muted.value) {
      controller.setMuted(config.muted.value);
    }

    _subscriptions.addAll([
      config.mediaControl.stream.listen(_onMediaControl),
      config.hideMediaControlInfo.stream.listen(_onHideMediaControlInfo),
      controller.stream.error.listen((e) => _log.e('onPlayerError', error: e)),
      controller.stream.duration.listen(_onDuration),
      controller.stream.volume.listen(_onVolume),
      controller.stream.muted.listen(_onMuted),
      controller.stream.completed.listen(_onCompleted),
      widget.bsbsbConfig.enable.stream.listen(_onBsbsbEnable),
    ]);
  }

  @override
  void didUpdateWidget(covariant BiliVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.playInfo != widget.playInfo) {
      _disposeWithPlayInfo();
      _createWithPlayInfo();

      if (bsbsbController != null) {
        if (widget.playInfo.videoId != bsbsbController!.videoId) {
          bsbsbController?.dispose();
          bsbsbController = BsbsbController(
            config: widget.bsbsbConfig,
            bsbsbRepository: widget.bsbsbRepository,
            videoId: widget.playInfo.videoId,
          );
        }
      }
    }

    if (oldWidget.playlistController != widget.playlistController) {
      _mediaSession?.deactivate();
      _mediaSession = null;

      if (config.mediaControl.value) {
        _onMediaControl(true);
      }
    }
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    titlebarHandler.dispose();
    panelController.dispose();
    _disposeWithPlayInfo();

    _mediaSession?.deactivate();
    bsbsbController?.dispose();

    super.dispose();
  }

  /// 销毁所有依赖 playInfo 的控制器
  void _disposeWithPlayInfo() {
    qualityController.dispose();
    previewController.dispose();
    waveformController.dispose();
    segmentController.dispose();
    danmakuController.dispose();
    historyReporter.dispose();
    refreshHandler.dispose();
  }

  /// 创建所有依赖 playInfo 的控制器
  void _createWithPlayInfo() {
    qualityController = BiliQualityController(
      controller: controller,
      config: config,
      playInfo: widget.playInfo,
      authRepository: widget.authRepository,
    );
    previewController = BiliTimelinePreviewController(
      videoRepository: widget.videoRepository,
      videoId: widget.playInfo.videoId,
      episodeId: widget.playInfo.episodeId,
    );
    waveformController = BiliTimelineWaveformController(
      videoRepository: widget.videoRepository,
      videoId: widget.playInfo.videoId,
      episodeId: widget.playInfo.episodeId,
    );
    segmentController = TimelineSegmentController(controller: controller);
    danmakuController = BiliDanmakuController(
      contentType: .video,
      contentId: widget.playInfo.videoId,
      episodeId: widget.playInfo.episodeId,
      controller: controller,
      config: widget.danmakuConfig,
      videoRepository: widget.videoRepository,
      maskUrl: widget.playInfo.maskUrl,
    );
    historyReporter = BiliHistoryReporter(
      controller: controller,
      playInfo: widget.playInfo,
      qualityController: qualityController,
      videoRepository: widget.videoRepository,
    );
    refreshHandler = BiliRefreshHandler(
      controller: controller,
      onRefresh: widget.onRefresh,
    );
  }

  void onSeekStart(Duration event) {
    historyReporter.onSeekStart(event);
  }

  void onSeekEnd(Duration event) {
    historyReporter.onSeekEnd(event);
  }

  void _onMediaControl(bool event) {
    if (event) {
      debugPrint('_onMediaControl: ${widget.playlistController.hashCode}');
      _mediaSession ??= widget.mediaSessionController.createSession(
        ExtraVideoPlayerMediaSessionAdapter(
          player: controller.player,
          mediaSessionData: widget.mediaSessionData,
          playlistController: widget.playlistController,
        ),
      );
      _mediaSession!.activate();
    } else {
      _mediaSession?.deactivate();
    }
  }

  void _onHideMediaControlInfo(bool event) {
    widget.mediaSessionData.setPrivacyMode(event);
  }

  void onFrontend() {
    if (config.mediaControl.value) {
      _mediaSession?.activate();
    }
  }

  void onBackend() {
    if (controller.state.fullscreen) {
      controller.exitFullscreen();
    }
    if (controller.state.windowFullscreen) {
      controller.exitWindowFullscreen();
    }
  }

  void _onDuration(Duration event) {
    if (config.autoPlay.value) controller.play();
  }

  void _onVolume(double event) {
    if (!controller.state.muted) {
      config.volume.set(event);
    }
  }

  void _onMuted(bool event) {
    config.muted.set(event);
  }

  void _onCompleted(bool event) {
    if (!event) return;

    if (config.loopPlayback.value) {
      controller.play();
    } else {
      widget.playlistController?.next();
    }
  }

  void _onBsbsbEnable(bool event) {
    if (event) {
      bsbsbController ??= BsbsbController(
        config: widget.bsbsbConfig,
        bsbsbRepository: widget.bsbsbRepository,
        videoId: widget.playInfo.videoId,
      );
    } else {
      bsbsbController?.dispose();
      bsbsbController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ExtraVideoPlayer(
      controller: controller,
      playerConfig: config,
      danmakuConfig: widget.danmakuConfig,
      videoRepository: widget.videoRepository,
      aspectRatio: widget.aspectRatio,
      borderRadius: widget.borderRadius,
      topItems: [
        StreamBuilder(
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
                  return const SizedBox.shrink();
                }

                return Row(
                  mainAxisSize: .min,
                  spacing: 4.0,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(Icons.arrow_back_outlined, color: Colors.white),
                      hoverColor: Colors.white24,
                      tooltip: '返回',
                    ),
                    IconButton(
                      onPressed: () => context.popToRoot(),
                      icon: Icon(Icons.home_outlined, color: Colors.white),
                      hoverColor: Colors.white24,
                      tooltip: '返回主页',
                    ),
                  ],
                );
              },
            );
          },
        ),
        Expanded(
          child: Stack(
            alignment: .centerLeft,
            children: [
              DefaultTextStyle.merge(
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.0,
                  fontWeight: .w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                child: StreamBuilder(
                  stream: widget.mediaSessionData.stream.title,
                  initialData: widget.mediaSessionData.state.title,
                  builder: (context, snapshot) => Text(snapshot.data ?? ''),
                ),
              ),
              StreamBuilder(
                stream: controller.stream.windowFullscreen,
                builder: (context, asyncSnapshot) {
                  final isWindowFullscreen = asyncSnapshot.data ?? controller.state.windowFullscreen;
                  if (!isWindowFullscreen) {
                    return SizedBox.shrink();
                  }

                  return GestureDetector(
                    behavior: .translucent,
                    onPanStart: (_) => windowManager.startDragging(),
                  );
                },
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => panelController.push(
            DanmakuSettingsPanel(
              controller: panelController,
              config: widget.danmakuConfig,
            ),
          ),
          icon: const Icon(CustomIcons.danmaku_settings, color: Colors.white),
          tooltip: '弹幕设置',
        ),
        IconButton(
          onPressed: () => panelController.push(
            SettingsPanel(
              controller: panelController,
              config: config,
            ),
          ),
          icon: const Icon(Icons.settings_sharp, color: Colors.white),
          tooltip: '设置',
        ),
      ],
      bottomItems: [
        const Spacer(),
        StreamBuilder(
          stream: controller.stream.fullscreen,
          initialData: controller.state.fullscreen,
          builder: (context, asyncSnapshot) {
            final isFullscreen = asyncSnapshot.data!;
            return StreamBuilder(
              stream: controller.stream.windowFullscreen,
              initialData: controller.state.windowFullscreen,
              builder: (context, asyncSnapshot) {
                final isWindowFullscreen = asyncSnapshot.data!;
                if (!isFullscreen && !isWindowFullscreen) {
                  return const SizedBox.shrink();
                }

                final episodeController = widget.playlistController?.episodeController;
                final playlistController = widget.playlistController?.playlistController;
                final collectionController = widget.playlistController?.collectionController;

                return Row(
                  mainAxisSize: .min,
                  children: [
                    if (episodeController != null)
                      ControlButton(
                        label: '剧集',
                        onPressed: () {
                          panelController.push(EpisodePanel(episodeController));
                        },
                      ),
                    if (playlistController != null)
                      ControlButton(
                        label: '列表',
                        onPressed: () {
                          panelController.push(PlaylistPanel(playlistController));
                        },
                      ),
                    if (collectionController != null)
                      ControlButton(
                        label: '合集',
                        onPressed: () {
                          panelController.push(CollectionPanel(collectionController));
                        },
                      ),
                  ],
                );
              },
            );
          },
        ),

        // subtitle
        // ControlIconButton(
        //   onPressed: () => openPanel(subtitleSettingsPanel),
        //   icon: Icons.closed_caption_outlined,
        //   tooltip: '字幕',
        // ),

        // playback rate
        StreamBuilder(
          stream: controller.stream.rate,
          initialData: controller.state.rate,
          builder: (context, asyncSnapshot) {
            final rate = asyncSnapshot.data!;
            return ControlButton(
              label: '${rate}x',
              onPressed: () => panelController.push(
                PlaybackRatePanel(
                  controller: controller,
                  panelController: panelController,
                ),
              ),
            );
          },
        ),

        // quality
        QualityButton(panelController: panelController, qualityController: qualityController),
      ],
      layers: [
        ExtraVideoPlayerLayer(child: PanelLayer(controller: panelController)),

        // notice
        ExtraVideoPlayerLayer(
          child: Positioned(
            left: 8.0,
            bottom: 100.0,
            child: NoticeLayer(controller: noticeController),
          ),
        ),

        // danmaku
        ExtraVideoPlayerLayer(
          inForeground: false,
          child: StreamBuilder(
            stream: widget.danmakuConfig.enabled.stream,
            initialData: widget.danmakuConfig.enabled.value,
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.data!) {
                return SizedBox.shrink();
              }

              return DanmakuLayer(
                key: ObjectKey(danmakuController),
                controller: danmakuController,
                videoController: controller,
              );
            },
          ),
        ),

        // history reporter debug hud
        ExtraVideoPlayerLayer(
          inForeground: false,
          child: StreamBuilder(
            stream: config.historyReporterDebugOverlay.stream,
            initialData: config.historyReporterDebugOverlay.value,
            builder: (context, asyncSnapshot) {
              if (!asyncSnapshot.data!) {
                return SizedBox.shrink();
              }

              return BiliHistoryReporterDebugLayer(controller: historyReporter);
            },
          ),
        ),

        if (Platform.isWindows)
          ExtraVideoPlayerLayer(
            child: WindowsTaskbarAdapter(
              controller: controller,
              playlistController: widget.playlistController,
            ),
          ),

        // bsbsb
        if (bsbsbController != null)
          ExtraVideoPlayerLayer(
            child: BsbsbLayer(
              controller: bsbsbController!,
              segmentController: segmentController,
              videoController: controller,
              noticeController: noticeController,
              episodeId: widget.playInfo.episodeId,
            ),
          ),
      ],
      background: StreamBuilder(
        stream: config.ambientLight.stream,
        initialData: config.ambientLight.value,
        builder: (context, asyncSnapshot) {
          final isDarkMode = Theme.brightnessOf(context) == .dark;

          return AnimatedOpacity(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOut,
            opacity: isDarkMode && asyncSnapshot.data! ? 1.0 : 0.0,
            child: AmbientLightLayer(controller: controller),
          );
        },
      ),
      previewController: previewController,
      waveformController: waveformController,
      segmentController: segmentController,
      onSeekStart: onSeekStart,
      onSeekEnd: onSeekEnd,
      onFrontend: onFrontend,
      onBackend: onBackend,
      panelController: panelController,
      playlistController: widget.playlistController,
    );
  }
}
