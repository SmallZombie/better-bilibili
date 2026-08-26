import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class JumpProgressParseNode implements ParseNode {
  final Color primaryColor;
  final Function(int ep, double time)? onTap;

  JumpProgressParseNode({required this.primaryColor, this.onTap});

  final jumpRegex = RegExp(r'(?:(\d+)#)?(\b\d+(?:[:：]\d{2,})+\b)');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final matches = jumpRegex.allMatches(rawText);
    for (final match in matches) {
      final String text = match.group(0)!.replaceAll('：', ':');
      final String? epStr = match.group(1);
      final String timeStr = match.group(2)!.replaceAll('：', ':');

      final int ep = epStr != null ? int.parse(epStr) : 0;
      final double time = _timeStringToDouble(timeStr);

      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(ep, time);
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

  double _timeStringToDouble(String timeStr) {
    final parts = timeStr.split(':');

    double totalSeconds = 0.0;
    double weight = 1.0;

    for (int i = parts.length - 1; i >= 0; i--) {
      final double value = double.parse(parts[i]);
      totalSeconds += value * weight;
      weight *= 60.0;
    }

    return totalSeconds;
  }
}
