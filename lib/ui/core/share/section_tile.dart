import 'package:better_bilibili/ui/core/share/sliver_scetion_tile_header.dart';
import 'package:flutter/material.dart';

class SectionTile extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final EdgeInsets headerPadding;
  final double? expandedHeight;
  final Widget child;
  final VoidCallback? onTap;

  const SectionTile({
    super.key,
    required this.title,
    this.subtitle,
    this.headerPadding = const .symmetric(horizontal: 16.0, vertical: 8.0),
    this.expandedHeight,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTileHeader(
          title: title,
          subtitle: subtitle,
          padding: headerPadding,
          onTap: onTap,
        ),
        expandedHeight != null ? SizedBox(height: expandedHeight!, child: child) : child,
      ],
    );
  }
}
