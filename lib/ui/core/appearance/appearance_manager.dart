import 'dart:io';

import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// 外观管理器，负责管理应用的主题、颜色模式、缩放级别等主题设置。
/// 此外，还向整个应用提供加载指示器、进度条、图标、导航栏背景、点赞动画等预制组件
class AppearanceManager extends ChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'AppearanceManager'));

  ThemeData? _lightTheme;
  ThemeData? get lightTheme => _lightTheme;

  ThemeData? _darkTheme;
  ThemeData? get darkTheme => _darkTheme;

  ThemeMode _themeMode = .system;
  ThemeMode get themeMode => _themeMode;

  /// 尝试通过系统动态颜色更新主题，失败则使用默认颜色
  Future<void> tryUpdateThemeWithDynamicColor() async {
    ColorScheme? lightDynamic;
    ColorScheme? darkDynamic;
    try {
      final corePalette = await DynamicColorPlugin.getCorePalette();
      if (corePalette != null) {
        _log.i('Core palette detected.');
        lightDynamic = corePalette.toColorScheme();
        darkDynamic = corePalette.toColorScheme(brightness: Brightness.dark);
      }
    } on PlatformException {
      _log.e('Failed to obtain core palette.');
    }

    try {
      final Color? accentColor = await DynamicColorPlugin.getAccentColor();

      if (accentColor != null) {
        _log.i('Accent color detected.');
        lightDynamic = ColorScheme.fromSeed(seedColor: accentColor, brightness: .light);
        darkDynamic = ColorScheme.fromSeed(seedColor: accentColor, brightness: .dark);
      }
    } on PlatformException {
      _log.e('Failed to obtain accent color.');
    }

    ColorScheme lightColorScheme = lightDynamic ?? .fromSeed(seedColor: Colors.blue);
    lightColorScheme = lightColorScheme.harmonized();

    ColorScheme darkColorScheme = darkDynamic ?? .fromSeed(seedColor: Colors.blue, brightness: .dark);
    darkColorScheme = darkColorScheme.harmonized();

    _lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      fontFamily: Platform.isWindows ? 'HarmonyOS_Sans' : null,
      chipTheme: ChipThemeData(
        backgroundColor: lightColorScheme.surfaceContainerHigh,
        side: .none,
        shadowColor: Colors.black.withAlpha(150),
      ),
      appBarTheme: AppBarThemeData(actionsPadding: const .only(right: 16.0)),
      snackBarTheme: SnackBarThemeData(
        behavior: .floating,
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        width: 600,
      ),
    );

    _darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      fontFamily: Platform.isWindows ? 'HarmonyOS_Sans' : null,
      chipTheme: ChipThemeData(
        backgroundColor: darkColorScheme.surfaceContainerHigh,
        side: .none,
        shadowColor: Colors.black.withAlpha(150),
      ),
      appBarTheme: AppBarThemeData(actionsPadding: const .only(right: 16.0)),
      snackBarTheme: SnackBarThemeData(
        behavior: .floating,
        shape: RoundedRectangleBorder(borderRadius: .circular(12)),
        width: 600,
      ),
    );

    notifyListeners();
  }
}
