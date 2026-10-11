import 'package:material_ui/material_ui.dart';

class UnsupportedCard extends StatelessWidget {
  final String title;

  const UnsupportedCard({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [Text('不支持的内容：$title')],
      ),
    );
  }
}
