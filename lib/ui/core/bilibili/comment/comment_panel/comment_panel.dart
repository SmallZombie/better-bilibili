import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:better_bilibili/domain/models/bilibili/comment.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_panel/comment_panel_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_tile/comment_tile.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_tile/comment_tile_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/themes/theme.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CommentPanel extends StatefulWidget {
  final CommentPanelViewModel viewModel;
  final Function(int episodeIndex, Duration time)? onTapTime;

  const CommentPanel({
    super.key,
    required this.viewModel,
    this.onTapTime,
  });

  @override
  State<CommentPanel> createState() => _CommentPanelState();
}

class _CommentPanelState extends State<CommentPanel> with AutomaticKeepAliveClientMixin {
  @override
  void initState() {
    super.initState();

    widget.viewModel.deleteComment.addListener(_onResult);
  }

  @override
  void dispose() {
    widget.viewModel.deleteComment.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.deleteComment.error) {
      context.showError('删除失败: ${widget.viewModel.deleteComment.result.toString()}');
      widget.viewModel.deleteComment.clearResult();
    }
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (notification.metrics.maxScrollExtent - notification.metrics.pixels <= 400 &&
        !widget.viewModel.loadData.running &&
        widget.viewModel.hasMore) {
      widget.viewModel.loadData.execute();
    }

