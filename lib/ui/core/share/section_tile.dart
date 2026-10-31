import 'package:better_bilibili/ui/core/share/section_tile_header.dart';
import 'package:material_ui/material_ui.dart';

class SectionTile extends StatelessWidget {
  final Widget header;
  final double? expandedHeight;
  final Widget child;

  const SectionTile({
    super.key,
    required this.header,
    this.expandedHeight,
    required this.child,
  });

  factory SectionTile.viewAll({
    Key? key,
    double? expandedHeight,
    required Widget child,
    required Widget title,
    Widget? subtitle,
    VoidCallback? onTap,
  }) {
    return SectionTile(
      key: key,
      header: SectionTileHeader(
        title: title,
        subtitle: subtitle,
        trailing: onTap != null ? _ViewAllTrailing() : null,
        onTap: onTap,
      ),
      expandedHeight: expandedHeight,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        expandedHeight != null ? SizedBox(height: expandedHeight!, child: child) : child,
      ],
    );
  }
}

class _ViewAllTrailing extends StatelessWidget {
  const _ViewAllTrailing();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: .min,
      spacing: 4.0,
      children: [
        Text(
          '查看全部',
          style: TextStyle(
            color: color,
            fontSize: 13.0,
          ),
        ),
        Icon(
          Icons.chevron_right_rounded,
          size: 22.0,
          color: color,
        ),
      ],
    );
  }
}
