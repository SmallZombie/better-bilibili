import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

class UserParseNode implements ParseNode {
  final Color primaryColor;
  final List<CommentContentUser> users;
  final ValueChanged<String>? onTap;

  UserParseNode({
    required this.primaryColor,
    required this.users,
    this.onTap,
  });

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];
    final sortedUsers = [...users]..sort((a, b) => b.nickname.length.compareTo(a.nickname.length));

    for (final user in sortedUsers) {
      final text = '@${user.nickname}';

      final start = rawText.indexOf(text);
      if (start == -1) continue;

      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(user.id);

      segments.add(
        RichSegment(
          start: start,
          end: start + text.length,
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
