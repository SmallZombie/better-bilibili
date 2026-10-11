import 'package:material_ui/material_ui.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('龙渊不吃鱼'),
        backgroundColor: colorScheme.primaryContainer,
      ),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Container(
            color: Colors.red,
            width: 100,
            height: 20,
          );
        },
      ),
    );
  }
}
