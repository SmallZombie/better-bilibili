import 'package:better_bilibili/ui/core/share/settings/setting_group.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_switch.dart';
import 'package:better_bilibili/ui/core/share/settings/setting_tile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      home: SettingsTest1(),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
    ),
  );
}

class SettingsTest1 extends StatefulWidget {
  const SettingsTest1({super.key});

  @override
  State<SettingsTest1> createState() => _SettingsTest1State();
}

class _SettingsTest1State extends State<SettingsTest1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          SettingGroup(
            title: Text('外观'),
            children: [
              SettingTile(
                icon: const Icon(Icons.abc),
                title: Text('主题'),
                subtitle: Text('跟随系统'),
                onTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
              SettingTile(
                icon: const Icon(Icons.abc),
                title: Text('动态取色'),
                subtitle: Text('使用系统提供的主题色'),
                onTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
              SettingTile(
                icon: const Icon(Icons.abc),
                title: Text('强调色'),
                subtitle: Text('#FA2D48'),
                onTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
          SettingGroup(
            title: Text('播放'),
            children: [
              SettingTile(
                icon: const Icon(Icons.abc),
                title: Text('淡入淡出'),
                subtitle: Text('跟随系统'),
                onTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
              SettingTile(
                icon: const Icon(Icons.abc),
                title: Text('很可怕吗'),
                subtitle: Text('是的很可怕'),
                onTap: () {},
                action: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.settings),
                ),
              ),
            ],
          ),
          SettingGroup(
            title: Text('???'),
            children: [
              SettingSwitchTile(
                title: Text('标题'),
                subtitle: Text('副标题'),
                icon: Icon(Icons.safety_check),
                onChanged: (_) {},
              ),
              SettingSwitchTile(
                title: Text('标题'),
                subtitle: Text('副标题'),
                icon: Icon(Icons.safety_check),
                onChanged: (_) {},
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
