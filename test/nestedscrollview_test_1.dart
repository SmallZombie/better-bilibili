import 'dart:ui';

import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_user_avatar.dart';
import 'package:better_bilibili/ui/core/themes/theme.dart';
import 'package:better_bilibili/utils/base_util.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/hex_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

// https://medium.com/@diegoveloper/flutter-collapsing-toolbar-sliver-app-bar-14b858e87abe
// https://github.com/diegoveloper/flutter-samples

void main() {
  runApp(
    MaterialApp(
      home: MainCollapsingToolbar(),
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
    ),
  );
}

class MainCollapsingToolbar extends StatefulWidget {
  const MainCollapsingToolbar({super.key});

  @override
  State<MainCollapsingToolbar> createState() => _MainCollapsingToolbarState();
}

class _MainCollapsingToolbarState extends State<MainCollapsingToolbar> {
  final avatarSize = 128.0;

  @override
  Widget build(BuildContext context) {
    final userInfo = GetUserInfoResponse(
      id: '',
      nickname: '七濑Unia',
      avatar: 'https://i2.hdslb.com/bfs/face/99a03fc75ad7246a86a8e8f5770417be9b650ca9.jpg',
      avatarFrame: AvatarFrame(id: '', url: 'https://i2.hdslb.com/bfs/garb/item/c3df9001ad9040cae8d7ee55d1fbe283caaaffda.png'),
      banner: '',
      level: .lv6,
      sponsorCount: 114,
      // 标签最多5个，每个最多10字符，中文每个算1字符
      tags: List.generate(5, (index) => '虚拟主播虚拟主播虚拟'),
      gender: .female,
      birthDate: '12-01',
      // 简介最多70字符，中文每个算1字符
      description: generateRandomString(
        70,
        useCustomChars: ['啊'],
        useLowerCase: false,
        useNumbers: false,
        useUpperCase: false,
      ),
      vip: UserVip(type: .year, expiredAt: 114514, labelImage: 'https://i0.hdslb.com/bfs/vip/ede64e00ce36b8190d24f2d5ceacea854c855af9.png'),
      verified: 'bilibili 知名虚拟UP主、直播高能主播',
    );

    final colorScheme = Theme.of(context).colorScheme;

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: Scaffold(
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: 380,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            'https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350',
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                        Padding(
                          padding: const .only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: .start,
                            spacing: 8.0,
                            children: [
                              Transform.translate(
                                offset: Offset(0.0, avatarSize / 2 * -1),
                                child: BiliUserAvatar(
                                  url: userInfo.avatar,
                                  frameImage: userInfo.avatarFrame == null ? null : NetworkImage(userInfo.avatarFrame!.url),
                                  size: avatarSize,
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: .start,
                                  spacing: 8.0,
                                  children: [
                                    Row(
                                      spacing: 8.0,
                                      crossAxisAlignment: .center,
                                      children: [
                                        Flexible(
                                          child: SelectableText(
                                            userInfo.nickname,
                                            style: TextStyle(fontSize: 24.0),
                                          ),
                                        ),
                                        SvgPicture.asset(
                                          getLevelIconPath(userInfo.level.level),
                                          height: 20,
                                        ),
                                        if (userInfo.vip != null)
                                          Image.network(
                                            userInfo.vip!.labelImage,
                                            height: 22,
                                          ),
                                        if (userInfo.achievement != null)
                                          Tooltip(
                                            message: '${userInfo.achievement!.name}: ${userInfo.achievement!.description}',
                                            child: Image.network(
                                              userInfo.achievement!.icon,
                                              height: 20.0,
                                            ),
                                          ),
                                        if (userInfo.fanBadge != null)
                                          Container(
                                            padding: const .symmetric(horizontal: 8.0, vertical: 1.0),
                                            decoration: BoxDecoration(
                                              color: HexColor(userInfo.fanBadge!.backgroundColorStart),
                                              borderRadius: kInfiniteBorderRadius,
                                              border: .all(color: HexColor(userInfo.fanBadge!.borderColor)),
                                            ),
                                            child: Row(
                                              mainAxisSize: .min,
                                              spacing: 2.0,
                                              children: [
                                                Text(
                                                  userInfo.fanBadge!.name,
                                                  style: TextStyle(
                                                    color: HexColor(userInfo.fanBadge!.nameColor),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                                Text(
                                                  userInfo.fanBadge!.level.toString(),
                                                  style: TextStyle(
                                                    fontSize: 10.0,
                                                    fontWeight: .bold,
                                                    color: HexColor(userInfo.fanBadge!.levelColor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    if (userInfo.description != null)
                                      SelectableText(
                                        userInfo.description!,
                                        style: TextStyle(color: colorScheme.outline),
                                      ),
                                    Wrap(
                                      spacing: 8.0,
                                      runSpacing: 8.0,
                                      children: [
                                        if (userInfo.verified != null)
                                          Row(
                                            mainAxisSize: .min,
                                            spacing: 4.0,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/verified_icon.svg',
                                                height: 20.0,
                                              ),
                                              Text(
                                                userInfo.verified!,
                                                style: TextStyle(color: colorScheme.outline),
                                              ),
                                            ],
                                          ),
                                        if (userInfo.organizationVerified != null)
                                          Row(
                                            mainAxisSize: .min,
                                            spacing: 4.0,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/organization_verified_icon.svg',
                                                height: 20.0,
                                              ),
                                              Text(
                                                userInfo.organizationVerified!,
                                                style: TextStyle(color: colorScheme.outline),
                                              ),
                                            ],
                                          ),
                                        if (userInfo.gender != .unknown)
                                          Row(
                                            mainAxisSize: .min,
                                            spacing: 2.0,
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: 20.0,
                                                color: colorScheme.outline,
                                              ),
                                              Text(
                                                switch (userInfo.gender) {
                                                  .male => '男',
                                                  .female => '女',
                                                  _ => '',
                                                },
                                                style: TextStyle(color: colorScheme.outline),
                                              ),
                                            ],
                                          ),
                                        if (userInfo.birthDate != null)
                                          Row(
                                            mainAxisSize: .min,
                                            spacing: 2.0,
                                            children: [
                                              Icon(
                                                Icons.cake_outlined,
                                                size: 18.0,
                                                color: colorScheme.outline,
                                              ),
                                              Text(
                                                userInfo.birthDate!,
                                                style: TextStyle(color: colorScheme.outline),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    if (userInfo.tags.isNotEmpty)
                                      Wrap(
                                        spacing: 4.0,
                                        runSpacing: 4.0,
                                        children: userInfo.tags
                                            .map(
                                              (v) => Chip(
                                                label: Text(
                                                  v,
                                                  style: TextStyle(fontSize: 12.0),
                                                ),
                                                shape: const StadiumBorder(),
                                                padding: const .symmetric(horizontal: 4.0),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.abc))],
                ),
                SliverPersistentHeader(
                  delegate: _SliverAppBarDelegate(
                    TabBar(
                      tabs: const [
                        Tab(text: "Tab 1"),
                        Tab(text: "Tab 2"),
                      ],
                    ),
                  ),
                  pinned: true,
                ),
              ];
            },
            body: TabBarView(
              children: [
                SafeArea(
                  top: false,
                  bottom: false,
                  child: ListView(
                    children: List.generate(
                      50,
                      (index) => Text('awa $index'),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  bottom: false,
                  child: ListView(
                    children: List.generate(
                      50,
                      (index) => Text('qwp $index'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
