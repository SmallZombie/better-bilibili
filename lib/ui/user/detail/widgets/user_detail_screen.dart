import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button.dart';
import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_anthology_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_article_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_audio_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_home_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_playlist_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_post_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_shop_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_video_view_model.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_view_model.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_anthology_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_article_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_audio_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_home_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_playlist_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_post_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_shop_view.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_video_view.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/hex_color.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

const _avatarSize = 128.0;

class UserDetailScreen extends StatefulWidget {
  final UserDetailViewModel viewModel;
  final UserDetailTabEnum initTabIndex;

  const UserDetailScreen({
    super.key,
    required this.viewModel,
    this.initTabIndex = .home,
  });

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: UserDetailTabEnum.values.length,
      vsync: this,
      initialIndex: widget.initTabIndex.tabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();

    super.dispose();
  }

  void _onSwitchTab(UserDetailTabEnum newTab) {
    if (_tabController.index == newTab.tabIndex || _tabController.indexIsChanging) {
      return;
    }

    _tabController.animateTo(newTab.tabIndex);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.loadData,
      builder: (context, child) {
        if (widget.viewModel.loadData.error) {
          return Scaffold(
            appBar: AppBar(),
            body: CenterErrorMessage(
              errorMessage: getErrorMessage(widget.viewModel.loadData.result!),
              onRetry: widget.viewModel.loadData.execute,
            ),
          );
        }
        if (widget.viewModel.loadData.running) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final userCounters = widget.viewModel.userCounters!;
        final List<String> tabs = [
          UserDetailTabEnum.home.name,
          UserDetailTabEnum.post.name,
          '${UserDetailTabEnum.video.name} (${userCounters.videoCount})',
          '${UserDetailTabEnum.playList.name} (${userCounters.collectionAndPlaylistCount})',
          '${UserDetailTabEnum.article.name} (${userCounters.articleCount})',
          UserDetailTabEnum.anthology.name,
          '${UserDetailTabEnum.audio.name} (${userCounters.audioCount})',
          UserDetailTabEnum.shop.name,
        ];

        final userInfo = widget.viewModel.userInfo!;

        return Material(
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 450,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(background: _buildHeader()),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.search),
                    tooltip: '搜索',
                  ),
                  const SizedBox(width: 4.0),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.share),
                    tooltip: '分享',
                  ),
                  const SizedBox(width: 4.0),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(Icons.settings_outlined),
                    tooltip: '设置',
                  ),
                ],
              ),
              SliverPersistentHeader(
                delegate: _TabBarHeaderDelegate(
                  TabBar(
                    controller: _tabController,
                    tabs: tabs.map((e) => Tab(text: e)).toList(),
                    dividerColor: Colors.transparent,
                  ),
                ),
                pinned: true,
              ),
            ],
            body: SafeArea(
              child: ScrollConfiguration(
                // fix: The provided ScrollController is attached to more than one ScrollPosition.
                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    ChangeNotifierProvider(
                      create: (context) => UserDetailHomeViewModel(
                        userRepository: context.read(),
                        videoRepository: context.read(),
                        articleRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailHomeView(
                        viewModel: context.read(),
                        nickname: userInfo.nickname,
                        onSwitchTab: _onSwitchTab,
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailPostViewModel(
                        postRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailPostView(
                        viewModel: context.read(),
                        appConfig: context.read(),
                        eagleConfig: context.read(),
                        eagleRepository: context.read(),
                        networkManager: context.read(),
                      ),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailVideoViewModel(
                        videoRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailVideoView(viewModel: context.read()),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailPlaylistViewModel(
                        videoRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailPlaylistView(viewModel: context.read()),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailArticleViewModel(
                        videoRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailArticleView(viewModel: context.read()),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailAnthologyViewModel(
                        articleRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailAnthologyView(viewModel: context.read()),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailAudioViewModel(
                        audioRepository: context.read(),
                        userId: widget.viewModel.userId,
                      ),
                      builder: (context, _) => UserDetailAudioView(viewModel: context.read()),
                    ),
                    ChangeNotifierProvider(
                      create: (context) => UserDetailShopViewModel(),
                      builder: (context, _) => UserDetailShopView(viewModel: context.read()),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    final userInfo = widget.viewModel.userInfo!;
    final userStats = widget.viewModel.userStats!;
    final userTotalLikeAndViewCount = widget.viewModel.userTotalLikeAndViewCount!;
    final userRelation = widget.viewModel.userRelation!;

    return Column(
      children: [
        Expanded(
          child: ImageWapper(
            image: NetworkImage(userInfo.banner),
            fit: .cover,
            width: .infinity,
          ),
        ),
        MaxWidthViewport(
          maxWidth: 2100,
          child: Padding(
            padding: const .symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              crossAxisAlignment: .start,
              spacing: 8.0,
              children: [
                Transform.translate(
                  offset: Offset(0.0, _avatarSize / 2 * -1),
                  child: BiliUserAvatar(
                    url: userInfo.avatar,
                    frameImage: userInfo.avatarFrame == null ? null : NetworkImage(userInfo.avatarFrame!.url),
                    size: _avatarSize,
                    suffix: '@256w_256h_1c_1s',
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    spacing: 8.0,
                    children: [
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        crossAxisAlignment: .center,
                        children: [
                          SelectableText(
                            userInfo.nickname,
                            maxLines: 1,
                            style: TextStyle(fontSize: 24.0, overflow: .ellipsis),
                          ),
                          SvgPicture.asset(
                            getLevelIconPath(userInfo.level.level),
                            height: 20,
                          ),
                          if (userInfo.vip != null)
                            Image.network(
                              userInfo.vip!.labelImage,
                              height: 22,
                            ),
                          if (userInfo.achievement != null)
                            Tooltip(
                              message: '${userInfo.achievement!.name}: ${userInfo.achievement!.description}',
                              child: Image.network(
                                userInfo.achievement!.icon,
                                height: 26.0,
                              ),
                            ),
                          if (userInfo.fanBadge != null)
                            Container(
                              padding: const .symmetric(horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: HexColor(userInfo.fanBadge!.backgroundColorStart),
                                borderRadius: kInfiniteBorderRadius,
                                border: .all(color: HexColor(userInfo.fanBadge!.borderColor)),
                              ),
                              child: Row(
                                mainAxisSize: .min,
                                spacing: 2.0,
                                children: [
                                  Text(
                                    userInfo.fanBadge!.name,
                                    style: TextStyle(
                                      color: HexColor(userInfo.fanBadge!.nameColor),
                                      fontSize: 10,
                                    ),
                                  ),
                                  Text(
                                    userInfo.fanBadge!.level.toString(),
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: .bold,
                                      color: HexColor(userInfo.fanBadge!.levelColor),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          widget.viewModel.isCurrentAccount
                              ? TextButton(onPressed: () {}, child: Text('编辑资料'))
                              : ChangeNotifierProvider(
                                  create: (context) => FollowTextButtonViewModel(
                                    userRepository: context.read(),
                                    userId: userInfo.id,
                                    initState: userRelation.imFans,
                                  ),
                                  builder: (context, _) => FollowTextButton(viewModel: context.read()),
                                ),
                        ],
                      ),
                      if (userInfo.description != null)
                        SelectableText(
                          userInfo.description!,
                          style: TextStyle(color: colorScheme.outline),
                        ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          if (userInfo.verified != null)
                            Row(
                              mainAxisSize: .min,
                              spacing: 4.0,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/verified_icon.svg',
                                  height: 20.0,
                                ),
                                Text(
                                  userInfo.verified!,
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),
                          if (userInfo.organizationVerified != null)
                            Row(
                              mainAxisSize: .min,
                              spacing: 4.0,
                              children: [
                                SvgPicture.asset(
                                  'assets/images/organization_verified_icon.svg',
                                  height: 20.0,
                                ),
                                Text(
                                  userInfo.organizationVerified!,
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),
                          if (userInfo.gender != .unknown)
                            Row(
                              mainAxisSize: .min,
                              spacing: 2.0,
                              children: [
                                Icon(
                                  Icons.person_outline,
                                  size: 20.0,
                                  color: colorScheme.outline,
                                ),
                                Text(
                                  switch (userInfo.gender) {
                                    .male => '男',
                                    .female => '女',
                                    _ => '',
                                  },
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),
                          if (userInfo.birthDate != null)
                            Row(
                              mainAxisSize: .min,
                              spacing: 2.0,
                              children: [
                                Icon(
                                  Icons.cake_outlined,
                                  size: 18.0,
                                  color: colorScheme.outline,
                                ),
                                Text(
                                  userInfo.birthDate!,
                                  style: TextStyle(color: colorScheme.outline),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (userInfo.tags.isNotEmpty)
                        Wrap(
                          spacing: 4.0,
                          runSpacing: 4.0,
                          children: userInfo.tags
                              .map(
                                (v) => Chip(
                                  label: Text(
                                    v,
                                    style: TextStyle(fontSize: 12.0),
                                  ),
                                  shape: const StadiumBorder(),
                                  padding: const .symmetric(horizontal: 4.0),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: .min,
                  children: [
                    _StatChip(
                      label: '关注',
                      value: formatCountToHumanReadable(userStats.following),
                      onTap: () {
                        if (widget.viewModel.isCurrentAccount) {
                          context.push(Routes.followings);
                        } else {
                          context.push(Routes.buildUserFollowings(userInfo.id));
                        }
                      },
                    ),
                    _StatChip(
                      label: '粉丝',
                      value: formatCountToHumanReadable(userStats.fans),
                      onTap: () => context.push(Routes.buildUserFans(userInfo.id)),
                    ),
                    _StatChip(
                      label: '总播放',
                      value: formatCountToHumanReadable(userTotalLikeAndViewCount.viewCount),
                    ),
                    _StatChip(
                      label: '总获赞',
                      value: formatCountToHumanReadable(userTotalLikeAndViewCount.likeCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

enum UserDetailTabEnum {
  home,
  post,
  video,
  playList,
  article,
  anthology,
  audio,
  shop,
}

extension UserDetailTabEnumExtension on UserDetailTabEnum {
  int get tabIndex => switch (this) {
    .home => 0,
    .post => 1,
    .video => 2,
    .playList => 3,
    .article => 4,
    .anthology => 5,
    .audio => 6,
    .shop => 7,
  };

  String get name => switch (this) {
    .home => '主页',
    .post => '帖子',
    .video => '视频',
    .playList => '播放列表',
    .article => '文章',
    .anthology => '文集',
    .audio => '音频',
    .shop => '店铺',
  };

  static UserDetailTabEnum fromTabIndex(String index) {
    return UserDetailTabEnum.values.firstWhere(
      (e) => e.tabIndex == int.parse(index),
      orElse: () => .home,
    );
  }
}

class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height + 1;

  @override
  double get maxExtent => tabBar.preferredSize.height + 1;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: .min,
        children: [
          MaxWidthViewport(maxWidth: 2100, child: tabBar),
          Divider(height: 1),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(_TabBarHeaderDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _StatChip({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(fontSize: 18.0),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 12.0, color: colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
