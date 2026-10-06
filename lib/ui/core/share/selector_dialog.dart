import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SelectorDialogExtension on BuildContext {
  Future<String?> showSelectorDialog<T>({
    required List<SelectorDialogItem<T>> items,
    String? title,
    String? selectedId,
  }) {
    return showDialog<String>(
      context: this,
      builder: (context) {
        return _SelectorDialog<T>(
          title: title,
          items: items,
          selectedId: selectedId,
        );
      },
    );
  }
}

class _SelectorDialog<T> extends StatelessWidget {
  const _SelectorDialog({
    required this.items,
    this.title,
    this.selectedId,
  });

  final String? title;
  final List<SelectorDialogItem<T>> items;
  final String? selectedId;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title == null ? null : Text(title!),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 280,
          maxWidth: 400,
          maxHeight: 500,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: .min,
            children: items.map((v) {
              final selected = v.id == selectedId;

              return ListTile(
                title: Text(v.value),
                selected: selected,
                trailing: selected ? const Icon(Icons.check) : null,
                onTap: () {
                  context.pop(v.id);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class SelectorDialogItem<T> {
  final T id;
  final String value;

  const SelectorDialogItem({
    required this.id,
    required this.value,
  });
}
