import 'package:material_ui/material_ui.dart';

extension SimpleSnackBar on BuildContext {
  void showError(String message) {
    if (!mounted) return;

    final colorScheme = Theme.of(this).colorScheme;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: colorScheme.onError),
        ),
        backgroundColor: colorScheme.error,
      ),
    );
  }

  void showInfo(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void showSnackBar(SnackBar snackBar) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }
}
