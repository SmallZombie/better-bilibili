import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorite_article_view_model.dart';
import 'package:better_bilibili/ui/favorites/view_models/favorites_tab_view_model.dart';
import 'package:better_bilibili/ui/favorites/widgets/favorite_article_view.dart';
import 'package:better_bilibili/ui/favorites/widgets/favorites_tab_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late final FavoritesTabViewModel _viewModel;
  late final TabController _tabBarController;

  int _currentTab = 0;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _tabBarController = TabController(length: 3, vsync: this);
    _tabBarController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (_tabBarController.indexIsChanging) {
      return;
    }

    setState(() {
      _currentTab = _tabBarController.index;
    });
  }

  Future<void> _onCreateFavorites() async {
    final result = await context.showCreateFavoritesDialog();
    if (result != null) {
      _viewModel.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: TabBar(
          controller: _tabBarController,
          tabs: [
            const Tab(text: '收藏夹'),
            const Tab(text: '文章'),
            const Tab(text: '课程'),
          ],
          tabAlignment: TabAlignment.center,
          dividerColor: Colors.transparent,
        ),
        actions: _currentTab == 0
            ? [
                IconButton(
                  onPressed: () => context.push(Routes.searchFavorites),
                  icon: Icon(Icons.search_outlined),
                  tooltip: '在全部收藏夹中搜索',
                ),
                SizedBox(width: 8.0),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.reorder),
                  tooltip: '收藏夹重排',
                ),
                SizedBox(width: 8.0),
                IconButton(
                  onPressed: _onCreateFavorites,
                  icon: Icon(Icons.add),
                  tooltip: '创建收藏夹',
                ),
              ]
            : null,
      ),
      body: TabBarView(
        controller: _tabBarController,
        children: [
          ChangeNotifierProvider(
            create: (context) => FavoritesTabViewModel(
              userRepository: context.read(),
              authRepository: context.read(),
            ),
            child: const FavoritesTabView(),
          ),
          ChangeNotifierProvider(
            create: (context) => FavoriteArticleViewModel(userRepository: context.read()),
            child: const FavoriteArticleView(),
          ),
          const Text('课程页'),
        ],
      ),
    );
  }
}
