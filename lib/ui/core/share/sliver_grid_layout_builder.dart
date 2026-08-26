import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverGridLayoutBuilder extends StatefulWidget {
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

  const SliverGridLayoutBuilder({
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
  });

  @override
  State<SliverGridLayoutBuilder> createState() => _SliverGridLayoutBuilderState();
}

class _SliverGridLayoutBuilderState extends State<SliverGridLayoutBuilder> {
  double? _lastCrossAxisExtent;
  Widget? _lastChild;

  @override
  void didUpdateWidget(SliverGridLayoutBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.minColumns != oldWidget.minColumns ||
        widget.maxColumns != oldWidget.maxColumns ||
        widget.minItemWidth != oldWidget.minItemWidth ||
        widget.imageAspectRatio != oldWidget.imageAspectRatio ||
        widget.extraHeight != oldWidget.extraHeight ||
        widget.crossAxisSpacing != oldWidget.crossAxisSpacing ||
        widget.mainAxisSpacing != oldWidget.mainAxisSpacing ||
        widget.horizontalPadding != oldWidget.horizontalPadding ||
        widget.maxWidth != oldWidget.maxWidth ||
        widget.builder != oldWidget.builder) {
      _lastCrossAxisExtent = null;
      _lastChild = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        if (_lastCrossAxisExtent == constraints.crossAxisExtent && _lastChild != null) {
          return _lastChild!;
        }

        final constrainedWidth = constraints.crossAxisExtent.clamp(0.0, widget.maxWidth);
        final sidePadding = (constraints.crossAxisExtent - constrainedWidth) / 2;
        final gridDelegate = _resolveGridDelegate(constrainedWidth);
        _lastCrossAxisExtent = constraints.crossAxisExtent;
        _lastChild = SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          sliver: widget.builder(context, constraints, gridDelegate),
        );
        return _lastChild!;
      },
    );
  }

  SliverGridDelegateWithFixedCrossAxisCount _resolveGridDelegate(double width) {
    final available = (width - widget.horizontalPadding * 2).clamp(0.0, double.infinity);
    final cellStride = widget.minItemWidth + widget.crossAxisSpacing;
    final rawColumns = cellStride <= 0 ? widget.maxColumns : ((available + widget.crossAxisSpacing) / cellStride).floor();

    final columns = rawColumns.clamp(widget.minColumns, widget.maxColumns);
    final itemWidth = (available - (columns - 1) * widget.crossAxisSpacing) / columns;
    final safeItemWidth = itemWidth <= 0 ? widget.minItemWidth : itemWidth;
    final itemHeight = safeItemWidth / widget.imageAspectRatio + widget.extraHeight;

    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      childAspectRatio: safeItemWidth / itemHeight,
      crossAxisSpacing: widget.crossAxisSpacing,
      mainAxisSpacing: widget.mainAxisSpacing,
    );
  }
}
