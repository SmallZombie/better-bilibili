import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorite_folder_card.dart';
import 'package:better_bilibili/ui/core/bilibili/series/series_poster.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:better_bilibili/ui/core/bilibili/post/post_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/responsive/sliver_max_width_viewport.dart';
import 'package:better_bilibili/ui/core/share/section_tile.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_home_view_model.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_screen.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class UserDetailHomeView extends StatefulWidget {
  final UserDetailHomeViewModel viewModel;
  final String nickname;
  final ValueChanged<UserDetailTabEnum> onSwitchTab;

  const UserDetailHomeView({
    super.key,
    required this.viewModel,
    required this.onSwitchTab,
    required this.nickname,
  });

  @override
  State<UserDetailHomeView> createState() => _UserDetailHomeViewState();
}

class _UserDetailHomeViewState extends State<UserDetailHomeView> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ListenableBuilder(
      listenable: widget.viewModel.loadData,
      builder: (context, _) {
        if (widget.viewModel.loadData.error) {
          return CenterErrorMessage(
            errorMessage: getErrorMessage(widget.viewModel.loadData.result!),
            onRetry: widget.viewModel.loadData.execute,
          );
        }
        if (widget.viewModel.loadData.running) {
          return const Center(child: CircularProgressIndicator());
        }

        final List<Widget> slivers = [];
        if (widget.viewModel.pinnedVideos.isNotEmpty) {
          slivers.add(
            _buildSection(
              SectionTile.viewAll(
                title: const Text('精选视频'),
                expandedHeight: 280,
                child: ListView.builder(
                  scrollDirection: .horizontal,
                  padding: const .symmetric(horizontal: 16.0),
                  itemCount: widget.viewModel.pinnedVideos.length,
                  itemBuilder: (context, index) {
                    final video = widget.viewModel.pinnedVideos[index];
                    return SizedBox(
                      width: 340,
                      height: 300,
                      child: VideoCard(
                        videoId: video.id,
                        title: video.title,
                        cover: video.cover,
                        duration: video.duration,
                        uploadTime: video.releaseTime,
                        viewCount: video.viewCount,
                        danmakuCount: video.danmakuCount,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }
        for (final i in widget.viewModel.profileSettings!.moduleSorting) {
          if (i == 1 && widget.viewModel.videos.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('视频'),
                  expandedHeight: 280,
                  onTap: () => widget.onSwitchTab(.video),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.videos.length,
                    itemBuilder: (context, index) {
                      final video = widget.viewModel.videos[index];
                      return SizedBox(
                        width: 340,
                        child: VideoCard(
                          videoId: video.id,
                          title: video.title,
                          cover: video.cover,
                          duration: video.duration,
                          uploadTime: video.releaseTime,
                          viewCount: video.stats.view,
                          danmakuCount: video.stats.danmaku,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (i == 2 && widget.viewModel.favoritesList.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('收藏夹'),
                  expandedHeight: 280,
                  onTap: () => context.push(Routes.buildUserSubscriptions(widget.viewModel.userId)),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.favoritesList.length,
                    itemBuilder: (context, index) {
                      final favorite = widget.viewModel.favoritesList[index];
                      return SizedBox(
                        width: 340,
                        child: FavoriteFolderCard(
                          favoritesId: favorite.id,
                          cover: favorite.cover ?? kEmptyImageUrl,
                          title: favorite.name,
                          total: favorite.total,
                          user: favorite.owner,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (i == 3 && widget.viewModel.series.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('订阅的剧集'),
                  expandedHeight: 350,
                  onTap: () => context.push(
                    Routes.buildUserSubscriptions(widget.viewModel.userId),
                  ),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.series.length,
                    itemBuilder: (context, index) {
                      final series = widget.viewModel.series[index];
                      return SizedBox(
                        width: 200,
                        child: SeriesPoster(
                          seriesId: series.id,
                          cover: series.cover,
                          title: series.title,
                          year: series.year,
                          countries: series.countries.first,
                          category: series.category,
                          badge: series.badge,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (i == 5 && widget.viewModel.coindVideos.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('近期投币'),
                  expandedHeight: 280,
                  onTap: () => context.push(
                    Routes.buildUserRecentlyCoined(
                      widget.viewModel.userId,
                      nickname: widget.nickname,
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.coindVideos.length,
                    itemBuilder: (context, index) {
                      final item = widget.viewModel.coindVideos[index];
                      return SizedBox(
                        width: 340,
                        child: DynamicCard(data: item),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (i == 7 && widget.viewModel.playlists.isNotEmpty) {
            for (final playlist in widget.viewModel.playlists) {
              if (playlist.videos.isEmpty) {
                continue;
              }

              slivers.add(
                _buildSection(
                  SectionTile.viewAll(
                    title: Text(playlist.name),
                    subtitle: playlist.description == null ? null : Text(playlist.description!),
                    expandedHeight: 280,
                    onTap: () => context.push(Routes.buildPlaylistDetail(playlist.id)),
                    child: ListView.builder(
                      scrollDirection: .horizontal,
                      padding: const .symmetric(horizontal: 16.0),
                      itemCount: playlist.videos.length,
                      itemBuilder: (context, index) {
                        final video = playlist.videos[index];
                        return SizedBox(
                          width: 340,
                          child: VideoCard(
                            videoId: video.id,
                            title: video.title,
                            cover: video.cover,
                            duration: video.duration,
                            uploadTime: video.releaseTime,
                            viewCount: video.viewCount,
                            danmakuCount: video.danmakuCount,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            }
          } else if (i == 8 && widget.viewModel.articles.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('文章'),
                  expandedHeight: 260,
                  onTap: () => widget.onSwitchTab(.article),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.articles.length,
                    itemBuilder: (context, index) {
                      final post = widget.viewModel.articles[index];
                      return SizedBox(
                        width: 340,
                        child: PostCard(
                          postId: post.postId,
                          cover: post.cover,
                          title: post.title,
                          likeCount: post.likeCount,
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          } else if (i == 10 && widget.viewModel.likedVideos.isNotEmpty) {
            slivers.add(
              _buildSection(
                SectionTile.viewAll(
                  title: const Text('近期赞过'),
                  expandedHeight: 290,
                  onTap: () => context.push(
                    Routes.buildUserRecentlyLiked(
                      widget.viewModel.userId,
                      nickname: widget.nickname,
                    ),
                  ),
                  child: ListView.builder(
                    scrollDirection: .horizontal,
                    padding: const .symmetric(horizontal: 16.0),
                    itemCount: widget.viewModel.likedVideos.length,
                    itemBuilder: (context, index) {
                      final item = widget.viewModel.likedVideos[index];
                      return SizedBox(
                        width: 340,
                        child: DynamicCard(data: item),
                      );
                    },
                  ),
                ),
              ),
            );
          }
        }

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8.0)),
            ...slivers,
            const SliverToBoxAdapter(child: SizedBox(height: 16.0)),
          ],
        );
      },
    );
  }

  Widget _buildSection(SectionTile sectionTile) {
    return SliverMaxWidthViewport(
      maxWidth: 2100,
      sliver: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(dragDevices: {.touch, .mouse}),
        child: SliverToBoxAdapter(child: sectionTile),
      ),
    );
  }
}
