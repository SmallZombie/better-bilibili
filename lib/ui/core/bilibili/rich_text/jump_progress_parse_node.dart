import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

class JumpProgressParseNode implements ParseNode {
  final Color primaryColor;
  final Function(int episodeIndex, Duration time)? onTap;

  JumpProgressParseNode({required this.primaryColor, this.onTap});

  final jumpRegex = RegExp(r'(?:(\d+)#)?(\d+(?:[:：]\d{2,})+)');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final matches = jumpRegex.allMatches(rawText);
    for (final match in matches) {
      final String text = match.group(0)!.replaceAll('：', ':');
      final String? indexStr = match.group(1);
      final String timeStr = match.group(2)!.replaceAll('：', ':');

      final int episodeIndex = indexStr != null ? int.parse(indexStr) - 1 : 0;
      final Duration time = _parseTimeStr(timeStr);

      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(episodeIndex, time);
      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: text,
            style: TextStyle(color: primaryColor),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }
}

Duration _parseTimeStr(String timeStr) {
  final parts = timeStr.split(':');

  double totalSeconds = 0.0;
  double weight = 1.0;

  for (int i = parts.length - 1; i >= 0; i--) {
    final double value = double.parse(parts[i]);
    totalSeconds += value * weight;
    weight *= 60.0;
  }

  return Duration(microseconds: (totalSeconds * Duration.microsecondsPerSecond).round());
}
