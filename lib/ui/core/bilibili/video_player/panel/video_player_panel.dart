import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/bili_video_player_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/danmaku_settings_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/quality_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/settings_shell.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_settings_shell.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel_player_state.dart';
import 'package:flutter/material.dart';

const playbackRatePanel = 'playback_rate';
const qualityPanel = 'quality';
const subtitleSettingsPanel = 'subtitle_settings';
const settingsPanel = 'settings';
const danmakuSettingsPanel = 'danmaku_settings';

class VideoPlayerPanel extends StatelessWidget {
  final BiliVideoPlayerController controller;
  final PlayerConfig playerConfig;
  final DanmakuConfig danmakuConfig;
  final String? activePanel;
  final VoidCallback onClose;
  final PanelPlayerState? panelState;
  final ValueChanged<double> onPlaybackRateChanged;
  final List<QualityPanelLabel> availableVideoQuality;
  final List<QualityPanelLabel> availableAudioQuality;
  final ValueChanged<QualityPanelValues>? onQualityChanged;

  const VideoPlayerPanel({
    super.key,
    required this.controller,
    required this.playerConfig,
    required this.danmakuConfig,
    this.activePanel,
    required this.onClose,
    this.panelState,
    required this.onPlaybackRateChanged,
    this.availableVideoQuality = const [],
    this.availableAudioQuality = const [],
    this.onQualityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            ignoring: activePanel == null,
            child: AnimatedOpacity(
              opacity: activePanel != null ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                behavior: .opaque,
                onTap: onClose,
                child: Container(color: Colors.black38),
              ),
            ),
          ),
        ),
        Align(
          alignment: .centerRight,
          child: AnimatedSlide(
            offset: activePanel != null ? .zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: 300,
              height: .infinity,
              child: Material(
                elevation: 12,
                color: Colors.black.withAlpha(150),
                child: SafeArea(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 160),
                    child: switch (activePanel) {
                      playbackRatePanel => StreamBuilder(
                        stream: controller.stream.rate,
                        builder: (context, asyncSnapshot) {
                          final rate = asyncSnapshot.data ?? controller.state.rate;
                          return SelectionPanel(
                            header: PanelHeader(title: Text('播放速度'), onBack: onClose),
                            items: const [
                              SelectionPanelItem(label: '0.1x', value: 0.1),
                              SelectionPanelItem(label: '0.2x', value: 0.2),
                              SelectionPanelItem(label: '0.5x', value: 0.5),
                              SelectionPanelItem(label: '1.0x', value: 1.0),
                              SelectionPanelItem(label: '1.5x', value: 1.5),
                              SelectionPanelItem(label: '2.0x', value: 2.0),
                              SelectionPanelItem(label: '2.5x', value: 2.5),
                              SelectionPanelItem(label: '3.0x', value: 3.0),
                            ],
                            value: rate,
                            onChange: onPlaybackRateChanged,
                          );
                        },
                      ),
                      qualityPanel => StreamBuilder(
                        stream: controller.stream.track,
                        builder: (context, asyncSnapshot) {
                          return QualityPanel(
                            videoLabels: availableVideoQuality,
                            audioLabels: availableAudioQuality,
                            values: controller.quality,
                            onBack: onClose,
                            onChange: onQualityChanged,
                          );
                        },
                      ),
                      subtitleSettingsPanel => SubtitleSettingsShell(onBack: onClose),
                      settingsPanel => SettingsShell(
                        playerConfig: playerConfig,
                        onBack: onClose,
                      ),
                      danmakuSettingsPanel => DanmakuSettingsPanel(
                        config: danmakuConfig,
                        onBack: onClose,
                        key: const ValueKey(danmakuSettingsPanel),
                      ),
                      _ => SizedBox.shrink(),
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