    return false;
  }

  void _onReply(Comment? target) {
    widget.viewModel.setReplyTarget(target);
    showModalBottomSheet(
      context: context,
      enableDrag: false,
      isScrollControlled: true,
      builder: (context) => ChangeNotifierProvider.value(
        value: widget.viewModel,
        child: _CommentInput(viewModel: widget.viewModel),
      ),
    );
  }

  Future<void> _onDelete(Comment comment) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除评论'),
        content: Text('确定要删除评论吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('确定')),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      widget.viewModel.deleteComment.execute(comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        ListenableBuilder(
          listenable: Listenable.merge([
            widget.viewModel.loadData,
            widget.viewModel.post,
            widget.viewModel.deleteComment,
          ]),
          builder: (context, child) {
            if (widget.viewModel.loadData.running && widget.viewModel.comments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (widget.viewModel.loadData.error) {
              return CenterErrorMessage(
                errorMessage: widget.viewModel.loadData.result.toString(),
                onRetry: widget.viewModel.loadData.execute,
              );
            }

            return NotificationListener<ScrollNotification>(
              onNotification: _onScroll,
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: ListView.builder(
                  itemCount: widget.viewModel.comments.length,
                  itemBuilder: (context, index) {
                    final comment = widget.viewModel.comments[index];
                    return ChangeNotifierProvider(
                      key: ValueKey('${comment.id}-${comment.replyCount}'),
                      create: (context) => CommentTileViewModel(commentApiService: context.read(), comment: comment),
                      child: CommentTile(
                        onReply: (target) => _onReply(target),
                        onDelete: _onDelete,
                        onTapTime: widget.onTapTime,
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: FloatingActionButton.small(
            onPressed: () => _onReply(null),
            child: const Icon(Icons.comment_outlined),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _CommentInput extends StatefulWidget {
  final CommentPanelViewModel viewModel;

  const _CommentInput({required this.viewModel});

  @override
  State<_CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<_CommentInput> {
  final FocusNode _focusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _editingController = TextEditingController();

  bool _isMentionPanelOpend = false;
  bool _isStickerPanelOpend = false;

  String lastMentionKeyword = '';
  final List<MentionUser> _mentionedUsers = [];

  @override
  void initState() {
    super.initState();

    _editingController.addListener(_onEditingChanged);
    widget.viewModel.post.addListener(_onResult);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _editingController.removeListener(_onEditingChanged);
    widget.viewModel.post.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (widget.viewModel.post.completed) {
      _editingController.clear();
      widget.viewModel.clearImage();
      widget.viewModel.setReplyTarget(null);
      widget.viewModel.post.clearResult();
      context.pop();
    } else if (widget.viewModel.post.error) {
      context.showError('发布失败: ${widget.viewModel.post.result.toString()}');
      widget.viewModel.post.clearResult();
    }
  }

  void _onCancelReply() {
    widget.viewModel.setReplyTarget(null);
  }

  void _onEditingChanged() {
    final mentionAt = _getMentionAtCursor();

    if (mentionAt == null && _isMentionPanelOpend) {
      _hideMentionPanel();
    }
    if (mentionAt != null && !_isMentionPanelOpend) {
      _showMentionPanel(reloadList: false);
    }
    if (_isMentionPanelOpend && mentionAt != lastMentionKeyword) {
      widget.viewModel.reloadMentionUserList(mentionAt);
      lastMentionKeyword = mentionAt!;
    }
  }

  void _toggleMentionPanel() {
    if (_isMentionPanelOpend) {
      _hideMentionPanel();
    } else {
      _showMentionPanel();
      if (_isStickerPanelOpend) _toggleStickerPanel();
    }
  }

  void _showMentionPanel({bool reloadList = true}) {
    if (_isMentionPanelOpend) return;
    setState(() {
      _isMentionPanelOpend = true;
    });

    if (reloadList) {
      widget.viewModel.reloadMentionUserList(null);
      lastMentionKeyword = '';
    }
    _focusNode.requestFocus();
  }

  void _hideMentionPanel() {
    if (!_isMentionPanelOpend) return;
    setState(() {
      _isMentionPanelOpend = false;
    });
    _focusNode.requestFocus();
  }

  void _onPickMentionUser(MentionUser user) {
    final text = _editingController.text;
    final selection = _editingController.selection;
    final cursor = selection.isValid ? selection.baseOffset : text.length;

    // 从 cursor 往前找最近的 '@'，直到空格/行首为止
    int at = cursor - 1;
    while (at >= 0 && at < text.length) {
      final ch = text[at];
      if (ch == '@') break;
      if (ch == ' ' || ch == '\n') {
        at = -1;
        break;
      }
      at--;
    }

    if (at < 0) {
      // 没找到就直接插入
      final before = text.substring(0, cursor);
      final after = text.substring(cursor);
      final insert = '@${user.nickname} ';
      _editingController.value = TextEditingValue(
        text: '$before$insert$after',
        selection: TextSelection.collapsed(offset: before.length + insert.length),
      );
    } else {
      // mention 的结束位置：cursor 之后直到遇到空格/换行/文本末尾
      int end = cursor;
      while (end < text.length) {
        final ch = text[end];
        if (ch == ' ' || ch == '\n') break;
        end++;
      }

      final before = text.substring(0, at);
      final after = text.substring(end);
      final insert = '@${user.nickname} ';
      _editingController.value = TextEditingValue(
        text: '$before$insert$after',
        selection: TextSelection.collapsed(offset: before.length + insert.length),
      );
    }

    _mentionedUsers.add(user);
    _hideMentionPanel();
  }

  /// 获取指针处的提及文本，没有有效提及返回 null，有 '@' 但什么都没输入则是 ''
  String? _getMentionAtCursor() {
    final text = _editingController.text;
    final selection = _editingController.selection;
    final cursor = selection.isValid && selection.isCollapsed ? selection.baseOffset : text.length;

    final end = cursor - 1;
    if (end < 0 || end >= text.length) return null;
    int start = end;
    while (start >= 0) {
      if (text[start] == ' ' || text[start] == '@') {
        break;
      }
      start--;
    }

    final mentionText = text.substring(max(start, 0), end + 1);
    return mentionText.startsWith('@') ? mentionText.substring(1) : null;
  }

  void _toggleStickerPanel() {
    setState(() {
      _isStickerPanelOpend = !_isStickerPanelOpend;
    });
    if (_isStickerPanelOpend) {
      if (_isMentionPanelOpend) _toggleMentionPanel();
      if (widget.viewModel.stickers.isEmpty) {
        widget.viewModel.loadStickers.execute();
      }
    }
    _focusNode.requestFocus();
  }

  void _insertSticker(Sticker sticker) {
    final text = _editingController.text;
    final selection = _editingController.selection;

    int baseOffset;
    int extentOffset;
    if (selection.isValid) {
      baseOffset = selection.baseOffset;
      extentOffset = selection.extentOffset;
    } else {
      baseOffset = extentOffset = text.length;
    }

    final before = text.substring(0, baseOffset);
    final after = text.substring(extentOffset, text.length);

    _editingController.value = TextEditingValue(
      text: '$before${sticker.code}$after',
      selection: TextSelection.collapsed(offset: (before + sticker.code).length),
    );
    _focusNode.requestFocus();
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (!mounted || result == null) return;

    final maxCount = 9 - result.files.length;
    if (maxCount <= 0) {
      context.showInfo('最多选择9张图片');
      return;
    }

    for (final file in result.files) {
      if (file.path == null) continue;

      widget.viewModel.addAndUploadImage(
        CommentImage(
          localPath: file.path!,
          localName: file.name,
        ),
      );
    }
  }

  Future<void> _onPost() async {
    final content = _editingController.text.trim();

    if (content.isEmpty && widget.viewModel.images.isEmpty) {
      context.showInfo('评论内容不能为空');
      return;
    }

    for (final image in widget.viewModel.images) {
      if (image.status == .uploading) {
        context.showInfo('有图片仍在上传中');
        return;
      }
      if (image.status == .failed) {
        context.showInfo('有图片上传失败');
        return;
      }
    }

    final Map<String, String> nicknameToUserId = {};
    for (final user in _mentionedUsers) {
      if (content.contains('@${user.nickname}')) {
        nicknameToUserId[user.nickname] = user.id;
      }
    }

    widget.viewModel.post.execute(
      PostRequest(
        content: content,
        nicknameToUserId: nicknameToUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Selector<CommentPanelViewModel, Comment?>(
          selector: (context, vm) => vm.replyTarget,
          builder: (context, replyTarget, _) {
            if (replyTarget == null) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                spacing: 4.0,
                children: [
                  Text(
                    '回复 @${replyTarget.owner.nickname}',
                    style: TextStyle(fontSize: 12, color: colorScheme.primary),
                  ),
                  InkWell(
                    onTap: _onCancelReply,
                    borderRadius: kInfiniteBorderRadius,
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        // 输入框
        Container(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colorScheme.outline)),
          ),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              Form(
                key: _formKey,
                child: TextField(
                  controller: _editingController,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: '下面我简单喵两句...',
                    contentPadding: const .fromLTRB(20.0, 20.0, 20.0, 6.0),
                    isDense: true,
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(fontSize: 14),
                  maxLines: 4,
                  minLines: 4,
                ),
              ),
              // 待发送图片
              Selector<CommentPanelViewModel, List<CommentImage>>(
                selector: (context, vm) => vm.images,
                builder: (context, images, _) {
                  if (images.isEmpty) {
                    return SizedBox.shrink();
                  }

                  return SizedBox(
                    height: 70.0,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      child: ListView.separated(
                        scrollDirection: .horizontal,
                        padding: .symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          final image = images[index];
                          return Container(
                            width: 156.0,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              border: Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                              color: colorScheme.surfaceContainerLow,
                            ),
                            child: Row(
                              children: [
                                if (image.status == .success)
                                  Icon(Icons.check_circle, size: 14, color: Colors.green)
                                else if (image.status == .failed)
                                  Icon(Icons.error, size: 14, color: colorScheme.error)
                                else
                                  SizedBox(
                                    width: 14,
                                    height: 14,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        image.localName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        image.status == .uploading ? '上传中' : (image.status == .success ? '已上传' : '上传失败'),
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: image.status == .uploading
                                              ? colorScheme.primary
                                              : (image.status == .success ? Colors.green : colorScheme.error),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (image.status == .failed)
                                  InkWell(
                                    onTap: () => widget.viewModel.uploadImage(image),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: Icon(Icons.refresh, size: 14, color: colorScheme.primary),
                                    ),
                                  ),
                                InkWell(
                                  onTap: () => widget.viewModel.removeImage(image),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Padding(
                                    padding: const EdgeInsets.all(2),
                                    child: Icon(Icons.close, size: 14, color: colorScheme.outline),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        // 操作区
        Padding(
          padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            spacing: 4.0,
            children: [
              // 贴纸
              IconButton(
                onPressed: _toggleStickerPanel,
                icon: Icon(
                  Icons.emoji_emotions_outlined,
                  color: _isStickerPanelOpend ? colorScheme.primary : colorScheme.outline,
                  size: 20,
                ),
                tooltip: '贴纸',
                style: _isStickerPanelOpend ? IconButton.styleFrom(backgroundColor: colorScheme.primaryContainer) : null,
                visualDensity: .compact,
              ),

              // 提及
              IconButton(
                onPressed: _toggleMentionPanel,
                icon: Icon(
                  Icons.alternate_email,
                  color: _isMentionPanelOpend ? colorScheme.primary : colorScheme.outline,
                  size: 20,
                ),
                style: _isMentionPanelOpend ? IconButton.styleFrom(backgroundColor: colorScheme.primaryContainer) : null,
                tooltip: '提及',
                visualDensity: .compact,
              ),

              // 图片
              IconButton(
                onPressed: _pickAndUploadImage,
                icon: Icon(
                  Icons.image_outlined,
                  color: colorScheme.outline,
                  size: 20,
                ),
                tooltip: '图片',
                visualDensity: .compact,
              ),

              // 发布
              const Spacer(),
              ListenableBuilder(
                listenable: widget.viewModel.post,
                builder: (context, child) => FilledButton.tonal(
                  onPressed: widget.viewModel.post.running ? null : _onPost,
                  style: FilledButton.styleFrom(
                    padding: const .symmetric(horizontal: 16),
                    // minimumSize: const Size(0, 36),
                    shape: const RoundedRectangleBorder(
                      borderRadius: kInfiniteBorderRadius,
                    ),
                  ),
                  child: widget.viewModel.post.running
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('发送', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),

        // 贴纸面板
        if (_isStickerPanelOpend)
          SizedBox(
            height: 250,
            child: ListenableBuilder(
              listenable: widget.viewModel.loadStickers,
              builder: (context, child) {
                if (widget.viewModel.loadStickers.running) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (widget.viewModel.loadStickers.error) {
                  return CenterErrorMessage(
                    errorMessage: widget.viewModel.loadStickers.result.toString(),
                    onRetry: widget.viewModel.loadStickers.execute,
                  );
                }

                if (widget.viewModel.stickers.isEmpty) {
                  return const Center(child: Text('暂无内容'));
                }

                return Material(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(
                            dragDevices: {
                              PointerDeviceKind.touch,
                              PointerDeviceKind.mouse,
                            },
                          ),
                          child: ListView.separated(
                            scrollDirection: .horizontal,
                            itemCount: widget.viewModel.stickers.length,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemBuilder: (context, index) {
                              final pack = widget.viewModel.stickers[index];
                              return Selector<CommentPanelViewModel, bool>(
                                selector: (context, vm) => vm.selectedStickerPackIndex == index,
                                builder: (context, selected, _) => ChoiceChip(
                                  label: Text(pack.name, style: const TextStyle(fontSize: 12)),
                                  selected: selected,
                                  onSelected: (_) => widget.viewModel.setSelectedStickerPackIndex(index),
                                  showCheckmark: false,
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(width: 4.0),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Selector<CommentPanelViewModel, StickerPack>(
                          selector: (context, vm) => vm.stickers[vm.selectedStickerPackIndex],
                          builder: (context, stickerPack, _) => GridView.builder(
                            padding: const .all(8.0),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 9,
                              mainAxisSpacing: 4.0,
                              crossAxisSpacing: 4.0,
                            ),
                            itemCount: stickerPack.stickers.length,
                            itemBuilder: (context, index) {
                              final sticker = stickerPack.stickers[index];
                              return Tooltip(
                                message: sticker.name,
                                child: InkWell(
                                  onTap: () => _insertSticker(sticker),
                                  borderRadius: .circular(8.0),
                                  child: Padding(
                                    padding: const .all(4.0),
                                    child: ImageWapper(
                                      image: NetworkImage(sticker.thumbnail ?? sticker.url),
                                      fit: .contain,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        // 提及面板
        if (_isMentionPanelOpend)
          SizedBox(
            height: 200,
            child: ListenableBuilder(
              listenable: widget.viewModel.loadMentionUserList,
              builder: (context, child) {
                if (widget.viewModel.loadMentionUserList.running) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (widget.viewModel.loadMentionUserList.error) {
                  return CenterErrorMessage(
                    errorMessage: widget.viewModel.loadMentionUserList.result.toString(),
                    onRetry: () => widget.viewModel.reloadMentionUserList(null),
                  );
                }

                if (widget.viewModel.mentionUserList.isEmpty) {
                  return const Center(child: Text('暂无内容'));
                }

                return Material(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    shrinkWrap: true,
                    itemCount: widget.viewModel.mentionUserList.length,
                    itemBuilder: (context, index) {
                      final user = widget.viewModel.mentionUserList[index];
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(backgroundImage: NetworkImage(user.avatar)),
                        title: Text(user.nickname),
                        subtitle: user.hasFollowed ? Text('已关注') : null,
                        onTap: () => _onPickMentionUser(user),
                      );
                    },
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
