import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_info_box.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_switch.dart';
import 'package:material_ui/material_ui.dart';

class EagleSettingsScreen extends StatefulWidget {
  const EagleSettingsScreen({super.key});

  @override
  State<EagleSettingsScreen> createState() => _EagleSettingsScreenState();
}

class _EagleSettingsScreenState extends State<EagleSettingsScreen> {
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
                  content: Text('此集成允许您将图片直接保存到本地或局域网中的 Eagle 素材库'),
                ),
              ],
            ),
            SettingGroup(
              children: [
                SettingSwitchTile(
                  title: Text('启用'),
                  subtitle: Text('控制此集成的总开关'),
                  icon: const Icon(Icons.extension_outlined),
                ),
              ],
            ),
            SettingGroup(
              title: Text('偏好'),
              children: [
                SettingSwitchTile(
                  title: Text('立即编辑'),
                  subtitle: Text('保存时立即进行分类、添加标签和评分等操作'),
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
