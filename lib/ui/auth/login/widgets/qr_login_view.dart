import 'package:better_bilibili/ui/auth/login/view_models/login_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrLoginView extends StatefulWidget {
  final LoginViewModel viewModel;

  const QrLoginView({super.key, required this.viewModel});

  @override
  State<QrLoginView> createState() => _QrLoginViewState();
}

class _QrLoginViewState extends State<QrLoginView> {
  LoginViewModel get viewModel => widget.viewModel;

  @override
  void initState() {
    super.initState();

    viewModel.getQrCodeStatus.addListener(_onResult);
  }

  @override
  void dispose() {
    viewModel.getQrCodeStatus.removeListener(_onResult);

    super.dispose();
  }

  void _onResult() {
    if (viewModel.qrCodeStatus == .success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const .all(24.0),
      children: [
        const SizedBox(height: 40.0),
        Center(
          child: Container(
            width: 250.0,
            height: 250.0,
            padding: const .all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: .circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListenableBuilder(
              listenable: viewModel.getLoginQrCode,
              builder: (context, child) {
                if (viewModel.getLoginQrCode.error) {
                  return Center(child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error));
                }
                if (viewModel.qrCodeUrl != null) {
                  return QrImageView(
                    data: viewModel.qrCodeUrl!,
                    version: QrVersions.auto,
                    size: 218,
                    backgroundColor: Colors.white,
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ),
        const SizedBox(height: 32),
        ListenableBuilder(
          listenable: Listenable.merge([viewModel.getLoginQrCode, viewModel.getQrCodeStatus]),
          builder: (context, child) => _buildStatusText(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: viewModel.refreshQrLogin,
          icon: const Icon(Icons.refresh),
          label: const Text('刷新'),
        ),
      ],
    );
  }

  /// 此处同时负责展示获取二维码错误和获取二维码状态错误和获取二维码状态成功的情况
  Widget _buildStatusText(ColorScheme colorScheme, TextTheme textTheme) {
    String text;
    IconData icon;
    Color? color;

    if (viewModel.getLoginQrCode.result case Err(:final error)) {
      text = '获取二维码失败：$error';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (viewModel.getQrCodeStatus.result case Err(:final error)) {
      text = '获取二维码状态失败：$error';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (viewModel.qrCodeStatus == .waiting) {
      text = '请使用 B 站客户端扫描二维码';
      icon = Icons.qr_code_scanner;
      color = colorScheme.primary;
    } else if (viewModel.qrCodeStatus == .scanned) {
      text = '请在手机上确认登录';
      icon = Icons.check_circle_outline;
      color = Colors.orange;
    } else if (viewModel.qrCodeStatus == .expired) {
      text = '二维码已过期';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (viewModel.qrCodeStatus == .success) {
      text = '登录成功';
      icon = Icons.check_circle_outline;
      color = Colors.green;
    } else {
      text = '加载中';
      icon = Icons.more_horiz;
    }

    return Row(
      mainAxisAlignment: .center,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: textTheme.bodyLarge?.copyWith(color: color),
            textAlign: .center,
          ),
        ),
      ],
    );
  }
}
