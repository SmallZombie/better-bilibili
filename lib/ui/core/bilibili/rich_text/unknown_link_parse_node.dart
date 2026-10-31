import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

class UnknownLinkParseNode implements ParseNode {
  final Color primaryColor;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onTapVideo;
  final ValueChanged<String>? onTapUser;

  UnknownLinkParseNode({
    required this.primaryColor,
    this.onTap,
    this.onTapVideo,
    this.onTapUser,
  });

  final _urlRegex = RegExp(
    r'(?:https?://|www\.)[^\s<>\[\](){}"\u4e00-\u9fff，。！？；：、 【】]+',
    caseSensitive: false,
  );

  final _avUrlRegex = RegExp(r'(?:https?://)?www\.bilibili\.com/video/([aA][vV]\d+)(?:\?.*)?');
  final _bvUrlRegex = RegExp(r'(?:https?://)?www\.bilibili\.com/video/(BV1[a-zA-Z0-9]{9})(?:\?.*)?');
  final _spaceUrlRegex = RegExp(r'(?:https?://)?space\.bilibili\.com/(\d+)(?:\?.*)?');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final matches = _urlRegex.allMatches(rawText);
    for (final match in matches) {
      final text = match.group(0)!;

      bool matched = false;
      late GestureRecognizer recognizer;

      // av url
      if (!matched) {
        final avUrlMatch = _avUrlRegex.firstMatch(text);
        if (avUrlMatch != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(avUrlMatch.group(1)!);
          matched = true;
        }
      }

      // bv url
      if (!matched) {
        final bvUrlMatch = _bvUrlRegex.firstMatch(text);
        if (bvUrlMatch != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(bv2av(bvUrlMatch.group(1)!).toString());
          matched = true;
        }
      }

      // space url
      if (!matched) {
        final spaceUrlMatch = _spaceUrlRegex.firstMatch(text);
        if (spaceUrlMatch != null) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapUser?.call(spaceUrlMatch.group(1)!);
          matched = true;
        }
      }

      if (!matched) {
        recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(text);
      }

      String? decodeText;
      try {
        decodeText = Uri.decodeComponent(text);
      } catch (_) {
        decodeText = text;
      }

      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: decodeText,
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
