import 'dart:ui';

import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/paginator.dart';
import 'package:better_bilibili/ui/core/share/section_tile.dart';
import 'package:better_bilibili/ui/core/share/sliver_max_width_box.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_playlist_view_model.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class UserDetailPlaylistView extends StatefulWidget {
  final UserDetailPlaylistViewModel viewModel;

  const UserDetailPlaylistView({super.key, required this.viewModel});

  @override
  State<UserDetailPlaylistView> createState() => _UserDetailPlaylistViewState();
}

class _UserDetailPlaylistViewState extends State<UserDetailPlaylistView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final colorScheme = Theme.of(context).colorScheme;

    return ListenableBuilder(
      listenable: widget.viewModel.loadData,
      builder: (context, child) {
        if (widget.viewModel.loadData.running) {
          return const Center(child: CircularProgressIndicator());
        }

        if (widget.viewModel.loadData.error) {
          return CenterErrorMessage(
            errorMessage: widget.viewModel.loadData.result.toString(),
            onRetry: widget.viewModel.reload,
          );
        }

        if (widget.viewModel.playlists.isEmpty) {
          return const Center(child: Text('暂无内容'));
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
            ...widget.viewModel.playlists.map(
              (playlist) => SliverMaxWidthBox(
                sliver: SliverToBoxAdapter(
                  child: SectionTile(
                    title: Row(
                      mainAxisSize: .min,
                      spacing: 4.0,
                      children: [
                        Text(playlist.name),
                        Text(
                          '(${playlist.total}个视频)',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: colorScheme.outline,
                            fontWeight: .normal,
                          ),
                        ),
                      ],
                    ),
                    subtitle: playlist.description == null ? null : Text(playlist.description!),
                    headerPadding: const .symmetric(horizontal: 24.0, vertical: 8.0),
                    onTap: () {},
                    expandedHeight: 300,
                    child: playlist.videos.isEmpty
                        ? const Center(child: Text('暂无内容'))
                        : ScrollConfiguration(
                            behavior: ScrollConfiguration.of(context).copyWith(
                              dragDevices: {
                                PointerDeviceKind.touch,
                                PointerDeviceKind.mouse,
                              },
                            ),
                            child: ListView.builder(
                              scrollDirection: .horizontal,
                              padding: const .symmetric(horizontal: 16.0),
                              itemCount: playlist.videos.length,
                              itemBuilder: (context, index) {
                                final video = playlist.videos[index];
                                return SizedBox(
                                  width: 370,
                                  child: VideoCard(
                                    videoId: video.id,
                                    title: video.title,
                                    cover: video.cover,
                                    duration: video.duration,
                                    uploadTime: video.releaseTime,
                                    viewCount: video.viewCount,
                                    danmakuCount: video.danmakuCount,
                                    playListId: playlist.isPlaylist ? playlist.id : null,
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const .all(16.0),
                child: Selector<UserDetailPlaylistViewModel, ({int pn, int total})>(
                  selector: (context, vm) => (pn: vm.pn, total: vm.total),
                  builder: (context, state, _) => Paginator(
                    maxPageCount: (state.total + (ps - 1)) ~/ ps,
                    currentPage: state.pn,
                    onPageChanged: (page) => widget.viewModel.setPn(page),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
