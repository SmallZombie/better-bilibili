import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/chat.dart';
import 'package:better_bilibili/ui/chat/view_models/conversation_list_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class ConversationListView extends StatefulWidget {
  final ConversationListViewModel viewModel;
  final String? currentConversation;
  final ValueChanged<String>? onChange;

  const ConversationListView({
    super.key,
    required this.viewModel,
    this.currentConversation,
    this.onChange,
  });

  @override
  State<ConversationListView> createState() => _ConversationListViewState();
}

class _ConversationListViewState extends State<ConversationListView> {
  ConversationListViewModel get viewModel => widget.viewModel;

  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(minutes: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    timer?.cancel();
    timer = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const .symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              TextButton.icon(
                onPressed: () {
                  viewModel.reload();
                },
                icon: Icon(Icons.refresh),
                label: Text('刷新'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.auto_awesome_outlined),
                label: Text('自动回复'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Icon(Icons.settings_outlined),
                label: Text('设置'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: Selector<ConversationListViewModel, List<Conversation>>(
              selector: (context, vm) => vm.data,
              builder: (context, data, _) => ListView.builder(
                padding: .only(bottom: 16.0),
                itemCount: data.length + 1,
                itemBuilder: (context, index) {
                  // if (index == 0) {
                  //   return _ListItem(
                  //     data: Conversation(
                  //       id: '#unfollowed',
                  //       type: .system,
                  //       user: User(),
                  //       lastMessage: TextMessage(
                  //         id: id,
                  //         content: content,
                  //         textContent: textContent,
                  //         sendTime: sendTime,
                  //         user: user,
                  //       ),
                  //       unreadCount: unreadCount,
                  //     ),
                  //     currentUserId: viewModel.currentUserId,
                  //     selected: id == widget.currentConversation,
                  //     onTap: () => widget.onChange?.call(id),
                  //   );
                  // }

                  if (index == data.length) {
                    return _ListItemSkeleton(
                      onBuild: viewModel.loadMore.execute,
                      showError: viewModel.loadMore.error,
                      whenError: CenterErrorMessage(
                        errorMessage: viewModel.loadMore.result.toString(),
                        onRetry: viewModel.reload,
                      ),
                    );
                  }

                  final id = data[index].id;

                  return _ListItem(
                    data: data[index],
                    currentUserId: viewModel.currentUserId,
                    selected: id == widget.currentConversation,
                    onTap: () => widget.onChange?.call(id),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  final Conversation data;
  final String currentUserId;
  final bool selected;
  final VoidCallback? onTap;

  const _ListItem({
    required this.data,
    required this.currentUserId,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Badge.count(
        count: data.unreadCount,
        isLabelVisible: data.unreadCount > 0,
        child: BiliUserAvatar(
          url: data.user?.avatar ?? '',
          suffix: '@80w_80h_1c_1s',
        ),
      ),
      title: Row(
        children: [
          Text(data.user?.nickname ?? ''),
          if (ChatRepository.isOfficial(data.id)) Chip(label: Text('官方')),
        ],
      ),
      subtitle: Row(
        children: [
          if (data.user?.id == currentUserId)
            Text(
              '我：',
              style: TextStyle(color: colorScheme.primary),
            ),
          Expanded(
            child: Text(
              data.lastMessage.textContent,
              style: TextStyle(overflow: .ellipsis),
              maxLines: 1,
              overflow: .ellipsis,
            ),
          ),
          SizedBox(width: 10.0),
          Text(formatTimeToHumanReadable(data.lastMessage.sendTime)),
        ],
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: .all(.circular(12.0))),
      selected: selected,
      selectedTileColor: colorScheme.secondaryContainer,
    );
  }
}

class _ListItemSkeleton extends StatelessWidget {
  final VoidCallback? onBuild;

  final bool showError;
  final Widget? whenError;

  final bool showNoMore;
  final Widget? whenNoMore;

  const _ListItemSkeleton({
    this.onBuild,
    this.showError = false,
    this.whenError,
    this.showNoMore = false,
    this.whenNoMore,
  });

  @override
  Widget build(BuildContext context) {
    if (showError) {
      return whenError ?? SizedBox.shrink();
    }
    if (showNoMore) {
      return whenNoMore ?? SizedBox.shrink();
    }

    debugPrint('build skeleton once');
    onBuild?.call();

    final colorScheme = Theme.of(context).colorScheme;
    final color = colorScheme.secondaryContainer.withAlpha(200);

    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: color,
      ),
      title: Container(
        height: 16,
        width: 80,
        color: color,
        margin: const .symmetric(vertical: 4),
      ),
      subtitle: Row(
        children: [
          Container(
            height: 14,
            width: 24,
            color: color,
            margin: const .only(right: 6),
          ),
          Expanded(
            child: Container(
              height: 14,
              color: color,
              margin: const .only(right: 10),
            ),
          ),
          Container(
            height: 14,
            width: 60,
            color: color,
          ),
        ],
      ),
      shape: RoundedRectangleBorder(borderRadius: .all(.circular(12.0))),
    );
  }
}
