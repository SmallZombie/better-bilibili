import 'package:better_bilibili/ui/core/bilibili/dynamic_card.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/card_layout_builder.dart';
import 'package:better_bilibili/ui/user/recently_coined/recently_coined_view_model.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class RecentlyCoinedScreen extends StatefulWidget {
  final RecentlyCoinedViewModel viewModel;
  final String? nickname;

  const RecentlyCoinedScreen({super.key, required this.viewModel, this.nickname});

  @override
  State<RecentlyCoinedScreen> createState() => _RecentlyCoinedScreenState();
}

class _RecentlyCoinedScreenState extends State<RecentlyCoinedScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.nickname == null ? const Text('最近投币') : Text('${widget.nickname}的最近投币'),
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel.loadData,
        builder: (context, child) {
          if (widget.viewModel.loadData.error) {
            return CenterErrorMessage(
              errorMessage: getErrorMessage(widget.viewModel.loadData.result!),
              onRetry: widget.viewModel.loadData.execute,
            );
          }
          if (widget.viewModel.videos.isEmpty) {
            if (widget.viewModel.loadData.running) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('暂无内容'));
          }

          return CardLayoutBuilder(
            builder: (context, constraints, gridDelegate, padding) => GridView.builder(
              gridDelegate: gridDelegate,
              padding: padding,
              itemCount: widget.viewModel.videos.length,
              itemBuilder: (context, index) => DynamicCard(data: widget.viewModel.videos[index]),
            ),
          );
        },
      ),
    );
  }
}
