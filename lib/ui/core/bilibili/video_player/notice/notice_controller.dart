import 'dart:collection';

import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:material_ui/material_ui.dart';
import 'package:logger/logger.dart';

class NoticeController extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'NoticeController'));

  final int maxCount;

  NoticeController({this.maxCount = 3}) : assert(maxCount > 0);

  final List<Notice> _visibleNotices = [];
  final Queue<Notice> _pendingNotices = Queue();

  List<Notice> get visibleNotices => List.unmodifiable(_visibleNotices);

  void show(Notice notice) {
    if (_visibleNotices.length < maxCount) {
      _showNotice(notice);
    } else {
      _pendingNotices.add(notice);
    }
  }

  void dismiss(Notice notice) => _removeNotice(notice);

  void _showNotice(Notice notice) {
    _log.i('showNotice: $notice');

    _visibleNotices.add(notice);
    notifyListeners();

    Future.delayed(notice.duration, () {
      _removeNotice(notice);
    });
  }

  void _removeNotice(Notice notice) {
    _log.i('removeNotice: $notice');

    if (!_visibleNotices.remove(notice)) {
      return;
    }

    if (_pendingNotices.isNotEmpty) {
      final next = _pendingNotices.removeFirst();
      _showNotice(next);
    } else {
      notifyListeners();
    }
  }
}

class Notice {
  final Widget content;
  final Duration duration;
  final String? action;
  final Function(Notice)? onTap;

  const Notice({
    required this.content,
    this.duration = const Duration(seconds: 3),
    this.action,
    this.onTap,
  });

  @override
  String toString() {
    return '(content=$content, duration=$duration, action=$action)';
  }
}
