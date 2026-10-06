import 'package:flutter/material.dart';

class SettingInfoBox extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final CrossAxisAlignment align;

  const SettingInfoBox({
    super.key,
    this.title,
    this.content,
    this.align = .start,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const .all(6.0),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: align,
        spacing: 4.0,
        children: [
          if (title != null)
            DefaultTextStyle.merge(
              style: TextStyle(fontSize: 18.0),
              child: title!,
            ),
          if (content != null)
            DefaultTextStyle.merge(
              style: TextStyle(color: colorScheme.outline),
              textAlign: switch (align) {
                .center => .center,
                .end => .end,
                _ => null,
              },
              child: content!,
            ),
        ],
      ),
    );
  }
}
