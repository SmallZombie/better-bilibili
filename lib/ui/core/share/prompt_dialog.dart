import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

extension PromptDialog on BuildContext {
  Future<T?> showPrompt<T>({
    String? title,
    String? description,
    String? initialValue,
    bool barrierDismissible = true,
  }) async {
    final tIsNumber = T == int || T == double;
    final controller = TextEditingController(text: initialValue);

    await showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        contentPadding: const .symmetric(horizontal: 24.0, vertical: 16.0),
        content: Column(
          mainAxisSize: .min,
          children: [
            if (description != null)
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
            TextField(
              controller: controller,
              keyboardType: tIsNumber ? .number : null,
              inputFormatters: <TextInputFormatter>[
                if (tIsNumber) FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: context.pop,
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => context.pop(controller.text),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    final value = controller.text.trim();
    controller.dispose();

    if (T == String) return value as T;
    if (T == int) return int.tryParse(value) as T?;
    if (T == double) return double.tryParse(value) as T?;

    return null;
  }
}
