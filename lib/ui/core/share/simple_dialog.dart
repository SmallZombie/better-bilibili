import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

extension SimpleDialog on BuildContext {
  Future<bool> showConfirm({
    required String title,
    required String content,
    Color? confirmColor,
    bool canDismissible = false,
  }) async {
    final choice = await showDialog<bool>(
      context: this,
      barrierDismissible: canDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => context.pop(false),
            ),
            TextButton(
              child: Text('确定', style: TextStyle(color: confirmColor)),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );

    return choice ?? false;
  }
}
