import 'package:flutter/material.dart';

class TextedDivider extends StatelessWidget {
  final Widget child;
  final double? height;

  const TextedDivider({super.key, required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      spacing: 12.0,
      children: [
        Expanded(
          child: Divider(height: height),
        ),
        DefaultTextStyle.merge(
          style: TextStyle(color: colorScheme.outline),
          child: child,
        ),
        Expanded(child: Divider(height: height)),
      ],
    );
  }
}
