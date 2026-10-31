import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/dependencies.dart';
import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/l10n/generated/app_localizations.dart';
import 'package:better_bilibili/routing/router.dart';
import 'package:better_bilibili/routing/deep_link_handler.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/app/app_title_bar.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/appearance/appearance_manager.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_media_session/flutter_media_session.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:media_kit/media_kit.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:logger/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  Logger.level = .all;

  // debugRepaintRainbowEnabled = true;

  final configDir = await getApplicationSupportDirectory();
  await Hive.initFlutter(configDir.absolute.path);

  final packageInfo = await PackageInfo.fromPlatform();

  final appConfig = AppConfig(
    appName: packageInfo.appName,
    appPackageName: packageInfo.packageName,
    appVersion: packageInfo.version,
    appBuildNumber: packageInfo.buildNumber,
  );
  final accountConfig = AccountConfig();
  final playerConfig = PlayerConfig();
  final danmakuConfig = DanmakuConfig();
  final bsbsbConfig = BsbsbConfig();
  final eagleConfig = EagleConfig();
  await Future.wait([
    appConfig.init,
    accountConfig.init,
    playerConfig.init,
    danmakuConfig.init,
    bsbsbConfig.init,
    eagleConfig.init,
  ]);

  if (Platform.isWindows) {
    await FlutterMediaSession().setWindowsAppUserModelId('SmallZombie.BetterBilibili');

    await windowManager.ensureInitialized();
    final windowOptions = WindowOptions(
      size: Size(1635, 920),
      minimumSize: Size(kMinWindowWidth, kMinWindowHeight),
      center: true,
      titleBarStyle: .hidden,
      windowButtonVisibility: false,
      title: appConfig.appName,
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
        ChangeNotifierProvider(create: (_) => appearanceManager),
        Provider(
          create: (_) => appConfig,
          dispose: (_, value) => value.dispose(),
        ),
        Provider.value(value: accountConfig),
        Provider(
          create: (_) => playerConfig,
          dispose: (_, value) => value.dispose(),
        ),
        Provider(
          create: (_) => danmakuConfig,
          dispose: (_, value) => value.dispose(),
        ),
        Provider(
          create: (_) => bsbsbConfig,
          dispose: (_, value) => value.dispose(),
        ),
        Provider(
          create: (_) => eagleConfig,
          dispose: (_, value) => value.dispose(),
        ),
        ...onlineProviders,
        ...mockProviders,
        ...generalProviders,
      ],
      child: App(config: appConfig),
    ),
  );
}

class App extends StatefulWidget {
  final AppConfig config;

  const App({required this.config, super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'App'));

  late final StreamSubscription _subscription;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final appLinks = AppLinks();
    _subscription = appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;

      final cleanUri = deepLinkHandler(uri.toString());
      _log.i('onAppLink: "$uri" -> "$cleanUri');

      if (cleanUri == Routes.home) {
        while (router.canPop()) {
          router.pop();
        }
      } else {
        router.push(cleanUri);
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appearanceManager = context.watch<AppearanceManager>();
    return MaterialApp.router(
      title: widget.config.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: appearanceManager.lightTheme,
      darkTheme: appearanceManager.darkTheme,
      themeMode: appearanceManager.themeMode,
      localizationsDelegates: [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
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
            if (showTitleBar) AppTitleBar(config: widget.config),
            Expanded(child: child ?? const SizedBox.shrink()),
          ],
        );
      },
    );
  }
}
