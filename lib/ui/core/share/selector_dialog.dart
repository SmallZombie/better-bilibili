import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension SelectorDialogExtension on BuildContext {
  Future<T?> showSelectorDialog<T>({
    required List<SelectorDialogItem<T>> items,
    String? title,
    T? initialSelected,
  }) async {
    final selected = items.where((v) => v.value == initialSelected).firstOrNull;
    final selectedIndex = selected != null ? items.indexOf(selected) : null;

    final index = await showDialog<int>(
      context: this,
      builder: (context) {
        return _SelectorDialog<T>(
          title: title,
          items: items,
          selectedIndex: selectedIndex,
        );
      },
    );

    if (index == null) return null;
    return items[index].value;
  }
}

class _SelectorDialog<T> extends StatelessWidget {
  final String? title;
  final List<SelectorDialogItem<T>> items;
  final int? selectedIndex;

  const _SelectorDialog({required this.items, this.title, this.selectedIndex});

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
            children: [
              for (int i = 0; i < items.length; i++)
                ListTile(
                  title: Text(items[i].name),
                  selected: selectedIndex == i,
                  trailing: selectedIndex == i ? const Icon(Icons.check) : null,
                  onTap: () => context.pop(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SelectorDialogItem<T> {
  final String name;
  final T value;

  const SelectorDialogItem({required this.name, required this.value});
}
