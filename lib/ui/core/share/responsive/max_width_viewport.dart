import 'dart:math' as math;

import 'package:flutter/material.dart';

class MaxWidthViewport extends StatelessWidget {
  final double maxWidth;
  final EdgeInsets padding;

  final Widget? child;
  final Widget Function(BuildContext context, EdgeInsets padding)? builder;

  /// 用于构建一个占满父容器但限制了最大内容宽度的容器，
  /// 默认最大宽度为建议的宽度，通常不需要修改
  ///
  /// 滚动容器请使用 builder 模式
  const MaxWidthViewport({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = .zero,
  }) : builder = null;

  /// 用于构建一个占满父容器但限制了最大内容宽度的容器，
  /// 默认最大宽度为建议的宽度，通常不需要修改
  ///
  /// 适用于滚动容器
  const MaxWidthViewport.builder({
    super.key,
    required this.builder,
    this.maxWidth = 1200,
    this.padding = .zero,
  }) : child = null;

  @override
  Widget build(BuildContext context) {
    assert(child == null || builder == null);

    if (builder != null) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = math.max(
            (constraints.maxWidth - maxWidth) / 2.0,
            padding.horizontal / 2.0,
          );

          return builder!(
            context,
            .only(
              left: horizontalPadding,
              top: padding.top,
              right: horizontalPadding,
              bottom: padding.bottom,
            ),
          );
        },
      );
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child!),
      ),
    );
  }
}
