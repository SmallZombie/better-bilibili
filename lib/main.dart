import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:better_bilibili/config/dependencies.dart';
import 'package:better_bilibili/l10n/generated/app_localizations.dart';
import 'package:better_bilibili/routing/router.dart';
import 'package:better_bilibili/routing/scheme_parser.dart';
import 'package:better_bilibili/ui/core/app_shell/app_title_bar.dart';
import 'package:better_bilibili/ui/core/app_shell/app_title_bar_controller.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logging/logging.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart' as new_logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  Logger.root.level = Level.ALL;
  new_logger.Logger.level = new_logger.Level.all;

  // debugRepaintRainbowEnabled = true;

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1635, 920),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
    await windowManager.focus();
  }

  runApp(
    MultiProvider(
      providers: providersOnline,
      child: const App(),
    ),
  );
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appLinks = AppLinks();
      appLinks.uriLinkStream.listen((uri) {
        debugPrint('appLinks: $uri');
        router.push(schemeParser(uri.toString()));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightColorScheme = lightDynamic?.harmonized() ?? .fromSeed(seedColor: Colors.pinkAccent);
        final darkColorScheme = darkDynamic?.harmonized() ?? .fromSeed(seedColor: Colors.pinkAccent, brightness: .dark);

        return MaterialApp.router(
          title: 'Better Bilibili',
          debugShowCheckedModeBanner: false,
          routerConfig: router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            fontFamily: Platform.isWindows ? 'HarmonyOS_Sans' : null,
            chipTheme: ChipThemeData(
              backgroundColor: lightColorScheme.surfaceContainerHigh,
              side: BorderSide.none,
              shadowColor: Colors.black.withAlpha(150),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            fontFamily: Platform.isWindows ? 'HarmonyOS_Sans' : null,
            chipTheme: ChipThemeData(
              backgroundColor: darkColorScheme.surfaceContainerHigh,
              side: BorderSide.none,
              shadowColor: Colors.black.withAlpha(150),
            ),
          ),
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            if (!Platform.isWindows) {
              return child ?? const SizedBox.shrink();
            }

            final showTitleBar = context.select<AppTitleBarController, bool>(
              (state) => state.showTitleBar,
            );

            return Column(
              children: [
                if (showTitleBar) const AppTitleBar(),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            );
          },
        );
      },
    );
  }
}
