import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_section_title.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/switch_panel_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPanel extends StatelessWidget {
  final PlayerConfig config;
  final VoidCallback? onBack;
  final VoidCallback? onSelectPreferredCodec;
  final VoidCallback? onSelectFallbackCodec;

  const SettingsPanel({
    super.key,
    required this.config,
    this.onBack,
    this.onSelectPreferredCodec,
    this.onSelectFallbackCodec,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: Text('设置'), onBack: onBack),
        Expanded(
          child: ListView(
            children: [
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.autoPlay,
                builder: (context, autoPlay, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAutoPlay(value),
                  value: autoPlay,
                  title: const Text('自动播放'),
                ),
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.loopPlayback,
                builder: (context, loopPlayback, _) => SwitchPanelTile(
                  onChanged: (value) => config.setLoopPlayback(value),
                  value: loopPlayback,
                  title: const Text('循环播放'),
                ),
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.ambientLight,
                builder: (context, ambientLight, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAmbientLight(value),
                  value: ambientLight,
                  title: const Text('氛围光效'),
                  subtitle: const Text('仅在深色模式下生效'),
                ),
              ),

              PanelSectionTitle(title: '连续播放'),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.autoPlayNextEpisode,
                builder: (context, autoPlayNextEpisode, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAutoPlayNextEpisode(value),
                  value: autoPlayNextEpisode,
                  title: const Text('连续播放剧集'),
                ),
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.autoPlayNextPlaylist,
                builder: (context, autoPlayNextPlaylist, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAutoPlayNextPlaylist(value),
                  value: autoPlayNextPlaylist,
                  title: const Text('连续播放列表'),
                ),
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.autoPlayNextCollection,
                builder: (context, autoPlayNextCollection, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAutoPlayNextCollection(value),
                  value: autoPlayNextCollection,
                  title: const Text('连续播放合集'),
                ),
              ),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.autoPlayNextRecommend,
                builder: (context, autoPlayNextRecommend, _) => SwitchPanelTile(
                  onChanged: (value) => config.setAutoPlayNextRecommend(value),
                  value: autoPlayNextRecommend,
                  title: const Text('连续播放推荐'),
                ),
              ),

              PanelSectionTitle(title: '编解码'),
              PanelTile(
                onTap: onSelectPreferredCodec,
                title: const Text('首选编码格式'),
                trailing: Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: Colors.white.withAlpha(120),
                ),
              ),
              PanelTile(
                onTap: onSelectFallbackCodec,
                title: const Text('备选编码格式'),
                trailing: Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: Colors.white.withAlpha(120),
                ),
              ),

              PanelSectionTitle(),
              Selector<PlayerConfig, bool>(
                selector: (context, config) => config.historyReporterDebugHud,
                builder: (context, historyReporterDebugHud, _) => SwitchPanelTile(
                  onChanged: (value) => config.setHistoryReporterDebugHud(value),
                  value: historyReporterDebugHud,
                  title: const Text('HistoryReporterDebugHUD'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
