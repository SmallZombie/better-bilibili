import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:material_ui/material_ui.dart';

const scheme = 'bilibili://';

/// 目前可匹配的 uri
String schemeParser(String uri) {
  if (uri.startsWith(scheme)) {
    final content = uri.substring(scheme.length);

    final bvRegex = RegExp(r'BV[a-zA-Z0-9]{10}');

    return content.replaceAllMapped(bvRegex, (match) {
      final bv = match.group(0)!;
      return bv2av(bv).toString();
    });
  } else {
    debugPrint('Invalid URI: $uri');
    return '/';
  }
}
