import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const App());
}

class CommandPanelIntent extends Intent {
  const CommandPanelIntent();
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  bool _isPanelOpen = false;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      navigatorKey: _navigatorKey,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );
  }

  void _handleCommandPanel() async {
    bool isTextFocused = false;

    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext != null) {
      isTextFocused = focusContext.widget is EditableText || focusContext.findAncestorWidgetOfExactType<EditableText>() != null;
    }

    if (isTextFocused || _isPanelOpen) return;

    final navigatorContext = _navigatorKey.currentContext;
    if (navigatorContext == null) return;

    _isPanelOpen = true;

    await showDialog(
      context: navigatorContext,
      builder: (context) => const CommandPanel(),
    );

    _isPanelOpen = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      builder: (context, child) {
        return Shortcuts(
          shortcuts: <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.keyP, control: true): const CommandPanelIntent(),
            SingleActivator(LogicalKeyboardKey.keyP, meta: true): const CommandPanelIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              CommandPanelIntent: CallbackAction<CommandPanelIntent>(
                onInvoke: (intent) {
                  _handleCommandPanel();
                  return null;
                },
              ),
            },
            child: child!,
          ),
        );
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home Screen')),
      body: Center(
        child: SizedBox(
          width: 300,
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'input',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ),
    );
  }
}

class CommandPanel extends StatefulWidget {
  const CommandPanel({super.key});

  @override
  State<CommandPanel> createState() => _CommandPanelState();
}

class _CommandPanelState extends State<CommandPanel> {
  final List<String> _commands = ['Open Settings', 'Create New File', 'Go to Line', 'Format Document'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCommands = _commands.where((c) => c.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return Dialog(
      alignment: Alignment.topCenter,
      insetPadding: const EdgeInsets.only(top: 60, left: 16, right: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Type a command...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Divider(height: 1),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredCommands.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(filteredCommands[index]),
                    onTap: () {
                      context.pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Selected: ${filteredCommands[index]}')),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CommandEntry {
  final String name;
  final String desc;
  final VoidCallback execute;

  const CommandEntry({required this.name, required this.desc, required this.execute});
}
