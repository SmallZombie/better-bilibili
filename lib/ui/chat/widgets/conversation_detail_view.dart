import 'package:better_bilibili/data/services/bilibili/model/get_video_cards.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/chat/view_models/conversation_detail_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/live/live_room_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/bili_rich_text_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/sticker_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/rich_text/unknown_link_parse_node.dart';
import 'package:better_bilibili/ui/core/bilibili/skeleton/skeleton_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_tile.dart';
import 'package:better_bilibili/ui/core/share/mini_text_button.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/share/texted_divider.dart';
import 'package:better_bilibili/utils/list_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ConversationDetailView extends StatefulWidget {
  final ConversationDetailViewModel viewModel;

  const ConversationDetailView({super.key, required this.viewModel});

  @override
  State<ConversationDetailView> createState() => _ConversationDetailViewState();
}

class _ConversationDetailViewState extends State<ConversationDetailView> {
  ConversationDetailViewModel get viewModel => widget.viewModel;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    viewModel.loadMore.addListener(_onResult);
  }

  @override
  void dispose() {
    _scrollController.dispose();

    super.dispose();
  }

  void _onResult() {
    if (viewModel.loadMore.completed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });

      _scrollToBottom();
      viewModel.loadMore.clearResult();
    } else if (viewModel.loadMore.error) {
      context.showError('加载失败');
      viewModel.loadMore.clearResult();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.elasticOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 65.0,
        backgroundColor: colorScheme.secondary,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(Routes.homeChat);
            }
          },
          icon: Icon(
            Icons.arrow_back,
            color: colorScheme.onSecondary,
          ),
        ),
        titleSpacing: 0,
        title: Selector<ConversationDetailViewModel, ({String avatar, String nickname, String desc})>(
          selector: (context, vm) => (
            avatar: vm.headerInfo.avatar,
            nickname: vm.headerInfo.nickname,
            desc: vm.headerInfo.description,
          ),
          builder: (context, state, _) => Row(
            spacing: 16.0,
            children: [
              BiliUserAvatar(url: state.avatar, size: 45.0),
              Column(
                crossAxisAlignment: .start,
                spacing: 4.0,
                children: [
                  Text(
                    state.nickname,
                    style: TextStyle(color: colorScheme.onSecondary, fontSize: 22.0),
                  ),
                  Text(
                    state.desc,
                    style: TextStyle(
                      color: Color.lerp(colorScheme.onSecondary, colorScheme.outline, .3),
                      fontSize: 14.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => viewModel.reload(),
            icon: Icon(Icons.more_horiz, color: colorScheme.onSecondary),
            tooltip: '更多选项',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Selector<ConversationDetailViewModel, List<BaseMessage>>(
              selector: (context, vm) => vm.data,
              builder: (context, data, _) {
                if (data.isEmpty) {
                  return Text('loading...');
                }

                final List<Widget> slivers = [];

                slivers.add(SliverToBoxAdapter(child: TextedDivider(height: 80.0, child: Text('到顶了'))));

                for (final i in data) {
                  if (i is TextMessage) {
                    slivers.add(
                      SliverPadding(
                        padding: const .symmetric(horizontal: 24.0),
                        sliver: SliverToBoxAdapter(
                          child: _TextMessageBlock(
                            style: i.sender.id == viewModel.currentUser.id ? .right : .left,
                            message: i,
                          ),
                        ),
                      ),
                    );
                  } else if (i is ImageMessage) {
                    slivers.add(
                      SliverPadding(
                        padding: const .symmetric(horizontal: 24.0),
                        sliver: SliverToBoxAdapter(
                          child: _ImageMessageBlock(message: i),
                        ),
                      ),
                    );
                  } else if (i is LiveRoomShareMessage) {
                    slivers.add(
                      SliverPadding(
                        padding: const .symmetric(horizontal: 24.0),
                        sliver: SliverToBoxAdapter(
                          child: _LiveRoomShareMessageBlock(message: i),
                        ),
                      ),
                    );
                  } else if (i is VideoShareMessage) {
                    slivers.add(
                      SliverPadding(
                        padding: const .symmetric(horizontal: 24.0),
                        sliver: SliverToBoxAdapter(
                          child: Selector<ConversationDetailViewModel, bool>(
                            selector: (context, vm) => vm.videoInfoMap.containsKey(i.videoId),
                            builder: (context, value, _) => _VideoShareMessageBlock(
                              loading: !value,
                              message: i,
                              video: viewModel.videoInfoMap[i.videoId],
                            ),
                          ),
                        ),
                      ),
                    );
                  } else if (i is PostShareMessage) {
                    slivers.add(
                      SliverPadding(
                        padding: const .symmetric(horizontal: 24.0),
                        sliver: SliverToBoxAdapter(
                          child: _PostShareMessageBlock(message: i),
                        ),
                      ),
                    );
                  }
                }

                return CustomScrollView(
                  controller: _scrollController,
                  slivers: slivers.intersperse(SliverToBoxAdapter(child: SizedBox(height: 8.0))),
                );
              },
            ),
          ),

          SizedBox(height: 8.0),
          _MessageComposer(
            onSubmit: (value) {
              debugPrint('onSubmit: $value');
              viewModel.appendMessage(
                TextMessage(
                  id: '0',
                  content: value,
                  textContent: value,
                  sendTime: (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
                  sender: User(
                    id: viewModel.currentUser.id,
                    nickname: viewModel.currentUser.nickname,
                    avatar: viewModel.currentUser.avatar,
                  ),
                  isAutoReply: false,
                ),
              );
            },
          ),

          SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final ValueChanged<String>? onSubmit;

  _MessageComposer({this.onSubmit});

  final GlobalKey<FormState> formKey = GlobalKey();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: .center,
      spacing: 4.0,
      children: [
        IconButton(
          onPressed: () {},
          icon: Icon(
            Icons.add_circle_outline,
            size: 26.0,
          ),
        ),
        LimitedBox(
          maxWidth: 500,
          child: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              minLines: 1,
              maxLines: 5,
              keyboardType: .multiline,
              textInputAction: .done,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: .circular(24.0)),
                labelText: '喵',
                floatingLabelBehavior: .never,
                suffixIcon: Row(
                  mainAxisSize: .min,
                  crossAxisAlignment: .center,
                  spacing: 4.0,
                  children: [
                    IconButton(onPressed: () {}, icon: Icon(Icons.emoji_emotions_outlined)),
                    IconButton(onPressed: () {}, icon: Icon(Icons.file_upload_outlined)),
                    SizedBox(width: 4.0),
                  ],
                ),
              ),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            final input = controller.text.trim();
            if (input.isEmpty) return;

            onSubmit?.call(input);
            controller.clear();
          },
          icon: Icon(Icons.send_outlined),
        ),
      ],
    );
  }
}

enum _MessageBlockStyle {
  left,
  right,
}

class _MessageBlockWapper extends StatelessWidget {
  final _MessageBlockStyle style;
  final User user;
  final int sendTime;
  final Widget child;

  const _MessageBlockWapper({
    this.style = .left,
    required this.user,
    required this.sendTime,
    required this.child,
  });

  /// 格式化秒级时间戳
  /// 当天时间会被格式化为 `10:00 PM`、`24:00`
  /// 昨天的时间会被格式化为 `昨天 10:00`、`昨天 24:00`
  /// 更早的则会被格式化为 `yyyy-MM-dd HH:mm`
  String formatTime(BuildContext context, int ts, {bool use12HourFormat = true}) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;

    if (isToday) {
      if (use12HourFormat) {
        return TimeOfDay.fromDateTime(date).format(context);
      } else {
        return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
    } else if (isYesterday) {
      String hourMinute;
      if (use12HourFormat) {
        hourMinute = TimeOfDay.fromDateTime(date).format(context);
      } else {
        hourMinute = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
      return "昨天 $hourMinute";
    } else {
      return "${date.year.toString().padLeft(4, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: style == .left ? .start : .end,
      crossAxisAlignment: .start,
      spacing: 6.0,
      children: [
        BiliUserAvatar(url: user.avatar, size: 45.0),
        Flexible(
          child: Column(
            crossAxisAlignment: style == .left ? .start : .end,
            children: [
              Row(
                spacing: 6.0,
                children: [
                  MiniTextButton(
                    child: Text(user.nickname),
                    onTap: () => context.push(Routes.buildUserDetail(user.id)),
                  ),
                  Text(
                    formatTime(context, sendTime),
                    style: TextStyle(color: colorScheme.outline, fontSize: 12.0),
                  ),
                ].reverseWhenTrue(style == .right),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: child,
              ),
            ],
          ),
        ),
      ].reverseWhenTrue(style == .right),
    );
  }
}

class _TextMessageBlock extends StatelessWidget {
  final _MessageBlockStyle style;
  final TextMessage message;

  const _TextMessageBlock({this.style = .left, required this.message});

  /// 格式化秒级时间戳
  /// 当天时间会被格式化为 `10:00 PM`、`24:00`
  /// 昨天的时间会被格式化为 `昨天 10:00`、`昨天 24:00`
  /// 更早的则会被格式化为 `yyyy-MM-dd HH:mm`
  String formatTime(BuildContext context, int ts, {bool use12HourFormat = true}) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
    final isYesterday = date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;

    if (isToday) {
      if (use12HourFormat) {
        return TimeOfDay.fromDateTime(date).format(context);
      } else {
        return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
    } else if (isYesterday) {
      String hourMinute;
      if (use12HourFormat) {
        hourMinute = TimeOfDay.fromDateTime(date).format(context);
      } else {
        hourMinute = "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
      }
      return "昨天 $hourMinute";
    } else {
      return "${date.year.toString().padLeft(4, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')} "
          "${date.hour.toString().padLeft(2, '0')}:"
          "${date.minute.toString().padLeft(2, '0')}";
    }
  }

  /// 检查消息中是否只有一个 sticker
  bool isOnlySticker() {
    if (!RegExp(r'^\[[\u4E00-\u9FFF_a-zA-Z0-9]+\]$').hasMatch(message.content)) {
      return false;
    }

    if (message.stickers.length != 1) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    List<Sticker> stickers = message.stickers;
    if (isOnlySticker()) {
      stickers = [
        message.stickers.first.copyWith(
          size: 100,
        ),
      ];
    }

    return _MessageBlockWapper(
      style: .left,
      user: message.sender,
      sendTime: message.sendTime,
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          Container(
            padding: .symmetric(horizontal: 12.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: .all(.circular(18.0)),
              color: colorScheme.surfaceContainerHigh,
            ),
            child: BiliRichTextWapper(
              rawText: message.content,
              parserNodes: [
                StickerParseNode(stickers: stickers),
                UnknownLinkParseNode(primaryColor: colorScheme.primary),
              ],
            ),
          ),
          if (message.isAutoReply)
            Padding(
              padding: const .only(top: 2.0),
              child: Row(
                spacing: 4.0,
                children: [
                  Icon(
                    Icons.auto_awesome_outlined,
                    color: colorScheme.outline,
                    size: 14,
                  ),
                  Text(
                    '此消息为自动回复',
                    style: TextStyle(
                      color: colorScheme.outline,
                      fontSize: 13.0,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageMessageBlock extends StatelessWidget {
  final ImageMessage message;

  const _ImageMessageBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return _MessageBlockWapper(
      style: .left,
      user: message.sender,
      sendTime: message.sendTime,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 100),
        child: BiliImageWapper(
          url: message.url,
          width: 100,
          height: 100,
          suffix: '@${(message.width / 2).toInt()}w_${(message.height / 2).toInt()}h_1c',
        ),
      ),
    );
  }
}

class _LiveRoomShareMessageBlock extends StatelessWidget {
  final LiveRoomShareMessage message;

  const _LiveRoomShareMessageBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return _MessageBlockWapper(
      style: .left,
      user: message.sender,
      sendTime: message.sendTime,
      child: Padding(
        padding: const .all(8),
        child: LiveRoomTile(
          liveRoomId: message.liveRoomId,
          cover: message.liveRoomCover,
          title: message.liveRoomName,
          nickname: message.nickname,
        ),
      ),
    );
  }
}

class _VideoShareMessageBlock extends StatelessWidget {
  final bool loading;
  final VideoShareMessage message;
  final GetVideoCardsItem? video;

  const _VideoShareMessageBlock({
    this.loading = false,
    required this.message,
    this.video,
  }) : assert(loading == true || video != null);

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = SkeletonTile();
    } else {
      content = VideoTile(
        videoId: video!.videoId,
        title: video!.title,
        cover: video!.cover,
      );
    }

    return _MessageBlockWapper(
      style: .left,
      user: message.sender,
      sendTime: message.sendTime,
      child: Padding(
        padding: const .all(8),
        child: content,
      ),
    );
  }
}

class _ArticleShareMessageBlock extends StatelessWidget {
  final bool loading;
  final ArticleShareMessage message;
  final GetVideoCardsItem? article;

  const _ArticleShareMessageBlock({
    this.loading = false,
    required this.message,
    this.article,
  }) : assert(loading == true || article != null);

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = SkeletonTile();
    }

    content = VideoTile(
      videoId: article!.videoId,
      title: article!.title,
      cover: article!.cover,
    );

    return _MessageBlockWapper(
      style: .left,
      user: message.sender,
      sendTime: message.sendTime,
      child: Padding(
        padding: const .all(8),
        child: content,
      ),
    );
  }
}

class _SeriesShareMessageBlock extends StatelessWidget {
  final bool loading;
  final GetVideoCardsItem? series;

  const _SeriesShareMessageBlock({
    this.loading = false,
    this.series,
  }) : assert(loading == true || series != null);

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (loading) {
      content = SkeletonTile();
    }

    content = VideoTile(
      videoId: series!.videoId,
      title: series!.title,
      cover: series!.cover,
    );

    return Padding(
      padding: const .all(8),
      child: content,
    );
  }
}

class _PostShareMessageBlock extends StatelessWidget {
  final PostShareMessage message;

  const _PostShareMessageBlock({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(8),
      child: PostTile(
        postId: message.postId,
        cover: message.postCover,
        title: message.postTitle,
      ),
    );
  }
}

class _UnreadMessageBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primaryContainer,
      margin: .symmetric(vertical: 16.0),
      padding: .symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        spacing: 8.0,
        children: [
          Icon(
            Icons.more_horiz,
            color: colorScheme.onPrimaryContainer,
          ),
          Text(
            '以下为新消息',
            style: TextStyle(color: colorScheme.onPrimaryContainer),
          ),
        ],
      ),
    );
  }
}

extension _ReverseWhenTrueExtension on List<Widget> {
  List<Widget> reverseWhenTrue(bool shouldReverse) {
    return shouldReverse ? reversed.toList() : this;
  }
}
