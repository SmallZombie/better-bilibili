import 'package:material_ui/material_ui.dart';

class NotInterestedCard extends StatelessWidget {
  final VoidCallback onUndo;

  const NotInterestedCard({super.key, required this.onUndo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        spacing: 4.0,
        children: [
          const Icon(Icons.remove_circle_outline),
          Text('已标记为不感兴趣', style: TextStyle(fontSize: 20.0)),
          TextButton.icon(
            icon: const Icon(Icons.undo),
            onPressed: onUndo,
            label: Text('撤销'),
          ),
        ],
      ),
    );
  }
}
