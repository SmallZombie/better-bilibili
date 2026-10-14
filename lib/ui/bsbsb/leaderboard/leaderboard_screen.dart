import 'package:better_bilibili/ui/bsbsb/leaderboard/leaderboard_view_model.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/command_builder.dart';
import 'package:better_bilibili/ui/core/share/responsive/max_width_viewport.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';

class LeaderboardScreen extends StatefulWidget {
  final LeaderboardViewModel viewModel;

  const LeaderboardScreen({super.key, required this.viewModel});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardViewModel get viewModel => widget.viewModel;

  @override
  Widget build(BuildContext context) {
    final spacing = 12.0;

    return Scaffold(
      appBar: AppBar(title: Text('排行榜')),
      body: CommandBuilder(
        command: viewModel.loadData,
        loadingBuilder: (context) => Center(child: const CircularProgressIndicator()),
        successBuilder: (context, value) => MaxWidthViewport.builder(
          builder: (context, padding) => Column(
            crossAxisAlignment: .start,
            children: [
              Padding(
                padding: padding.copyWith(top: 0, bottom: 0),
                // TODO OptionsSheet 实现后回来优化
                child: Row(
                  children: [
                    SizedBox(
                      width: 32.0 + 12.0,
                      child: Center(child: Text('排名', textAlign: .center)),
                    ),
                    Expanded(
                      child: Text('用户名', maxLines: 1, overflow: .ellipsis),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const .symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 64.0,
                          height: 32.0,
                          child: Align(
                            alignment: .centerLeft,
                            child: Text('提交量 ↓'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const .symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 128.0,
                          height: 32.0,
                          child: Align(
                            alignment: .centerLeft,
                            child: Text('节省时间'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const .symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 64.0,
                          height: 32.0,
                          child: Align(
                            alignment: .centerLeft,
                            child: Text('获赞量'),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {},
                      child: Padding(
                        padding: const .symmetric(horizontal: 8.0),
                        child: SizedBox(
                          width: 64.0,
                          height: 32.0,
                          child: Align(
                            alignment: .centerLeft,
                            child: Text('跳过数量'),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const .symmetric(horizontal: 8.0),
                      child: SizedBox(
                        width: 128.0,
                        height: 32.0,
                        child: Align(
                          alignment: .centerLeft,
                          child: Text('绑定搬运视频'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: padding,
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    final item = value[index];
                    return Material(
                      child: InkWell(
                        onTap: () {},
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            spacing: spacing,
                            children: [
                              SizedBox(width: 32.0, child: _buildRankBadge(index + 1)),
                              Expanded(child: Text(item.username)),
                              SizedBox(width: 64.0, child: Text(item.submitCount.toString())),
                              SizedBox(width: 128.0, child: Text(formatDuration(item.saveTime))),
                              SizedBox(width: 64.0, child: Text(item.likeCount.toString())),
                              SizedBox(width: 64.0, child: Text(item.skipCount.toString())),
                              SizedBox(width: 128.0, child: Text(item.bindvideoSourceCount.toString())),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        errorBuilder: (context, message) => CenterErrorMessage(
          errorMessage: message,
          onRetry: viewModel.loadData.execute,
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank) {
    final colorScheme = Theme.of(context).colorScheme;

    final (background, foreground, icon) = switch (rank) {
      1 => (const Color(0xFFFFF1C2), const Color(0xFF9B6500), Icons.emoji_events_rounded),
      2 => (const Color(0xFFE8EDF3), const Color(0xFF536273), Icons.workspace_premium_rounded),
      3 => (const Color(0xFFF8E5D8), const Color(0xFF9A5B35), Icons.workspace_premium_rounded),
      >= 4 && <= 20 => (colorScheme.secondaryContainer, colorScheme.onSecondaryContainer, null),
      _ => (null, colorScheme.onSecondaryContainer, null),
    };

    return Container(
      width: 34.0,
      height: 34.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: icon == null
          ? Text(
              '$rank',
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            )
          : Icon(icon, size: 19.0, color: foreground),
    );
  }
}
