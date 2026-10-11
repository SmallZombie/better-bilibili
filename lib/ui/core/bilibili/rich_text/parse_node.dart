import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// 解析器接受原始文本并返回自身关注的片段
abstract class ParseNode {
  List<RichSegment> parse(String rawText);
}

/// 用于描述一段富文本在原始文本中的所在位置和特定的交互逻辑
class RichSegment {
  final int start;
  final int end;
  final InlineSpan span;
  final GestureRecognizer? recognizer;
  final Size? size;

  const RichSegment({
    required this.start,
    required this.end,
    required this.span,
    this.recognizer,
    this.size,
  });
}
