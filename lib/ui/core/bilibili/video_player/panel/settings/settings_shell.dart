import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/settings_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/share/panel_header.dart';
import 'package:flutter/material.dart';

enum SettingsRoute {
  home,
  preferredCodec,
  fallbackCodec,
  loudnessNormalization,
}

class SettingsShell extends StatefulWidget {
  final PlayerConfig playerConfig;
  final VoidCallback? onBack;

  const SettingsShell({
    super.key,
    required this.playerConfig,
    this.onBack,
  });

  @override
  State<SettingsShell> createState() => _SettingsShellState();
}

class _SettingsShellState extends State<SettingsShell> {
  SettingsRoute _route = SettingsRoute.home;

  void _go(SettingsRoute route) {
    setState(() => _route = route);
  }

  void _backToHome() {
    if (_route == SettingsRoute.home) {
      widget.onBack?.call();
      return;
    }

    setState(() => _route = SettingsRoute.home);
  }

  @override
  Widget build(BuildContext context) {
    final child = switch (_route) {
      SettingsRoute.home => SettingsPanel(
        key: const ValueKey(SettingsRoute.home),
        config: widget.playerConfig,
        onBack: widget.onBack,
        onTapPreferredCodec: () => _go(SettingsRoute.preferredCodec),
        onTapFallbackCodec: () => _go(SettingsRoute.fallbackCodec),
        onTapLoudnessNormalization: () => _go(SettingsRoute.loudnessNormalization),
      ),
      SettingsRoute.preferredCodec => StreamBuilder(
        stream: widget.playerConfig.stream.preferredCodec,
        initialData: widget.playerConfig.preferredCodec,
        builder: (context, asyncSnapshot) {
          final preferredCodec = asyncSnapshot.data!;
          return SelectionPanel(
            key: const ValueKey(SettingsRoute.preferredCodec),
            header: PanelHeader(title: const Text('选择编码'), onBack: _backToHome),
            items: CodecEnum.values.map((v) => SelectionPanelItem(label: v.value, value: v)).toList(),
            value: preferredCodec,
            onChange: widget.playerConfig.setPreferredCodec,
          );
        },
      ),
      SettingsRoute.fallbackCodec => StreamBuilder(
        stream: widget.playerConfig.stream.fallbackCodec,
        initialData: widget.playerConfig.fallbackCodec,
        builder: (context, asyncSnapshot) {
          final fallbackCodec = asyncSnapshot.data!;
          return SelectionPanel(
            key: const ValueKey(SettingsRoute.fallbackCodec),
            header: PanelHeader(title: const Text('选择编码'), onBack: _backToHome),
            items: CodecEnum.values.map((v) => SelectionPanelItem(label: v.value, value: v)).toList(),
            value: fallbackCodec,
            onChange: widget.playerConfig.setFallbackCodec,
          );
        },
      ),
      SettingsRoute.loudnessNormalization => StreamBuilder(
        stream: widget.playerConfig.stream.loudnessNormalization,
        initialData: widget.playerConfig.loudnessNormalization,
        builder: (context, asyncSnapshot) {
          final value = asyncSnapshot.data!;
          return SelectionPanel(
            key: const ValueKey(SettingsRoute.loudnessNormalization),
            header: PanelHeader(title: const Text('响度均衡'), onBack: _backToHome),
            items: LoudnessNormalizationModeEnum.values.map((v) {
              return SelectionPanelItem(
                label: switch (v) {
                  .off => '关闭',
                  .normal => '普通',
                  .highDynamic => '高动态',
                },
                value: v,
              );
            }).toList(),
            value: value,
            onChange: widget.playerConfig.setLoudnessNormalization,
          );
        },
      ),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) {
        final offset =
            Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

        return SlideTransition(
          position: offset,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: child,
    );
  }
}
