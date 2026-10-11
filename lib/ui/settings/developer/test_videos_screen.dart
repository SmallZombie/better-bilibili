import 'package:better_bilibili/routing/routes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';

const data = [
  ('需要滚动合集组', null, '116112897345701'),
  ('', null, ''),
  ('简介带进度跳转', null, '116662988703802'),
  ('评论区带进度跳转', null, '116714075325975'),
  ('简介提及', null, '116696929016063'),
  ('简介链接', null, '116692231591572'),
  ('简介链接', null, '116711860735928'),
  ('简介BV', null, '116566402276143'),
  ('评论商品链接', null, '112864861882377'),
  ('评论小程序链接', null, '116567576805852'),
  ('简介提及+链接混排', null, '116709679763876'),
  ('评论AV链接', null, '14661594'),
  ('简介AV', null, '6009789'),
  ('简介额外链接', null, '282920076'),
  ('简介BV, 评论AV+评论BV+额外链接混排', null, '712088826'),
  ('简介额外链接+进度跳转, 评论进度跳转', null, '116068655826919'),
  ('', null, ''),
  ('私有', null, '113550009829810'),
  ('失效', null, '115588273806052'),
  ('', null, ''),
  ('置顶评论+UP+下方原始粉丝', null, '116707414773605'),
  ('', null, ''),
  ('4K+8K', null, '934637444'),
  ('4K+8K, Hi-Res', null, '116684211885461'),
  ('HDR+HDRVivid', null, '113707162011107'),
  ('DolbyVision+4K, Hi-Res+DolbyAtmos', null, '116588816631835'),
  ('', null, ''),
  ('环境光效测试1', null, '113719459710903'),
  ('环境光效测试2', null, '116668961458081'),
  ('环境光效测试3', null, '85054372'),
  ('环境光效测试4', null, '116754256758421'),
  ('环境光效测试5', null, '468419263'),
  ('', null, ''),
  ('逆向弹幕', null, '271'),
  ('弹幕综合测试1', null, '810872'),
  ('弹幕综合测试2', null, '79028837'),
  ('弹幕综合测试3', null, '4008791'),
  ('弹幕综合测试4', null, '9940487'),
  ('弹幕合并测试', null, '4105447'),
];

class TestVideosScreen extends StatefulWidget {
  const TestVideosScreen({super.key});

  @override
  State<TestVideosScreen> createState() => _TestVideosScreenState();
}

class _TestVideosScreenState extends State<TestVideosScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TestVideosScreen')),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final video = data[index];

          if (video.$1.isEmpty) {
            return const Divider();
          }

          return ListTile(
            leading: const Icon(Icons.play_arrow_outlined),
            title: Text(video.$1),
            subtitle: video.$2 == null ? null : Text(video.$2!),
            onTap: () => context.push(Routes.buildVideoDetail(videoId: video.$3)),
          );
        },
      ),
    );
  }
}
