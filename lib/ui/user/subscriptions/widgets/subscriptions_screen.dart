import 'package:better_bilibili/ui/user/subscriptions/view_models/manga_tab_view_model.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/movie_tab_view_model.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/playlist_tab_view_model.dart';
import 'package:better_bilibili/ui/user/subscriptions/view_models/series_tab_view_model.dart';
import 'package:better_bilibili/ui/user/subscriptions/widgets/manga_tab_view.dart';
import 'package:better_bilibili/ui/user/subscriptions/widgets/movie_tab_view.dart';
import 'package:better_bilibili/ui/user/subscriptions/widgets/playlist_tab_view.dart';
import 'package:better_bilibili/ui/user/subscriptions/widgets/series_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SubscriptionsScreen extends StatelessWidget {
  final String userId;
  final SubscriptionsTabEnum initTabIndex;

  const SubscriptionsScreen({super.key, required this.userId, this.initTabIndex = .playlist});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: SubscriptionsTabEnum.values.length,
      initialIndex: initTabIndex.tabIndex,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: TabBar(
            tabs: SubscriptionsTabEnum.values.map((v) => Tab(text: v.tabName)).toList(),
            tabAlignment: TabAlignment.center,
            dividerColor: Colors.transparent,
          ),
        ),
        body: TabBarView(
          children: [
            ChangeNotifierProvider(
              create: (_) => PlaylistTabViewModel(
                userRepository: context.read(),
                authRepository: context.read(),
                userId: userId,
              ),
              builder: (context, child) => PlaylistTabView(viewModel: context.read()),
            ),
            ChangeNotifierProvider(
              create: (_) => SeriesTabViewModel(
                userRepository: context.read(),
                authRepository: context.read(),
                userId: userId,
              ),
              builder: (context, _) => SeriesTabView(viewModel: context.read()),
            ),
            ChangeNotifierProvider(
              create: (_) => MovieTabViewModel(
                userRepository: context.read(),
                authRepository: context.read(),
                userId: userId,
              ),
              builder: (context, _) => MovieTabView(viewModel: context.read()),
            ),
            ChangeNotifierProvider(
              create: (_) => MangaTabViewModel(
                userRepository: context.read(),
                authRepository: context.read(),
                userId: userId,
              ),
              builder: (context, _) => MangaTabView(viewModel: context.read()),
            ),
          ],
        ),
      ),
    );
  }
}

enum SubscriptionsTabEnum {
  playlist,
  series,
  movie,
  manga,
}

extension SubscriptionsTabEnumExtension on SubscriptionsTabEnum {
  int get tabIndex => switch (this) {
    .playlist => 0,
    .series => 1,
    .movie => 2,
    .manga => 3,
  };

  String get tabName => switch (this) {
    .playlist => '播放列表',
    .series => '追番',
    .movie => '追剧',
    .manga => '追漫',
  };

  static SubscriptionsTabEnum fromString(String str) => switch (str) {
    '0' => .playlist,
    '1' => .series,
    '2' => .movie,
    '3' => .manga,
    _ => throw Exception('Invaild string'),
  };
}
