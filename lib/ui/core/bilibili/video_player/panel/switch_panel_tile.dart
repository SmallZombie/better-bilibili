import 'package:material_ui/material_ui.dart';

class SwitchPanelTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget title;
  final Widget? subtitle;

  const SwitchPanelTile({
    super.key,
    required this.value,
    this.onChanged,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged?.call(!value),
      child: Padding(
        padding: .symmetric(horizontal: 16.0, vertical: subtitle == null ? 0.0 : 6.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: 2.0,
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(color: Colors.white, fontSize: 12.5),
                    child: title,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: Colors.white70, fontSize: 12.5),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            Transform.scale(
              scale: .85,
              child: Switch(
                value: value,
                onChanged: (value) => onChanged?.call(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
