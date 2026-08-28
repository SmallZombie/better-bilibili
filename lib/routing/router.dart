import 'package:better_bilibili/routing/app_route_observer.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/article_detail/article_detail_screen.dart';
import 'package:better_bilibili/ui/article_detail/article_detail_view_model.dart';
import 'package:better_bilibili/ui/auth/login/view_models/login_view_model.dart';
import 'package:better_bilibili/ui/auth/login/widgets/login_screen.dart';
import 'package:better_bilibili/ui/chat/chat_shell.dart';
import 'package:better_bilibili/ui/echo_cave/echo_cave_screen.dart';
import 'package:better_bilibili/ui/favorites/widgets/favorites_screen.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorites_tab_view_model.dart';
import 'package:better_bilibili/ui/favorites_detail/favorites_detail_screen.dart';
import 'package:better_bilibili/ui/favorites_detail/favorites_detail_view_model.dart';
import 'package:better_bilibili/ui/home/view_models/article_home_view_model.dart';
import 'package:better_bilibili/ui/home/view_models/me_view_model.dart';
import 'package:better_bilibili/ui/home/view_models/post_view_model.dart';
import 'package:better_bilibili/ui/home/view_models/video_home_view_model.dart';
import 'package:better_bilibili/ui/home/widgets/article_home_view.dart';
import 'package:better_bilibili/ui/home/widgets/home_shell.dart';
import 'package:better_bilibili/ui/home/widgets/me_view.dart';
import 'package:better_bilibili/ui/home/widgets/post_view.dart';
import 'package:better_bilibili/ui/home/widgets/video_home_view.dart';
import 'package:better_bilibili/ui/post_detail/widgets/post_detail_screen.dart';
import 'package:better_bilibili/ui/post_detail/view_models/post_detail_view_model.dart';
import 'package:better_bilibili/ui/settings/developer/developer_setting_screen.dart';
import 'package:better_bilibili/ui/settings/developer/test_app_title_bar_screen.dart';
import 'package:better_bilibili/ui/user/recently_coined/recently_coined_screen.dart';
import 'package:better_bilibili/ui/user/recently_coined/recently_coined_view_model.dart';
import 'package:better_bilibili/ui/user/recently_liked/recently_liked_screen.dart';
import 'package:better_bilibili/ui/user/recently_liked/recently_liked_view_model.dart';
import 'package:better_bilibili/ui/root_shell.dart';
import 'package:better_bilibili/ui/search/search_view_model.dart';
import 'package:better_bilibili/ui/settings/developer/test_articles_screen.dart';
import 'package:better_bilibili/ui/settings/developer/test_posts_screen.dart';
import 'package:better_bilibili/ui/settings/developer/test_users_screen.dart';
import 'package:better_bilibili/ui/settings/developer/test_videos_screen.dart';
import 'package:better_bilibili/ui/user/subscriptions/widgets/subscriptions_screen.dart';
import 'package:better_bilibili/ui/search/search_screen.dart';
import 'package:better_bilibili/ui/search_favorites/search_favorites_screen.dart';
import 'package:better_bilibili/ui/search_favorites/search_favorites_view_model.dart';
import 'package:better_bilibili/ui/settings/account_manager/account_manager_screen.dart';
import 'package:better_bilibili/ui/settings/account_manager/account_manager_view_model.dart';
import 'package:better_bilibili/ui/settings/setting_screen.dart';
import 'package:better_bilibili/ui/user/detail/widgets/user_detail_screen.dart';
import 'package:better_bilibili/ui/user/detail/view_models/user_detail_view_model.dart';
import 'package:better_bilibili/ui/user/fans/user_fans_screen.dart';
import 'package:better_bilibili/ui/user/fans/user_fans_view_model.dart';
import 'package:better_bilibili/ui/user/followings/user_followings_screen.dart';
import 'package:better_bilibili/ui/user/followings/user_followings_view_model.dart';
import 'package:better_bilibili/ui/video/widgets/video_detail_screen.dart';
import 'package:better_bilibili/ui/video/view_models/video_detail_view_model.dart';
import 'package:better_bilibili/ui/watch_history/watch_history_screen.dart';
import 'package:better_bilibili/ui/watch_history/watch_history_view_model.dart';
import 'package:better_bilibili/ui/watch_later/watch_later_screen.dart';
import 'package:better_bilibili/ui/watch_later/watch_later_view_model.dart';
import 'package:better_bilibili/ui/webview/web_view_screen.dart';
import 'package:better_bilibili/ui/webview/web_view_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

