import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/chat/view_models/conversation_detail_view_model.dart';
import 'package:better_bilibili/ui/chat/view_models/conversation_list_view_model.dart';
import 'package:better_bilibili/ui/chat/widgets/conversation_detail_view.dart';
import 'package:better_bilibili/ui/chat/widgets/conversation_list_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// bilibili://home/chat/:id bilibili://chat/:id
class ChatShell extends StatefulWidget {
  final String? conversationId;

  const ChatShell({super.key, this.conversationId});

  @override
  State<ChatShell> createState() => _ChatShellState();
}

class _ChatShellState extends State<ChatShell> {
  // @override
  // void didUpdateWidget(covariant ChatShell oldWidget) {
  //   super.didUpdateWidget(oldWidget);

  //   if (oldWidget.conversationId != widget.conversationId) {
  //     if (widget.conversationId != null) {
  //       onConversationChanged(widget.conversationId!);
  //     }
  //   }
  // }

  void onConversationChanged(String conversationId) {
    final location = Routes.buildConversationDetail(conversationId);

    if (MediaQuery.sizeOf(context).width >= 720) {
      context.go(location);
    } else {
      context.push(location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    if (size.width >= 720) {
      return Material(
        color: colorScheme.surfaceContainer,
        borderRadius: .only(topLeft: .circular(24.0), bottomLeft: .circular(24.0)),
        child: Row(
          children: [
            Padding(
              padding: const .symmetric(horizontal: 16.0),
              child: SizedBox(
                width: 360,
                child: ChangeNotifierProvider(
                  create: (context) => ConversationListViewModel(
                    authRepository: context.read(),
                    chatRepository: context.read(),
                  ),
                  builder: (context, _) => ConversationListView(
                    viewModel: context.read(),
                    currentConversation: widget.conversationId,
                    onChange: (conversationId) => onConversationChanged(conversationId),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: .all(16.0),
                decoration: BoxDecoration(borderRadius: .all(.circular(16.0))),
                clipBehavior: .antiAlias,
                child: widget.conversationId == null
                    ? _EmptyMessageDetail()
                    : ChangeNotifierProvider(
                        key: Key('conversation_detail.${widget.conversationId}'),
                        create: (context) => ConversationDetailViewModel(
                          authRepository: context.read(),
                          chatRepository: context.read(),
                          userRepository: context.read(),
                          videoRepository: context.read(),
                          conversationId: widget.conversationId!,
                        ),
                        builder: (context, _) => ConversationDetailView(viewModel: context.read()),
                      ),
              ),
            ),
          ],
        ),
      );
    }

    if (widget.conversationId != null) {
      return ChangeNotifierProvider(
        create: (context) => ConversationDetailViewModel(
          authRepository: context.read(),
          chatRepository: context.read(),
          userRepository: context.read(),
          videoRepository: context.read(),
          conversationId: widget.conversationId!,
        ),
        builder: (context, _) => ConversationDetailView(viewModel: context.read()),
      );
    }

    return ChangeNotifierProvider(
      create: (context) => ConversationListViewModel(
        authRepository: context.read(),
        chatRepository: context.read(),
      ),
      builder: (context, _) => ConversationListView(
        viewModel: context.read(),
        onChange: (conversationId) => onConversationChanged(conversationId),
      ),
    );
  }
}

class _EmptyMessageDetail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(child: Text('未选择任何对话'));
  }
}
