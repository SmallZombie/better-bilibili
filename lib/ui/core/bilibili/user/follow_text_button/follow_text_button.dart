import 'package:better_bilibili/ui/core/bilibili/user/follow_text_button/follow_text_button_view_model.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:material_ui/material_ui.dart';

class FollowTextButton extends StatefulWidget {
  final FollowTextButtonViewModel viewModel;
  final Function(bool)? onChange;

  const FollowTextButton({
    super.key,
    required this.viewModel,
    this.onChange,
  });

  @override
  State<FollowTextButton> createState() => _FollowTextButtonState();
}

class _FollowTextButtonState extends State<FollowTextButton> {
  @override
  void initState() {
    super.initState();

    widget.viewModel.follow.addListener(_onResult);
  }

  void _onResult() {
    if (widget.viewModel.follow.success) {
      widget.onChange?.call(widget.viewModel.followed);
    } else if (widget.viewModel.follow.error) {
      context.showError('${widget.viewModel.followed ? '取消' : ''}关注失败: ${(widget.viewModel.follow.result as Error).toString()}');
      widget.viewModel.follow.clearResult();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel.follow,
      builder: (context, child) {
        if (widget.viewModel.followed) {
          return TextButton(
            onPressed: widget.viewModel.follow.execute,
            child: const Text('取消关注'),
          );
        } else {
          return FilledButton(
            onPressed: widget.viewModel.follow.execute,
            child: const Text('关注'),
          );
        }
      },
    );
  }
}
