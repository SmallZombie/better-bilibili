import 'package:better_bilibili/ui/user/mutual_follows/mutual_follows_tab_view_model.dart';
import 'package:material_ui/material_ui.dart';

class MutualFollowsTabView extends StatefulWidget {
  final MutualFollowsTabViewModel viewModel;

  const MutualFollowsTabView({super.key, required this.viewModel});

  @override
  State<MutualFollowsTabView> createState() => _MutualFollowsTabViewState();
}

class _MutualFollowsTabViewState extends State<MutualFollowsTabView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('MutualFollowsTabView'),
    );
  }
}
