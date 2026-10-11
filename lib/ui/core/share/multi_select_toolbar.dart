import 'package:material_ui/material_ui.dart';

const double kMultiSelectToolbarDefaultSpacing = 4.0;

class MultiSelectToolbar extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onToggleMultiSelectMode;
  final int? count;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onInvertSelection;
  final List<Widget>? actions;

  const MultiSelectToolbar({
    super.key,
    this.enabled = true,
    this.onToggleMultiSelectMode,
    this.count,
    this.onSelectAll,
    this.onDeselectAll,
    this.onInvertSelection,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return IconButton(
        onPressed: onToggleMultiSelectMode,
        icon: Icon(Icons.checklist_rtl),
        tooltip: '多选模式',
      );
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: .min,
      children: [
        Container(
          padding: const .symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outlineVariant),
            ),
          ),
          child: Row(
            mainAxisSize: .min,
            spacing: kMultiSelectToolbarDefaultSpacing,
            children: [
              if (count != null)
                Text(
                  '已选 $count 项',
                  style: TextStyle(fontSize: 14.0),
                ),
              if (onSelectAll != null)
                IconButton(
                  onPressed: onSelectAll,
                  icon: const Icon(Icons.select_all),
                  tooltip: '全选',
                ),
              if (onDeselectAll != null)
                IconButton(
                  onPressed: onDeselectAll,
                  icon: const Icon(Icons.deselect),
                  tooltip: '取消全选',
                ),
              if (onInvertSelection != null)
                IconButton(
                  onPressed: onInvertSelection,
                  icon: const Icon(Icons.invert_colors),
                  tooltip: '反选',
                ),
              ...actions ?? [],
            ],
          ),
        ),
        IconButton(
          onPressed: onToggleMultiSelectMode,
          icon: Icon(Icons.checklist_rtl, color: colorScheme.primary),
          style: IconButton.styleFrom(backgroundColor: colorScheme.primaryContainer),
          tooltip: '多选模式',
        ),
      ],
    );
  }
}
