import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final Widget? leading;
  final Widget title;

  const InfoBanner({super.key, this.leading, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: .fromLTRB(8.0, 0, 8.0, 8.0),
      padding: .all(6.0),
      decoration: BoxDecoration(
        borderRadius: .circular(8.0),
        color: colorScheme.secondaryContainer,
      ),
      child: Row(
        spacing: 6.0,
        children: [
          ?leading,
          DefaultTextStyle.merge(
            style: TextStyle(color: colorScheme.onSecondaryContainer),
            child: title,
          ),
        ],
      ),
    );
  }
}
