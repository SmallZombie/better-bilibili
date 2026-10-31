import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

class SliverCardLayoutBuilder extends StatelessWidget {
  final int minColumns;
  final int maxColumns;
  final double minItemWidth;
  final double imageAspectRatio;
  final double extraHeight;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double horizontalPadding;
  final double maxWidth;

  final Widget Function(
    BuildContext context,
    SliverConstraints constraints,
    SliverGridDelegateWithFixedCrossAxisCount gridDelegate,
  )
  builder;

  const SliverCardLayoutBuilder({
    super.key,
    this.minColumns = 1,
    this.maxColumns = 5,
    this.minItemWidth = 280,
    this.imageAspectRatio = 16 / 9,
    this.extraHeight = 100,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.horizontalPadding = 16.0,
    this.maxWidth = 2100,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisExtent = constraints.crossAxisExtent;
        final constrainedWidth = crossAxisExtent.clamp(0.0, maxWidth).toDouble();
        final sidePadding = (crossAxisExtent - constrainedWidth) / 2;
        final effectiveHorizontalPadding = horizontalPadding.clamp(0.0, constrainedWidth / 2).toDouble();

        final gridWidth = constrainedWidth - effectiveHorizontalPadding * 2;
        final gridDelegate = _resolveGridDelegate(gridWidth);

        return SliverPadding(
          padding: EdgeInsets.symmetric(
            horizontal: sidePadding + effectiveHorizontalPadding,
          ),
          sliver: builder(context, constraints, gridDelegate),
        );
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _resolveGridDelegate(
    double width,
  ) {
    final available = width;
    final cellStride = minItemWidth + crossAxisSpacing;

    final rawColumns = cellStride <= 0 ? maxColumns : ((available + crossAxisSpacing) / cellStride).floor();
    final columns = rawColumns.clamp(minColumns, maxColumns).toInt();

    final itemWidth = (available - (columns - 1) * crossAxisSpacing) / columns;
    final safeItemWidth = itemWidth <= 0 ? minItemWidth : itemWidth;
    final itemHeight = safeItemWidth / imageAspectRatio + extraHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: safeItemWidth / itemHeight,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }
}
