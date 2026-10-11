import 'package:better_bilibili/ui/user/detail/view_models/user_detail_shop_view_model.dart';
import 'package:material_ui/material_ui.dart';

class UserDetailShopView extends StatefulWidget {
  final UserDetailShopViewModel viewModel;

  const UserDetailShopView({super.key, required this.viewModel});

  @override
  State<UserDetailShopView> createState() => _UserDetailShopViewState();
}

class _UserDetailShopViewState extends State<UserDetailShopView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('UserDetailShopView'),
    );
  }
}
