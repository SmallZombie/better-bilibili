import 'package:flutter/material.dart';

/// 一个类 CSS Grid `auto-fill minmax(...)` 的布局 builder
///
/// 给定单个 item 的最小宽度 [minItemWidth] 以及列数上下限 [minColumns]、
/// [maxColumns]，会自动算出一个合适的
/// [SliverGridDelegateWithFixedCrossAxisCount]，通过 [builder] 回调出去，
/// 调用方拿去喂给 [GridView] 即可
///
/// 高度由「图片宽高比 + 图片以外的固定高度」精确计算：
/// ```
/// itemHeight = itemWidth / imageAspectRatio + extraHeight
/// ```
/// 这样无论窗口宽度怎么变，item 的高度始终贴合内容、不会溢出也不会留白
///
/// 重要：[horizontalPadding]、[crossAxisSpacing]、[mainAxisSpacing] 仅用于
/// 推算列数和列宽，**不会**自动套到 [GridView] 上调用方需要在 [builder]
/// 内自行设置 `padding` 和 `spacing`，并保持与传入这里的值一致
class GridLayoutBuilder extends StatelessWidget {
  /// 列数下限（item 最宽时的列数），不能小于 1
  final int minColumns;

  /// 列数上限（item 最窄时的列数）
  final int maxColumns;

  /// 单个 item 期望的最小宽度（不含 spacing）
  /// 算法会在保证 `itemWidth >= minItemWidth` 的前提下尽量多塞列
  final double minItemWidth;

  /// item 中随宽度伸缩的部分（通常是封面图片）的宽高比，即 width / height
  ///
  /// 例：16:9 横版封面填 `16 / 9`，竖版海报 1:1.4 填 `1 / 1.4`
  final double imageAspectRatio;

  /// item 中不随宽度伸缩的固定高度部分的总和（像素）
  ///
  /// 包括：图片以外的标题/作者/统计等文字块、内部 gap 与 padding、
  /// 外层 margin 等一般肉眼测量或经验值，跑起来再微调
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
  }) : assert(minColumns >= 1, 'minColumns 必须 >= 1'),
       assert(maxColumns >= minColumns, 'maxColumns 必须 >= minColumns'),
       assert(minItemWidth > 0, 'minItemWidth 必须 > 0'),
       assert(imageAspectRatio > 0, 'imageAspectRatio 必须 > 0'),
       assert(extraHeight >= 0, 'extraHeight 不能为负');

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

    // n 列需要的总宽：n * itemWidth + (n - 1) * crossAxisSpacing
    // 反解：n = (available + crossAxisSpacing) / (minItemWidth + crossAxisSpacing)
    // 取 floor 得到不溢出 minItemWidth 的最大列数
    final cellStride = minItemWidth + crossAxisSpacing;
    final rawColumns = cellStride <= 0 ? maxColumns : ((available + crossAxisSpacing) / cellStride).floor();
    final columns = rawColumns.clamp(minColumns, maxColumns);

    // 真实 itemWidth：扣掉所有列间距后均分
    final itemWidth = columns == 0 ? minItemWidth : (available - (columns - 1) * crossAxisSpacing) / columns;
    final safeItemWidth = itemWidth <= 0 ? minItemWidth : itemWidth;

    // itemHeight = 图片高度 + 固定块高度
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
