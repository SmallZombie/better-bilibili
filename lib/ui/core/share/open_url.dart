import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

extension OpenUrl on BuildContext {
  // 第二次进入 WebViewScreen 就会无法加载网页并报错 `Error -2147221008: 尚未调用 CoInitialize。`
  // 由于我无法解决这个问题，所以暂时停用应用内打开链接
  void openUrl(String url, {OpenModeEnum mode = .auto}) {
    // if (mode == .internal) {
    //   push(Routes.buildWebView(url));
    //   return;
    // }

    // if (mode == .external) {
    //   launchUrl(Uri.parse(url));
    //   return;
    // }

    // if (url.startsWith('http://') || url.startsWith('https://')) {
    //   push(Routes.buildWebView(url));
    //   return;
    // }

    // if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //   launchUrl(Uri.parse(url));
    // } else {
    //   push(Routes.buildWebView(url));
    // }

    launchUrl(Uri.parse(url));
  }
}

enum OpenModeEnum {
  auto,
  internal,
  external,
}
