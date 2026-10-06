import 'package:better_bilibili/ui/core/bilibili/video_player/notice/notice_controller.dart';
import 'package:flutter/material.dart';

class NoticeLayer extends StatelessWidget {
  const NoticeLayer({
    super.key,
    required this.controller,
  });

  final NoticeController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: .min,
          mainAxisAlignment: .end,
          crossAxisAlignment: .start,
          spacing: 8.0,
          children: controller.visibleNotices.map((v) => _NoticeWidget(notice: v)).toList(),
        );
      },
    );
  }
}

class _NoticeWidget extends StatelessWidget {
  final Notice notice;

  const _NoticeWidget({required this.notice});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final hasAction = notice.action != null && notice.onTap != null;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(
          opacity: opacity,
          child: child,
        );
      },
      child: Container(
        padding: .fromLTRB(16.0, 8.0, hasAction ? 8.0 : 16.0, 8.0),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: .circular(8.0),
        ),
        child: DefaultTextStyle.merge(
          style: const TextStyle(color: Colors.white),
          child: Row(
            mainAxisSize: .min,
            spacing: 6.0,
            children: [
              Flexible(child: notice.content),
              if (hasAction)
                TextButton(
                  onPressed: () => notice.onTap!(notice),
                  style: TextButton.styleFrom(
                    padding: const .symmetric(horizontal: 8.0, vertical: 6.0),
                    minimumSize: .zero,
                    tapTargetSize: .shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: .circular(4)),
                  ),
                  child: Text(
                    notice.action!,
                    style: TextStyle(color: colorScheme.onPrimaryContainer),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
