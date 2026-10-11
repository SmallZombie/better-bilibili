import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:material_ui/material_ui.dart';

class StickerParseNode implements ParseNode {
  final List<Sticker> stickers;

  const StickerParseNode({required this.stickers});

  @override
  List<RichSegment> parse(String rawText) {
    if (stickers.isEmpty) return [];

    final List<RichSegment> segments = [];

    final patternString = stickers.map((sticker) => RegExp.escape(sticker.code)).join('|');
    final regex = RegExp(patternString);

    final matches = regex.allMatches(rawText);

    for (final match in matches) {
      final start = match.start;
      final text = match.group(0);
      final sticker = stickers.firstWhere((s) => s.code == text);

      segments.add(
        RichSegment(
          start: start,
          end: match.end,
          span: WidgetSpan(
            child: Tooltip(
              message: sticker.name,
              verticalOffset: sticker.size / 2 + 4,
              child: ImageWapper(
                width: sticker.size,
                height: sticker.size,
                image: NetworkImage(sticker.url),
              ),
            ),
          ),
          size: Size(sticker.size, sticker.size),
        ),
      );
    }

    return segments;
  }
}
