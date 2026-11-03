import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/services/update_service.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/open_url.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_info_box.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_switch.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/ui/core/share/update_dialog.dart';
import 'package:material_ui/material_ui.dart';

class AboutScreen extends StatelessWidget {
  final AppConfig config;
  final UpdateService updateService;

  const AboutScreen({
    super.key,
    required this.config,
    required this.updateService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于')),
      body: ListView(
        children: [
          SettingGroup(
            align: .center,
            backgroundColor: Colors.transparent,
            children: [
              ImageWapper(
                image: AssetImage('assets/icons/icon_256x256.png'),
                width: 120,
                aspectRatio: 1,
              ),
              SizedBox(height: 8.0),
              SettingInfoBox(
                align: .center,
                title: Text(
                  config.appName,
                  style: TextStyle(fontSize: 20.0),
                  textAlign: .center,
                ),
                content: Column(
                  mainAxisSize: .min,
                  children: [
                    Text('试图打造一个更好的 Bilibili 客户端'),
                    Text('Version ${config.fullVersion}'),
                  ],
                ),
              ),
            ],
          ),
          SettingGroup(
            title: Text('更新'),
            children: [
              StreamBuilder(
                stream: config.enableAutoUpdate.stream,
                initialData: config.enableAutoUpdate.value,
                builder: (context, asyncSnapshot) {
                  return SettingSwitchTile(
                    title: Text('检查更新'),
                    subtitle: Text('启用后将会在每次启动时检查更新'),
                    icon: const Icon(Icons.update_outlined),
                    value: asyncSnapshot.data!,
                    onChanged: config.enableAutoUpdate.set,
                  );
                },
              ),
              StreamBuilder(
                stream: config.enablePreReleaseUpdate.stream,
                initialData: config.enablePreReleaseUpdate.value,
                builder: (context, asyncSnapshot) {
                  return SettingSwitchTile(
                    title: Text('预发布版本'),
                    subtitle: Text('启用后将会收到预发布版本的更新通知'),
                    icon: const Icon(Icons.new_releases_outlined),
                    value: asyncSnapshot.data!,
                    onChanged: config.enablePreReleaseUpdate.set,
                  );
                },
              ),
              SettingTile(
                title: Text('立即检查'),
                icon: const Icon(Icons.update_outlined),
                onTap: () async {
                  try {
                    final update = await updateService.checkForUpdates();
                    if (!context.mounted) return;

                    if (update == null) {
                      context.showInfo('当前已是最新版本');
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => UpdateDialog(
                        updateInfo: update,
                        updateService: updateService,
                      ),
                    );
                  } catch (e) {
                    if (!context.mounted) return;
                    context.showError('检查更新失败: $e');
                  }
                },
              ),
            ],
          ),
          SettingGroup(
            title: Text('项目'),
            children: [
              SettingTile(
                title: Text('GitHub'),
                subtitle: Text('查看项目源代码'),
                icon: const Icon(Icons.code_rounded),
                onTap: () => context.openUrl(kGitHubUrl),
                arrow: const Icon(Icons.open_in_new_outlined, size: 20),
              ),
              SettingTile(
                title: Text('问题反馈'),
                subtitle: Text('报告问题或提交建议'),
                icon: const Icon(Icons.bug_report_outlined),
                onTap: () => context.openUrl(kIssuesUrl),
                arrow: const Icon(Icons.open_in_new_outlined, size: 20),
              ),
            ],
          ),
          SettingGroup(
            title: Text('其他'),
            children: [
              SettingTile(
                title: Text('开源许可'),
                subtitle: Text('查看项目使用的许可证'),
                icon: const Icon(Icons.description_outlined),
                onTap: () => context.openUrl(kGitHubUrl),
                arrow: const Icon(Icons.open_in_new_outlined, size: 20),
              ),
              SettingTile(
                title: Text('隐私政策'),
                subtitle: Text('了解应用如何处理数据'),
                icon: const Icon(Icons.privacy_tip_outlined),
                onTap: () => context.openUrl(kIssuesUrl),
                arrow: const Icon(Icons.open_in_new_outlined, size: 20),
              ),
              SettingTile(
                title: Text('第三方开源项目'),
                subtitle: Text('查看项目依赖的第三方库使用的许可证'),
                icon: const Icon(Icons.privacy_tip_outlined),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationIcon: ImageWapper(
                      image: AssetImage('assets/icons/icon_256x256.png'),
                      width: 120,
                      aspectRatio: 1,
                    ),
                    applicationName: config.appName,
                    applicationVersion: config.fullVersion,
                  );
                },
              ),
            ],
          ),
          SettingGroup(
            align: .center,
            backgroundColor: Colors.transparent,
            children: [
              SettingInfoBox(
                align: .center,
                content: Column(
                  mainAxisSize: .min,
                  children: [
                    Text('Made with 💖 and Flutter'),
                    Text('© ${DateTime.now().year} ${config.appName}'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
