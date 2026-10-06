import 'dart:math' as math;

import 'package:flutter/material.dart';

class SliverMaxWidthViewport extends StatelessWidget {
  final double maxWidth;
  final EdgeInsets padding;

  final Widget sliver;

  /// 用于构建一个占满父容器但限制了最大内容宽度的容器，
  /// 默认最大宽度为建议的宽度，通常不需要修改
  ///
  /// 适用于 CustomScrollView
  const SliverMaxWidthViewport({
    super.key,
    required this.sliver,
    this.maxWidth = 1200,
    this.padding = .zero,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = math.max(
          (constraints.crossAxisExtent - maxWidth) / 2.0,
          padding.horizontal / 2.0,
        );

        return SliverPadding(
          padding: .only(
            left: horizontalPadding,
            top: padding.top,
            right: horizontalPadding,
            bottom: padding.bottom,
          ),
          sliver: sliver,
        );
      },
    );
  }
}
