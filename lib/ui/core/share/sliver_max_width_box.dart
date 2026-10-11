import 'package:material_ui/material_ui.dart';
import 'package:flutter/rendering.dart';

class SliverMaxWidthBox extends StatefulWidget {
  final double maxWidth;
  final Widget sliver;

  const SliverMaxWidthBox({
    super.key,
    this.maxWidth = 2100,
    required this.sliver,
  });

  @override
  State<SliverMaxWidthBox> createState() => _SliverMaxWidthBoxState();
}

class _SliverMaxWidthBoxState extends State<SliverMaxWidthBox> {
  double? _lastCrossAxisExtent;
  Widget? _lastChild;

  @override
  void didUpdateWidget(SliverMaxWidthBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.maxWidth != oldWidget.maxWidth || widget.sliver != oldWidget.sliver) {
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

        _lastCrossAxisExtent = constraints.crossAxisExtent;
        _lastChild = SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: sidePadding),
          sliver: widget.sliver,
        );
        return _lastChild!;
      },
    );
  }
}
