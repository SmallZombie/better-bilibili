import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/l10n/l10n_util.dart';
import 'package:better_bilibili/ui/home/widgets/home_shell.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class RootShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const RootShell({super.key, required this.navigationShell});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  void _onNavDestinationSelected(int index) {
    widget.navigationShell.goBranch(index);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerHighest,
      drawer: const HomeDrawer(),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: widget.navigationShell.currentIndex,
            labelType: .all,
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const .symmetric(vertical: 8.0),
              child: FloatingActionButton(
                heroTag: null,
                elevation: 0,
                hoverElevation: 1,
                onPressed: () => {},
                child: const Icon(Icons.add),
              ),
            ),
            onDestinationSelected: _onNavDestinationSelected,
            destinations: [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: Text(context.l.navHomeName),
              ),
              NavigationRailDestination(
                icon: Selector<BiliBackgroundService, int>(
                  selector: (context, vm) => vm.unreadPostCount,
                  builder: (context, count, _) => Badge(
                    label: Text(count > 99 ? '99+' : count.toString()),
                    isLabelVisible: count > 0,
                    child: Icon(Icons.motion_photos_on_outlined),
                  ),
                ),
                selectedIcon: Selector<BiliBackgroundService, int>(
                  selector: (context, vm) => vm.unreadPostCount,
                  builder: (context, count, _) => Badge(
                    label: Text(count > 99 ? '99+' : count.toString()),
                    isLabelVisible: count > 0,
                    child: Icon(Icons.motion_photos_on),
                  ),
                ),
                label: Text('动态'),
              ),
              NavigationRailDestination(
                icon: Selector<BiliBackgroundService, int>(
                  selector: (context, vm) => vm.unreadChatCount,
                  builder: (context, count, _) => Badge(
                    label: count > 99 ? const Text('99+') : Text(count.toString()),
                    isLabelVisible: count > 0,
                    child: Icon(Icons.forum_outlined),
                  ),
                ),
                selectedIcon: Selector<BiliBackgroundService, int>(
                  selector: (context, vm) => vm.unreadChatCount,
                  builder: (context, count, _) => Badge(
                    label: count > 99 ? const Text('99+') : Text(count.toString()),
                    isLabelVisible: count > 0,
                    child: Icon(Icons.forum),
                  ),
                ),
                label: Text('聊天'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: Text('我'),
              ),
            ],
          ),
          Expanded(
            child: Material(
              borderRadius: .only(topLeft: .circular(24.0), bottomLeft: .circular(24.0)),
              color: colorScheme.surfaceContainerLowest,
              child: widget.navigationShell,
            ),
          ),
        ],
      ),
    );
  }
}
