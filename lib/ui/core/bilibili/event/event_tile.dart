import 'package:better_bilibili/ui/core/bilibili/bili_image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/theme/theme.dart';
import 'package:material_ui/material_ui.dart';

class EventTile extends StatelessWidget {
  final String eventId;
  final String name;
  final String description;
  final String cover;
  final String url;

  const EventTile({
    super.key,
    required this.eventId,
    required this.name,
    required this.description,
    required this.cover,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      child: InkWell(
        onTap: () => context.openUrl(url),
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
                        '活动',
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
