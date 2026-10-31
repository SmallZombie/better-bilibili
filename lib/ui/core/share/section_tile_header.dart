import 'package:material_ui/material_ui.dart';

class SectionTileHeader extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;

  const SectionTileHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const .symmetric(horizontal: 20.0, vertical: 8.0),
        child: Row(
          spacing: 8.0,
          children: [
            ?leading,
            Expanded(
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: 4.0,
                children: [
                  DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 18.0),
                    child: title,
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  if (subtitle != null)
                    DefaultTextStyle.merge(
                      style: TextStyle(color: colorScheme.outline),
                      child: subtitle!,
                      maxLines: 2,
                      overflow: .ellipsis,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
