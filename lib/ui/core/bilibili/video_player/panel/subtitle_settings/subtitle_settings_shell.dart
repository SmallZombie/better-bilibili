import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_selection_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/video_player/panel/subtitle_settings/subtitle_settings_panel.dart';
import 'package:flutter/material.dart';

const homeRoute = '/';
const selectPrimarySubtitleRoute = '/select_primary_subtitle';
const selectSecondarySubtitleRoute = '/select_secondary_subtitle';

class SubtitleSettingsShell extends StatefulWidget {
  final VoidCallback? onBack;

  const SubtitleSettingsShell({super.key, this.onBack});

  @override
  State<SubtitleSettingsShell> createState() => _SubtitleSettingsShellState();
}

class _SubtitleSettingsShellState extends State<SubtitleSettingsShell> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navigatorKey,
      initialRoute: homeRoute,
      onGenerateRoute: (settings) {
        final Widget child;

        switch (settings.name) {
          case homeRoute:
            child = SubtitleSettingsPanel(
              onBack: widget.onBack,
            );
          case selectPrimarySubtitleRoute:
            child = SubtitleSelectionPanel(
              onBack: () => _navigatorKey.currentState?.pop(),
            );
          case selectSecondarySubtitleRoute:
            child = SubtitleSelectionPanel(
              onBack: () => _navigatorKey.currentState?.pop(),
            );
          default:
            child = const SizedBox.shrink();
        }

        return PageRouteBuilder<void>(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final offsetAnimation =
                Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: .zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                    reverseCurve: Curves.easeInCubic,
                  ),
                );

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
      },
    );
  }
}
