import 'package:better_bilibili/routing/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const data = [
  ('七濑Unia', null, '353361863'),
  ('明日方舟', null, '161775300'),
  ('宋竹小姐', null, '221501689'),
  ('碧月狐', null, '289475254'),
  ('墨水猫猫Suki', null, '230073718'),
  ('', null, ''),
  ('522475522', '注销', '522475522'),
  ('墨茶Official(212535360)', '纪念账号,3代表', '212535360'),
  ('2323凤凰(14135892)', '官测号,1代表', '14135892'),
  ('爱拖更的飞鹰(1955882692)', '专栏,视频,吐槽', '1955882692'),
  ('Kinyue霜寒清月(3546376382188005)', '专栏,视频,吐槽', '3546376382188005'),
  ('伏吕琦(225588262)', '专栏,视频', '225588262'),
  ('镜野七罪(219658506)', '专栏,视频', '219658506'),
  ('北墨清imonaki(676381141)', '专栏,视频,学校,游戏', '676381141'),
  ('终将扑向光明(690206800)', '专栏,学校', '690206800'),
  ('破竹残羽Jalen(84222265)', '合集,合集描述', '84222265'),
  ('', null, ''),
  ('小潮院长(5970160)', null, '5970160'),
  ('人好嘴甜凯尔希(1683678)', null, '1683678'),
  ('银月泽(260170266)', null, '260170266'),
  ('圊侑(397344158)', null, '397344158'),
  ('', null, ''),
  ('非法签名', null, '2108448578'),
];

class TestUsersScreen extends StatefulWidget {
  const TestUsersScreen({super.key});

  @override
  State<TestUsersScreen> createState() => _TestUsersScreenState();
}

class _TestUsersScreenState extends State<TestUsersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TestUsersScreen')),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final user = data[index];

          if (user.$1.isEmpty) {
            return const Divider();
          }

          return ListTile(
            leading: const Icon(Icons.person_outlined),
            title: Text(user.$1),
            subtitle: user.$2 == null ? null : Text(user.$2!),
            onTap: () => context.push(Routes.buildUserDetail(user.$3)),
          );
        },
      ),
    );
  }
}
