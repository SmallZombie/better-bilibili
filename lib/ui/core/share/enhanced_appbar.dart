import 'package:flutter/material.dart';

const double kMultiSelectActionsSpacing = 4.0;

class EnhancedAppBar extends StatefulWidget implements PreferredSizeWidget {
  final Widget? title;
  final PreferredSizeWidget? bottom;

  final bool searchMode;
  final VoidCallback? onToggleSearchMode;
  final TextEditingController? searchController;
  final FocusNode? searchFocusNode;
  final String? searchHintText;
  final void Function(String?)? onSearch;

  final bool multiSelectMode;
  final VoidCallback? onToggleMultiSelectMode;
  final int? multiSelectCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onDeselectAll;
  final VoidCallback? onInvertSelection;
  final List<Widget>? multiSelectActions;

  final VoidCallback? onToggleFilter;

  final List<Widget> actions;
  final double spacing;

  @Deprecated('Use [AppBarWithSearch] and [MultiSelectToolbar] instead')
  const EnhancedAppBar({
    super.key,
    this.title,
    this.bottom,
    this.searchMode = false,
    this.onToggleSearchMode,
    this.searchController,
    this.searchFocusNode,
    this.searchHintText,
    this.onSearch,
    this.multiSelectMode = false,
    this.onToggleMultiSelectMode,
    this.multiSelectCount,
    this.onSelectAll,
    this.onDeselectAll,
    this.onInvertSelection,
    this.multiSelectActions,
    this.onToggleFilter,
    this.actions = const [],
    this.spacing = 4,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  State<EnhancedAppBar> createState() => _EnhancedAppBarState();
}

class _EnhancedAppBarState extends State<EnhancedAppBar> {
  bool _searchMode = false;
  bool get searchMode => widget.searchMode || _searchMode;
  VoidCallback get onToggleSearchMode => widget.onToggleSearchMode ?? _onToggleSearchMode;

  TextEditingController? _searchController;
  FocusNode? _searchFocusNode;
  TextEditingController get searchController => widget.searchController ?? (_searchController ??= TextEditingController());
  FocusNode get searchFocusNode => widget.searchFocusNode ?? (_searchFocusNode ??= FocusNode());

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
    if (value.isEmpty) {
      return widget.onSearch?.call(null);
    }

    final trim = value.trim();
    widget.onSearch?.call(trim.isEmpty ? null : trim);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final enableSearch = widget.onSearch != null;

    final enableMultiSelect = widget.onToggleMultiSelectMode != null;

    final List<Widget> mutiSelectActions = [];

    if (widget.multiSelectCount != null) {
      mutiSelectActions.add(
        Text(
          '已选 ${widget.multiSelectCount} 项',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      );
    }
    if (widget.onSelectAll != null) {
      if (mutiSelectActions.isNotEmpty) {
        mutiSelectActions.add(const SizedBox(width: kMultiSelectActionsSpacing));
      }
      mutiSelectActions.add(
        IconButton(
          onPressed: widget.onSelectAll,
          icon: const Icon(Icons.select_all),
          tooltip: '全选',
        ),
      );
    }
    if (widget.onDeselectAll != null) {
      if (mutiSelectActions.isNotEmpty) {
        mutiSelectActions.add(const SizedBox(width: kMultiSelectActionsSpacing));
      }
      mutiSelectActions.add(
        IconButton(
          onPressed: widget.onDeselectAll,
          icon: const Icon(Icons.deselect),
          tooltip: '取消全选',
        ),
      );
    }
    if (widget.onInvertSelection != null) {
      if (mutiSelectActions.isNotEmpty) {
        mutiSelectActions.add(const SizedBox(width: kMultiSelectActionsSpacing));
      }
      mutiSelectActions.add(
        IconButton(
          onPressed: widget.onInvertSelection,
          icon: const Icon(Icons.invert_colors),
          tooltip: '反选',
        ),
      );
    }
    widget.multiSelectActions?.forEach((action) {
      if (mutiSelectActions.isNotEmpty) {
        mutiSelectActions.add(const SizedBox(width: kMultiSelectActionsSpacing));
      }
      mutiSelectActions.add(action);
    });

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
                          _searchHandler('');
                        },
                      ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: _searchHandler,
              onChanged: (_) => setState(() {}),
            )
          : widget.title,
      actions: [
        if (enableSearch && !searchMode)
          IconButton(
            onPressed: onToggleSearchMode,
            icon: const Icon(Icons.search),
            tooltip: '搜索',
          ),
        if (widget.multiSelectMode) ...[
          if (enableSearch && !searchMode) SizedBox(width: widget.spacing),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colorScheme.outlineVariant),
              ),
            ),
            child: Row(children: mutiSelectActions),
          ),
        ],
        if (enableMultiSelect) ...[
          if ((enableSearch && !searchMode) || widget.multiSelectMode) SizedBox(width: widget.spacing),
          IconButton(
            onPressed: widget.onToggleMultiSelectMode,
            icon: Icon(Icons.checklist_rtl, color: widget.multiSelectMode ? colorScheme.primary : null),
            style: widget.multiSelectMode
                ? IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                  )
                : null,
            tooltip: '多选模式',
          ),
        ],

        if (enableFilter) ...[
          if ((enableSearch && !searchMode) || widget.multiSelectMode || enableFilter) SizedBox(width: widget.spacing),
          IconButton(
            onPressed: widget.onToggleFilter,
            icon: Icon(Icons.filter_list),
            tooltip: '筛选',
          ),
        ],
        if (widget.actions.isNotEmpty) SizedBox(width: widget.spacing),
        ...widget.actions,
      ],
      bottom: widget.bottom,
    );
  }
}
