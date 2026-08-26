import 'dart:io';

import 'package:better_bilibili/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

extension OpenUrl on BuildContext {
  void openUrl(String url) {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      launchUrl(Uri.parse(url));
    } else {
      push(Routes.buildWebView(url));
    }
  }
}
