import 'package:material_ui/material_ui.dart';

class SectionTileHeader extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const SectionTileHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: padding,
        child: Row(
          spacing: 8.0,
          children: [
            Expanded(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: 4.0,
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 18.0),
                    child: title,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: colorScheme.outline),
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            Text(
              '查看全部',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.0,
              ),
            ),
            const SizedBox(width: 4.0),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.0,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
