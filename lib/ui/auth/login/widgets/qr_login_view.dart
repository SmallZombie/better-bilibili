import 'package:better_bilibili/data/services/bilibili/model/get_qr_code_status_response.dart';
import 'package:better_bilibili/ui/auth/login/view_models/login_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrLoginView extends StatefulWidget {
  const QrLoginView({super.key});

  @override
  State<QrLoginView> createState() => _QrLoginViewState();
}

class _QrLoginViewState extends State<QrLoginView> {
  late final LoginViewModel _viewModel;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _viewModel.getQrCodeStatus.addListener(_onQrCodeStatusChanged);
  }

  @override
  void dispose() {
    _viewModel.getQrCodeStatus.removeListener(_onQrCodeStatusChanged);

    super.dispose();
  }

  void _onQrCodeStatusChanged() {
    if (_viewModel.qrCodeStatus == QrCodeStatus.success) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 250,
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListenableBuilder(
              listenable: _viewModel.getLoginQrCode,
              builder: (context, child) {
                if (_viewModel.getLoginQrCode.error) {
                  return Center(child: Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error));
                }
                if (_viewModel.qrCodeUrl != null) {
                  return QrImageView(
                    data: _viewModel.qrCodeUrl!,
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
          listenable: Listenable.merge([_viewModel.getLoginQrCode, _viewModel.getQrCodeStatus]),
          builder: (context, child) => _buildStatusText(
            Theme.of(context).colorScheme,
            Theme.of(context).textTheme,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton.icon(
          onPressed: _viewModel.refreshQrLogin,
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

    if (_viewModel.getLoginQrCode.result case Error(:final error)) {
      text = '获取二维码失败：$error';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (_viewModel.getQrCodeStatus.result case Error(:final error)) {
      text = '获取二维码状态失败：$error';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (_viewModel.qrCodeStatus == .waiting) {
      text = '请使用 B 站客户端扫描二维码';
      icon = Icons.qr_code_scanner;
      color = colorScheme.primary;
    } else if (_viewModel.qrCodeStatus == .scanned) {
      text = '请在手机上确认登录';
      icon = Icons.check_circle_outline;
      color = Colors.orange;
    } else if (_viewModel.qrCodeStatus == .expired) {
      text = '二维码已过期';
      icon = Icons.error_outline;
      color = Colors.red;
    } else if (_viewModel.qrCodeStatus == .success) {
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
