import 'dart:convert';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/parse_node.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

final _base64Regex = RegExp(r'^(?:[A-Za-z0-9+/]{4})*(?:[A-Za-z0-9+/]{2}==|[A-Za-z0-9+/]{3}=)?$');

/// 最大可以触发搜索的选区
const _maxSearchKeywordLength = 20;

/// 上下文菜单中搜索关键词预览的最大长度, 超过此长度会被截断并加上 "..."
const _maxSearchKeywordPreviewLength = 10;

class BiliRichTextWapper extends StatefulWidget {
  final String rawText;
  final List<ParseNode> parserNodes;
  final int? maxLines;
  final TextStyle? style;

  const BiliRichTextWapper({
    super.key,
    required this.rawText,
    required this.parserNodes,
    this.maxLines,
    this.style,
  });

  @override
  State<BiliRichTextWapper> createState() => _BiliRichTextWapperState();
}

class _BiliRichTextWapperState extends State<BiliRichTextWapper> {
  final List<RichSegment> _segments = [];

  late TextStyle textStyle;
  late TextSpan textSpan;

  bool hasOverflow = false;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();

    _parseText();
  }

  @override
  void didUpdateWidget(covariant BiliRichTextWapper oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.rawText != widget.rawText || oldWidget.parserNodes != widget.parserNodes) {
      _parseText();
      changeKey = '';
    }

    if (oldWidget.maxLines != widget.maxLines || oldWidget.style != widget.style) {
      changeKey = '';
    }
  }

  @override
  void dispose() {
    for (final segment in _segments) {
      segment.recognizer?.dispose();
    }
    super.dispose();
  }

  void _parseText() {
    for (final segment in _segments) {
      segment.recognizer?.dispose();
    }
    _segments.clear();

    final List<RichSegment> results = [];
    for (final node in widget.parserNodes) {
      results.addAll(node.parse(widget.rawText));
    }

    results.sort((a, b) => a.start.compareTo(b.start));

    // 去除重叠片段
    for (final segment in results) {
      if (_segments.isNotEmpty && segment.start < _segments.last.end) {
        segment.recognizer?.dispose();
        continue;
      }
      _segments.add(segment);
    }
  }

  List<InlineSpan> _collectSegments() {
    final List<InlineSpan> spans = [];

    String text = widget.rawText;
    int offset = 0;
    for (final segment in _segments) {
      final start = segment.start - offset;
      final length = segment.end - segment.start;

      if (segment.start != 0) {
        spans.add(TextSpan(text: text.substring(0, start)));
        text = text.substring(start);
        offset += start;
      }

      spans.add(segment.span);
      text = text.substring(length);
      offset += length;
    }

    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  String changeKey = '';

  void reLayoutIfNeeded(double maxWidth) {
    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final newChangeKey = '${textSpan.hashCode}_${widget.maxLines}_${textDirection.hashCode}_${textScaler.hashCode}_$maxWidth';

    if (newChangeKey == changeKey) return;

    if (widget.maxLines != null) {
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: widget.maxLines,
        textDirection: textDirection,
        textScaler: textScaler,
      );

      textPainter.setPlaceholderDimensions(
        _segments.where((v) => v.size != null).map(
          (v) {
            return PlaceholderDimensions(
              size: v.size!,
              alignment: .middle,
            );
          },
        ).toList(),
      );

      textPainter.layout(maxWidth: maxWidth);
      hasOverflow = textPainter.didExceedMaxLines;
    } else {
      hasOverflow = false;
    }

    changeKey = newChangeKey;
  }

  String _selectedText = '';

  String? _base64Decode(String text) {
    if (text.isEmpty || !_base64Regex.hasMatch(text)) {
      return null;
    }

    try {
      return utf8.decode(base64Decode(text));
    } on FormatException {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final segments = _collectSegments();
        textStyle = DefaultTextStyle.of(context).style.merge(widget.style);
        textSpan = TextSpan(children: segments, style: textStyle);

        reLayoutIfNeeded(constraints.maxWidth);

        final richText = SelectionArea(
          child: Text.rich(
            textSpan,
            // https://github.com/flutter/flutter/issues/127477#issuecomment-1561260464
            // `maxLines: null` 和 `TextOverflow.ellipsis` 的组合会导致文本在第一行被截断
            maxLines: hasOverflow && !isExpanded ? widget.maxLines : null,
            overflow: hasOverflow && !isExpanded ? .ellipsis : null,
          ),
          onSelectionChanged: (value) => _selectedText = value?.plainText ?? '',
          contextMenuBuilder: (context, selectableRegionState) {
            final buttonItems = selectableRegionState.contextMenuButtonItems;
            final selectedText = _selectedText.trim().replaceAll('\n', '');

            final decodedText = _base64Decode(selectedText);
            if (decodedText != null) {
              buttonItems.insert(
                1,
                ContextMenuButtonItem(
                  label: '复制 (解码)',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: decodedText));
                    ContextMenuController.removeAny();
                  },
                ),
              );
            }

            if (selectedText.isNotEmpty && selectedText.length <= _maxSearchKeywordLength) {
              String searchPreview = selectedText;
              if (searchPreview.length > _maxSearchKeywordPreviewLength) {
                searchPreview = '${searchPreview.substring(0, _maxSearchKeywordPreviewLength - 2)}...';
              }
              buttonItems.add(
                ContextMenuButtonItem(
                  label: '搜索 "$searchPreview"',
                  onPressed: () => context.push(Routes.buildSearch(selectedText)),
                ),
              );
            }

            return AdaptiveTextSelectionToolbar.buttonItems(
              anchors: selectableRegionState.contextMenuAnchors,
              buttonItems: buttonItems,
            );
          },
        );

        if (!hasOverflow) return richText;

        final colorScheme = Theme.of(context).colorScheme;
        return Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            richText,
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => setState(() => isExpanded = !isExpanded),
                child: Text(
                  isExpanded ? '收起' : '展开',
                  style: TextStyle(color: colorScheme.primary),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
