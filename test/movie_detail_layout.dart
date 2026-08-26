import 'dart:io';
import 'dart:ui';

import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

class Data {
  final String title;
  final String desc;
  final String banner;
  final String poster;
  final List<Staff> staff;
  final List<Recommend> recommend;

  Data({
    required this.title,
    required this.desc,
    required this.banner,
    required this.poster,
    required this.staff,
    required this.recommend,
  });
}

class Staff {
  final String avatar;
  final String name;
  final String role;

  Staff({required this.avatar, required this.name, required this.role});
}

class Recommend {
  final String cover;
  final String title;

  Recommend({required this.cover, required this.title});
}

final data = Data(
  title: '判处勇者刑：惩罚勇者9004队刑务记录',
  desc:
      '所谓勇者，是世间最为残酷的刑罚。犯下大罪之人被制造为“勇者”，其刑罚便是和魔王战斗。哪怕死了也会被复活起来，无法享受死亡的安宁。被判处勇者刑的前圣骑士团团长赛罗·弗巴茨，率领着由各种性格古怪之人构成的刑罚勇者部队，奔走于战斗的最前线。在残酷的战场上，赛罗与最强的生物兵器之一，剑之“女神”缇欧丽塔相遇了。“在将敌人歼灭之后，要为我献上赞赏……以及抚摸我的头。”为了活下来，以及报复陷害自己的人——赛罗与“女神”订下契约，在这令人绝望的世界中，投身于炽烈的斗争与阴谋的漩涡。',
  banner: 'https://media.themoviedb.org/t/p/w1920_and_h800_multi_faces/k8uBEraJWZf9o7oJbaVHrECwvjC.jpg',
  poster: 'https://www.themoviedb.org/t/p/w1280/jshoRakvXi5jefQPWMxVZ6SL1kF.jpg',
  staff: [
    Staff(
      avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/rLIqw8pIjVIxPb5engrTbu9iOex.jpg',
      name: '阿座上洋平',
      role: 'voice',
    ),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/lCwSzCM8Ifny4V6SSvOZZgKHTCz.jpg', name: '饭冢麻结', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/kXTYBI7skkVSjQ4eg49iEGblt3f.jpg', name: '石上静香', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/1OFi5ofRX0B2ldTPF8ThzLI2wKa.jpg', name: '堀江瞬', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/3hauO9r1NEzgXxk8d2ed1p5dnxM.jpg', name: '土岐隼一', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/fHvIfE0Q7ab0DFlkNVFcXvTKX9y.jpg', name: '上田耀司', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/ugDwdWEXnmv43jcbnfAi4XwiQ8C.jpg', name: '松冈祯丞', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/xo2A4cr8TnhC9rLFxSQvhwCbIOw.jpg', name: '福岛润', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w276_and_h350_face/pF2urY77wuCYd9Fxh7dTirFYKSF.jpg', name: '千叶翔也', role: 'voice'),
    Staff(avatar: 'https://media.themoviedb.org/t/p/w600_and_h900_face/mP3bj0s1gqJ6tCKFLhu4b1CkJj7.jpg', name: '日笠阳子', role: 'voice'),
  ],
  recommend: [
    Recommend(
      cover: "https://i0.hdslb.com/bfs/bangumi/image/84d577271d3f344a95c3e4dc2475cdd5e15fc006.png",
      title: "离开A级队伍的我，和从前的弟子往迷宫深处迈进",
    ),
    Recommend(cover: "http://i0.hdslb.com/bfs/bangumi/fcdb9db0cc3f5c0c3aaa4ca1a9ddea6c121db471.jpg", title: "刀剑神域"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/60929846673c6fe4f2c01cdf3eccfbbf8f4a3f3f.png", title: "刀剑神域外传：暴风之铳 第二季"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/6179b0449be273e4146f25d671ed1115ddae3962.png", title: "克雷瓦提斯-魔兽之王与婴儿与尸之勇者-"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/f78a4fc8d791d4f34300a22d6c0e448076925134.png", title: "叹气的亡灵想隐退"),
    Recommend(cover: "http://i0.hdslb.com/bfs/bangumi/image/3c125e1aad08643e3eff2fb7d45e740c1a052725.png", title: "Re：从零开始的异世界生活 新编集版"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/d01c8128d44478373b846f1c0ce98dadfa15a99b.png", title: "龙与魔女/BURN THE WITCH"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/bc49d339181414b8e23a5d35f1fb1b3a727d9d00.png", title: "野生的大魔王出现了！"),
    Recommend(cover: "http://i0.hdslb.com/bfs/bangumi/85992826bc6c729ad992acd6ac871ae551cae133.jpg", title: "东京教父"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/f3ebb500b701a387f5abde67516c5c96bbd2faff.png", title: "葬送的芙莉莲"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/9cbb6bc074f679f1e11c056c26ea004353421d55.png", title: "弹珠汽水瓶里的千岁同学"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/8cf02211c3fefa4eccc7307ca4fab404707d0cf7.png", title: "迷宫饭"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/eb3173ac8125210368aba37088f42881ff52f33d.png", title: "終末起點（僅限港澳台地區）"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/2f5946880c07914d1cccd112702884f232b647e0.png", title: "末日后酒店"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/b99cc9b9c31d250dd08216a28aa6ebcd6518eee7.png", title: "驯龙高手 重回家园"),
    Recommend(
      cover: "https://i0.hdslb.com/bfs/bangumi/image/2adaf95842a9aa2ea8f05e8ab5efdbff4f425cab.png",
      title: "我要招架一切 逆向误解的世界最强梦想成为冒险者",
    ),
    Recommend(cover: "http://i0.hdslb.com/bfs/bangumi/image/b8b9741464fe51ed7dd4876644a96eabfbbfee52.png", title: "地球隊長（僅限港澳台地區）"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/6b431f3e7aef2fd476a11a59449096f20e5c34a4.jpg", title: "夏目友人帐 第七季"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/7bb44950773cc46fc4eeb7373f95e9dc87f56e8b.png", title: "最后可以再拜托您一件事吗？"),
    Recommend(cover: "https://i0.hdslb.com/bfs/bangumi/image/4903bfced5e901f14bf823fd2c6b50381711f6a9.jpg", title: "魔王2099"),
  ],
);

