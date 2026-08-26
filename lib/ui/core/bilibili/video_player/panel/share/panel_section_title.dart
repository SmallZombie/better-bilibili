import 'package:flutter/material.dart';

class PanelSectionTitle extends StatelessWidget {
  final String? title;

  const PanelSectionTitle({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14.0, 16.0, 0.0, 6.0),
      child: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12.0,
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
