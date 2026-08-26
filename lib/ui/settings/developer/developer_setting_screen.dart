import 'package:better_bilibili/routing/routes.dart';
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
          children: [
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试用户'),
              onTap: () {
                context.push(Routes.settingDevTestUsers);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试视频'),
              onTap: () {
                context.push(Routes.settingDevTestVideos);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试文章'),
              onTap: () {
                context.push(Routes.settingDevTestArticles);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('测试帖子'),
              onTap: () {
                context.push(Routes.settingDevTestPosts);
              },
            ),
            ListTile(
              leading: const Icon(Icons.question_mark),
              title: const Text('标题栏测试'),
              onTap: () {
                context.push(Routes.settingDevTestAppTitleBar);
              },
            ),
          ],
        ),
      ),
    );
  }
}
