import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_section_title.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/slider_panel_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/switch_panel_tile.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DanmakuSettingsPanel extends StatelessWidget {
  final DanmakuConfig config;
  final VoidCallback? onBack;

  const DanmakuSettingsPanel({super.key, this.onBack, required this.config});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        PanelHeader(title: Text('弹幕设置'), onBack: onBack),
        Expanded(
          child: ListView(
            children: [
              StreamBuilder<bool>(
                stream: config.stream.enabled,
                initialData: config.enabled,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setEnabled,
                  value: snapshot.data ?? config.enabled,
                  title: const Text('启用弹幕'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.showScroll,
                initialData: config.showScroll,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setShowScroll,
                  value: snapshot.data ?? config.showScroll,
                  title: const Text('自右向左滚动弹幕'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.showScroll,
                initialData: config.showScroll,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setShowScroll,
                  value: snapshot.data ?? config.showScroll,
                  title: const Text('自左向右滚动弹幕'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.showTop,
                initialData: config.showTop,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setShowTop,
                  value: snapshot.data ?? config.showTop,
                  title: const Text('顶部弹幕'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.showBottom,
                initialData: config.showBottom,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setShowBottom,
                  value: snapshot.data ?? config.showBottom,
                  title: const Text('底部弹幕'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.showAdvanced,
                initialData: config.showAdvanced,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setShowAdvanced,
                  value: snapshot.data ?? config.showAdvanced,
                  title: const Text('高级弹幕'),
                ),
              ),

              const PanelSectionTitle(title: '显示设置'),
              StreamBuilder<double>(
                stream: config.stream.displayArea,
                initialData: config.displayArea,
                builder: (context, snapshot) {
                  final displayArea = snapshot.data ?? config.displayArea;
                  final displayText = NumberFormat.percentPattern().format(displayArea);
                  return SliderPanelTile(
                    title: const Text('滚动弹幕区域'),
                    subtitle: Text(displayText),
                    value: displayArea,
                    min: 0.1,
                    max: 1,
                    divisions: 9,
                    onChanged: config.setDisplayArea,
                  );
                },
              ),
              StreamBuilder<double>(
                stream: config.stream.fixedDisplayArea,
                initialData: config.fixedDisplayArea,
                builder: (context, snapshot) {
                  final fixedDisplayArea = snapshot.data ?? config.fixedDisplayArea;
                  final displayText = NumberFormat.percentPattern().format(fixedDisplayArea);
                  return SliderPanelTile(
                    title: const Text('固定弹幕区域'),
                    subtitle: Text(displayText),
                    value: fixedDisplayArea,
                    min: 0.1,
                    max: 1,
                    divisions: 9,
                    onChanged: config.setFixedDisplayArea,
                  );
                },
              ),
              StreamBuilder<double>(
                stream: config.stream.opacity,
                initialData: config.opacity,
                builder: (context, snapshot) {
                  final opacity = snapshot.data ?? config.opacity;
                  final displayText = NumberFormat.percentPattern().format(opacity);
                  return SliderPanelTile(
                    title: const Text('透明度'),
                    subtitle: Text(displayText),
                    value: opacity,
                    min: 0.1,
                    max: 1,
                    onChanged: config.setOpacity,
                  );
                },
              ),
              StreamBuilder<double>(
                stream: config.stream.fontSize,
                initialData: config.fontSize,
                builder: (context, snapshot) {
                  final fontSize = snapshot.data ?? config.fontSize;
                  final displayText = NumberFormat.percentPattern().format(fontSize);
                  return SliderPanelTile(
                    title: const Text('文字大小'),
                    subtitle: Text(displayText),
                    value: fontSize,
                    min: 0.1,
                    max: 1,
                    onChanged: config.setFontSize,
                  );
                },
              ),
              StreamBuilder<double>(
                stream: config.stream.scrollSpeed,
                initialData: config.scrollSpeed,
                builder: (context, snapshot) {
                  final scrollSpeed = snapshot.data ?? config.scrollSpeed;
                  final displayText = NumberFormat.percentPattern().format(scrollSpeed);
                  return SliderPanelTile(
                    title: const Text('滚动速度'),
                    subtitle: Text(displayText),
                    value: scrollSpeed,
                    min: 0.25,
                    max: 2,
                    divisions: 7,
                    onChanged: config.setScrollSpeed,
                  );
                },
              ),
              StreamBuilder<bool>(
                stream: config.stream.syncPlaybackRate,
                initialData: config.syncPlaybackRate,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setSyncPlaybackRate,
                  value: snapshot.data ?? config.syncPlaybackRate,
                  title: const Text('同步播放速度'),
                  subtitle: const Text('与视频同步加减速'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.antiOcclusion,
                initialData: config.antiOcclusion,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setAntiOcclusion,
                  value: snapshot.data ?? config.antiOcclusion,
                  title: const Text('防止遮挡'),
                  subtitle: const Text('弹幕将尝试显示在人物等关键内容后方'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.carnivalMode,
                initialData: config.carnivalMode,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setCarnivalMode,
                  value: snapshot.data ?? config.carnivalMode,
                  title: const Text('狂欢模式'),
                  subtitle: const Text('所有弹幕忽略遮挡全量展示'),
                ),
              ),
              StreamBuilder<bool>(
                stream: config.stream.duplicateMerge,
                initialData: config.duplicateMerge,
                builder: (context, snapshot) => SwitchPanelTile(
                  onChanged: config.setDuplicateMerge,
                  value: snapshot.data ?? config.duplicateMerge,
                  title: const Text('重复合并'),
                  subtitle: const Text('以计数器形式展示重复过多的弹幕'),
                ),
              ),

              PanelSectionTitle(title: '屏蔽设置'),
              PanelTile(
                title: Text('全局弹幕过滤器'),
                subtitle: Text('前往设置'),
                trailing: const Icon(Icons.keyboard_arrow_right_outlined),
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
}
