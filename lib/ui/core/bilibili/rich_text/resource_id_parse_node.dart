import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// 用于解析纯 BVID、AVID、UserId，最低优先级
class ResourceIdParseNode implements ParseNode {
  final ValueChanged<String>? onTapVideo;

  ResourceIdParseNode({this.onTapVideo});

  final _avRegex = RegExp(r'\b[aA][vV]\d{1,12}\b');
  final _bvRegex = RegExp(r'\bBV1[a-zA-Z0-9]{9}\b');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final avMatches = _avRegex.allMatches(rawText);
    for (final match in avMatches) {
      final text = match.group(0)!;
      final avid = text.substring(2);

      final recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(avid);

      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: text,
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    final bvMatches = _bvRegex.allMatches(rawText);
    for (final match in bvMatches) {
      final text = match.group(0)!;

      final recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(bv2av(text).toString());

      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: text,
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }
}
