import 'package:better_bilibili/data/services/bilibili/model/get_playlist_videos_response.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_tile.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/video/view_models/playlist_tab_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PlaylistTab extends StatefulWidget {
  final PlaylistTabViewModel viewModel;
  final String currentVideoId;
  final ValueChanged<PlaylistVideo> onSwitchVideo;

  const PlaylistTab({super.key, required this.viewModel, required this.currentVideoId, required this.onSwitchVideo});

  @override
  State<PlaylistTab> createState() => _PlaylistTabState();
}

class _PlaylistTabState extends State<PlaylistTab> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final _padding = const EdgeInsets.symmetric(vertical: 8.0);
  final ScrollController _scrollController = ScrollController();
  // late final ListObserverController _observerController;

  @override
  void initState() {
    super.initState();

    // _observerController = ListObserverController(controller: _scrollController);

    // final initIndex = widget.episodes.indexWhere((episode) => episode.episodeId == widget.currentEpisodeId);
    // if (initIndex != -1) {
    //   _observerController.initialIndexModel = ObserverIndexPositionModel(
    //     index: initIndex,
    //     isFixedHeight: true,
    //   );
    // }

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // 向前加载更多
    if (_scrollController.position.pixels <= 0 && !widget.viewModel.loadMoreBefore.running && widget.viewModel.hasMoreBefore) {
      widget.viewModel.loadMoreBefore.execute();
    }

    // 向后加载更多
    if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 400 &&
        !widget.viewModel.loadMoreAfter.running &&
        widget.viewModel.hasMoreAfter) {
      widget.viewModel.loadMoreAfter.execute();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    context.watch<PlaylistTabViewModel>();

    if (widget.viewModel.initLoad.error) {
      return CenterErrorMessage(
        errorMessage: widget.viewModel.initLoad.result.toString(),
        onRetry: widget.viewModel.initLoad.execute,
      );
    }
    if (widget.viewModel.loadMoreBefore.error) {
      return CenterErrorMessage(
        errorMessage: widget.viewModel.loadMoreBefore.result.toString(),
        onRetry: widget.viewModel.loadMoreBefore.execute,
      );
    }
    if (widget.viewModel.loadMoreAfter.error) {
      return CenterErrorMessage(
        errorMessage: widget.viewModel.loadMoreAfter.result.toString(),
        onRetry: widget.viewModel.loadMoreAfter.execute,
      );
    }

    if (widget.viewModel.initLoad.running ||
        widget.viewModel.loadMoreBefore.running ||
        widget.viewModel.loadMoreAfter.running && widget.viewModel.videos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: _padding,
          child: Text(
            '${widget.viewModel.playlistInfo!.name} · 共 ${widget.viewModel.playlistInfo!.total} 个视频',
            style: TextStyle(fontSize: 16.0),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: _padding,
            itemCount: widget.viewModel.videos.length,
            itemBuilder: (context, index) {
              final video = widget.viewModel.videos[index];
              final isCurrent = widget.currentVideoId == video.id;
              return VideoTile(
                videoId: video.id,
                title: video.title,
                cover: video.cover,
                duration: video.duration,
                nickname: video.owner.nickname,
                onTap: isCurrent ? () {} : () => widget.onSwitchVideo(video),
                compact: true,
                isActive: isCurrent,
              );
            },
          ),
        ),
      ],
    );
  }
}
