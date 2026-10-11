import 'package:material_ui/material_ui.dart';

class PanelTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final bool selected;
  final VoidCallback? onTap;

  const PanelTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      dense: true,
      title: title,
      subtitle: subtitle != null
          ? DefaultTextStyle.merge(
              style: TextStyle(color: Colors.white70, fontSize: 12.5),
              child: subtitle!,
            )
          : null,
      textColor: Colors.white,
      selected: selected,
      trailing: trailing,
    );
  }
}
