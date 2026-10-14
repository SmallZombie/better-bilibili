import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

extension PromptDialog on BuildContext {
  /// 返回 null 表示未做修改，
  /// 不传泛型会导致始终返回 null
  Future<T?> showPrompt<T>({
    String? title,
    String? description,
    String? initialValue,
    bool barrierDismissible = true,
  }) async {
    final tIsNumber = T == int || T == double;
    final controller = TextEditingController(text: initialValue);

    await showDialog(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => AlertDialog(
        title: title != null ? Text(title) : null,
        contentPadding: const .symmetric(horizontal: 24.0, vertical: 16.0),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              if (description != null)
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              TextField(
                controller: controller,
                keyboardType: tIsNumber ? .number : null,
                inputFormatters: <TextInputFormatter>[
                  if (tIsNumber) FilteringTextInputFormatter.digitsOnly,
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: context.pop,
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => context.pop(controller.text),
            child: const Text('确认'),
          ),
        ],
      ),
    );

    final value = controller.text.trim();
    controller.dispose();

    if (initialValue == value) return null;
    if (T == String) return value as T;
    if (T == int) return int.tryParse(value) as T?;
    if (T == double) return double.tryParse(value) as T?;

    return null;
  }

  Future<void> showPromptAsync<T>({
    String? title,
    String? description,
    String? initialValue,
    required Future<String?> Function(T value) onSubmit,
  }) async {
    await showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => _AsyncPromptDialog<T>(
        title: title,
        description: description,
        initialValue: initialValue,
        onSubmit: onSubmit,
      ),
    );
  }
}

class _AsyncPromptDialog<T> extends StatefulWidget {
  final String? title;
  final String? description;
  final String? initialValue;
  final Future<String?> Function(T value) onSubmit;

  const _AsyncPromptDialog({
    required this.title,
    required this.description,
    required this.initialValue,
    required this.onSubmit,
  });

  @override
  State<_AsyncPromptDialog<T>> createState() => _AsyncPromptDialogState<T>();
}

class _AsyncPromptDialogState<T> extends State<_AsyncPromptDialog<T>> {
  late final TextEditingController _controller;
  bool _isSubmitting = false;
  String? _errorMessage;

  bool get _isNumber => T == int || T == double;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  T? _getValue() {
    final value = _controller.text.trim();

    if (T == String) return value as T;
    if (T == int) return int.tryParse(value) as T?;
    if (T == double) return double.tryParse(value) as T?;

    return null;
  }

  Future<void> _submit(BuildContext context) async {
    final value = _getValue();
    if (value == null) {
      context.pop();
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final result = await widget.onSubmit(value);

      if (!mounted || !context.mounted) return;
      if (result == null) {
        context.pop();
        return;
      }

      setState(() => _errorMessage = result);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: widget.title != null ? Text(widget.title!) : null,
      contentPadding: const .symmetric(horizontal: 24.0, vertical: 16.0),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            if (widget.description != null)
              Text(
                widget.description!,
                style: TextStyle(color: colorScheme.outline),
              ),
            TextField(
              controller: _controller,
              keyboardType: _isNumber ? .number : null,
              inputFormatters: [
                if (_isNumber) FilteringTextInputFormatter.digitsOnly,
              ],
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: colorScheme.error),
              ),
          ],
        ),
      ),
      actions: [
        if (!_isSubmitting)
          TextButton(
            onPressed: context.pop,
            child: const Text('取消'),
          ),
        _isSubmitting
            ? TextButton(
                onPressed: null,
                child: SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: const CircularProgressIndicator(strokeWidth: 3.0),
                ),
              )
            : TextButton(
                onPressed: () => _submit(context),
                child: const Text('确认'),
              ),
      ],
    );
  }
}
