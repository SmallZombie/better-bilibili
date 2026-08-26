import 'package:better_bilibili/data/services/bilibili/model/get_post_detail_response.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_embed.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_theme.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/tier_required_prompt.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/post_detail/view_models/collection_tab_view_model.dart';
import 'package:better_bilibili/ui/post_detail/widgets/collection_tab.dart';
import 'package:better_bilibili/ui/post_detail/view_models/post_detail_view_model.dart';
import 'package:better_bilibili/ui/post_detail/widgets/contents_tab.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart' hide Block;
import 'package:provider/provider.dart';

class PostDetailScreen extends StatefulWidget {
  final PostDetailViewModel viewModel;

  const PostDetailScreen({super.key, required this.viewModel});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final GlobalKey<EditorState> _editorKey = GlobalKey<EditorState>();
  final GlobalKey _scrollViewKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final Map<String, Line> _headerMap = {};
  final Map<String, double> _headerTopOffsetMap = {};

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();

    super.dispose();
  }

  void _onScroll() {
    if (_headerTopOffsetMap.isEmpty || !_scrollController.hasClients) return;

    const activationOffset = 16.0;
    final currentOffset = _scrollController.offset + activationOffset;
    final headerOffsets = _headerTopOffsetMap.values.toList();

    var currentIndex = 0;
    for (var i = 0; i < headerOffsets.length; i++) {
      if (currentOffset >= headerOffsets[i]) {
        currentIndex = i;
      } else {
        break;
      }
    }

    widget.viewModel.setCurrentContentsIndex(currentIndex);
  }

  double _getLineGlobalOffset(Line line) {
    final renderEditor = _editorKey.currentState?.renderEditor;
    final scrollViewBox = _scrollViewKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderEditor == null || scrollViewBox == null) return 0.0;

    final caretRect = renderEditor.getLocalRectForCaret(TextPosition(offset: line.documentOffset));
    final caretGlobal = renderEditor.localToGlobal(caretRect.topLeft);

    final viewportGlobal = scrollViewBox.localToGlobal(Offset.zero);
    final targetOffset = _scrollController.offset + caretGlobal.dy - viewportGlobal.dy;

    return targetOffset;
  }

  void _onContentsIndexChanged(int index) {
    final line = _headerMap.values.toList()[index];
    final offset = _getLineGlobalOffset(line);

    _scrollController.animateTo(
      offset.clamp(
        _scrollController.position.minScrollExtent,
        _scrollController.position.maxScrollExtent,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  String _cleanHeaderStr(String str) {
    return str.replaceAll('￼', '');
  }

  void _recalculateHeaderOffsets() {
    _headerTopOffsetMap.clear();
    for (final line in _headerMap.values) {
      _headerTopOffsetMap[_cleanHeaderStr(line.toPlainText())] = _getLineGlobalOffset(line);
    }
  }

  @override
  Widget build(BuildContext context) {
    final detail = context.select<PostDetailViewModel, PostDetail?>((value) => value.postDetail);
    if (detail == null && widget.viewModel.collectionId == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final size = MediaQuery.sizeOf(context);
    final sidebarWidth = (size.width * 0.32).clamp(350.0, 440.0);

    if (detail != null && detail.content == null) {
      return Scaffold(
        appBar: AppBar(title: Text(detail.title ?? '')),
        body: Center(child: TierRequiredPrompt(requiredTier: detail.requiredTier!)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(detail?.title ?? '')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1200.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24.0,
            children: [
              Expanded(child: _buildContent()),
              SizedBox(width: sidebarWidth, child: _buildSidebar()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final detail = widget.viewModel.postDetail;
    if (detail == null) {
      if (widget.viewModel.cover != null) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: BiliImageWapper(
            url: widget.viewModel.cover!,
            height: 400.0,
            borderRadius: BorderRadius.circular(16.0),
            suffix: kThumbnailSuffix,
          ),
        );
      } else {
        const Center(child: CircularProgressIndicator());
      }
    }

    final colorScheme = Theme.of(context).colorScheme;

    final document = Document.fromDelta(detail!.content!);
    final quillController = QuillController(
      document: document,
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );

    _headerMap.clear();
    for (final node in document.root.children) {
      if (node is Line) {
        final header = node.style.attributes['header'];
        if (header != null) {
          _headerMap[node.toPlainText()] = node;
        }
      } else if (node is Block) {
        for (final line in node.children) {
          final header = line.style.attributes['header'];
          if (header != null) {
            _headerMap[_cleanHeaderStr(line.toPlainText())] = line as Line;
          }
        }
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _recalculateHeaderOffsets());

    return Stack(
      children: [
        CustomScrollView(
          key: _scrollViewKey,
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: SelectableText(
                detail.title ?? '',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            SliverToBoxAdapter(
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                onTap: () => context.push(Routes.buildUserDetail(detail.owner.id)),
                leading: BiliUserAvatar(url: detail.owner.avatar),
                title: Text(detail.owner.nickname),
                subtitle: Text(
                  detail.modifyTime == null
                      ? '发布于 ${formatTimeToHumanReadable(detail.releaseTime!, useTime: true)}'
                      : '修改于 ${formatTimeToHumanReadable(detail.modifyTime!, useTime: true)}',
                  style: TextStyle(color: colorScheme.outline),
                ),
                trailing: ChangeNotifierProvider(
                  create: (context) => FollowTextButtonViewModel(
                    userRepository: context.read(),
                    userId: detail.owner.id,
                    initState: false,
                  ),
                  builder: (context, _) => FollowTextButton(
                    viewModel: context.read(),
                    // onChange: widget.viewModel.updateFollowStatus,
                  ),
                ),
              ),
            ),
            if (detail.cover != null) ...[
              const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
              SliverToBoxAdapter(
                child: BiliImageWapper(
                  url: detail.cover!,
                  height: 400.0,
                  borderRadius: BorderRadius.circular(16.0),
                  suffix: kThumbnailSuffix,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            SliverToBoxAdapter(
              child: NotificationListener(
                onNotification: (_) {
                  _recalculateHeaderOffsets();
                  return false;
                },
                child: SizeChangedLayoutNotifier(
                  child: QuillEditor.basic(
                    controller: quillController,
                    config: QuillEditorConfig(
                      scrollable: false,
                      padding: EdgeInsets.zero,
                      enableInteractiveSelection: true,
                      showCursor: false,
                      embedBuilders: [
                        ImageEmbedBuilder(),
                        VideoCardEmbedBuilder(),
                        PostCardEmbedBuilder(),
                        UserEmbedBuilder(),
                        DividerEmbedBuilder(),
                        InnerUserEmbedBuilder(),
                      ],
                      customStyles: quillEditorStyle(context),
                      editorKey: _editorKey,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            SliverToBoxAdapter(
              child: Wrap(
                spacing: 4.0,
                runSpacing: 4.0,
                children: [
                  // 话题
                  if (detail.topic != null)
                    ActionChip(
                      label: Text(detail.topic!.name),
                      onPressed: () {},
                    ),
                  // 小站
                  if (detail.forum != null)
                    ActionChip(
                      label: Text(detail.forum!.categoryName),
                      onPressed: () {},
                    ),
                  // 普通标签
                  ...detail.tags.map(
                    (v) => ActionChip(
                      label: Text(v),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
          ],
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: Column(
            spacing: 8.0,
            children: [
              Selector<PostDetailViewModel, ({int likeCount, bool hasLiked})>(
                selector: (_, vm) => (
                  likeCount: vm.postDetail?.stats.like ?? 0,
                  hasLiked: vm.interaction!.hasLiked,
                ),
                builder: (context, state, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.0,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'like',
                      onPressed: widget.viewModel.like.execute,
                      tooltip: '赞',
                      child: Icon(state.hasLiked ? Icons.thumb_up_alt_rounded : Icons.thumb_up_outlined),
                    ),
                    Text(
                      state.likeCount == 0 ? '赞' : formatCountToHumanReadable(state.likeCount),
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
              Selector<PostDetailViewModel, ({int favoriteCount, bool hasFavorited})>(
                selector: (_, vm) => (
                  favoriteCount: vm.postDetail?.stats.favorite ?? 0,
                  hasFavorited: vm.interaction!.hasFavorited,
                ),
                builder: (context, state, child) => Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 4.0,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'favorite',
                      onPressed: widget.viewModel.favorite.execute,
                      tooltip: '收藏',
                      child: Icon(state.hasFavorited ? Icons.star_rounded : Icons.star_outline),
                    ),
                    Text(
                      state.favoriteCount == 0 ? '收藏' : formatCountToHumanReadable(state.favoriteCount),
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final detail = widget.viewModel.postDetail;
    final collectionId = widget.viewModel.collectionId;
    if (detail == null && collectionId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    int length = 0;
    final List<Widget> tabs = [];
    final List<Widget> children = [];

    if (_headerMap.isNotEmpty) {
      length++;
      tabs.add(Tab(text: '目录', height: 32));
      children.add(
        Selector<PostDetailViewModel, int>(
          selector: (_, vm) => vm.currentContentsIndex,
          builder: (context, index, child) => ContentsTab(
            contents: _headerMap.keys.map((v) => _cleanHeaderStr(v)).toList(),
            currentIndex: index,
            onIndexChanged: _onContentsIndexChanged,
          ),
        ),
      );
    }

    if (collectionId != null) {
      length++;
      tabs.add(Tab(text: '文集', height: 32));
      children.add(
        ChangeNotifierProvider(
          create: (context) => CollectionTabViewModel(
            articleRepository: context.read(),
            collectionId: collectionId,
          ),
          builder: (context, _) => CollectionTab(
            viewModel: context.read(),
            selectedItemId: widget.viewModel.postId,
            onItemTap: (value) => widget.viewModel.switchPost(value.id, value.cover),
          ),
        ),
      );
    }

    if (detail != null) {
      length++;
      tabs.add(Tab(text: '评论', height: 32));
      children.add(
        ChangeNotifierProvider(
          create: (context) => CommentPanelViewModel(
            commentRepository: context.read(),
            commonRepository: context.read(),
            type: detail.commentType,
            id: detail.commentId,
          ),
          builder: (context, _) => CommentPanel(viewModel: context.read()),
        ),
      );
    }

    return DefaultTabController(
      length: length,
      child: Column(
        children: [
          SizedBox(height: 4.0),
          TabBar(
            splashBorderRadius: BorderRadius.circular(8.0),
            dividerColor: Colors.transparent,
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            tabs: tabs,
          ),
          Expanded(child: TabBarView(children: children)),
        ],
      ),
    );
  }
}
