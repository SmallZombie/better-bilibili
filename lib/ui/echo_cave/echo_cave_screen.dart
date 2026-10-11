import 'dart:math';

import 'package:better_bilibili/routing/routes.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

class Echo {
  final String? prefix;
  final List<String> validValues;
  final String? suffix;
  final ValueChanged<BuildContext> onSubmit;
  final Color? color;

  const Echo({
    this.prefix,
    required this.validValues,
    this.suffix,
    required this.onSubmit,
    this.color,
  });
}

final _data = [
  Echo(
    prefix: '谎言的谎言，',
    validValues: [
      '这便可瞬间颠倒正反',
      '这便能翻转成真实',
      '那便能翻转成真实',
      'それはクルリと裏返る',
    ],
    onSubmit: (context) => context.replace(Routes.buildVideoDetail(videoId: '114324815220956')),
  ),
  Echo(
    prefix: '在日渐沉没的世界里，',
    validValues: [
      '我找到了你',
      '君をみつけた',
    ],
    onSubmit: (context) => context.replace(Routes.buildVideoDetail(videoId: '1955707906')),
  ),
  Echo(
    prefix: '天若无能制裁邪恶，',
    validValues: [
      '吾等将于黑暗之中给予消逝',
    ],
    onSubmit: (context) => context.replace(Routes.buildVideoDetail(videoId: '14522631')),
  ),
  Echo(
    prefix: '我们之中混入了一位魔女',
    validValues: [
      '月代雪',
      'TsukishiroYuki'.toLowerCase(),
      'つきしろゆき',
    ],
    onSubmit: (context) => context.replace(Routes.buildVideoDetail(videoId: '114116593259152')),
    color: Colors.red,
  ),
  Echo(
    prefix: '一个对所有人',
    suffix: '的地方，依然是遥远的理想',
    validValues: [
      '公正',
    ],
    onSubmit: (context) => context.replace(Routes.buildVideoDetail(videoId: '116034413527204')),
    color: Colors.red,
  ),
];

class EchoCaveScreen extends StatefulWidget {
  const EchoCaveScreen({super.key});

  @override
  State<EchoCaveScreen> createState() => _EchoCaveScreenState();
}

class _EchoCaveScreenState extends State<EchoCaveScreen> {
  late final Echo _echo;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();

    _echo = _data[Random().nextInt(_data.length)];
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  void _onInputChanged(String value) {
    final cleanedInput = cleanString(value);
    if (_echo.validValues.contains(cleanedInput)) {
      FocusScope.of(context).unfocus();
      _echo.onSubmit(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: DefaultTextStyle.merge(
        style: TextStyle(color: _echo.color),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0,
              runSpacing: 12.0,
              alignment: WrapAlignment.center,
              children: [
                if (_echo.prefix != null)
                  Text(
                    _echo.prefix!,
                    style: const TextStyle(fontSize: 18),
                  ),

                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _controller,
                    onChanged: _onInputChanged,
                    decoration: null,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),

                if (_echo.suffix != null)
                  Text(
                    _echo.suffix!,
                    style: const TextStyle(fontSize: 18),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
