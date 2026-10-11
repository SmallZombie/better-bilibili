import 'dart:math';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const _homeDrawerDivider = (icon: Icons.abc, title: '', route: '');
const _homeDrawerItems = [
  (icon: Icons.home_outlined, title: '首页', route: Routes.home),
  (icon: Icons.movie_outlined, title: '电影', route: ''),
  (icon: Icons.tv_outlined, title: '剧集', route: ''),
  (icon: Icons.live_tv_outlined, title: '直播', route: ''),
  (icon: Icons.article_outlined, title: '文章', route: Routes.homeArticle),
  (icon: Icons.music_note_outlined, title: '音乐', route: ''),
  _homeDrawerDivider,
  (icon: Icons.book_outlined, title: '书籍', route: ''),
  (icon: Icons.school_outlined, title: '课程', route: ''),
  (icon: Icons.sports_esports_outlined, title: '游戏', route: ''),
  (icon: Icons.shopping_cart_outlined, title: '商城', route: ''),
];

class HomeShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const HomeShell({super.key, required this.navigationShell});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  void _onPressed() {
    Scaffold.maybeOf(context)?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // 展开/折叠
              IconButton(
                onPressed: _onPressed,
                icon: const Icon(Icons.menu),
              ),

              // 搜索
              const SizedBox(width: 8),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Material(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: kInfiniteBorderRadius,
                      child: InkWell(
                        borderRadius: kInfiniteBorderRadius,
                        onTap: () => context.push(Routes.search),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 10.0, 16.0, 10.0),
                          child: Row(
                            children: [
                              Icon(Icons.search, size: 20.0, color: colorScheme.onSurfaceVariant),
                              const SizedBox(width: 10),
                              Text('搜索', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 新增
              const SizedBox(width: 8),
              IconButton(onPressed: () {}, icon: Icon(Icons.add)),

              // 通知
              const SizedBox(width: 2),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
              ),

              // 右边距
              SizedBox(width: 8),
            ],
          ),
        ),
        Expanded(child: widget.navigationShell),
      ],
    );
  }
}

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        width: min(248, MediaQuery.sizeOf(context).width),
        child: ListView(
          children: [
            // const Padding(
            //   padding: EdgeInsets.fromLTRB(14, 14, 0, 4),
            //   child: Icon(CustomIcons.better_logo),
            // ),
            ..._homeDrawerItems.map((item) {
              if (item == _homeDrawerDivider) {
                return const Divider();
              }

              return ListTile(
                enabled: item.route.isNotEmpty,
                leading: Icon(item.icon),
                title: Text(item.title),
                onTap: () {
                  context.pop();
                  context.go(item.route);
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
