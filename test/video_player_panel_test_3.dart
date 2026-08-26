import 'package:better_bilibili/ui/core/bilibili/video_player/panel/playback_rate_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/quality_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/settings_shell.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_settings_shell.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: VideoPlayerPanelTest3(),
    ),
  );
}

class VideoPlayerPanelTest3 extends StatefulWidget {
  const VideoPlayerPanelTest3({super.key});

  @override
  State<VideoPlayerPanelTest3> createState() => _VideoPlayerPanelTest3State();
}

class _VideoPlayerPanelTest3State extends State<VideoPlayerPanelTest3> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VideoPlayerPanelTest3'),
      ),
      body: Center(
        child: SizedBox(
          width: 1920 / 2,
          height: 1080 / 2,
          child: TestVideoPlayer(),
        ),
      ),
    );
  }
}

class TestVideoPlayer extends StatefulWidget {
  const TestVideoPlayer({super.key});

  @override
  State<TestVideoPlayer> createState() => _TestVideoPlayerState();
}

class _TestVideoPlayerState extends State<TestVideoPlayer> {
  String? _activePanel;

  double _playbackRate = 1.0;
  QualityPanelValues _quality = QualityPanelValues(video: -1, audio: -1);

  void _openPanel(String panel) {
    setState(() {
      _activePanel = panel;
    });
  }

  void _closePanel() {
    setState(() => _activePanel = null);
  }

  void _onPlaybackRateChanged(double value) {
    debugPrint('_onPlaybackRateChanged: $value');
    _playbackRate = value;
    _closePanel();
  }

  void _onQualityChanged(QualityPanelValues value) {
    debugPrint('_onPlaybackRateChanged: ${value.video}, ${value.audio}');
    _quality = value;
    _closePanel();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: ColoredBox(color: Color(0xFF1F2937)),
        ),
        const Center(
          child: Icon(
            Icons.play_circle_fill,
            color: Colors.white70,
            size: 86,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black87],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 36, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: const LinearProgressIndicator(
                      value: 0.42,
                      minHeight: 4,
                      color: Color(0xFF00A1D6),
                      backgroundColor: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      IconButton(
                        color: Colors.white,
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow),
                        tooltip: '播放',
                      ),
                      const Text(
                        '08:24 / 20:00',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => _openPanel('danmaku_settings'),
                        icon: const Icon(Icons.closed_caption_off),
                        color: Colors.white,
                        tooltip: '弹幕设置',
                      ),
                      const SizedBox(width: 8),
                      _ControlButton(
                        label: '1.0x',
                        onPressed: () => _openPanel('playback_rate'),
                      ),
                      const SizedBox(width: 8),
                      _ControlButton(
                        label: '1080P',
                        onPressed: () => _openPanel('quality'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openPanel('subtitle_settings'),
                        icon: const Icon(Icons.closed_caption_off),
                        color: Colors.white,
                        tooltip: '字幕设置',
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _openPanel('settings'),
                        icon: const Icon(Icons.settings),
                        color: Colors.white,
                        tooltip: '设置',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _activePanel == null,
            child: AnimatedOpacity(
              opacity: _activePanel != null ? 1 : 0,
              duration: const Duration(milliseconds: 180),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closePanel,
                child: Container(color: Colors.black38),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedSlide(
            offset: _activePanel != null ? Offset.zero : const Offset(1, 0),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: 300,
              height: double.infinity,
              child: _PlayerSidePanel(
                activePanel: _activePanel,
                playbackRate: _playbackRate,
                quality: _quality,
                preferredEncoding: 'H.266',
                fallbackEncoding: 'H.265',
                autoPlay: true,
                smtcEnabled: true,
                onClose: _closePanel,
                onPlaybackRateChanged: _onPlaybackRateChanged,
                onQualityChanged: _onQualityChanged,
                onAutoPlayChanged: (value) {},
                onSmtcChanged: (value) {},
                onPrimaryEncodingSelected: (encoding) {},
                onFallbackEncodingSelected: (encoding) {},
              ),
            ),
          ),
        ),
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label),
    );
  }
}

class _PlayerSidePanel extends StatelessWidget {
  final String? activePanel;
  final double playbackRate;
  final QualityPanelValues quality;
  final String preferredEncoding;
  final String fallbackEncoding;
  final bool autoPlay;
  final bool smtcEnabled;
  final VoidCallback onClose;
  final ValueChanged<double> onPlaybackRateChanged;
  final ValueChanged<QualityPanelValues> onQualityChanged;
  final ValueChanged<bool> onAutoPlayChanged;
  final ValueChanged<bool> onSmtcChanged;
  final ValueChanged<String> onPrimaryEncodingSelected;
  final ValueChanged<String> onFallbackEncodingSelected;

  const _PlayerSidePanel({
    this.activePanel,
    required this.playbackRate,
    required this.quality,
    required this.preferredEncoding,
    required this.fallbackEncoding,
    required this.autoPlay,
    required this.smtcEnabled,
    required this.onClose,
    required this.onPlaybackRateChanged,
    required this.onQualityChanged,
    required this.onAutoPlayChanged,
    required this.onSmtcChanged,
    required this.onPrimaryEncodingSelected,
    required this.onFallbackEncodingSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 12,
      // color: const Color(0xFF111827),
      color: Colors.transparent,
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          child: switch (activePanel) {
            'playback_rate' => PlaybackRatePanel(
              value: playbackRate,
              onBack: onClose,
              onChange: onPlaybackRateChanged,
            ),
            'quality' => QualityPanel(
              videoLabels: [
                QualityPanelLabel(id: -1, title: '跟随全局(自动)'),
                QualityPanelLabel(id: 0, title: '自动'),
                QualityPanelLabel(id: 129, title: 'HDR Vivid'),
                QualityPanelLabel(id: 127, title: '8K'),
                QualityPanelLabel(id: 126, title: 'DolbyVision'),
                QualityPanelLabel(id: 125, title: 'HDR'),
                QualityPanelLabel(id: 120, title: '4K'),
                QualityPanelLabel(id: 116, title: '1080P++'),
                QualityPanelLabel(id: 112, title: '1080P+'),
                QualityPanelLabel(id: 100, title: 'AI修复'),
                QualityPanelLabel(id: 80, title: '1080P'),
                QualityPanelLabel(id: 74, title: '720P+'),
                QualityPanelLabel(id: 64, title: '720P'),
                QualityPanelLabel(id: 32, title: '480P'),
                QualityPanelLabel(id: 16, title: '360P'),
                QualityPanelLabel(id: 6, title: '240P'),
              ],
              audioLabels: [
                QualityPanelLabel(id: -1, title: '跟随全局(自动)'),
                QualityPanelLabel(id: 0, title: '自动'),
                QualityPanelLabel(id: 30251, title: 'Hi-Res'),
                QualityPanelLabel(id: 30250, title: 'DolbyAtmos'),
                QualityPanelLabel(id: 30280, title: '192K'),
                QualityPanelLabel(id: 30232, title: '132K'),
                QualityPanelLabel(id: 30216, title: '64K'),
              ],
              values: quality,
              onBack: onClose,
              onChange: onQualityChanged,
            ),
            'subtitle_settings' => SubtitleSettingsShell(onBack: onClose),
            // 'settings' => SettingsShell(onBack: onClose),
            _ => SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
