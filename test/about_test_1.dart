import 'package:flutter/material.dart';

void main() {
  runApp(const AboutDemoApp());
}

class AboutDemoApp extends StatelessWidget {
  const AboutDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '关于',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const AboutPage(),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('关于'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 720,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo
                Center(
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.play_circle_outline_rounded,
                      size: 56,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // App name
                Text(
                  'Better Bilibili',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '一个更好用的第三方哔哩哔哩客户端',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Version 1.0.0',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.outline,
                  ),
                ),

                const SizedBox(height: 40),

                // Description
                const _SectionTitle(
                  title: '关于应用',
                ),

                const SizedBox(height: 12),

                Text(
                  'Better Bilibili 是一个面向桌面平台的第三方客户端，'
                  '旨在提供更加简洁、现代且具有良好交互体验的视频观看体验。',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.7,
                  ),
                ),

                const SizedBox(height: 32),

                // Links
                const _SectionTitle(
                  title: '项目',
                ),

                const SizedBox(height: 8),

                _AboutTile(
                  icon: Icons.code_rounded,
                  title: 'GitHub',
                  subtitle: '查看项目源代码',
                  onTap: () {},
                ),
                _AboutTile(
                  icon: Icons.home_outlined,
                  title: '项目主页',
                  subtitle: '访问项目官方网站',
                  onTap: () {},
                ),
                _AboutTile(
                  icon: Icons.bug_report_outlined,
                  title: '问题反馈',
                  subtitle: '报告问题或提交建议',
                  onTap: () {},
                ),

                const SizedBox(height: 32),

                // Legal
                const _SectionTitle(
                  title: '其他',
                ),

                const SizedBox(height: 8),

                _AboutTile(
                  icon: Icons.description_outlined,
                  title: '开源许可',
                  subtitle: '查看项目及第三方依赖的许可证',
                  onTap: () {
                    showLicensePage(
                      context: context,
                      applicationName: 'Better Bilibili',
                      applicationVersion: '1.0.0',
                    );
                  },
                ),
                _AboutTile(
                  icon: Icons.privacy_tip_outlined,
                  title: '隐私政策',
                  subtitle: '了解应用如何处理数据',
                  onTap: () {},
                ),
                _AboutTile(
                  icon: Icons.info_outline_rounded,
                  title: '第三方开源项目',
                  subtitle: '查看使用的第三方库',
                  onTap: () {},
                ),

                const SizedBox(height: 48),

                // Footer
                Column(
                  children: [
                    Text(
                      'Made with Flutter',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '© 2026 Better Bilibili',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(
        Icons.chevron_right_rounded,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
