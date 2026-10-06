import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:flutter/material.dart';

class SettingSwitchTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? icon;
  final VoidCallback? onTap;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const SettingSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.onTap,
    this.value = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SettingTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      action: Switch(value: value, onChanged: onChanged),
      onTap: onTap ?? () => onChanged?.call(!value),
      hideArrow: onTap == null,
    );
  }
}
