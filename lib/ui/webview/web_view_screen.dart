import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/webview/web_view_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ListenableBuilder(listenable: _viewModel, builder: (context, _) => Text(_viewModel.title)),
        actions: [
          IconButton(
            onPressed: () => context.openUrl(_viewModel.url, mode: .external),
            icon: const Icon(Icons.open_in_browser),
          ),
        ],
      ),
      // body: InAppWebView(
      //   initialUrlRequest: URLRequest(url: WebUri(_viewModel.url)),
      //   onTitleChanged: (controller, title) => _viewModel.setTitle(title ?? ''),
      // ),
    );
  }
}
