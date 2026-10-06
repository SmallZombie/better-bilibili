import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_section_title.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/switch_panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/settings/settings_fallback_codec_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/settings/settings_preferred_codec_panel.dart';
import 'package:better_bilibili/ui/core/share/config_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SettingsPanel implements Panel {
  final PanelController controller;
  final PlayerConfig config;

  const SettingsPanel({required this.controller, required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: Text('设置'), onBack: controller.pop),
        Expanded(
          child: ListView(
            children: [
              ConfigBuilder(
                configItem: config.autoPlay,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.autoPlay.set,
                  value: value,
                  title: const Text('自动播放'),
                ),
              ),
              ConfigBuilder(
                configItem: config.loopPlayback,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.loopPlayback.set,
                  value: value,
                  title: const Text('循环播放'),
                ),
              ),
              ConfigBuilder(
                configItem: config.ambientLight,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.ambientLight.set,
                  value: value,
                  title: const Text('氛围光效'),
                  subtitle: const Text('仅在深色模式下生效'),
                ),
              ),
              // 响度均衡之死见 README.md
              // ConfigBuilder(
              // configItem   stream: config.loudnessNormalization,
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
              ConfigBuilder(
                configItem: config.heatWaveforms,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.heatWaveforms.set,
                  value: value,
                  title: const Text('热度波形图'),
                  subtitle: const Text('显示一个代表互动热度的波形图，不支持部分视频'),
                ),
              ),

              PanelSectionTitle(title: '连续播放'),
              ConfigBuilder(
                configItem: config.autoPlayNextEpisode,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.autoPlayNextEpisode.set,
                  value: value,
                  title: const Text('连续播放剧集'),
                ),
              ),
              ConfigBuilder(
                configItem: config.autoPlayNextPlaylist,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.autoPlayNextPlaylist.set,
                  value: value,
                  title: const Text('连续播放列表'),
                ),
              ),
              ConfigBuilder(
                configItem: config.autoPlayNextCollection,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.autoPlayNextCollection.set,
                  value: value,
                  title: const Text('连续播放合集'),
                ),
              ),
              ConfigBuilder(
                configItem: config.autoPlayNextRecommend,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.autoPlayNextRecommend.set,
                  value: value,
                  title: const Text('连续播放推荐'),
                ),
              ),

              PanelSectionTitle(title: '编解码'),
              ConfigBuilder(
                configItem: config.preferredCodec,
                builder: (context, value) => PanelTile(
                  onTap: () => controller.push(
                    SettingsPreferredCodecPanel(
                      controller: controller,
                      config: config,
                    ),
                  ),
                  title: const Text('首选编码格式'),
                  subtitle: Text(value.toString()),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_outlined,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ),
              ConfigBuilder(
                configItem: config.fallbackCodec,
                builder: (context, value) => PanelTile(
                  onTap: () => controller.push(
                    SettingsFallbackCodecPanel(
                      controller: controller,
                      config: config,
                    ),
                  ),
                  title: const Text('备选编码格式'),
                  subtitle: Text(value.toString()),
                  trailing: Icon(
                    Icons.keyboard_arrow_right_outlined,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
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
              ConfigBuilder(
                configItem: config.mediaControl,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.mediaControl.set,
                  value: value,
                  title: const Text('启用媒体控制'),
                  subtitle: const Text('允许通过系统媒体控件控制播放，并显示当前播放信息'),
                ),
              ),
              ConfigBuilder(
                configItem: config.hideMediaControlInfo,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.hideMediaControlInfo.set,
                  value: value,
                  title: const Text('隐藏信息'),
                  subtitle: const Text('即便使用媒体控制，也始终隐藏播放信息'),
                ),
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
                ConfigBuilder(
                  configItem: config.historyReporterDebugHud,
                  builder: (context, value) => SwitchPanelTile(
                    onChanged: config.historyReporterDebugHud.set,
                    value: value,
                    title: const Text('HistoryReporterDebugHUD'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get id => 'settings';

  @override
  double get width => 310;
}
