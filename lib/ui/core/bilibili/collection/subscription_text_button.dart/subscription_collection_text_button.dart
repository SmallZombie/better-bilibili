import 'package:better_bilibili/ui/core/bilibili/collection/subscription_text_button.dart/subscription_collection_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:flutter/material.dart';

class SubscriptionCollectionTextButton extends StatefulWidget {
  final SubscriptionCollectionTextButtonViewModel viewModel;
  final Function(bool)? onChange;

  const SubscriptionCollectionTextButton({
    super.key,
    required this.viewModel,
    this.onChange,
  });

  @override
  State<SubscriptionCollectionTextButton> createState() => _SubscriptionCollectionTextButtonState();
}

class _SubscriptionCollectionTextButtonState extends State<SubscriptionCollectionTextButton> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.subscription.addListener(_onResult);
  }

  void _onResult() {
    if (widget.viewModel.subscription.completed) {
      widget.onChange?.call(widget.viewModel.subscribed);
    } else if (widget.viewModel.subscription.error) {
      context.showError('${widget.viewModel.subscribed ? '取消' : ''}订阅失败: ${(widget.viewModel.subscription.result as Error).toString()}');
      widget.viewModel.subscription.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.subscription,
      builder: (context, child) {
        if (widget.viewModel.subscribed) {
          return TextButton(
            onPressed: widget.viewModel.subscription.execute,
            child: const Text('取消订阅'),
          );
        } else {
          return FilledButton(
            onPressed: widget.viewModel.subscription.execute,
            child: const Text('订阅'),
          );
        }
      },
    );
  }
}
