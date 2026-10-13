import 'dart:io';

import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/ui/core/share/image_wapper.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue, useMaterial3: true),
      home: const RichTextTest1(),
    ),
  );
}

class RichTextTest1 extends StatefulWidget {
  const RichTextTest1({super.key});

  @override
  State<RichTextTest1> createState() => _RichTextTest1State();
}

class _RichTextTest1State extends State<RichTextTest1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RichTextTest1')),
      body: Padding(
        padding: const .all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: .start,
            spacing: 24.0,
            children: [
              BiliRichTextWapper(
                rawText:
                    'https://miniapp.bilibili.com/appletx/biliaf83c642b5ce025e/pages/detail/detail?bl_album_id=166901&bl_episode_id=3121696\n↑↑↑↑戳这里直达完整高清全集\n（免费看，不用充电）\n辛苦宝子们点个关注和赞赞呀~！！！',
                parserNodes: [
                  LinkParseNode(
                    links: [
                      CommentInnerLink(
                        title: '【情感完结】【一口气看完系列】《【10小时甜文完结】一觉醒来后自己居然成了白毛萝莉，更要命的是好兄弟竟然馋我身子》',
                        rawText:
                            'https://miniapp.bilibili.com/appletx/biliaf83c642b5ce025e/pages/detail/detail?bl_album_id=166901&bl_episode_id=3121696',
                        url:
                            'https://miniapp.bilibili.com/appletx/biliaf83c642b5ce025e/pages/detail/detail?bl_album_id=166901&bl_episode_id=3121696',
                        appUrl:
                            'https://miniapp.bilibili.com/appletx/biliaf83c642b5ce025e/pages/detail/detail?bl_album_id=166901&bl_episode_id=3121696&planting_info=0hd1nACOCIFrU0fEF3q2RfZG-RYoX5rEz9nPRnKZ4NRrMh1b8Wu6gprJWwo2Gycp&sourcefrom=100101&reportExtra=%7B%22from_avid%22:%22116567576805852%22,%22is_up_reply%22:%221%22,%22jump_type%22:%2210000%22,%22track_id%22:%22%22%7D',
                      ),
                    ],
                  ),
                ],
              ),
              BiliRichTextWapper(
                rawText: 'https://b23.tv/mall-G0GAuI7tO-15eIQPf5B4K',
                parserNodes: [
                  LinkParseNode(
                    links: [
                      CommentInnerLink(
                        title: '16厘米采耳镊子专业采耳工具夹耳屎夹异物夹子',
                        rawText: 'https://b23.tv/mall-G0GAuI7tO-15eIQPf5B4K',
                        url: 'https://b23.tv/mall-G0GAuI7tO-15eIQPf5B4K',
                        appUrl:
                            'tbopen://m.taobao.com/tbopen/index.html?action=ali.open.nav&module=h5&bootImage=0&source=alimama&appkey=27696150&appName=bilibili&packageName=tv.danmaku.bili&backURL=bilibili%3A%2F%2Fblank%3Fcm_mark%3Dtaobao&bc_fl_src=tunion_wl_tk_content&h5Url=https%3A%2F%2Fs.click.taobao.com%2Ft%3Fe%3Dm%253D2%2526s%253D%252BBZsLAMHx6tw4vFB6t2Z2ueEDrYVVa64XoO8tOebS%252BdRAdhuF14FMeklZSzlbb9Y5x%252BIUlGKNpWSdGC1rpOKsk1BDNvYGRHjnTrj2wREI%252FOs9nS%252BlCltJGPTgTrE37eL1qrpxiwMoCNxc1AtbZGVS0fl3ylFVVyPnLyOxdE%252BRwNvCWsUrmbeS%252FpeYgZIHhnW546trwdBYTdeInGjFILyFYrvVw%252Fm75J4%252B6oAndPx4U9SzORAvonu3S1Ni1TN3kHu9CZYS5NCZeE7a6NY1Dbp4R5yKhFLeSdSxRwNXYe0TSUru%252BmSW8c0TlS3bAsv%252B0bKxt97d4Y0QgMfN7GzsR96505veXzgmNMiXtohqgrB0poLsZjQdeACVcGfq8%252B26TT0AiTevyaoSaBMdIp1rr4P3Q%253D%253D%26union_lens%3DlensId%3ATAPI%401722181455%402133e87c_13e3_190fa038f39_8c95%4001%26cont_id%3DBV11vefeXEpm',
                      ),
                    ],
                  ),
                ],
              ),
              BiliRichTextWapper(
                rawText: '@糖炒灬小板栗 @和雪狐贴贴的夕岛 @猫咪钥匙 @大荒丶星陨Night 曼波和最左边那个反过来，那个人是睡神，曼波是不睡觉的神人, https://www.baidu.com',
                parserNodes: [
                  LinkParseNode(
                    links: [
                      CommentInnerLink(
                        rawText: 'https://www.baidu.com',
                        url: 'https://www.baidu.com',
                      ),
                    ],
                  ),
                  UserParseNode(
                    users: [
                      CommentInnerUser(id: '179644859', nickname: '和雪狐贴贴的夕岛'),
                      CommentInnerUser(id: '687856297', nickname: '大荒丶星陨Night'),
                      CommentInnerUser(id: '360406982', nickname: '猫咪钥匙'),
                      CommentInnerUser(id: '38451180', nickname: '糖炒灬小板栗'),
                    ],
                  ),
                ],
              ),
              BiliRichTextWapper(
                rawText:
                    '曲绘是星尘+谱尼、Minus+索伦森的结合，不是单纯的谱尼索伦森，也不是单纯的星尘Minus。\n非要说的话，会更接近星尘cos谱尼+Minus cos索伦森。\n如果你认为看不出性别，是因为谱尼和（没进化前的）索伦森无性别，所以特地拜托雪子这样画的。如果你认为女性化，是因为唱歌的星尘和Minus是女的。\n这种歌姬与另一个角色融合的形式，跟冠世/权御/9981pv里出现的立绘是一样的行为。\n\n给不知道星尘和Minus的常长老：\n　　星尘和Minus是平行四界的两位虚拟歌姬，就是输入音符和发音他就能唱歌的软件。\n　　星尘和Minus的官方故事设定是一光一影的对应。这是我开这个坑的原因之一。\n　　星尘的官方试听曲：BV1Zs411D7vo \n　　Minus的官方试听曲：BV1hk4y117kk （←你可以看到这里面出现的Minus立绘有点混索的味道，相关推荐里星尘版本的立绘有点圣谱的味道，这是我开这个坑的原因之二\n\n给不知道秩序之战的歌姬听众：\n　　秩序之战是页游赛尔号历时最长规模最宏大的战争剧情。这场战争从2017年正式开始，于2019年结束（pv里是结束的任务录像）。虽然正式打了2年，但它开始的苗头甚至可以追溯到2013。谱尼与索伦森是这场战争中秩序与混沌两个阵营的领军。\n　　《秩序之战》大致剧情：av24368882  BV1ab411v7B1 \n　　谱尼解说：BV1Zx411G7G9    索伦森解说：BV1nW41167pC \n　　《秩序之战》完整剧情：\n　　https://space.bilibili.com/7285804/channel/detail?cid=14462   ←Part12-47\n\n给没补过页游秩序之战的动画党：\n　　动画页游的索谱设定不一样，不要瞎代入动画设定。',
                parserNodes: [
                  LinkParseNode(
                    links: [
                      CommentInnerLink(
                        rawText: 'BV1Zs411D7vo',
                        title: '【星尘V4官方试听曲】星愿StarWish',
                        url: '$kAppDeepLinkScheme://video/BV1Zs411D7vo',
                      ),
                      CommentInnerLink(
                        rawText: 'BV1Zx411G7G9',
                        title: '赛尔号“永远的神”，圣光联军的指引者——谱尼剧情解说',
                        url: '$kAppDeepLinkScheme://video/BV1Zx411G7G9',
                      ),
                      CommentInnerLink(
                        rawText: 'BV1ab411v7B1',
                        title: '【赛尔号剧情解说】跨越十年的决战：2018.6-2019.3全主线剧情回顾',
                        url: '$kAppDeepLinkScheme://video/BV1ab411v7B1',
                      ),
                      CommentInnerLink(
                        rawText: 'BV1hk4y117kk',
                        title: '【Minus丨官方试听曲】零和Zero-Sum【SynthV side】',
                        url: '$kAppDeepLinkScheme://video/BV1hk4y117kk',
                      ),
                      CommentInnerLink(
                        rawText: 'BV1nW41167pC',
                        title: '混沌教派的主宰，《赛尔号》顶级反派——索伦森',
                        url: '$kAppDeepLinkScheme://video/BV1nW41167pC',
                      ),
                      CommentInnerLink(
                        rawText: 'av24368882',
                        title: '【赛尔号剧情解说】尚未完结的故事：2009.6-2018.6全主线剧情回顾',
                        url: '$kAppDeepLinkScheme://video/av24368882',
                      ),
                    ],
                  ),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                ],
              ),
              BiliRichTextWapper(
                rawText:
                    '这是伪合唱，是将多个翻唱版本混合在一起的，并不是找这么多人过来唱的。\n\n▼本家（Orangestar feat. IA×初音ミク）\nhttps://youtu.be/rkaNKAvksDE\n\n▽使用歌手音源\n\n▼しほ×航友\nhttps://youtu.be/MT0DwQbwK-k\n▼ころん\nhttps://youtu.be/0YbxWj5QllM\n▼花鋏キョウ×エルセ\nhttps://youtu.be/riHkkuqmX1w\n▼りする\nhttps://youtu.be/i4woNWycBsg\n▼Lucia\nhttps://youtu.be/53JRla6WIco\n▼夢河かのん×こうよう\nhttps://youtu.be/G8qAc9Rpttk\n▼SILVANA×まるぐり×しゃけみー×すたんちゃん\nhttps://youtu.be/Ypp3ZtmRAA0\n▼葉加瀬冬雪×フレン・E・ルスタリオ\nhttps://youtu.be/XvCgIFaUCG0\n▼まぜ太×ぷりっつ×あっきぃ\nhttps://youtu.be/BoPqCx-klYQ\n▼绊爱\nhttps://youtu.be/QwP_GF5xU58',
                parserNodes: [
                  LinkParseNode(links: []),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                ],
              ),
              BiliRichTextWapper(
                rawText:
                    '【タイムライン】\n0:00 イントロ by 全員\n0:05 Aメロ① by 葉音©\n0:16 Aメロ② by いもゆり\n0:27 Bメロ① by 宮原彩\n0:41 サビ① by あーち\n0:53 サビ② by ちな\n1:07 Aメロ③ by ひらななか\n1:19 Aメロ④ by UKI\n1:30 Bメロ② by MIIKO\n1:44 サビ③ by rino\n1:56 サビ④ by 吉川美音\n2:11 Cメロ① by Riai\n2:22 Cメロ② by 有里\n2:38 サビ⑤ by 小林優奈\n2:50 サビ⑥ by 瀬戸つかさ\n3:05 アウトロ by 全員\n3:28 ご挨拶 by 全員\n\nChorus：吉川美音\n歌い方解説監修：兼元夕見子\n音源制作：残響レコード',
                parserNodes: [
                  LinkParseNode(links: []),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                  JumpProgressParseNode(),
                ],
              ),
              BiliRichTextWapper(
                rawText:
                    '网页版可以使用tampermonkey插件强制跳转到开头，只要每次开b\nb站就运行这个代码就好了[鼓掌]亲测有效https://greasyfork.org/ckb/scripts/526520-b%E7%AB%99%E8%A7%86%E9%A2%91%E5%BC%BA%E5%88%B6%E4%BB%8E%E6%9C%80%E5%BC%80%E5%A7%8B%E6%92%AD%E6%94%BE/code 虽然不能自动点掉那个回到开头但是对我来说也够用了',
                parserNodes: [
                  LinkParseNode(links: []),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                  JumpProgressParseNode(),
                ],
              ),
              BiliRichTextWapper(
                rawText: '00:00\n100:00\n00:100\n2#10:00\n100#10:00\n2#00：00\n2#0：00\n00:00:00\n00:00:00:00\n00:00:00:00:00',
                parserNodes: [
                  LinkParseNode(links: []),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                  JumpProgressParseNode(),
                ],
              ),
              BiliRichTextWapper(
                rawText:
                    '这是[doge_金箍]伪合唱，是将[tv_睡着]多个翻唱版本混[千恋万花表情包_芳乃Ciallo]合在一[千恋万花表情包_丛雨Ciallo]起的，[千恋万花表情包_茉子Ciallo]并不是找这[千恋万花表情包_蕾娜Ciallo][千恋万花表情包_蕾娜Ciallo]么多人过 [千恋万花表情包_哇~] 来唱的。[千恋万花表情包_呆][亚托莉我挚爱的时光_晚安]',
                parserNodes: [
                  LinkParseNode(links: []),
                  UserParseNode(users: []),
                  UnknownLinkParseNode(),
                  JumpProgressParseNode(),
                  StickerParseNode(
                    stickers: [
                      CommentInnerSticker(
                        rawText: '[doge_金箍]',
                        name: '金箍',
                        url: 'https://i0.hdslb.com/bfs/emote/aadaca1895e09c5596fc6365192ec93a23718cf0.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[tv_睡着]',
                        name: '睡着',
                        url: 'https://i0.hdslb.com/bfs/emote/3c8b5e293261287a6203597e29b3de07df4d18c6.gif',
                      ),
                      CommentInnerSticker(
                        rawText: '[亚托莉我挚爱的时光_晚安]',
                        name: '晚安',
                        url: 'https://i0.hdslb.com/bfs/garb/fc897de19c1034dd94200d21858eaad615e12308.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_丛雨Ciallo]',
                        name: '丛雨Ciallo',
                        url: 'https://i0.hdslb.com/bfs/garb/item/eea9a26bbaf90be4736a2208aea26299e2ab73b4.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_呆]',
                        name: '呆',
                        url: 'https://i0.hdslb.com/bfs/garb/96574acd57a94f3e157643ef05d0547a03cdc1d3.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_哇~]',
                        name: '哇~',
                        url: 'https://i0.hdslb.com/bfs/garb/ab6e5c95e8fa4115d4986c407929174db44249c0.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_芳乃Ciallo]',
                        name: '芳乃Ciallo',
                        url: 'https://i0.hdslb.com/bfs/garb/cb30647b069b1cc6ac64947448a2ee233091b265.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_茉子Ciallo]',
                        name: '茉子Ciallo',
                        url: 'https://i0.hdslb.com/bfs/garb/item/62d026b0c7636835e92aabce899a1b3abbb8292c.png',
                      ),
                      CommentInnerSticker(
                        rawText: '[千恋万花表情包_蕾娜Ciallo]',
                        name: '蕾娜Ciallo',
                        url: 'https://i0.hdslb.com/bfs/garb/ff1473e69b5d17954134da15c75f557c7ada5e32.png',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentInnerLink {
  final String? title;
  final String rawText;
  final String? appUrl;
  final String url;

  const CommentInnerLink({
    this.title,
    required this.rawText,
    this.appUrl,
    required this.url,
  });
}

class CommentInnerUser {
  final String id;
  final String nickname;

  const CommentInnerUser({required this.id, required this.nickname});
}

class CommentInnerSticker {
  final String rawText;
  final String name;
  final String url;

  const CommentInnerSticker({required this.rawText, required this.name, required this.url});
}

class BiliRichTextWapper extends StatefulWidget {
  final String rawText;
  final List<ParseNode> parserNodes;
  final int? maxLines;

  const BiliRichTextWapper({
    super.key,
    required this.rawText,
    required this.parserNodes,
    this.maxLines,
  });

  @override
  State<BiliRichTextWapper> createState() => _BiliRichTextWapperState();
}

class _BiliRichTextWapperState extends State<BiliRichTextWapper> {
  final List<RichSegment> segments = [];

  @override
  void initState() {
    super.initState();

    _parseText();
  }

  @override
  void didUpdateWidget(covariant BiliRichTextWapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rawText != widget.rawText || oldWidget.parserNodes != widget.parserNodes) {
      _parseText();
    }
  }

  @override
  void dispose() {
    for (final segment in segments) {
      segment.recognizer?.dispose();
    }
    super.dispose();
  }

  void _parseText() {
    for (final segment in segments) {
      segment.recognizer?.dispose();
    }
    segments.clear();

    final List<RichSegment> results = [];
    for (final node in widget.parserNodes) {
      results.addAll(node.parse(widget.rawText));
    }

    results.sort((a, b) => a.start.compareTo(b.start));

    // 去除重叠片段
    for (final segment in results) {
      if (segments.isNotEmpty && segment.start < segments.last.end) {
        segment.recognizer?.dispose();
        continue;
      }
      segments.add(segment);
    }
  }

  List<InlineSpan> _collectSegments() {
    final List<InlineSpan> spans = [];

    String text = widget.rawText;
    int offset = 0;
    for (final segment in segments) {
      final start = segment.start - offset;
      final length = segment.end - segment.start;

      if (segment.start != 0) {
        spans.add(TextSpan(text: text.substring(0, start)));
        text = text.substring(start);
        offset += start;
      }

      spans.add(segment.span);
      text = text.substring(length);
      offset += length;
    }

    if (text.isNotEmpty) {
      spans.add(TextSpan(text: text));
    }

    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return SelectableText.rich(
      TextSpan(children: _collectSegments()),
      maxLines: widget.maxLines,
    );
  }
}

/// 用于描述一段富文本在原始文本中的所在位置和特定的交互逻辑
class RichSegment {
  final int start;
  final int end;
  final InlineSpan span;
  final GestureRecognizer? recognizer;

  const RichSegment({
    required this.start,
    required this.end,
    required this.span,
    this.recognizer,
  });
}

/// 解析器接受原始文本并返回自身关注的片段
abstract class ParseNode {
  List<RichSegment> parse(String rawText);
}

class LinkParseNode implements ParseNode {
  final List<CommentInnerLink> links;
  final ValueChanged<String>? onTap;
  final ValueChanged<String>? onTapBv;
  final ValueChanged<String>? onTapAv;

  LinkParseNode({
    required this.links,
    this.onTap,
    this.onTapBv,
    this.onTapAv,
  });

  final bvRegex = RegExp(r'^BV1[a-zA-Z0-9]{9}$');
  final avRegex = RegExp(r'^[aA][vV]\d{1,12}$');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    for (final link in links) {
      final start = rawText.indexOf(link.rawText);
      if (start == -1) continue;

      final isBv = bvRegex.hasMatch(link.rawText);
      final isAv = avRegex.hasMatch(link.rawText);

      late GestureRecognizer recognizer;
      if (isBv) {
        recognizer = TapGestureRecognizer()..onTap = () => onTapBv?.call(link.rawText);
      } else if (isAv) {
        recognizer = TapGestureRecognizer()..onTap = () => onTapAv?.call(link.rawText);
      } else {
        late String href;
        if (Platform.isAndroid || Platform.isIOS && link.appUrl != null) {
          href = link.appUrl!;
        } else {
          href = link.url;
        }
        recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(href);
      }

      segments.add(
        RichSegment(
          start: start,
          end: start + link.rawText.length,
          span: TextSpan(
            text: link.title ?? rawText.substring(start, start + link.rawText.length),
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }
}

class UserParseNode implements ParseNode {
  final List<CommentInnerUser> users;
  final ValueChanged<String>? onTap;

  UserParseNode({required this.users, this.onTap});

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];
    final sortedUsers = [...users]..sort((a, b) => b.nickname.length.compareTo(a.nickname.length));

    for (final user in sortedUsers) {
      final text = '@${user.nickname}';

      final start = rawText.indexOf(text);
      if (start == -1) continue;

      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(user.id);

      segments.add(
        RichSegment(
          start: start,
          end: start + text.length,
          span: TextSpan(
            text: text,
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }
}

class UnknownLinkParseNode implements ParseNode {
  final ValueChanged<String>? onTap;

  UnknownLinkParseNode({this.onTap});

  final _urlRegex = RegExp(
    r'(?:https?://|www\.)[^\s<>\[\](){}"\u4e00-\u9fff，。！？；：、]+',
    caseSensitive: false,
  );

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final matches = _urlRegex.allMatches(rawText);
    for (final match in matches) {
      final text = match.group(0)!;
      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(text);
      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: Uri.decodeComponent(text),
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }
}

class JumpProgressParseNode implements ParseNode {
  final Function(int ep, double time)? onTap;

  JumpProgressParseNode({this.onTap});

  final jumpRegex = RegExp(r'(?:(\d+)#)?(\b\d+(?:[:：]\d{2,})+\b)');

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final matches = jumpRegex.allMatches(rawText);
    for (final match in matches) {
      final String text = match.group(0)!.replaceAll('：', ':');
      final String? epStr = match.group(1);
      final String timeStr = match.group(2)!.replaceAll('：', ':');

      final int ep = epStr != null ? int.parse(epStr) : 0;
      final double time = _timeStringToDouble(timeStr);

      final recognizer = TapGestureRecognizer()..onTap = () => onTap?.call(ep, time);
      segments.add(
        RichSegment(
          start: match.start,
          end: match.end,
          span: TextSpan(
            text: text,
            style: TextStyle(color: Colors.blue),
            recognizer: recognizer,
          ),
          recognizer: recognizer,
        ),
      );
    }

    return segments;
  }

  double _timeStringToDouble(String timeStr) {
    final parts = timeStr.split(':');

    double totalSeconds = 0.0;
    double weight = 1.0;

    for (int i = parts.length - 1; i >= 0; i--) {
      final double value = double.parse(parts[i]);
      totalSeconds += value * weight;
      weight *= 60.0;
    }

    return totalSeconds;
  }
}

class StickerParseNode implements ParseNode {
  final List<CommentInnerSticker> stickers;

  const StickerParseNode({required this.stickers});

  @override
  List<RichSegment> parse(String rawText) {
    final List<RichSegment> segments = [];

    final patternString = stickers.map((sticker) => RegExp.escape(sticker.rawText)).join('|');

    final regex = RegExp(patternString);

    final matches = regex.allMatches(rawText);

    for (final match in matches) {
      final start = match.start;
      final text = match.group(0);
      final sticker = stickers.firstWhere((s) => s.rawText == text);

      segments.add(
        RichSegment(
          start: start,
          end: match.end,
          span: WidgetSpan(
            child: Tooltip(
              message: sticker.name,
              verticalOffset: 32.0,
              child: ImageWapper(
                width: 60,
                aspectRatio: 1,
                image: NetworkImage(sticker.url),
              ),
            ),
          ),
        ),
      );
    }

    return segments;
  }
}
