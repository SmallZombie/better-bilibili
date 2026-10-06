import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:flutter/material.dart';

class GameTile extends StatelessWidget {
  final String gameId;
  final String name;
  final String description;
  final String cover;

  const GameTile({
    super.key,
    required this.gameId,
    required this.name,
    required this.description,
    required this.cover,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: InkWell(
        onTap: () => context.openUrl('https://www.biligame.com/detail/?id=$gameId'),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  BiliImageWapper(
                    url: cover,
                    height: 120,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  Positioned(
                    top: 8.0,
                    right: 8.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: kInfiniteBorderRadius,
                      ),
                      child: Text(
                        '游戏',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    Text(
                      description,
                      style: TextStyle(fontSize: 14.0, color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
