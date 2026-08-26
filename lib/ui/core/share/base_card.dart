import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/mini_text_button.dart';
import 'package:better_bilibili/utils/list_util.dart';
import 'package:better_bilibili/utils/platform_util.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaseCard extends StatelessWidget {
  final Widget title;
  final Widget? subtitle;
  final List<MetadataItem> contentItems;
  final Widget? contentItemSeparator;
  final Widget cover;
  final List<MetadataItem> coverItems;
  final Widget? badge;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;
  final List<MetadataItem> sheetItems;
  final Widget? leading;

  const BaseCard({
    super.key,
    required this.title,
    required this.cover,
    this.subtitle,
    this.contentItems = const [],
    this.contentItemSeparator,
    this.coverItems = const [],
    this.badge,
    this.contextActions = const [],
    this.onTap,
    this.sheetItems = const [],
    this.leading,
  });

  void _showSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BottomSheetWapper(child: _buildSheet(context)),
    );
  }

  void _showContextMenu(BuildContext context, Offset globalPosition) {
    final overlay = Navigator.of(context).overlay!;
    final renderBox = overlay.context.findRenderObject() as RenderBox;

    final localPosition = renderBox.globalToLocal(globalPosition);

    final relativePosition = RelativeRect.fromRect(
      Rect.fromLTWH(
        localPosition.dx,
        localPosition.dy,
        0,
        0,
      ),
      Offset.zero & renderBox.size,
    );

    showMenu<String>(
      context: context,
      position: relativePosition,
      items: [
        ...contextActions,
        PopupMenuItem(
          value: '#info',
          child: const Text('更多选项'),
          onTap: () => _showSheet(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasCustomContextMenu = contextActions.isNotEmpty;

    return Material(
      type: .card,
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onSecondaryTap: !hasCustomContextMenu ? () => _showSheet(context) : null,
        onLongPress: !hasCustomContextMenu && isMobile ? () => _showSheet(context) : null,
        onSecondaryTapDown: hasCustomContextMenu ? (details) => _showContextMenu(context, details.globalPosition) : null,
        borderRadius: .circular(12.0),
        child: Container(
          padding: const .all(10.0),
          child: Column(
            mainAxisSize: .min,
            spacing: 8.0,
            children: [
              Stack(
                children: [
                  cover,
                  Positioned(
                    right: 4,
                    bottom: 4,
                    child: Container(
                      padding: const .symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: .circular(20),
                      ),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        child: Row(
                          mainAxisSize: .min,
                          spacing: 6.0,
                          children: coverItems.map((v) => _buildMetadata(v)).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const .only(left: 6.0, right: 4.0),
                child: Row(
                  crossAxisAlignment: .start,
                  spacing: 8.0,
                  children: [
                    ?leading,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: .start,
                        spacing: 4.0,
                        children: [
                          DefaultTextStyle.merge(
                            maxLines: 2,
                            overflow: .ellipsis,
                            style: TextStyle(fontSize: 15),
                            child: title,
                          ),
                          DefaultTextStyle.merge(
                            style: TextStyle(
                              fontSize: 13,
                              color: colorScheme.outline,
                            ),
                            maxLines: 1,
                            child: Row(
                              children: contentItemSeparator == null
                                  ? contentItems.map((v) => _buildMetadata(v)).toList()
                                  : contentItems.map((v) => _buildMetadata(v)).toList().intersperse(contentItemSeparator!),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetadata(MetadataItem item) {
    Widget child;
    if (item.icon != null) {
      child = Row(
        mainAxisSize: .min,
        spacing: 2.0,
        children: [
          Icon(
            item.icon!,
            color: Colors.white,
            size: 14,
          ),
          Text(item.value),
        ],
      );
    } else {
      child = Text(item.value);
    }

    if (item.onTap != null) {
      return Flexible(
        child: MiniTextButton(onTap: item.onTap, child: child),
      );
    }

    return child;
  }

  Widget _buildSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: sheetItems.map(
        (v) {
          if (v.onTap == null && v.key != null) {
            return Padding(
              padding: const .symmetric(horizontal: 16.0, vertical: 6.0),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 2.0,
                children: [
                  Text(v.key!, style: TextStyle(fontSize: 17.0)),
                  SelectableText(v.value, style: TextStyle(color: colorScheme.outline)),
                ],
              ),
            );
          } else {
            return ListTile(
              leading: v.icon != null ? Icon(v.icon!) : null,
              title: Text(v.value),
              subtitle: switch (v.description) {
                final description? => Text(description),
                _ => null,
              },
              onTap: switch (v.onTap) {
                final onTap when v.autoClose => () {
                  context.pop();
                  onTap?.call();
                },
                _ => v.onTap,
              },
            );
          }
        },
      ).toList(),
    );
  }
}

class MetadataItem {
  final String value;
  final IconData? icon;
  final String? key;
  final VoidCallback? onTap;
  final bool autoClose;
  final String? description;

  const MetadataItem({
    required this.value,
    this.icon,
    this.key,
    this.onTap,
    this.autoClose = true,
    this.description,
  });
}
