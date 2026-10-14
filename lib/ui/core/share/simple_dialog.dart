import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

extension SimpleDialog on BuildContext {
  Future<bool> showConfirm({
    required String title,
    required String content,
    Color? confirmColor,
    String? confirmText,
    bool canDismissible = false,
  }) async {
    final choice = await showDialog<bool>(
      context: this,
      barrierDismissible: canDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(content),
          ),
          actions: [
            TextButton(
              child: const Text('取消'),
              onPressed: () => context.pop(false),
            ),
            TextButton(
              child: Text(confirmText ?? '确定', style: TextStyle(color: confirmColor)),
              onPressed: () => context.pop(true),
            ),
          ],
        );
      },
    );

    return choice ?? false;
  }
}
