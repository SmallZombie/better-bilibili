import 'package:better_bilibili/utils/safe_change_notifier.dart';

class WebViewViewModel extends SafeChangeNotifier {
  final String _url;
  String get url => _url;

  WebViewViewModel({
    required String url,
  }) : _url = url;

  String _title = '';
  String get title => _title;

  void setTitle(String title) {
    _title = title;
    notifyListeners();
  }
}
