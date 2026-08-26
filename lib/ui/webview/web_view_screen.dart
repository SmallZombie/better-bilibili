import 'package:better_bilibili/ui/webview/web_view_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ListenableBuilder(
          listenable: _viewModel,
          builder: (context, child) => AppBar(title: Text(_viewModel.title)),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(_viewModel.url)),
        onTitleChanged: (controller, title) => _viewModel.setTitle(title ?? ''),
      ),
    );
  }
}
