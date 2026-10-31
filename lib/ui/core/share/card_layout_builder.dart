import 'package:material_ui/material_ui.dart';

class CardLayoutBuilder extends StatelessWidget {
  /// 列数下限，不能小于 1
  final int minColumns;

  /// 列数上限
  final int maxColumns;

  /// 单个 item 期望的最小宽度
  final double minItemWidth;

  /// item 中随宽度伸缩的部分的宽高比
  final double imageAspectRatio;

  /// item 中不随宽度伸缩的固定高度部分
  final double extraHeight;

  final double crossAxisSpacing;
  final double mainAxisSpacing;

  /// 内容区域的最小内边距
  final EdgeInsetsGeometry padding;

  /// 内容区域的最大宽度
  final double maxWidth;

  final Widget Function(
    BuildContext context,
    BoxConstraints constraints,
    SliverGridDelegateWithFixedCrossAxisCount gridDelegate,
    EdgeInsets padding,
  )
  builder;

  const CardLayoutBuilder({
    super.key,
    this.minColumns = 1,
    this.maxColumns = 5,
    this.minItemWidth = 280,
    this.imageAspectRatio = 16 / 9,
    this.extraHeight = 100,
    this.crossAxisSpacing = 0,
    this.mainAxisSpacing = 0,
    this.padding = const .all(16.0),
    this.maxWidth = 2100,
    required this.builder,
  }) : assert(minColumns >= 1),
       assert(maxColumns >= minColumns),
       assert(minItemWidth > 0),
       assert(imageAspectRatio > 0),
       assert(extraHeight >= 0),
       assert(maxWidth > 0);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite ? constraints.maxWidth : maxWidth;

        final contentWidth = width.clamp(0.0, maxWidth);
        final extraHorizontalPadding = (width - contentWidth) / 2;

        final resolvedPadding = padding.resolve(Directionality.of(context));

        final effectivePadding = EdgeInsets.only(
          left: resolvedPadding.left + extraHorizontalPadding,
          top: resolvedPadding.top,
          right: resolvedPadding.right + extraHorizontalPadding,
          bottom: resolvedPadding.bottom,
        );

        final availableWidth = (width - effectivePadding.horizontal).clamp(0.0, double.infinity);

        final gridDelegate = _resolveGridDelegate(availableWidth);

        return builder(
          context,
          BoxConstraints(
            maxWidth: availableWidth,
            maxHeight: constraints.maxHeight,
          ),
          gridDelegate,
          effectivePadding,
        );
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _resolveGridDelegate(double available) {
    final cellStride = minItemWidth + crossAxisSpacing;
    final rawColumns = cellStride <= 0 ? maxColumns : ((available + crossAxisSpacing) / cellStride).floor();
    final columns = rawColumns.clamp(minColumns, maxColumns);

    final itemWidth = (available - (columns - 1) * crossAxisSpacing) / columns;
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
