import 'package:material_ui/material_ui.dart';

class SettingTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final Widget? action;
  final Widget? trailing;
  final Widget? arrow;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.action,
    this.trailing,
    this.arrow = const Icon(Icons.keyboard_arrow_right_rounded),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: icon,
      trailing: Row(
        mainAxisSize: .min,
        spacing: 12.0,
        children: [
          if (trailing != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 14.0),
              child: trailing!,
            ),
          if (onTap != null && arrow != null) arrow!,
          if (action != null && trailing != null)
            Center(
              child: FractionallySizedBox(
                heightFactor: 0.5,
                child: VerticalDivider(thickness: 1, width: 1),
              ),
            ),
          if (action != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 14.0),
              child: action!,
            ),
        ],
      ),
      onTap: onTap,
      tileColor: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
    );
  }
}
