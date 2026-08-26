import 'dart:io';

bool get isMobile => Platform.isAndroid || Platform.isIOS;
bool get isDesktop => Platform.isWindows || Platform.isLinux || Platform.isMacOS;
