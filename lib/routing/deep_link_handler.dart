import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:logger/logger.dart';

final _bvRegex = RegExp(r'BV[a-zA-Z0-9]{10}');
final _cvRegex = RegExp(r'(/?article/)cv(\d+)', caseSensitive: false);

final _log = Logger(printer: ComposablePrefixPrinter(prefix: 'deepLinkHandler'));

String deepLinkHandler(String uri) {
  final prefix = '$kAppDeepLinkScheme:/';
  if (!uri.startsWith(prefix)) {
    _log.e('Invalid URI: $uri');
    return Routes.home;
  }

  String content = uri.substring(prefix.length);

  try {
    // bv to av
    content = content.replaceAllMapped(_bvRegex, (match) {
      final bv = match.group(0)!;
      return bv2av(bv).toString();
    });

    // remove cv prefix
    content = content.replaceFirstMapped(
      _cvRegex,
      (match) => '${match.group(1)}${match.group(2)}',
    );

    return content;
  } catch (e, s) {
    _log.e('Error parsing URI: $uri', error: e, stackTrace: s);
    return Routes.home;
  }
}
