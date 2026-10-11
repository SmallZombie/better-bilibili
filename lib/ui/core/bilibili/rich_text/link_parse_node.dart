import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

class LinkParseNode implements ParseNode {
  final Color primaryColor;
  final List<CommentContentLink> links;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onTapVideo;

  LinkParseNode({
    required this.primaryColor,
    required this.links,
    this.onTap,
    this.onTapVideo,
  });

  final bvRegex = RegExp(r'^BV1[a-zA-Z0-9]{9}$');
  final avRegex = RegExp(r'^[aA][vV]\d{1,12}$');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    for (final link in links) {
      final start = rawText.indexOf(link.rawText);
      if (start == -1) continue;

      bool matched = false;
      GestureRecognizer? recognizer;

      // av
      if (!matched) {
        final isAv = avRegex.hasMatch(link.rawText);
        if (isAv) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(link.rawText);
          matched = true;
        }
      }

      // bv
      if (!matched) {
        final isBv = bvRegex.hasMatch(link.rawText);
        if (isBv) {
          recognizer = TapGestureRecognizer()..onTap = () => onTapVideo?.call(bv2av(link.rawText).toString());
          matched = true;
        }
      }

      // 到这里剩下的都是搜索链接, Better 使用自定义上下文菜单来代替此功能, 故不再处理此类链接
      // if (!matched) {
      //   late String href;
      //   if (Platform.isAndroid || Platform.isIOS && link.appUrl != null) {
      //     href = link.appUrl!;
      //   } else {
      //     href = link.url;
      //   }
      //   recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(href);
      // }

      if (recognizer == null) {
        continue;
      }

      segments.add(
        RichSegment(
          start: start,
          end: start + link.rawText.length,
          span: TextSpan(
            text: link.title ?? rawText.substring(start, start + link.rawText.length),
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
