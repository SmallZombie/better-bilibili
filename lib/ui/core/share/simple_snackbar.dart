import 'package:flutter/material.dart';

extension SimpleSnackBar on BuildContext {
  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
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
