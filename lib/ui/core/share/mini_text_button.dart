import 'package:flutter/material.dart';

class MiniTextButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;

  const MiniTextButton({super.key, this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: .circular(4.0),
      child: Padding(
        padding: const .symmetric(horizontal: 2, vertical: 2),
        child: DefaultTextStyle.merge(
          maxLines: 1,
          overflow: .ellipsis,
          child: child,
        ),
      ),
    );
  }
}
