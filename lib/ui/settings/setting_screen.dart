import 'package:better_bilibili/routing/routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('管理账号'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('切换账号'),
              onTap: () {
                context.push(Routes.settingAccountManager);
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_none),
              title: const Text('通知'),
              onTap: () {
                context.push(Routes.settingNotification);
              },
            ),
            Divider(height: 8.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 4.0),
              child: const Text('扩展服务'),
            ),
            ListTile(
              leading: const Icon(Icons.electrical_services),
              title: const Text('云汐岛'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.electrical_services),
              title: const Text('空降助手'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.electrical_services),
              title: const Text('保存到Eagle'),
              onTap: () {},
            ),
            Divider(height: 8.0),
            ListTile(
              leading: const Icon(Icons.code),
              title: const Text('开发者选项'),
              onTap: () {
                context.push(Routes.settingDeveloper);
              },
            ),
            ListTile(
              leading: const Icon(Icons.feedback_outlined),
              title: const Text('反馈'),
              onTap: () {
                // context.push(Routes.settingFeedback);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('关于'),
              onTap: () {
                // context.push(Routes.settingAbout);
              },
            ),
          ],
        ),
      ),
    );
  }
}
