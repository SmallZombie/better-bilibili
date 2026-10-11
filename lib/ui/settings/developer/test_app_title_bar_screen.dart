import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class TestAppTitleBarScreen extends StatelessWidget {
  const TestAppTitleBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test App Title Bar')),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Show Title Bar'),
            onTap: () {
              context.read<AppController>().setTitleBarVisible(true);
            },
          ),
          ListTile(
            title: const Text('Hide Title Bar'),
            onTap: () {
              context.read<AppController>().setTitleBarVisible(false);
            },
          ),
        ],
      ),
    );
  }
}
