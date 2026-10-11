import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:material_ui/material_ui.dart';

class SettingGroup extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final List<Widget> children;
  final Widget? bottom;
  final Color? backgroundColor;
  final CrossAxisAlignment align;

  const SettingGroup({
    super.key,
    this.title,
    this.subtitle,
    required this.children,
    this.bottom,
    this.backgroundColor,
    this.align = .start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MaxWidthViewport(
      maxWidth: 800,
      padding: const .symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Padding(
            padding: const .only(top: 12.0, left: 8.0, bottom: 8.0),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: align,
              spacing: 3.0,
              children: [
                if (title != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(color: colorScheme.primary),
                    child: title!,
                  ),
                if (subtitle != null)
                  DefaultTextStyle.merge(
                    style: TextStyle(color: colorScheme.outline, fontSize: 13.0),
                    child: subtitle!,
                  ),
              ],
            ),
          ),
          Material(
            color: backgroundColor ?? colorScheme.surfaceContainerLowest,
            borderRadius: .circular(12.0),
            child: Column(
              crossAxisAlignment: align,
              children: children,
            ),
          ),
          ?bottom,
        ],
      ),
    );
  }
}
