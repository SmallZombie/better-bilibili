import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/codec_selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/settings/settings_panel.dart';
import 'package:flutter/material.dart';

enum SettingsRoute {
  home,
  preferredCodec,
  fallbackCodec,
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
        onSelectPreferredCodec: () => _go(SettingsRoute.preferredCodec),
        onSelectFallbackCodec: () => _go(SettingsRoute.fallbackCodec),
      ),
      SettingsRoute.preferredCodec => CodecSelectionPanel(
        key: const ValueKey(SettingsRoute.preferredCodec),
        onBack: _backToHome,
      ),
      SettingsRoute.fallbackCodec => CodecSelectionPanel(
        key: const ValueKey(SettingsRoute.fallbackCodec),
        onBack: _backToHome,
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