final GoRouter router = GoRouter(
  initialLocation: Routes.home,
  debugLogDiagnostics: true,
  observers: [appRouteObserver],
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, rootNavShell) => RootShell(navigationShell: rootNavShell),
      branches: [
        StatefulShellBranch(
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, homeNavShell) => GestureDetector(
                behavior: .opaque,
                child: HomeShell(navigationShell: homeNavShell),
              ),
              branches: [
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: Routes.home,
                      builder: (context, state) => ChangeNotifierProvider(
                        create: (context) => VideoHomeViewModel(
                          authRepository: context.read(),
                          videoRepository: context.read(),
                        ),
                        builder: (context, _) => GestureDetector(
                          behavior: .opaque,
                          child: VideoHomeView(viewModel: context.read()),
                        ),
                      ),
                    ),
                  ],
                ),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeMovie,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeSeries,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeLive,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: Routes.homeArticle,
                      builder: (context, state) => ChangeNotifierProvider(
                        create: (context) => ArticleHomeViewModel(articleRepository: context.read()),
                        builder: (context, _) => GestureDetector(
                          behavior: .opaque,
                          child: ArticleHomeView(viewModel: context.read()),
                        ),
                      ),
                    ),
                  ],
                ),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeMusic,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeBook,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeCourse,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeGame,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
                // StatefulShellBranch(routes: [
                //   GoRoute(
                //     path: Routes.homeShop,
                //     builder:
                //         (context, state) => ChangeNotifierProvider(
                //           create: (_) => HomeViewModel(),
                //           builder: (context, _) => HomeScreen(viewModel: context.read()),
                //         ),
                //   )
                // ]),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homePost,
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => PostViewModel(
                  postRepository: context.read(),
                  biliBackgroundService: context.read(),
                  authRepository: context.read(),
                ),
                builder: (context, _) => PostView(viewModel: context.read()),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homeChat,
              builder: (context, state) {
                return ChatShell(
                  conversationId: state.uri.queryParameters['conversationId'],
                );
              },
            ),
            GoRoute(
              path: '${Routes.homeChat}/:conversationId',
              redirect: (context, state) {
                final id = state.pathParameters['conversationId']!;
                return Routes.buildConversationDetail(id);
              },
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.homeMe,
              builder: (context, state) => ChangeNotifierProvider(
                create: (context) => MeViewModel(
                  authRepository: context.read(),
                  userRepository: context.read(),
                  cacheService: context.read(),
                ),
                builder: (context, _) => const MeView(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: Routes.search,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => SearchViewModel(
          searchRepository: context.read(),
          userRepository: context.read(),
        ),
        builder: (context, _) => SearchScreen(
          viewModel: context.read(),
          initialKeyword: state.uri.queryParameters['keyword'],
        ),
      ),
    ),
    GoRoute(
      path: Routes.userDetail,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => UserDetailViewModel(
          userRepository: context.read(),
          authRepository: context.read(),
          userId: state.pathParameters['userId']!,
        ),
        builder: (context, _) {
          final initTabIndex = state.uri.queryParameters['initTabIndex'];
          return UserDetailScreen(
            viewModel: context.read(),
            initTabIndex: initTabIndex == null ? .home : UserDetailTabEnumExtension.fromTabIndex(initTabIndex),
          );
        },
      ),
      routes: [
        GoRoute(
          path: 'post',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 1),
        ),
        GoRoute(
          path: 'video',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 2),
        ),
        GoRoute(
          path: 'article',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 3),
        ),
        GoRoute(
          path: 'audio',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 4),
        ),
        GoRoute(
          path: 'playlist',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 5),
        ),
        GoRoute(
          path: 'shop',
          redirect: (context, state) => Routes.buildUserDetail(state.pathParameters['userId']!, initTabIndex: 6),
        ),
      ],
    ),
    GoRoute(
      path: Routes.login,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => LoginViewModel(authRepository: context.read()),
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: Routes.videoDetail,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => VideoDetailViewModel(
          videoRepository: context.read(),
          userRepository: context.read(),
          authRepository: context.read(),
          playerConfig: context.read(),
          danmakuConfig: context.read(),
          videoId: state.pathParameters['videoId']!,
          episodeId: state.uri.queryParameters['episodeId'],
          initCover: state.uri.queryParameters['initCover'],
          playlistId: state.uri.queryParameters['playlistId'],
          appController: context.read(),
          mediaSessionController: context.read(),
        ),
        builder: (context, child) => VideoDetailScreen(viewModel: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.watchHistory,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => WatchHistoryViewModel(
          userRepository: context.read(),
        ),
        child: const WatchHistoryScreen(),
      ),
    ),
    GoRoute(
      path: Routes.watchLater,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => WatchLaterViewModel(
          userRepository: context.read(),
        ),
        builder: (context, _) => WatchLaterScreen(viewModel: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.favorites,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => FavoritesTabViewModel(
          userRepository: context.read(),
        ),
        child: const FavoritesScreen(),
      ),
    ),
    GoRoute(
      path: Routes.searchFavorites,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => SearchFavoritesViewModel(
          userRepository: context.read(),
        ),
        child: SearchFavoritesScreen(initFavoritesId: state.uri.queryParameters['favoritesId']),
      ),
    ),
    GoRoute(
      path: Routes.favoritesDetail,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => FavoritesDetailViewModel(
          userRepository: context.read(),
        ),
        child: FavoritesDetailScreen(favoritesId: state.pathParameters['favoritesId']!),
      ),
    ),
    GoRoute(
      path: Routes.userSubscriptions,
      builder: (context, state) {
        final initTabIndex = state.uri.queryParameters['initTabIndex'];
        return SubscriptionsScreen(
          userId: state.pathParameters['userId']!,
          initTabIndex: initTabIndex == null ? .playlist : SubscriptionsTabEnumExtension.fromString(initTabIndex),
        );
      },
    ),
    GoRoute(
      path: Routes.setting,
      builder: (context, state) => const SettingScreen(),
    ),
    GoRoute(
      path: Routes.settingAccountManager,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => AccountManagerViewModel(authRepository: context.read()),
        builder: (context, child) => const AccountManagerScreen(),
      ),
    ),
    GoRoute(
      path: Routes.webView,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => WebViewViewModel(url: state.uri.queryParameters['url']!),
        builder: (context, child) => const WebViewScreen(),
      ),
    ),
    GoRoute(
      path: Routes.articleDetail,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => ArticleDetailViewModel(
          articleRepository: context.read(),
          articleId: state.pathParameters['articleId']!,
        ),
        builder: (context, _) => ArticleDetailScreen(
          viewModel: context.read(),
          cover: state.uri.queryParameters['initCover'],
        ),
      ),
    ),
    GoRoute(
      path: Routes.postDetail,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => PostDetailViewModel(
          postRepository: context.read(),
          userRepository: context.read(),
          postId: state.pathParameters['postId']!,
          initCover: state.uri.queryParameters['initCover'],
        ),
        builder: (context, _) => PostDetailScreen(viewModel: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.userRecentlyLiked,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => RecentlyLikedViewModel(
          userRepository: context.read(),
          userId: state.pathParameters['userId']!,
        ),
        builder: (context, _) => RecentlyLikedScreen(
          viewModel: context.read(),
          nickname: state.uri.queryParameters['nickname'],
        ),
      ),
    ),
    GoRoute(
      path: Routes.userRecentlyCoined,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => RecentlyCoinedViewModel(
          userRepository: context.read(),
          userId: state.pathParameters['userId']!,
        ),
        builder: (context, _) => RecentlyCoinedScreen(
          viewModel: context.read(),
          nickname: state.uri.queryParameters['nickname'],
        ),
      ),
    ),
    GoRoute(
      path: Routes.userFollowings,
      builder: (context, state) => ChangeNotifierProvider(
        create: (context) => UserFollowingsViewModel(
          userRepository: context.read(),
          authRepository: context.read(),
          userDialogViewModel: context.read(),
          userId: state.pathParameters['userId']!,
        ),
        builder: (context, _) => UserFollowingsScreen(viewModel: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.userFans,
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => UserFansViewModel(
          userRepository: context.read(),
          authRepository: context.read(),
          userId: state.pathParameters['userId']!,
        ),
        builder: (context, _) => UserFansScreen(viewModel: context.read()),
      ),
    ),
    GoRoute(
      path: Routes.settingDeveloper,
      builder: (context, state) => const DeveloperSettingScreen(),
    ),
    GoRoute(
      path: Routes.settingDevTestUsers,
      builder: (context, state) => const TestUsersScreen(),
    ),
    GoRoute(
      path: Routes.settingDevTestVideos,
      builder: (context, state) => const TestVideosScreen(),
    ),
    GoRoute(
      path: Routes.settingDevTestArticles,
      builder: (context, state) => const TestArticlesScreen(),
    ),
    GoRoute(
      path: Routes.settingDevTestPosts,
      builder: (context, state) => const TestPostsScreen(),
    ),
    GoRoute(
      path: Routes.settingDevTestAppTitleBar,
      builder: (context, state) => const TestAppTitleBarScreen(),
    ),
    GoRoute(
      path: Routes.echoCave,
      builder: (context, state) => const EchoCaveScreen(),
    ),
  ],
);
