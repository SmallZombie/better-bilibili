import 'dart:math';
import 'dart:ui';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_theme.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/favorite_folder_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/custom_icons.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/section_tile.dart';
import 'package:better_bilibili/ui/home/view_models/me_view_model.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class MeView extends StatelessWidget {
  final MeViewModel viewModel;

  const MeView({super.key, required this.viewModel});

  String getRandomLogoutText() {
    final texts = [
      '未登录',
      '角色未解锁',
      '干员未解锁',
      'Nya~',
    ];
    return texts[Random().nextInt(texts.length)];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == .dark;

    return Selector<MeViewModel, bool>(
      selector: (context, vm) => vm.hasLogin,
      builder: (context, value, _) => value ? _buildByLogin(context, colorScheme, isDarkMode) : _buildByLogout(context, colorScheme),
    );
  }

  Widget _buildByLogin(BuildContext context, ColorScheme colorScheme, bool darkMode) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          viewModel.getHeaderData.execute();
          viewModel.getContentData.execute();
        },
        child: Icon(Icons.refresh_outlined),
      ),
      body: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: SingleChildScrollView(
          child: Column(
            spacing: 8.0,
            children: [
              _buildHeader(colorScheme, darkMode),
              _buildContent(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Brightness color) {
    return Padding(
      padding: const .all(8.0),
      child: Row(
        children: [
          const Spacer(),
          IconButton(
            onPressed: () {
              context.push(Routes.setting.path);
            },
            icon: Icon(
              Icons.settings_outlined,
              color: color == .light ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme, bool isDarkMode) {
    assert(viewModel.hasLogin);

    final height = 240.0;

    return ListenableBuilder(
      listenable: viewModel.getHeaderData,
      builder: (context, child) {
        if (viewModel.getHeaderData.error) {
          return CenterErrorMessage(
            errorMessage: getErrorMessage(viewModel.getHeaderData.result!),
            onRetry: viewModel.getHeaderData.execute,
          );
        }

        return Selector<MeViewModel, HeaderData?>(
          selector: (context, vm) => vm.headerData,
          builder: (context, value, child) {
            if (value == null) {
              return ColoredBox(
                color: colorScheme.surfaceContainerLow,
                child: SizedBox(
                  width: .infinity,
                  height: height,
                  child: _buildAppBar(context, .light),
                ),
              );
            }

            final shadows = [
              Shadow(
                offset: Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: colorScheme.shadow.withAlpha(160),
              ),
            ];
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
                    image: NetworkImage(value.banner),
                    height: height,
                    width: .infinity,
                    fit: .cover,
                    alignment: .topRight,
                  ),
                ),
                Positioned(
                  bottom: 32.0,
                  left: 0,
                  right: 0,
                  child: Material(
                    color: Colors.transparent,
                    child: GestureDetector(
                      behavior: .opaque,
                      onTap: () {
                        context.push(Routes.buildUserDetail(value.id));
                      },
                      child: Padding(
                        padding: const .symmetric(horizontal: 24.0, vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: .start,
                          spacing: 8.0,
                          children: [
                            BiliUserAvatar(
                              url: value.avatar,
                              frameImage: value.avatarFrame != null ? NetworkImage(value.avatarFrame!) : null,
                              size: 128,
                              suffix: '@128w_128h_1c_1s',
                            ),
                            Column(
                              crossAxisAlignment: .start,
                              children: [
                                SizedBox(height: 18.0),
                                Row(
                                  children: [
                                    Text(
                                      value.nickname,
                                      style: TextStyle(
                                        fontSize: 22.0,
                                        fontWeight: .bold,
                                        color: Colors.white,
                                        shadows: shadows,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    SvgPicture.asset(getLevelIconPath(value.level.currentLevel), height: 18.0),
                                  ],
                                ),
                                if (value.vip.type != .none) ImageWapper(image: NetworkImage(value.vip.labelImage), height: 20.0),
                                Text(
                                  'B币：${value.wallet.bcoin}  硬币：${value.wallet.coin}',
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
                                      value: value.dynamicNum.toString(),
                                      onTap: () => context.push(Routes.buildUserFollowings('233114659')),
                                    ),
                                    _HeaderStatChip(
                                      label: '关注',
                                      value: value.followNum.toString(),
                                      onTap: () => context.push(Routes.followings),
                                    ),
                                    _HeaderStatChip(
                                      label: '粉丝',
                                      value: value.fansNum.toString(),
                                      onTap: () => context.push(Routes.buildUserFans(value.id)),
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
                _buildAppBar(context, .light),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    assert(viewModel.hasLogin);

    return ListenableBuilder(
      listenable: Listenable.merge([viewModel.getHeaderData, viewModel.getContentData]),
      builder: (context, child) {
        if (viewModel.getContentData.error) {
          return CenterErrorMessage(
            errorMessage: getErrorMessage(viewModel.getContentData.result!),
            onRetry: viewModel.getContentData.execute,
          );
        }

        if (viewModel.headerData == null || viewModel.contentData == null) {
          return const SizedBox(
            height: 64.0,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final headerData = viewModel.headerData!;
        final contentData = viewModel.contentData!;

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
            SectionTile.viewAll(
              title: Text('观看历史'),
              onTap: () => context.push(Routes.watchHistory),
              child: contentData.watchHistory.isEmpty
                  ? const Center(child: Text('暂无内容'))
                  : _horizontalScrollForDynamics(context, contentData.watchHistory),
            ),
            SectionTile.viewAll(
              title: Text('稍后观看'),
              onTap: () => context.push(Routes.watchLater),
              child: contentData.watchLater.isEmpty
                  ? const Center(child: Text('暂无内容'))
                  : _horizontalScrollForDynamics(context, contentData.watchLater),
            ),
            SectionTile.viewAll(
              title: Text('我的收藏'),
              onTap: () => context.push(Routes.favorites),
              child: contentData.favorites.isEmpty
                  ? const Center(child: Text('暂无内容'))
                  : _horizontalScrollForFavorites(context, contentData.favorites, headerData),
            ),
            SizedBox(height: kBottomNavigationBarHeight),
          ],
        );
      },
    );
  }

  Widget _horizontalScrollForDynamics(BuildContext context, List<dynamic> items) {
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

  Widget _horizontalScrollForFavorites(BuildContext context, List<FavoriteFolder> items, User user) {
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
              child: FavoriteFolderCard(
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

  Widget _buildByLogout(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Column(
        children: [
          _buildAppBar(context, .dark),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: .min,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Icon(
                      Icons.account_circle_outlined,
                      size: 96,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    getRandomLogoutText(),
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
          ),
        ],
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
                fontWeight: .bold,
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
