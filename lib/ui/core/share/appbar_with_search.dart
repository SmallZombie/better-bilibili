import 'package:material_ui/material_ui.dart';

class AppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final Widget? title;
  final bool searchMode;
  final VoidCallback? onToggleSearchMode;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? searchHintText;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onSearchChanged;
  final bool autoFocus;

  final VoidCallback? onToggleFilter;

  final List<Widget> actions;
  final double spacing;

  const AppBarWithSearch({
    super.key,
    this.title,
    this.searchMode = false,
    this.onToggleSearchMode,
    this.searchController,
    this.searchFocusNode,
    this.searchHintText,
    this.onSearch,
    this.onSearchChanged,
    this.autoFocus = false,
    this.onToggleFilter,
    this.actions = const [],
    this.spacing = 4,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  State<AppBarWithSearch> createState() => _AppBarWithSearchState();
}

class _AppBarWithSearchState extends State<AppBarWithSearch> {
  bool _searchMode = false;
  bool get searchMode => widget.searchMode || _searchMode;
  VoidCallback get onToggleSearchMode => widget.onToggleSearchMode ?? _onToggleSearchMode;

  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;
  TextEditingController get searchController => widget.searchController ?? (_searchController ??= TextEditingController());
  FocusNode get searchFocusNode => widget.searchFocusNode ?? (_searchFocusNode ??= FocusNode());

  @override
  void didUpdateWidget(covariant AppBarWithSearch oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (!oldWidget.searchMode && widget.searchMode) {
      _searchFocusNode?.requestFocus();
    }
  }

  void _onToggleSearchMode() {
    setState(() {
      _searchMode = !_searchMode;
    });
    searchFocusNode.requestFocus();
  }

  /// 如果传入了 [searchController] 则由使用者处理 trim 等事务
  ///
  /// 否则由此函数负责处理 trim 并调用 [onSearch]
  void _searchHandler(String value) {
    if (value.isEmpty) return;

    final trim = value.trim();
    if (trim.isEmpty) return;

    widget.onSearch?.call(trim);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final enableSearch = widget.onSearch != null;
    final enableFilter = widget.onToggleFilter != null;

    return AppBar(
      leading: enableSearch && searchMode
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                onToggleSearchMode();
                if (searchController.text.isNotEmpty) {
                  searchController.clear();
                  _searchHandler('');
                }
              },
              tooltip: '退出搜索',
            )
          : null,
      automaticallyImplyLeading: enableSearch ? !searchMode : true,
      title: enableSearch && searchMode
          ? TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              decoration: InputDecoration(
                hintText: widget.searchHintText,
                prefixIcon: const Icon(Icons.search, size: 22),
                suffixIcon: searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          searchController.clear();
                          setState(() {});
                          widget.onSearchChanged?.call('');
                        },
                      ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(borderRadius: .circular(8), borderSide: .none),
                contentPadding: const .symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              textInputAction: .search,
              onSubmitted: _searchHandler,
              onChanged: (value) {
                setState(() {});
                widget.onSearchChanged?.call(value);
              },
              autofocus: widget.autoFocus,
            )
          : widget.title,
      actions: [
        if (enableSearch && !searchMode)
          IconButton(
            onPressed: onToggleSearchMode,
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),

        if (enableFilter) ...[
          if ((enableSearch && !searchMode) || enableFilter) SizedBox(width: widget.spacing),
          IconButton(
            onPressed: widget.onToggleFilter,
            icon: const Icon(Icons.filter_list),
            tooltip: '筛选',
          ),
        ],
        if (widget.actions.isNotEmpty) SizedBox(width: widget.spacing),
        ...widget.actions,
      ],
    );
  }
}
