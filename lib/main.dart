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
import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/routing/router.dart';
import 'package:better_bilibili/routing/deep_link_handler.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/app/app_title_bar.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/appearance/appearance_manager.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
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
    appPrerelease: String.fromEnvironment('APP_PRERELEASE'),
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

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => _setupDeepLinkListener());
    _subscriptions.add(appRouteObserver.events.listen(_onRouteEvent));
  }

  @override
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();

    super.dispose();
  }

  void _setupDeepLinkListener() {
    final appLinks = AppLinks();
    _subscriptions.add(
      appLinks.uriLinkStream.listen((uri) {
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
      }),
    );
  }

  final List<String> _forwardHistory = [];

  void _tryBack() {
    _log.i('tryBack: canPop=${router.canPop()}, uri=${router.state.uri.toString()}');
    if (router.canPop()) {
      router.pop();
    }
  }

  void _tryForward() {
    _log.i('tryForward: _backHistory.length=${_forwardHistory.length}, last=${_forwardHistory.lastOrNull}');
    if (_forwardHistory.isNotEmpty) {
      router.push(_forwardHistory.last);
    }
  }

  void _onRouteEvent(AppRouteEvent event) {
    if (event is AppRoutePushEvent) {
      _log.i('onRouteEvent: AppRoutePushEvent: $event');

      final name = event.route.settings.name;
      if (name == null) return;

      final path = _getFullPath(name, event.route.settings.arguments as Map<String, dynamic>?);

      if (_forwardHistory.lastOrNull == path) {
        _forwardHistory.removeLast();
      } else {
        _forwardHistory.clear();
      }
    } else if (event is AppRoutePopEvent) {
      _log.i('onRouteEvent: AppRoutePopEvent: $event');

      final name = event.route.settings.name;
      if (name == null) return;

      final path = _getFullPath(name, event.route.settings.arguments as Map<String, dynamic>?);
      _forwardHistory.add(path);
    }
  }

  String _getFullPath(String name, Map<String, dynamic>? params) {
    if (params == null) return name;
    for (final i in params.keys) {
      final v = params[i];
      name = name.replaceAll(':$i', v.toString());
    }
    return '$name?${params.entries.map((e) => '${e.key}=${e.value}').join('&')}';
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

        return Focus(
          autofocus: true,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) {
              return .ignored;
            }

            final key = event.logicalKey;
            final alt = HardwareKeyboard.instance.isAltPressed;

            if (key == .browserBack || key == .goBack || (alt && key == .arrowLeft)) {
              _tryBack();
              return .handled;
            }

            if (key == .browserForward || (alt && key == .arrowRight)) {
              _tryForward();
              return .handled;
            }

            return .ignored;
          },
          child: Listener(
            onPointerDown: (event) {
              if ((event.buttons & kBackMouseButton) != 0) {
                _tryBack();
              } else if ((event.buttons & kForwardMouseButton) != 0) {
                _tryForward();
              }
            },
            child: Column(
              children: [
                if (showTitleBar) AppTitleBar(config: widget.config),
                Expanded(child: child ?? const SizedBox.shrink()),
              ],
            ),
          ),
        );
      },
    );
  }
}
