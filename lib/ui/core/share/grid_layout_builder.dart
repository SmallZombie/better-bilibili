import 'package:flutter/material.dart';

class GridLayoutBuilder extends StatelessWidget {
  /// 列数下限，不能小于 1
  final int minColumns;

  /// 列数上限
  final int maxColumns;

  /// 单个 item 期望的最小宽度(不含 spacing)
  final double minItemWidth;

  /// item 中随宽度伸缩的部分的宽高比
  final double imageAspectRatio;

  /// item 中不随宽度伸缩的固定高度部分
  final double extraHeight;

  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// 计算可用宽度时单边扣除的水平 padding
  final double horizontalPadding;

  /// 整个布局的最大宽度上限
  final double maxWidth;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    SliverGridDelegateWithFixedCrossAxisCount gridDelegate,
  )
  builder;

  const GridLayoutBuilder({
    super.key,
    required this.minColumns,
    required this.maxColumns,
    required this.minItemWidth,
    required this.imageAspectRatio,
    required this.extraHeight,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.horizontalPadding = 0,
    this.maxWidth = 2100,
    required this.builder,
  }) : assert(minColumns >= 1),
       assert(maxColumns >= minColumns),
       assert(minItemWidth > 0),
       assert(imageAspectRatio > 0),
       assert(extraHeight >= 0);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final gridDelegate = _resolveGridDelegate(constraints.maxWidth);
            return builder(context, constraints, gridDelegate);
          },
        ),
      ),
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _resolveGridDelegate(double width) {
    final available = (width - horizontalPadding * 2).clamp(
      0.0,
      double.infinity,
    );

    // n 列需要的总宽 = n * itemWidth + (n - 1) * crossAxisSpacing
    final cellStride = minItemWidth + crossAxisSpacing;
    final rawColumns = cellStride <= 0 ? maxColumns : ((available + crossAxisSpacing) / cellStride).floor();
    final columns = rawColumns.clamp(minColumns, maxColumns);

    final itemWidth = columns == 0 ? minItemWidth : (available - (columns - 1) * crossAxisSpacing) / columns;
    final safeItemWidth = itemWidth <= 0 ? minItemWidth : itemWidth;

    final itemHeight = safeItemWidth / imageAspectRatio + extraHeight;
    final aspectRatio = itemHeight <= 0 ? 1.0 : safeItemWidth / itemHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: aspectRatio,
      crossAxisSpacing: crossAxisSpacing,
      mainAxisSpacing: mainAxisSpacing,
    );
  }
}
