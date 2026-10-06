import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          SettingGroup(
            title: const Text('账号'),
            children: [
              SettingTile(
                title: const Text('管理账号'),
                icon: const Icon(Icons.person_outline),
                onTap: () {},
              ),
              SettingTile(
                title: const Text('切换账号'),
                icon: const Icon(Icons.person_outline),
                onTap: () {
                  context.push(Routes.settingAccountManager);
                },
              ),
              SettingTile(
                title: const Text('通知'),
                icon: const Icon(Icons.notifications_none),
                onTap: () {
                  context.push(Routes.settingNotification);
                },
              ),
            ],
          ),
          SettingGroup(
            title: Text('集成'),
            children: [
              SettingTile(
                title: const Text('小电视空降助手'),
                icon: const Icon(Icons.extension_outlined),
                onTap: () {
                  context.push(Routes.bsbsbSettings);
                },
              ),
              SettingTile(
                title: const Text('Eagle'),
                icon: const Icon(Icons.extension_outlined),
                onTap: () {
                  context.push(Routes.eagleSettings);
                },
              ),
            ],
          ),
          SettingGroup(
            children: [
              SettingTile(
                title: const Text('开发者选项'),
                icon: const Icon(Icons.code),
                onTap: () {
                  context.push(Routes.settingDeveloper);
                },
              ),
              SettingTile(
                title: const Text('反馈'),
                icon: const Icon(Icons.feedback_outlined),
                onTap: () {
                  // context.push(Routes.settingFeedback);
                },
              ),
              SettingTile(
                title: const Text('关于'),
                icon: const Icon(Icons.info_outline),
                onTap: () {
                  // context.push(Routes.settingAbout);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
