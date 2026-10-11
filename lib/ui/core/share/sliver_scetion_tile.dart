import 'package:better_bilibili/ui/core/share/sliver_scetion_tile_header.dart';
import 'package:material_ui/material_ui.dart';

class SliverSectionTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets headerPadding;
  final Widget sliver;
  final VoidCallback? onTap;

  const SliverSectionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.headerPadding = const .symmetric(horizontal: 16.0, vertical: 8.0),
    required this.sliver,
    this.onTap,
  });

  factory SliverSectionTile.box({
    Key? key,
    required Widget title,
    Widget? subtitle,
    EdgeInsets headerPadding = const .symmetric(horizontal: 16.0, vertical: 8.0),
    double? expandedHeight,
    required Widget child,
    VoidCallback? onTap,
  }) {
    return SliverSectionTile(
      key: key,
      title: title,
      subtitle: subtitle,
      headerPadding: headerPadding,
      sliver: SliverToBoxAdapter(
        child: expandedHeight != null ? SizedBox(height: expandedHeight, child: child) : child,
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SectionTileHeader(
            title: title,
            subtitle: subtitle,
            padding: headerPadding,
            onTap: onTap,
          ),
        ),
        sliver,
      ],
    );
  }
}
