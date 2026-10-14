import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class CommandBuilder<T> extends StatelessWidget {
  final Command<T> command;
  final Widget Function(BuildContext context) loadingBuilder;
  final Widget Function(BuildContext context, T value) successBuilder;
  final Widget Function(BuildContext context, String error) errorBuilder;

  const CommandBuilder({
    super.key,
    required this.command,
    required this.loadingBuilder,
    required this.successBuilder,
    required this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: command,
      builder: (context, child) {
        if (command.running || command.result == null) {
          return loadingBuilder(context);
        }

        switch (command.result as Result<T>) {
          case Ok(:final value):
            return successBuilder(context, value);
          case Error(:final error):
            return errorBuilder(context, error.toString());
        }
      },
    );
  }
}
