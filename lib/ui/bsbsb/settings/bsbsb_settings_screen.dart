import 'dart:async';

import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/l10n/l10n_util.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/bsbsb/settings/bsbsb_settings_view_model.dart';
import 'package:better_bilibili/ui/core/share/color_picker.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/prompt_dialog.dart';
import 'package:better_bilibili/ui/core/share/selector_dialog.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_info_box.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_switch.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:better_bilibili/ui/core/share/simple_dialog.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/hex_color.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class BsbsbSettingsScreen extends StatefulWidget {
  final BsbsbSettingsViewModel viewModel;

  const BsbsbSettingsScreen({super.key, required this.viewModel});

  @override
  State<BsbsbSettingsScreen> createState() => _BsbsbSettingsScreenState();
}

class _BsbsbSettingsScreenState extends State<BsbsbSettingsScreen> {
  BsbsbSettingsViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.loadData.addListener(_onResult);
    viewModel.getMyLeaderboardRank.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.loadData.removeListener(_onResult);
    viewModel.getMyLeaderboardRank.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.loadData.completed) {
      viewModel.loadData.clearResult();
      viewModel.getMyLeaderboardRank.execute();
    }
    if (viewModel.loadData.error) {
      context.showError('无法获取个人数据: ${getErrorFromResult(viewModel.loadData.result!)}');
      viewModel.loadData.clearResult();
    }
    if (viewModel.getMyLeaderboardRank.error) {
      context.showError('无法获取个人排行: ${getErrorFromResult(viewModel.getMyLeaderboardRank.result!)}');
      viewModel.getMyLeaderboardRank.clearResult();
    }
  }

  String _getSkipOptionName(SkipOptionsEnum option) => switch (option) {
    .disable => '禁用',
    .showOnly => '仅显示',
    .askOnlyStart || .askOnlyEnd => '仅询问',
    .skipToStart => '跳至开头',
    .skipToEnd => '跳至末尾',
  };

  Future<SkipOptionsEnum?> _selectSkipType({
    bool allowSkipToStart = false,
    bool allowSkipToEnd = false,
    required SkipOptionsEnum initialSelected,
  }) async {
    final result = await context.showSelectorDialog<SkipOptionsEnum>(
      items: [
        SelectorDialogItem(name: _getSkipOptionName(.disable), value: .disable),
        SelectorDialogItem(name: _getSkipOptionName(.showOnly), value: .showOnly),
        if (allowSkipToStart) SelectorDialogItem(name: _getSkipOptionName(.askOnlyStart), value: .askOnlyStart),
        if (allowSkipToEnd) SelectorDialogItem(name: _getSkipOptionName(.askOnlyEnd), value: .askOnlyEnd),
        if (allowSkipToStart) SelectorDialogItem(name: _getSkipOptionName(.skipToStart), value: .skipToStart),
        if (allowSkipToEnd) SelectorDialogItem(name: _getSkipOptionName(.skipToEnd), value: .skipToEnd),
      ],
      initialSelected: initialSelected,
    );

    if (result == null || !mounted) return null;
    return result;
  }

  String _colorToHex(Color color) {
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    return '#${r.toRadixString(16).padLeft(2, '0')}'
        '${g.toRadixString(16).padLeft(2, '0')}'
        '${b.toRadixString(16).padLeft(2, '0')}';
  }

  Future<void> _modifyUsername() async {
    assert(viewModel.userInfo != null);

    await context.showPromptAsync<String>(
      title: '修改用户名',
      initialValue: viewModel.userInfo!.userName,
      onSubmit: (value) async {
        await viewModel.modifyUsername.execute(value);
        switch (viewModel.modifyUsername.result!) {
          case Ok _:
            return null;
          case Error(:final error):
            return error.toString();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('小电视空降助手'),
        bottom: PreferredSize(
          preferredSize: .fromHeight(3),
          child: ListenableBuilder(
            listenable: Listenable.merge([viewModel.loadData, viewModel.getMyLeaderboardRank]),
            builder: (context, child) {
              if (viewModel.loadData.running || viewModel.getMyLeaderboardRank.running) {
                return const LinearProgressIndicator();
              }

              return const SizedBox.shrink();
            },
          ),
        ),
        actions: [
          IconButton(
            onPressed: viewModel.loadData.execute,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 12.0,
          children: [
            SettingGroup(
              align: .center,
              backgroundColor: Colors.transparent,
              children: [
                ImageWapper(
                  image: AssetImage('assets/images/bsbsb/logo.png'),
                  width: 120,
                  aspectRatio: 1,
                ),
                SizedBox(height: 8.0),
                SettingInfoBox(
                  align: .center,
                  title: Text(
                    '小电视空降助手',
                    style: TextStyle(fontSize: 20.0),
                    textAlign: .center,
                  ),
                  content: Text('一款帮你精准空降到广告之后的插件。它可以自动获取并跳过广告赞助片段、开场动画、 一键三连提示等等。所有片段均来自社区标注，您也可以标记并提交自己的片段。'),
                ),
              ],
            ),
            SettingGroup(
              children: [
                StreamBuilder(
                  stream: viewModel.config.enable.stream,
                  initialData: viewModel.config.enable.value,
                  builder: (context, asyncSnapshot) => SettingSwitchTile(
                    title: Text('启用'),
                    subtitle: Text('控制此集成的总开关'),
                    icon: const Icon(Icons.extension_outlined),
                    value: asyncSnapshot.data!,
                    onChanged: viewModel.config.enable.set,
                  ),
                ),
              ],
            ),
            Selector<BsbsbSettingsViewModel, UserInfo?>(
              selector: (context, vm) => vm.userInfo,
              builder: (context, userInfo, _) {
                if (userInfo == null) {
                  return SizedBox.shrink();
                }

                return SettingGroup(
                  title: Text('我'),
                  children: [
                    SettingTile(
                      title: Text('用户名'),
                      subtitle: Text(
                        userInfo.userName,
                        maxLines: 1,
                        overflow: .ellipsis,
                      ),
                      icon: const Icon(Icons.account_circle_outlined),
                      onTap: _modifyUsername,
                    ),
                    Selector<BsbsbSettingsViewModel, int>(
                      selector: (context, vm) => vm.myRank,
                      builder: (context, value, _) => SettingTile(
                        title: Text('贡献排行'),
                        subtitle: Text(value != -1 ? '位列第 $value' : '暂未上榜'),
                        icon: const Icon(Icons.leaderboard_outlined),
                        onTap: () {
                          context.push(Routes.bsbsbLeaderboard);
                        },
                      ),
                    ),
                    SettingTile(
                      title: Text('统计'),
                      subtitle: Text(
                        '您提交了 ${userInfo.segmentCount + userInfo.ignoredSegmentCount} 个片段，累计跳过 0 次，节省时间 0 秒\n全球通过您的片段累计跳过 ${userInfo.viewCount + userInfo.ignoredViewCount} 次，节省时间 ${context.formatCompactNumber(userInfo.minutesSaved.inSeconds)} 秒',
                      ),
                      icon: const Icon(Icons.history),
                    ),
                  ],
                );
              },
            ),
            SettingGroup(
              title: Text('按类型设置'),
              subtitle: Text('在右侧配置这些标记位于时间线中的颜色'),
              bottom: SettingInfoBox(
                content: Text('''
禁用: 不在进度条中显示也不使用跳过
仅显示: 仅在进度条中显示，不使用跳过
仅询问: Better 将在即将到达片段时询问您是否需要应用跳转
跳至开头: Better 将在到达片段时自动跳至片段开头
跳至末尾: Better 将在到达片段时自动跳至片段末尾'''),
              ),
              children: [
                StreamBuilder(
                  stream: viewModel.config.sponsor.stream,
                  initialData: viewModel.config.sponsor.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('商业推广'),
                    subtitle: Text('具有商业合作或付费推广的内容'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.sponsor.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.sponsorColor.stream,
                      initialData: viewModel.config.sponsorColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.sponsorColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.sponsorColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.selfpromo.stream,
                  initialData: viewModel.config.selfpromo.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('无偿/自我推广'),
                    subtitle: Text('无利益关系的推荐与自我推广内容'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.selfpromo.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.selfpromoColor.stream,
                      initialData: viewModel.config.selfpromoColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.selfpromoColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.selfpromoColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.interaction.stream,
                  initialData: viewModel.config.interaction.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('三连/互动提醒'),
                    subtitle: Text('点赞、关注、三连等互动提醒'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.interaction.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.interactionColor.stream,
                      initialData: viewModel.config.interactionColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.interactionColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.interactionColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.pointsOfInterest.stream,
                  initialData: viewModel.config.pointsOfInterest.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('精彩时刻/重点'),
                    subtitle: Text('通常指标题、封面或片头预告中所指部分'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToStart: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.pointsOfInterest.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.pointsOfInterestColor.stream,
                      initialData: viewModel.config.pointsOfInterestColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.pointsOfInterestColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.pointsOfInterestColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.intro.stream,
                  initialData: viewModel.config.intro.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('过场/开场动画'),
                    subtitle: Text('无实际内容的开场与过场，如静帧、直播开始前的等待屏幕、主题式开场、版权或法律免责声明等'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.intro.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.introColor.stream,
                      initialData: viewModel.config.introColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.introColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.introColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.outro.stream,
                  initialData: viewModel.config.outro.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('鸣谢/结束画面'),
                    subtitle: Text('通常指视频结尾的鸣谢与收尾部分，如鸣谢名单、片尾字幕、结束卡片、告别语等'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.outro.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.outroColor.stream,
                      initialData: viewModel.config.outroColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.outroColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.outroColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.preview.stream,
                  initialData: viewModel.config.preview.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('回顾/概要'),
                    subtitle: Text('回顾本系列过去内容或预览后续内容，且不包含新的额外信息'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.preview.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.previewColor.stream,
                      initialData: viewModel.config.previewColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.previewColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.previewColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.padding.stream,
                  initialData: viewModel.config.padding.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('填充内容/黑屏'),
                    subtitle: Text('通常指搬运视频开头/结尾的纯填充内容和无意义黑屏'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.padding.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.paddingColor.stream,
                      initialData: viewModel.config.paddingColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.paddingColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.paddingColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.filler.stream,
                  initialData: viewModel.config.filler.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('离题闲聊/玩笑'),
                    subtitle: Text('与视频主要内容无关的闲聊、玩笑或辅助画面，如B-roll、NG片段、无关慢动作等'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.filler.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.fillerColor.stream,
                      initialData: viewModel.config.fillerColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.fillerColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.fillerColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.musicOfftopic.stream,
                  initialData: viewModel.config.musicOfftopic.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('非音乐部分'),
                    subtitle: Text('以音乐为主的视频中出现的非音乐片段'),
                    trailing: Text(_getSkipOptionName(asyncSnapshot.data!)),
                    onTap: () async {
                      final result = await _selectSkipType(
                        allowSkipToEnd: true,
                        initialSelected: asyncSnapshot.data!,
                      );
                      if (result != null) {
                        viewModel.config.musicOfftopic.set(result);
                      }
                    },
                    action: StreamBuilder(
                      stream: viewModel.config.musicOfftopicColor.stream,
                      initialData: viewModel.config.musicOfftopicColor.value,
                      builder: (context, asyncSnapshot) => _ColorButton(
                        color: HexColor(asyncSnapshot.data!),
                        onTap: () async {
                          final result = await context.showColorPicker(
                            initialColor: HexColor(asyncSnapshot.data!),
                            resetColor: HexColor(viewModel.config.musicOfftopicColor.defaultValue),
                          );
                          if (result != null) {
                            viewModel.config.musicOfftopicColor.set(_colorToHex(result));
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SettingTile(
                  title: Text('重置跳过选项'),
                  subtitle: Text('将所有分类的跳过选项重置为默认值'),
                  onTap: () async {
                    final confirm = await context.showConfirm(
                      title: '重置跳过选项',
                      content: '此操作不可撤销，确定要重置吗？',
                      confirmColor: Colors.red,
                    );
                    if (!confirm) return;

                    viewModel.config.sponsor.set(viewModel.config.sponsor.defaultValue);
                    viewModel.config.selfpromo.set(viewModel.config.selfpromo.defaultValue);
                    viewModel.config.interaction.set(viewModel.config.interaction.defaultValue);
                    viewModel.config.pointsOfInterest.set(viewModel.config.pointsOfInterest.defaultValue);
                    viewModel.config.intro.set(viewModel.config.intro.defaultValue);
                    viewModel.config.outro.set(viewModel.config.outro.defaultValue);
                    viewModel.config.preview.set(viewModel.config.preview.defaultValue);
                    viewModel.config.padding.set(viewModel.config.padding.defaultValue);
                    viewModel.config.filler.set(viewModel.config.filler.defaultValue);
                    viewModel.config.musicOfftopic.set(viewModel.config.musicOfftopic.defaultValue);
                  },
                ),
                SettingTile(
                  title: Text('重置标记颜色'),
                  subtitle: Text('将所有分类的标记颜色重置为默认值'),
                  onTap: () async {
                    final confirm = await context.showConfirm(
                      title: '重置标记颜色',
                      content: '此操作不可撤销，确定要重置吗？',
                      confirmColor: Colors.red,
                    );
                    if (!confirm) return;

                    viewModel.config.sponsorColor.set(viewModel.config.sponsorColor.defaultValue);
                    viewModel.config.selfpromoColor.set(viewModel.config.selfpromoColor.defaultValue);
                    viewModel.config.interactionColor.set(viewModel.config.interactionColor.defaultValue);
                    viewModel.config.pointsOfInterestColor.set(viewModel.config.pointsOfInterestColor.defaultValue);
                    viewModel.config.introColor.set(viewModel.config.introColor.defaultValue);
                    viewModel.config.outroColor.set(viewModel.config.outroColor.defaultValue);
                    viewModel.config.previewColor.set(viewModel.config.previewColor.defaultValue);
                    viewModel.config.paddingColor.set(viewModel.config.paddingColor.defaultValue);
                    viewModel.config.fillerColor.set(viewModel.config.fillerColor.defaultValue);
                    viewModel.config.musicOfftopicColor.set(viewModel.config.musicOfftopicColor.defaultValue);
                  },
                ),
              ],
            ),
            SettingGroup(
              children: [
                StreamBuilder(
                  stream: viewModel.config.allowMutedSegment.stream,
                  initialData: viewModel.config.allowMutedSegment.value,
                  builder: (context, asyncSnapshot) => SettingSwitchTile(
                    title: Text('允许静音片段'),
                    subtitle: Text('当某个片段的音频属于可跳过类别但视频内容包含重要信息时，这些片段会被标记为静音片段，Better 将会在经过这些片段时自动静音'),
                    onChanged: viewModel.config.allowMutedSegment.set,
                    value: asyncSnapshot.data!,
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.showGlobalMark.stream,
                  initialData: viewModel.config.showGlobalMark.value,
                  builder: (context, asyncSnapshot) => SettingSwitchTile(
                    title: Text('显示全局标记'),
                    subtitle: Text('某些视频可能会被整体标记为广告或独家访问/抢鲜体验，Better 将在标题前方显示这些标记'),
                    onChanged: viewModel.config.showGlobalMark.set,
                    value: asyncSnapshot.data!,
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.minSegmentDuration.stream,
                  initialData: viewModel.config.minSegmentDuration.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('最短片段时长'),
                    subtitle: Text('单位秒，低于此值的片段将被禁用'),
                    onTap: () {},
                    action: Text('${asyncSnapshot.data! / 1000}s'),
                  ),
                ),
                StreamBuilder(
                  stream: viewModel.config.whitelist.stream,
                  initialData: viewModel.config.whitelist.value,
                  builder: (context, asyncSnapshot) {
                    final list = asyncSnapshot.data!.split(',');
                    return SettingTile(
                      title: Text('白名单'),
                      subtitle: Text('位于白名单内的用户将获得豁免，届时 Better 将忽略本应询问或跳转的片段'),
                      onTap: () {},
                      action: Text('${list.length}人'),
                    );
                  },
                ),
              ],
            ),
            SettingGroup(
              title: Text('隐私'),
              children: [
                StreamBuilder(
                  stream: viewModel.config.shareMyData.stream,
                  initialData: viewModel.config.shareMyData.value,
                  builder: (context, asyncSnapshot) => SettingSwitchTile(
                    title: Text('共享我的使用情况'),
                    subtitle: Text('与 "小电视空降助手" 共享我跳过的片段，用于帮助提交者了解他们提交的片段帮助了多少人，所有的数据均为匿名提交，它们永远不会关联到您和您的账号'),
                    onChanged: viewModel.config.shareMyData.set,
                    value: asyncSnapshot.data!,
                  ),
                ),
              ],
            ),
            SettingGroup(
              title: Text('高级'),
              children: [
                StreamBuilder(
                  stream: widget.viewModel.config.privateId.stream,
                  initialData: widget.viewModel.config.privateId.value,
                  builder: (context, asyncSnapshot) {
                    return SettingTile(
                      title: Text('私人ID'),
                      subtitle: Text('请勿泄露此ID，点按查看或修改'),
                      onTap: () async {
                        final confirm = await context.showConfirm(
                          title: '修改私人ID',
                          content: '更改私人ID后，您将无法访问使用旧私人ID提交的内容。请确保新的私人ID不会被他人轻易猜到或获取。\n\n私人ID相当于您的鉴权凭证，一旦泄露，他人将获得您在 "小电视空降助手" 服务下的全部权限。',
                          confirmColor: Colors.red,
                          confirmText: '我知道我在做什么',
                        );
                        if (!confirm || !context.mounted) return;

                        final input = await context.showPrompt<String>(title: '修改私人ID', initialValue: asyncSnapshot.data);
                        if (input == null || !context.mounted) return;

                        await viewModel.config.privateId.set(input);
                        if (!context.mounted) return;

                        unawaited(viewModel.loadData.execute());
                      },
                    );
                  },
                ),
                StreamBuilder(
                  stream: viewModel.config.baseUrls.stream,
                  initialData: viewModel.config.baseUrls.value,
                  builder: (context, asyncSnapshot) => SettingTile(
                    title: Text('服务器地址'),
                    subtitle: Text(asyncSnapshot.data!),
                    action: IconButton(
                      onPressed: () async {
                        final confirm = await context.showConfirm(
                          title: '重置为默认值',
                          content: '确定要将服务器地址重置为默认值吗？',
                          confirmColor: Colors.red,
                        );
                        if (!confirm || !context.mounted) return;

                        viewModel.config.baseUrls.set(viewModel.config.baseUrls.defaultValue);
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: '重置为默认值',
                    ),
                    onTap: () async {
                      final input = await context.showPrompt(
                        title: '服务器地址',
                        description: '多个地址之间使用 "," 分割',
                        initialValue: asyncSnapshot.data,
                      );
                      if (input == null || !mounted) return;

                      viewModel.config.baseUrls.set(input);
                    },
                  ),
                ),
              ],
            ),
            SettingGroup(
              children: [
                SettingTile(
                  title: Text('主页'),
                  subtitle: Text('前往此项目的主页'),
                  icon: const Icon(Icons.home_outlined),
                  onTap: () {
                    context.openUrl('https://www.bsbsb.top/');
                  },
                ),
                SettingTile(
                  title: Text('源代码'),
                  subtitle: Text('前往此项目的源代码仓库'),
                  icon: const Icon(Icons.info_outline),
                  onTap: () {
                    context.openUrl('https://github.com/hanydd/BilibiliSponsorBlock');
                  },
                ),
                SettingTile(
                  title: Text('服务器状态'),
                  icon: const Icon(Icons.trending_up),
                  onTap: () {
                    context.openUrl('https://status.bsbsb.top/');
                  },
                ),
              ],
            ),
            SizedBox(height: 64.0),
          ],
        ),
      ),
    );
  }
}

class _ColorButton extends StatelessWidget {
  final Color color;
  final VoidCallback? onTap;

  const _ColorButton({required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.0,
        height: 30.0,
        decoration: BoxDecoration(
          borderRadius: .circular(999),
          border: .all(color: Colors.white),
          color: color,
        ),
      ),
    );
  }
}
