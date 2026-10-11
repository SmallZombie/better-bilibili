import 'package:material_ui/material_ui.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CardStyle {
  final String? coverSuffix;

  const CardStyle({
    this.coverSuffix,
  });
}

DefaultStyles quillEditorStyle(BuildContext context) {
  // final defaultTextStyle = DefaultTextStyle.of(context);
  const baseHorizontalSpacing = HorizontalSpacing(0, 0);
  final colorScheme = Theme.of(context).colorScheme;

  return DefaultStyles(
    paragraph: DefaultTextBlockStyle(
      TextStyle(
        height: 1.7,
        fontSize: 16.0,
        color: colorScheme.onSurface,
      ),
      baseHorizontalSpacing,
      VerticalSpacing.zero,
      VerticalSpacing.zero,
      null,
    ),
    h1: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 30,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(16, 0),
      VerticalSpacing.zero,
      null,
    ),
    h2: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 24,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(8, 0),
      VerticalSpacing.zero,
      null,
    ),
    h3: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 20,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(8, 0),
      VerticalSpacing.zero,
      null,
    ),
    h4: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 16,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(6, 0),
      VerticalSpacing.zero,
      null,
    ),
    h5: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 12,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(6, 0),
      VerticalSpacing.zero,
      null,
    ),
    h6: DefaultTextBlockStyle(
      TextStyle(
        fontSize: 8,
        height: 1.7,
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
      baseHorizontalSpacing,
      const VerticalSpacing(4, 0),
      VerticalSpacing.zero,
      null,
    ),
  );
}
