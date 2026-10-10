import 'dart:ui';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_theme.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorites_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/section_tile.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:better_bilibili/ui/home/view_models/me_view_model.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MeView extends StatefulWidget {
  const MeView({super.key});

  @override
  State<MeView> createState() => _MeViewState();
}

class _MeViewState extends State<MeView> {
  late final MeViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, child) => _viewModel.hasLogin ? _buildByLogin(context, colorScheme, isDarkMode) : _buildByLogout(),
    );
  }

  Widget _buildByLogin(BuildContext context, ColorScheme colorScheme, bool isDarkMode) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.push(Routes.setting.path);
            },
            icon: Icon(Icons.settings_outlined, color: Colors.white),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _viewModel.getHeaderData.execute();
          _viewModel.getContentData.execute();
        },
        child: Icon(Icons.refresh_outlined),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderByLogin(colorScheme, isDarkMode),
              SizedBox(height: 8.0),
              _buildContentByLogin(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderByLogin(ColorScheme colorScheme, bool isDarkMode) {
    if (_viewModel.headerData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.getHeaderData.error) {
      return CenterErrorMessage(errorMessage: (_viewModel.getHeaderData.result as Error).toString());
    }

    final headerData = _viewModel.headerData!;

    final shadows = [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: colorScheme.shadow.withAlpha(160))];
    final double filterStrength = isDarkMode ? -50 : -10;
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.matrix([
            1, 0, 0, 0, filterStrength, // Red
            0, 1, 0, 0, filterStrength, // Green
            0, 0, 1, 0, filterStrength, // Blue
            0, 0, 0, 1, 0, // Alpha
          ]),
          child: ImageWapper(
            image: NetworkImage(headerData.banner),
            height: 240,
            width: double.infinity,
            fit: BoxFit.cover,
            alignment: Alignment.topRight,
          ),
        ),
        Positioned(
          bottom: 32.0,
          left: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.push(Routes.buildUserDetail(headerData.id));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8.0,
                  children: [
                    BiliUserAvatar(
                      url: headerData.avatar,
                      frameImage: headerData.avatarFrame != null ? NetworkImage(headerData.avatarFrame!) : null,
                      size: 128,
                      suffix: '@128w_128h_1c_1s',
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 18.0),
                        Row(
                          children: [
                            Text(
                              headerData.nickname,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: shadows,
                              ),
                            ),
                            SizedBox(width: 8.0),
                            SvgPicture.asset(getLevelIconPath(headerData.level.currentLevel), height: 18.0),
                          ],
                        ),
                        if (headerData.vip.type != UserVipType.none)
                          ImageWapper(image: NetworkImage(headerData.vip.labelImage), height: 20.0),
                        Text(
                          'B币：${headerData.wallet.bcoin}  硬币：${headerData.wallet.coin}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                            shadows: shadows,
                          ),
                        ),
                        SizedBox(height: 8.0),
                        Wrap(
                          spacing: 12.0,
                          children: [
                            _HeaderStatChip(
                              label: '动态',
                              value: headerData.dynamicNum.toString(),
                              onTap: () => context.push(Routes.buildUserFollowings('233114659')),
                            ),
                            _HeaderStatChip(
                              label: '关注',
                              value: headerData.followNum.toString(),
                              onTap: () => context.push(Routes.buildUserFollowings(headerData.id)),
                            ),
                            _HeaderStatChip(
                              label: '粉丝',
                              value: headerData.fansNum.toString(),
                              onTap: () => context.push(Routes.buildUserFans(headerData.id)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentByLogin(ColorScheme colorScheme) {
    if (_viewModel.contentData == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_viewModel.getContentData.error) {
      return CenterErrorMessage(errorMessage: (_viewModel.getContentData.result as Error).toString());
    }

    final headerData = _viewModel.headerData!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonalIcon(
                onPressed: () => context.push(Routes.buildUserDetail(headerData.id)),
                icon: const Icon(Icons.home_outlined, size: 20),
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                label: const Text('我的主页'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(Routes.buildUserSubscriptions(headerData.id)),
                icon: const Icon(Icons.subscriptions_outlined, size: 20),
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                label: const Text('我的订阅'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(Routes.buildUserRecentlyLiked(headerData.id)),
                icon: const Icon(Icons.thumb_up_outlined, size: 20),
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                label: const Text('最近点赞'),
              ),
              FilledButton.tonalIcon(
                onPressed: () => context.push(Routes.buildUserRecentlyCoined(headerData.id)),
                icon: const Icon(CustomIcons.coin_outlined, size: 20),
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                label: const Text('最近投币'),
              ),
              FilledButton.tonalIcon(
                onPressed: () {},
                icon: const Icon(Icons.sticky_note_2_outlined, size: 20),
                style: FilledButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                  backgroundColor: colorScheme.surfaceContainerHigh,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                label: const Text('我的笔记'),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.0),
        SectionTile(
          title: Text('观看历史'),
          onTap: () => context.push(Routes.watchHistory),
          child: _viewModel.contentData!.watchHistory.isEmpty
              ? const Center(child: Text('暂无记录'))
              : _horizontalScrollForDynamics(_viewModel.contentData!.watchHistory),
        ),
        SectionTile(
          title: Text('稍后观看'),
          onTap: () => context.push(Routes.watchLater),
          child: _viewModel.contentData!.watchLater.isEmpty
              ? const Center(child: Text('暂无记录'))
              : _horizontalScrollForDynamics(_viewModel.contentData!.watchLater),
        ),
        SectionTile(
          title: Text('我的收藏'),
          onTap: () => context.push(Routes.favorites),
          child: _viewModel.contentData!.favorites.isEmpty
              ? const Center(child: Text('暂无记录'))
              : _horizontalScrollForFavorites(_viewModel.contentData!.favorites, headerData),
        ),
        SizedBox(height: kScreenBottomPadding),
      ],
    );
  }

  Widget _horizontalScrollForDynamics(List<dynamic> items) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240.0,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return SizedBox(
              width: 260,
              child: DynamicCard(
                data: items[index],
                style: CardStyle(coverSuffix: BiliImageSuffix.small),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _horizontalScrollForFavorites(List<Favorites> items, User user) {
    if (items.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 240.0,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
          },
        ),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return SizedBox(
              width: 260,
              child: FavoritesCard(
                favoritesId: item.id,
                title: item.name,
                cover: item.cover ?? kEmptyImageUrl,
                user: user,
                total: item.total,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildByLogout() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          children: [
            CircleAvatar(
              radius: 64,
              backgroundColor: colorScheme.primaryContainer,
              child: Icon(Icons.account_circle_outlined, size: 96, color: colorScheme.onPrimaryContainer),
            ),
            SizedBox(height: 8),
            Text(
              _viewModel.getRandomLogoutText(),
              style: textTheme.headlineLarge,
            ),
            SizedBox(height: 18.0),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton(
                  onPressed: () {
                    context.push(Routes.login);
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: const Text('登录'),
                ),
                OutlinedButton(
                  onPressed: () {
                    context.push(Routes.settingAccountManager.path);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  ),
                  child: const Text('切换账号'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _HeaderStatChip({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: colorScheme.shadow)],
              ),
            ),
            Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: Colors.white,
                shadows: [Shadow(offset: Offset(1.0, 1.0), blurRadius: 3.0, color: colorScheme.shadow)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
