import 'dart:math';

import 'package:better_bilibili/ui/auth/login/widgets/code_login_view.dart';
import 'package:better_bilibili/ui/auth/login/widgets/cookie_login_view.dart';
import 'package:better_bilibili/ui/auth/login/widgets/password_login_view.dart';
import 'package:better_bilibili/ui/auth/login/widgets/qr_login_view.dart';
import 'package:better_bilibili/ui/auth/login/view_models/login_view_model.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late LoginViewModel _viewModel;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _viewModel = context.read();
    _tabController = TabController(length: LoginViewModel.tabCount, vsync: this);
    _tabController.addListener(_onTabControllerTick);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabControllerTick);
    _tabController.dispose();

    super.dispose();
  }

  void _onTabControllerTick() {
    if (_tabController.indexIsChanging) return;
    _viewModel.onTabChanged(_tabController.index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('登录'),
        centerTitle: true,
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: ImageWapper(
              image: AssetImage('assets/images/auth_${Random().nextInt(2) == 0 ? '1' : '2'}.png'),
              height: .infinity,
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                TabBar(
                  tabAlignment: TabAlignment.center,
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.lock_outline, size: 20),
                      text: '密码',
                    ),
                    Tab(
                      icon: Icon(Icons.sms_outlined, size: 20),
                      text: '验证码',
                    ),
                    Tab(
                      icon: Icon(Icons.qr_code_scanner, size: 20),
                      text: '二维码',
                    ),
                    Tab(
                      icon: Icon(Icons.cookie_outlined, size: 20),
                      text: 'Cookie',
                    ),
                  ],
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        PasswordLoginView(),
                        CodeLoginView(),
                        QrLoginView(),
                        CookieLoginView(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
