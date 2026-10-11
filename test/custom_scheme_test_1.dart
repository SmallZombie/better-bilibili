import 'package:app_links/app_links.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(home: CustomSchemeTest1()));
}

class CustomSchemeTest1 extends StatefulWidget {
  const CustomSchemeTest1({super.key});

  @override
  State<CustomSchemeTest1> createState() => _CustomSchemeTest1State();
}

class _CustomSchemeTest1State extends State<CustomSchemeTest1> {
  String? _currentUrl;

  @override
  void initState() {
    super.initState();

    final appLinks = AppLinks();
    appLinks.uriLinkStream.listen((uri) {
      print('appLinks: $uri');
      setState(() {
        _currentUrl = uri.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Custom Scheme Test 1'),
      ),
      body: Center(
        child: Text(_currentUrl ?? 'No URL'),
      ),
    );
  }
}
