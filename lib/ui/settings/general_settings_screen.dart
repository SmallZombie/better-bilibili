import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/ui/core/share/selector_dialog.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:material_ui/material_ui.dart';

class GeneralSettingsScreen extends StatelessWidget {
  final AppConfig config;

  const GeneralSettingsScreen({super.key, required this.config});

  String getViewOriginalImageName(BuildContext context, ViewOriginalImageEnum option) => switch (option) {
    .auto => '自动',
    .always => '始终',
    .wifiOnly => '仅 Wi-Fi',
    .never => '从不',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('通用设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SettingGroup(
              title: Text('图片查看器'),
              children: [
                StreamBuilder(
                  stream: config.viewOriginalImage.stream,
                  initialData: config.viewOriginalImage.value,
                  builder: (context, asyncSnapshot) {
                    return SettingTile(
                      title: Text('查看原图'),
                      subtitle: Text('设置图片查看器何时加载原图'),
                      trailing: Text(getViewOriginalImageName(context, asyncSnapshot.data!)),
                      onTap: () async {
                        final result = await context.showSelectorDialog<ViewOriginalImageEnum>(
                          items: [
                            SelectorDialogItem(name: getViewOriginalImageName(context, .auto), value: .auto),
                            SelectorDialogItem(name: getViewOriginalImageName(context, .always), value: .always),
                            SelectorDialogItem(name: getViewOriginalImageName(context, .wifiOnly), value: .wifiOnly),
                            SelectorDialogItem(name: getViewOriginalImageName(context, .never), value: .never),
                          ],
                          initialSelected: asyncSnapshot.data!,
                        );
                        if (result == null || !context.mounted) return;

                        config.viewOriginalImage.set(result);
                      },
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