void main() {
  runApp(
    DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final lightColorScheme = lightDynamic?.harmonized() ?? ColorScheme.fromSeed(seedColor: Colors.pinkAccent);
        final darkColorScheme =
            darkDynamic?.harmonized() ?? ColorScheme.fromSeed(seedColor: Colors.pinkAccent, brightness: Brightness.dark);

        return MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightColorScheme,
            fontFamily: Platform.isWindows ? 'HarmonyOS-Sans' : null,
            chipTheme: ChipThemeData(
              backgroundColor: lightColorScheme.surfaceContainerHigh,
              labelStyle: TextStyle(color: lightColorScheme.onSurface),
              side: BorderSide.none,
              shadowColor: Colors.black.withAlpha(150),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkColorScheme,
            fontFamily: Platform.isWindows ? 'HarmonyOS-Sans' : null,
            chipTheme: ChipThemeData(
              backgroundColor: darkColorScheme.surfaceContainerHigh,
              labelStyle: TextStyle(color: darkColorScheme.onSurface),
              side: BorderSide.none,
              shadowColor: Colors.black.withAlpha(150),
            ),
          ),
          home: MovieDetailLayout(),
        );
      },
    ),
  );
}

class MovieDetailLayout extends StatelessWidget {
  const MovieDetailLayout({super.key});

  final _maxWidth = 2350.0;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    final theme = ThemeData.dark(useMaterial3: true);
    final colorScheme = theme.colorScheme;

    return Theme(
      data: theme,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Image.network(
                    data.banner,
                    width: double.infinity,
                    height: 750,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 250,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            colorScheme.surface,
                            // colorScheme.surface.withAlpha(200),
                            colorScheme.surface.withAlpha(192),
                            Colors.transparent,
                          ],
                          stops: [
                            0.1,
                            0.3,
                            // 0.5,
                            1.0,
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: _maxWidth),
                          child: SizedBox(
                            width: double.infinity,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: AspectRatio(
                                    aspectRatio: 1 / 1.5,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12.0),
                                      child: Image.network(data.poster, fit: BoxFit.cover),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                SelectableText(
                                  data.title,
                                  style: TextStyle(
                                    fontSize: 32.0,
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                SelectableText(
                                  '2026 | 日本 | 动画/Sci-Fi & Fantasy/动作冒险',
                                  style: TextStyle(color: colorScheme.onSurface.withAlpha(192)),
                                ),
                                SizedBox(height: 12.0),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _maxWidth),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: SelectableText(data.desc),
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      spacing: 12.0,
                      children: [
                        // 继续播放
                        FilledButton.icon(
                          icon: Icon(Icons.play_arrow_rounded),
                          label: Text('继续播放'),
                          style: FilledButton.styleFrom(
                            iconSize: 24.0,
                            textStyle: TextStyle(fontSize: 16.0),
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          iconSize: 28.0,
                          onPressed: () {},
                          icon: Icon(Icons.edit_outlined),
                        ),
                        PopupMenuButton(
                          iconSize: 28.0,
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(child: Text('纠错')),
                                PopupMenuItem(child: Text('举报')),
                              ],
                        ),
                        // IconButton(onPressed: () {}, tooltip: '订阅', icon: Icon(Icons.)),
                      ],
                    ),
                    SizedBox(height: 4.0),
                    Text('上次观看: 第二话 00:00'),
                    SizedBox(height: 24.0),
                    Text(
                      '演职人员',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      height: 200,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.staff.length,
                          itemBuilder: (_, index) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: SizedBox(
                                    width: 100,
                                    child: AspectRatio(
                                      aspectRatio: 1 / 1.4,
                                      child: Image.network(
                                        data.staff[index].avatar,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 4.0),
                                Text(
                                  data.staff[index].name,
                                  style: TextStyle(fontSize: 15.0),
                                  maxLines: 1,
                                ),
                                Text(
                                  data.staff[index].role,
                                  style: TextStyle(color: colorScheme.outline),
                                  maxLines: 1,
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(width: 12.0),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.0),
                    Text(
                      '更多推荐',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    SizedBox(
                      height: 350,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(
                          dragDevices: {
                            PointerDeviceKind.touch,
                            PointerDeviceKind.mouse,
                          },
                        ),
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: data.recommend.length,
                          itemBuilder: (_, index) {
                            return SizedBox(
                              width: 180,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: AspectRatio(
                                      aspectRatio: 1 / 1.4,
                                      child: Image.network(
                                        data.recommend[index].cover,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 4.0),
                                  Text(
                                    data.recommend[index].title,
                                    style: TextStyle(fontSize: 15.0),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  // Text(
                                  //   data.recommend[index].role,
                                  //   style: TextStyle(color: colorScheme.outline),
                                  //   maxLines: 1,
                                  // ),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) => SizedBox(width: 12.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
