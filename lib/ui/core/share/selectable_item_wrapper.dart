import 'package:material_ui/material_ui.dart';

class SelectableItemWrapper extends StatelessWidget {
  final Widget child;
  final bool selected;
  final VoidCallback onTap;
  final EdgeInsets selectorPadding;
  final EdgeInsets borderPadding;
  final BorderRadius? borderRadius;

  const SelectableItemWrapper({
    super.key,
    required this.child,
    required this.selected,
    required this.onTap,
    this.selectorPadding = const EdgeInsets.all(16.0),
    this.borderPadding = EdgeInsets.zero,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.topLeft,
        children: [
          child,
          Positioned(
            top: selectorPadding.top,
            left: selectorPadding.left,
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected ? Icons.check_circle : Icons.radio_button_unchecked,
                color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                size: 22,
              ),
            ),
          ),
          if (selected)
            Positioned.fill(
              child: Container(
                margin: borderPadding,
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
                  border: Border.all(color: theme.colorScheme.primary, width: 3),
                ),
              ),
            ),
          Positioned.fill(
            child: Listener(behavior: HitTestBehavior.opaque, child: const SizedBox.shrink()),
          ),
        ],
      ),
    );
  }
}
