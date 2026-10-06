import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/config/dependencies.dart';
import 'package:better_bilibili/l10n/generated/app_localizations.dart';
import 'package:better_bilibili/routing/router.dart';
import 'package:better_bilibili/routing/scheme_parser.dart';
import 'package:better_bilibili/ui/core/app/app_title_bar.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/appearance/appearance_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_media_session/flutter_media_session.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart' as new_logger;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  new_logger.Logger.level = new_logger.Level.all;

  // debugRepaintRainbowEnabled = true;

  if (Platform.isWindows) {
    // https://github.com/wyrindev/flutter-media-session/blob/main/doc/windows_setup.md#the-challenge
    if (kDebugMode) {
      await FlutterMediaSession().setWindowsAppUserModelId(
        kAppId,
        displayName: kAppName,
      );
    }

    await windowManager.ensureInitialized();
    const windowOptions = WindowOptions(
      size: Size(1635, 920),
      center: true,
      titleBarStyle: TitleBarStyle.hidden,
      windowButtonVisibility: false,
      title: kDebugMode ? '$kAppName (Debug mode)' : kAppName,
    );
    await windowManager.waitUntilReadyToShow(windowOptions);
    await windowManager.show();
    await windowManager.focus();
  }

  final appearanceManager = AppearanceManager();
  await appearanceManager.tryUpdateThemeWithDynamicColor();

  runApp(
    MultiProvider(
      providers: [
        ...providersOnline,
        ChangeNotifierProvider(create: (_) => appearanceManager),
      ],
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
    final appearanceManager = context.watch<AppearanceManager>();
    return MaterialApp.router(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: appearanceManager.lightTheme,
      darkTheme: appearanceManager.darkTheme,
      themeMode: appearanceManager.themeMode,
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

        final showTitleBar = context.select<AppController, bool>(
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
  }
}
