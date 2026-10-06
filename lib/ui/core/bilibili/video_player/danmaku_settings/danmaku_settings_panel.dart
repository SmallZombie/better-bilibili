import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_section_title.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/slider_panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/switch_panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/panel_controller.dart';
import 'package:better_bilibili/ui/core/share/config_builder.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DanmakuSettingsPanel implements Panel {
  final PanelController controller;
  final DanmakuConfig config;

  const DanmakuSettingsPanel({required this.controller, required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: Text('弹幕设置'), onBack: controller.pop),
        Expanded(
          child: ListView(
            children: [
              ConfigBuilder(
                configItem: config.enabled,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.enabled.set,
                  value: value,
                  title: const Text('启用弹幕'),
                ),
              ),
              ConfigBuilder(
                configItem: config.showScroll,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.showScroll.set,
                  value: value,
                  title: const Text('自右向左弹幕'),
                ),
              ),
              ConfigBuilder(
                configItem: config.showScroll,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.showScroll.set,
                  value: value,
                  title: const Text('自左向右弹幕'),
                ),
              ),
              ConfigBuilder(
                configItem: config.showTop,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.showTop.set,
                  value: value,
                  title: const Text('顶部弹幕'),
                ),
              ),
              ConfigBuilder(
                configItem: config.showBottom,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.showBottom.set,
                  value: value,
                  title: const Text('底部弹幕'),
                ),
              ),
              ConfigBuilder(
                configItem: config.showAdvanced,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.showAdvanced.set,
                  value: value,
                  title: const Text('高级弹幕'),
                ),
              ),

              const PanelSectionTitle(title: '显示设置'),
              ConfigBuilder(
                configItem: config.displayArea,
                builder: (context, value) {
                  final displayText = NumberFormat.percentPattern().format(value);
                  return SliderPanelTile(
                    title: const Text('滚动弹幕区域'),
                    subtitle: Text(displayText),
                    value: value,
                    min: 0.1,
                    max: 1,
                    divisions: 9,
                    onChanged: config.displayArea.set,
                  );
                },
              ),
              ConfigBuilder(
                configItem: config.fixedDisplayArea,
                builder: (context, value) {
                  final displayText = NumberFormat.percentPattern().format(value);
                  return SliderPanelTile(
                    title: const Text('固定弹幕区域'),
                    subtitle: Text(displayText),
                    value: value,
                    min: 0.1,
                    max: 1,
                    divisions: 9,
                    onChanged: config.fixedDisplayArea.set,
                  );
                },
              ),
              ConfigBuilder(
                configItem: config.opacity,
                builder: (context, value) {
                  final displayText = NumberFormat.percentPattern().format(value);
                  return SliderPanelTile(
                    title: const Text('透明度'),
                    subtitle: Text(displayText),
                    value: value,
                    min: 0.1,
                    max: 1,
                    onChanged: config.opacity.set,
                  );
                },
              ),
              ConfigBuilder(
                configItem: config.fontSize,
                builder: (context, value) {
                  final displayText = NumberFormat.percentPattern().format(value);
                  return SliderPanelTile(
                    title: const Text('文字大小'),
                    subtitle: Text(displayText),
                    value: value,
                    min: 0.1,
                    max: 1,
                    onChanged: config.fontSize.set,
                  );
                },
              ),
              ConfigBuilder(
                configItem: config.scrollSpeed,
                builder: (context, value) {
                  final displayText = NumberFormat.percentPattern().format(value);
                  return SliderPanelTile(
                    title: const Text('滚动速度'),
                    subtitle: Text(displayText),
                    value: value,
                    min: 0.25,
                    max: 2,
                    divisions: 7,
                    onChanged: config.scrollSpeed.set,
                  );
                },
              ),
              ConfigBuilder(
                configItem: config.syncPlaybackRate,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.syncPlaybackRate.set,
                  value: value,
                  title: const Text('同步播放速度'),
                  subtitle: const Text('与视频同步加减速'),
                ),
              ),
              ConfigBuilder(
                configItem: config.antiOcclusion,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.antiOcclusion.set,
                  value: value,
                  title: const Text('防止遮挡'),
                  subtitle: const Text('弹幕将尝试显示在人物等关键内容后方'),
                ),
              ),
              ConfigBuilder(
                configItem: config.carnivalMode,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.carnivalMode.set,
                  value: value,
                  title: const Text('狂欢模式'),
                  subtitle: const Text('所有弹幕忽略遮挡全量展示'),
                ),
              ),
              ConfigBuilder(
                configItem: config.duplicateMerge,
                builder: (context, value) => SwitchPanelTile(
                  onChanged: config.duplicateMerge.set,
                  value: value,
                  title: const Text('重复合并'),
                  subtitle: const Text('以计数器形式展示重复过多的弹幕'),
                ),
              ),

              PanelSectionTitle(title: '屏蔽设置'),
              PanelTile(
                title: Text('全局弹幕过滤器'),
                subtitle: Text('前往设置'),
                trailing: Icon(
                  Icons.keyboard_arrow_right_outlined,
                  color: Colors.white.withAlpha(200),
                ),
                onTap: () => {},
              ),
              // const SizedBox(height: 16.0),
              // const Padding(
              //   padding: .symmetric(horizontal: 16.0),
              //   child: Text('显示效果'),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              //   child: Column(
              //     children: [
              //       Row(
              //         children: [
              //           Expanded(child: Text('透明度 ${viewModel.opacity.toStringAsFixed(2)}')),
              //           Expanded(
              //             child: Slider(
              //               value: viewModel.opacity,
              //               onChanged: (value) => viewModel.opacity = value,
              //               min: 0.2,
              //               max: 1.0,
              //             ),
              //           ),
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           Expanded(child: Text('密度 ${viewModel.density.toStringAsFixed(2)}x')),
              //           Expanded(
              //             child: Slider(
              //               value: viewModel.density,
              //               onChanged: (value) => viewModel.density = value,
              //               min: 0.2,
              //               max: 2.0,
              //             ),
              //           ),
              //         ],
              //       ),
              //       Row(
              //         children: [
              //           Expanded(child: Text('速度 ${viewModel.speed.toStringAsFixed(2)}x')),
              //           Expanded(
              //             child: Slider(
              //               value: viewModel.speed,
              //               onChanged: (value) => viewModel.speed = value,
              //               min: 0.5,
              //               max: 3.0,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ],
              //   ),
              // ),
              // const SizedBox(height: 16.0),
              // const Padding(
              //   padding: .symmetric(horizontal: 16.0),
              //   child: Text('按类型屏蔽'),
              // ),
              // SizedBox(
              //   height: kMinInteractiveDimension,
              //   child: ScrollConfiguration(
              //     behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {.mouse, .touch}),
              //     child: ListView(
              //       scrollDirection: .horizontal,
              //       padding: const .symmetric(horizontal: 16.0),
              //       children: [
              //         ChoiceChip(
              //           onSelected: (_) => viewModel.toggleBlockedType('顶部'),
              //           selected: viewModel.blockedTypes.contains('顶部'),
              //           label: const Text('顶部'),
              //         ),
              //         ChoiceChip(
              //           onSelected: (_) => viewModel.toggleBlockedType('底部'),
              //           selected: viewModel.blockedTypes.contains('底部'),
              //           label: const Text('底部'),
              //         ),
              //         ChoiceChip(
              //           onSelected: (_) => viewModel.toggleBlockedType('滚动'),
              //           selected: viewModel.blockedTypes.contains('滚动'),
              //           label: const Text('滚动'),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              // const SizedBox(height: 16.0),
              // const Padding(
              //   padding: .symmetric(horizontal: 16.0),
              //   child: Text('按云控等级屏蔽'),
              // ),
              // SizedBox(
              //   height: kMinInteractiveDimension,
              //   child: RangeSlider(
              //     values: viewModel.cloudLevel,
              //     onChanged: (value) => viewModel.cloudLevel = value,
              //     divisions: 12,
              //     labels: RangeLabels(viewModel.cloudLevel.start.toStringAsFixed(0), viewModel.cloudLevel.end.toStringAsFixed(0)),
              //     min: 0.0,
              //     max: 12.0,
              //   ),
              // ),
              // SwitchListTile(
              //   onChanged: (value) => viewModel.maskTask = value,
              //   value: viewModel.maskTask,
              //   dense: true,
              //   title: const Text('任务遮罩'),
              //   subtitle: const Text('启用后，弹幕会尝试避开人像部分'),
              // ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  String get id => 'danmaku_settings';

  @override
  double get width => 310;
}
