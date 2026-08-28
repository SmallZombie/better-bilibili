import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_section_title.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/switch_panel_tile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPanel extends StatelessWidget {
  final PlayerConfig config;
  final VoidCallback? onBack;
  final VoidCallback? onTapPreferredCodec;
  final VoidCallback? onTapFallbackCodec;
  final VoidCallback? onTapLoudnessNormalization;

  const SettingsPanel({
    super.key,
    required this.config,
    this.onBack,
    this.onTapPreferredCodec,
    this.onTapFallbackCodec,
    this.onTapLoudnessNormalization,
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
              StreamBuilder(
                stream: config.stream.autoPlay,
                builder: (context, asyncSnapshot) {
                  final autoPlay = asyncSnapshot.data ?? config.autoPlay;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAutoPlay(value),
                    value: autoPlay,
                    title: const Text('自动播放'),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.loopPlayback,
                builder: (context, asyncSnapshot) {
                  final loopPlayback = asyncSnapshot.data ?? config.loopPlayback;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setLoopPlayback(value),
                    value: loopPlayback,
                    title: const Text('循环播放'),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.ambientLight,
                builder: (context, asyncSnapshot) {
                  final ambientLight = asyncSnapshot.data ?? config.ambientLight;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAmbientLight(value),
                    value: ambientLight,
                    title: const Text('氛围光效'),
                    subtitle: const Text('仅在深色模式下生效'),
                  );
                },
              ),

              // 响度均衡之死见 README.md
              // StreamBuilder(
              //   stream: config.stream.loudnessNormalization,
              //   initialData: config.loudnessNormalization,
              //   builder: (context, asyncSnapshot) {
              //     final value = asyncSnapshot.data!;
              //     return PanelTile(
              //       title: const Text('响度均衡'),
              //       subtitle: Text(switch (value) {
              //         .off => '关闭',
              //         .normal => '普通',
              //         .highDynamic => '高动态',
              //       }),
              //       trailing: Icon(
              //         Icons.keyboard_arrow_right_outlined,
              //         color: Colors.white.withAlpha(200),
              //       ),
              //       onTap: onTapLoudnessNormalization,
              //     );
              //   },
              // ),
              PanelSectionTitle(title: '连续播放'),
              StreamBuilder(
                stream: config.stream.autoPlayNextEpisode,
                builder: (context, asyncSnapshot) {
                  final autoPlayNextEpisode = asyncSnapshot.data ?? config.autoPlayNextEpisode;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAutoPlayNextEpisode(value),
                    value: autoPlayNextEpisode,
                    title: const Text('连续播放剧集'),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.autoPlayNextPlaylist,
                builder: (context, asyncSnapshot) {
                  final autoPlayNextPlaylist = asyncSnapshot.data ?? config.autoPlayNextPlaylist;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAutoPlayNextPlaylist(value),
                    value: autoPlayNextPlaylist,
                    title: const Text('连续播放列表'),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.autoPlayNextCollection,
                builder: (context, asyncSnapshot) {
                  final autoPlayNextCollection = asyncSnapshot.data ?? config.autoPlayNextCollection;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAutoPlayNextCollection(value),
                    value: autoPlayNextCollection,
                    title: const Text('连续播放合集'),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.autoPlayNextRecommend,
                builder: (context, asyncSnapshot) {
                  final autoPlayNextRecommend = asyncSnapshot.data ?? config.autoPlayNextRecommend;
                  return SwitchPanelTile(
                    onChanged: (value) => config.setAutoPlayNextRecommend(value),
                    value: autoPlayNextRecommend,
                    title: const Text('连续播放推荐'),
                  );
                },
              ),

              PanelSectionTitle(title: '编解码'),
              StreamBuilder(
                stream: config.stream.preferredCodec,
                builder: (context, asyncSnapshot) {
                  final value = (asyncSnapshot.data ?? config.preferredCodec).toString();
                  return PanelTile(
                    onTap: onTapPreferredCodec,
                    title: const Text('首选编码格式'),
                    subtitle: Text(value),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_outlined,
                      color: Colors.white.withAlpha(200),
                    ),
                  );
                },
              ),
              StreamBuilder(
                stream: config.stream.fallbackCodec,
                builder: (context, asyncSnapshot) {
                  final value = (asyncSnapshot.data ?? config.fallbackCodec).toString();
                  return PanelTile(
                    onTap: onTapFallbackCodec,
                    title: const Text('备选编码格式'),
                    subtitle: Text(value),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_outlined,
                      color: Colors.white.withAlpha(200),
                    ),
                  );
                },
              ),

              // PanelSectionTitle(title: '互动卡片'),
              // SwitchPanelTile(
              //   title: const Text('显示互动卡片'),
              //   subtitle: const Text('展示由UP主添加的快捷关注、投票等卡片'),
              //   value: false,
              // ),
              // SwitchPanelTile(
              //   title: const Text('显示优化'),
              //   subtitle: const Text('强制卡片显示在右上角通知区域'),
              //   value: false,
              // ),
              // PanelTile(
              //   onTap: () {},
              //   title: const Text('过滤器'),
              //   subtitle: const Text('已隐藏 0 个卡片'),
              //   trailing: Icon(
              //     Icons.keyboard_arrow_right_outlined,
              //     color: Colors.white.withAlpha(200),
              //   ),
              // ),
              PanelSectionTitle(title: '媒体控制'),
              StreamBuilder(
                stream: config.stream.mediaControl,
                initialData: config.mediaControl,
                builder: (context, asyncSnapshot) {
                  final mediaControl = asyncSnapshot.data!;
                  return SwitchPanelTile(
                    title: const Text('启用媒体控制'),
                    subtitle: const Text('允许通过系统媒体控件控制播放，并显示当前播放信息'),
                    value: mediaControl,
                    onChanged: config.setMediaControl,
                  );
                },
              ),

              // SwitchPanelTile(
              //   title: const Text('后台播放'),
              //   value: false,
              // ),
              // SwitchPanelTile(
              //   title: const Text('阻止打断'),
              //   subtitle: const Text('强制占用音频通道，阻止其他应用打断 (铃声类除外)'),
              //   value: false,
              // ),
              if (kDebugMode) ...[
                PanelSectionTitle(),
                StreamBuilder(
                  stream: config.stream.historyReporterDebugHud,
                  builder: (context, asyncSnapshot) {
                    final historyReporterDebugHud = asyncSnapshot.data ?? config.historyReporterDebugHud;
                    return SwitchPanelTile(
                      onChanged: (value) => config.setHistoryReporterDebugHud(value),
                      value: historyReporterDebugHud,
                      title: const Text('HistoryReporterDebugHUD'),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
