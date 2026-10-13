import 'dart:async';

import 'package:better_bilibili/config/eagle_config.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/prompt_dialog.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_info_box.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_switch.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:material_ui/material_ui.dart';

class EagleSettingsScreen extends StatefulWidget {
  final EagleConfig config;

  const EagleSettingsScreen({super.key, required this.config});

  @override
  State<EagleSettingsScreen> createState() => _EagleSettingsScreenState();
}

class _EagleSettingsScreenState extends State<EagleSettingsScreen> {
  EagleConfig get config => widget.config;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eagle'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          spacing: 12.0,
          children: [
            SettingGroup(
              align: .center,
              backgroundColor: Colors.transparent,
              children: [
                ImageWapper(
                  image: AssetImage('assets/images/eagle/logo.png'),
                  width: 120,
                  aspectRatio: 1,
                ),
                SizedBox(height: 8.0),
                SettingInfoBox(
                  align: .center,
                  title: Text(
                    'Eagle',
                    style: TextStyle(fontSize: 20.0),
                    textAlign: .center,
                  ),
                  content: Text('此集成通过为图片查看器增加保存选项来允许您将图片直接保存到 Eagle App 中'),
                ),
              ],
            ),
            SettingGroup(
              children: [
                StreamBuilder(
                  stream: config.enable.stream,
                  initialData: config.enable.value,
                  builder: (context, asyncSnapshot) {
                    return SettingSwitchTile(
                      title: Text('启用'),
                      subtitle: Text('控制此集成的总开关'),
                      icon: const Icon(Icons.extension_outlined),
                      value: asyncSnapshot.data!,
                      onChanged: config.enable.set,
                    );
                  },
                ),
              ],
            ),
            SettingGroup(
              title: Text('偏好'),
              children: [
                StreamBuilder(
                  stream: config.useExternalLinks.stream,
                  initialData: config.useExternalLinks.value,
                  builder: (context, asyncSnapshot) {
                    return SettingSwitchTile(
                      title: Text('使用外部链接'),
                      subtitle: Text('使用官网的 HTTPS 链接而不是 Better 的应用内链接'),
                      value: asyncSnapshot.data!,
                      onChanged: config.useExternalLinks.set,
                    );
                  },
                ),
              ],
            ),
            SettingGroup(
              title: Text('高级'),
              bottom: SettingInfoBox(
                content: Text(
                  '通常情况下，Eagle 的 API 服务仅允许通过本地地址（localhost 和 127.0.0.1）访问。你可以通过配置 API Token 来绕过此限制。API Token 位于「EagleApp → 偏好设置 → 开发者选项」中',
                ),
              ),
              children: [
                StreamBuilder(
                  stream: config.baseUrl.stream,
                  initialData: config.baseUrl.value,
                  builder: (context, asyncSnapshot) {
                    return SettingTile(
                      title: Text('服务地址'),
                      subtitle: Text(asyncSnapshot.data!),
                      onTap: () async {
                        final result = await context.showPrompt<String>(
                          title: '服务地址',
                          initialValue: asyncSnapshot.data!,
                        );
                        if (result == asyncSnapshot.data! || result == null) {
                          return;
                        }

                        config.baseUrl.set(result);
                      },
                    );
                  },
                ),
                StreamBuilder(
                  stream: config.apiToken.stream,
                  initialData: config.apiToken.value,
                  builder: (context, asyncSnapshot) {
                    return SettingTile(
                      title: Text('API Token'),
                      subtitle: asyncSnapshot.data!.isNotEmpty ? Text('已隐藏') : Text('未设置'),
                      onTap: () async {
                        final result = await context.showPrompt<String>(
                          title: 'API Token',
                          initialValue: asyncSnapshot.data!,
                        );
                        if (result == asyncSnapshot.data! || result == null) {
                          return;
                        }

                        unawaited(config.apiToken.set(result));
                      },
                    );
                  },
                ),
              ],
            ),
            SettingGroup(
              children: [
                SettingTile(
                  title: Text('主页'),
                  subtitle: Text('前往 Eagle 官方网站'),
                  icon: const Icon(Icons.home_outlined),
                  onTap: () {
                    context.openUrl('https://eagle.cool/');
                  },
                ),
              ],
            ),
            SizedBox(height: 64.0),
          ],
        ),
      ),
    );
  }
}
