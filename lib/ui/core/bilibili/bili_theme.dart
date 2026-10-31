import 'package:material_ui/material_ui.dart';
import 'package:flutter_quill/flutter_quill.dart';

class CardStyle {
  final String? coverSuffix;

  const CardStyle({
    this.coverSuffix,
  });
}

DefaultStyles quillEditorStyle(BuildContext context) {
  final defaults = DefaultStyles.getInstance(context);
  const lineHeight = 1.7;

  DefaultTextBlockStyle withLineHeight(DefaultTextBlockStyle style) {
    return style.copyWith(style: style.style.copyWith(height: lineHeight));
  }

  DefaultTextBlockStyle headingStyle(
    DefaultTextBlockStyle style, {
    required double fontSize,
  }) {
    return style.copyWith(
      style: style.style.copyWith(
        fontSize: fontSize,
        fontWeight: .w500,
        height: lineHeight,
      ),
    );
  }

  return DefaultStyles(
    h1: headingStyle(defaults.h1!, fontSize: 30),
    h2: headingStyle(defaults.h2!, fontSize: 24),
    h3: headingStyle(defaults.h3!, fontSize: 20),
    h4: headingStyle(defaults.h4!, fontSize: 16),
    h5: headingStyle(defaults.h5!, fontSize: 12),
    h6: headingStyle(defaults.h6!, fontSize: 8),

    paragraph: withLineHeight(defaults.paragraph!),
    quote: withLineHeight(defaults.quote!),
    code: withLineHeight(defaults.code!),
    indent: withLineHeight(defaults.indent!),
    align: withLineHeight(defaults.align!),
    leading: withLineHeight(defaults.leading!),

    lists: defaults.lists!.copyWith(
      style: defaults.lists!.style.copyWith(height: lineHeight),
    ),

    placeHolder: withLineHeight(defaults.placeHolder!),
  );
}
