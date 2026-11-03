import 'package:better_bilibili/data/services/update_service.dart';
import 'package:better_bilibili/routing/routes.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final UpdateService updateService;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  double _progress = 0.0;
  bool _downloading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      constraints: BoxConstraints(maxWidth: 350),
      child: Padding(
        padding: const .fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: .min,
          spacing: 16.0,
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                Row(
                  spacing: 8.0,
                  children: [
                    const Icon(Icons.update, size: 30.0),
                    Text('发现新版本', style: textTheme.headlineSmall),
                  ],
                ),
                SizedBox(height: 16.0),
                Text('v${widget.updateInfo.version}', style: textTheme.titleMedium),
                SizedBox(height: 6.0),
                SelectableText(widget.updateInfo.releaseNotes),
                SizedBox(height: 16.0),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: '您可以在 '),
                      TextSpan(
                        text: '设置-关于',
                        style: TextStyle(
                          color: colorScheme.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            context.pop();
                            context.push(Routes.settingAbout.path);
                          },
                      ),
                      const TextSpan(text: ' 中关闭自动更新'),
                    ],
                  ),
                ),
              ],
            ),
            if (_errorMessage != null) Text('$_errorMessage', style: TextStyle(color: colorScheme.error)),
            Row(
              spacing: 8.0,
              children: [
                const Spacer(),
                TextButton(
                  onPressed: () => context.pop(),
                  child: Text('稍后'),
                ),
                if (_downloading)
                  TextButton(
                    onPressed: () {},
                    child: Text('${(_progress * 100).toStringAsFixed(1)}%'),
                  )
                else
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        _downloading = true;
                        _errorMessage = null;
                      });

                      try {
                        await widget.updateService.downloadAndInstall(
                          widget.updateInfo.downloadUrl,
                          (count, total) {
                            if (!context.mounted) return;
                            setState(() => _progress = count / total);
                          },
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        setState(() {
                          _downloading = false;
                          _errorMessage = '下载更新失败: $e';
                        });
                      }
                    },
                    child: Text('立即更新'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
