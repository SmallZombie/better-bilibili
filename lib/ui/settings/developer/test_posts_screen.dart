import 'package:better_bilibili/routing/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const data = [
  ('MuMu12开屏广告与桌面广告的简单解决办法', null, '830791956620640309'),
  ('将蔚蓝档案活动订阅到你的日历 (ba-event-ics)', null, '1025327350661775362'),
];

class TestPostsScreen extends StatefulWidget {
  const TestPostsScreen({super.key});

  @override
  State<TestPostsScreen> createState() => _TestPostsScreenState();
}

class _TestPostsScreenState extends State<TestPostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TestPostsScreen')),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final post = data[index];

          if (post.$1.isEmpty) {
            return const Divider();
          }

          return ListTile(
            leading: const Icon(Icons.person_outlined),
            title: Text(post.$1),
            subtitle: post.$2 == null ? null : Text(post.$2!),
            onTap: () => context.push(Routes.buildPostDetail(post.$3)),
          );
        },
      ),
    );
  }
}
