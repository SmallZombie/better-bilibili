import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/color_picker.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DeveloperSettingScreen extends StatelessWidget {
  const DeveloperSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('开发者选项'),
      ),
      body: SingleChildScrollView(
        child: Column(
          spacing: 12.0,
          children: [
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试用户'),
              onTap: () {
                context.push(Routes.settingDevTestUsers.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试视频'),
              onTap: () {
                context.push(Routes.settingDevTestVideos.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试文章'),
              onTap: () {
                context.push(Routes.settingDevTestArticles.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试帖子'),
              onTap: () {
                context.push(Routes.settingDevTestPosts.path);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('标题栏测试'),
              onTap: () {
                context.push(Routes.settingDevTestAppTitleBar.path);
              },
            ),
            SettingGroup(
              children: [
                SettingTile(
                  title: Text('颜色选择器'),
                  onTap: () {
                    context.showColorPicker();
                  },
                ),
                SettingTile(
                  title: Text('Info snackBar'),
                  onTap: () {
                    context.showInfo('Info snackBar');
                  },
                ),
                SettingTile(
                  title: Text('Warring snackBar'),
                  onTap: () {
                    context.showError('Warring snackBar');
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
