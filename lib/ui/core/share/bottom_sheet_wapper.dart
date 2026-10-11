import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class BottomSheetWapper extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final List<Widget> actions;
  final Widget child;

  /// ```
  /// showModalBottomSheet(
  ///   context: context,
  ///   isScrollControlled: true,
  ///   builder: (context) => BottomSheetWapper(child: xxx),
  /// );
  const BottomSheetWapper({
    super.key,
    this.title,
    this.subtitle,
    this.actions = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 400),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
            mouseCursor: SystemMouseCursors.click,
            child: Padding(
              padding: const .symmetric(vertical: 12.0),
              child: Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outline.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          if (title != null || subtitle != null)
            Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                crossAxisAlignment: .start,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: .min,
                      crossAxisAlignment: .start,
                      spacing: 4.0,
                      children: [
                        if (title != null)
                          DefaultTextStyle.merge(
                            style: textTheme.displayMedium!.copyWith(fontSize: 20.0),
                            child: title!,
                          ),
                        if (subtitle != null)
                          DefaultTextStyle.merge(
                            style: textTheme.titleSmall!,
                            child: subtitle!,
                          ),
                      ],
                    ),
                  ),
                  Row(spacing: 4.0, children: actions),
                ],
              ),
            ),
          Flexible(child: child),
        ],
      ),
    );
  }
}
