import 'package:flutter/material.dart';

class SettingTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final Widget? action;

  final bool hideArrow;

  const SettingTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.action,
    this.hideArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: title,
      subtitle: subtitle,
      leading: icon,
      trailing: action != null
          ? Row(
              mainAxisSize: .min,
              spacing: 12.0,
              children: [
                if (onTap != null && !hideArrow) ...[
                  const Icon(Icons.keyboard_arrow_right_rounded),
                  Center(
                    child: FractionallySizedBox(
                      heightFactor: 0.5,
                      child: VerticalDivider(thickness: 1, width: 1),
                    ),
                  ),
                ],
                DefaultTextStyle.merge(
                  style: TextStyle(fontSize: 14.0),
                  child: action!,
                ),
              ],
            )
          : onTap != null
          ? const Icon(Icons.keyboard_arrow_right_rounded)
          : null,
      onTap: onTap,
      tileColor: colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
    );
  }
}
