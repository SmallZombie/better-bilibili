import 'package:flutter/material.dart';

/// 分页组件，显示页码，允许用户切换页数
///
/// 用法示例：
///
/// ```dart
/// Paginator(
///   maxPageCount: (total + (ps - 1)) ~/ ps, // 向上取整
///   currentPage: pn,
///   onPageChanged: (page) => setPn(page),
/// )
/// ```
class Paginator extends StatefulWidget {
  final int maxPageCount;
  final int currentPage;
  final ValueChanged<int> onPageChanged;

  const Paginator({
    super.key,
    required this.maxPageCount,
    required this.currentPage,
    required this.onPageChanged,
  });

  @override
  State<Paginator> createState() => _PaginatorState();
}

class _PaginatorState extends State<Paginator> {
  late TextEditingController _pageController;
  late FocusNode _focusNode;

  bool get _hasPrev => widget.currentPage > 1;
  bool get _hasNext => widget.currentPage < widget.maxPageCount && widget.maxPageCount > 0;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(text: widget.currentPage.toString());
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(Paginator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _pageController.text = widget.currentPage.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final p = page.clamp(1, widget.maxPageCount);
    if (p != widget.currentPage && widget.maxPageCount > 0) {
      widget.onPageChanged(p);
    }
  }

  void _onJump() {
    _focusNode.unfocus();
    final text = _pageController.text.trim();
    if (text.isEmpty) return;
    final page = int.tryParse(text);
    if (page == null || page < 1) {
      _pageController.text = widget.currentPage.toString();
      return;
    }
    _goToPage(page);
    _pageController.text = widget.currentPage.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton.filled(
          onPressed: _hasPrev ? () => _goToPage(1) : null,
          icon: const Icon(Icons.first_page),
          tooltip: '首页',
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          onPressed: _hasPrev ? () => _goToPage(widget.currentPage - 1) : null,
          icon: const Icon(Icons.chevron_left),
          tooltip: '上一页',
        ),
        const SizedBox(width: 8),
        Text(
          '第 ${widget.currentPage} / ${widget.maxPageCount} 页',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(width: 8),
        IconButton.filled(
          onPressed: _hasNext ? () => _goToPage(widget.currentPage + 1) : null,
          icon: const Icon(Icons.chevron_right),
          tooltip: '下一页',
        ),
        const SizedBox(width: 4),
        IconButton.filled(
          onPressed: _hasNext ? () => _goToPage(widget.maxPageCount) : null,
          icon: const Icon(Icons.last_page),
          tooltip: '尾页',
        ),
        const SizedBox(width: 24),
        SizedBox(
          width: 64,
          child: TextField(
            controller: _pageController,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: const InputDecoration(
              hintText: '页',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              isDense: true,
            ),
            onSubmitted: (_) => _onJump(),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton(
          onPressed: _onJump,
          child: const Text('跳转'),
        ),
      ],
    );
  }
}
