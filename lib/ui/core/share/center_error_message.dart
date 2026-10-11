import 'package:material_ui/material_ui.dart';

class CenterErrorMessage extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const CenterErrorMessage({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 32),

          const SizedBox(height: 6),
          Text(errorMessage),

          const SizedBox(height: 12),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
        ],
      ),
    );
  }
}
