import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:better_bilibili/utils/base_util.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/quill_delta.dart';

/// 生成用于 LogReporter 的 UUID，相当于网页端存放于 cookie 的 _uuid
/// 格式: 8位-4位-4位-4位-12位+5位时间戳+"infoc"
String generateLogReporterUuid() {
  final e = _randomHex(8);
  final t = _randomHex(4);
  final r = _randomHex(4);
  final n = _randomHex(4);
  final a = _randomHex(12);
  final s = DateTime.now().millisecondsSinceEpoch;
  return '$e-$t-$r-$n-$a${_padLeft((s % 100000).toString(), 5)}infoc';
}

/// 生成指定长度的随机16进制字符串
String _randomHex(int length) {
  final random = Random();
  String result = '';
  for (int i = 0; i < length; i++) {
    result += _toHex(random.nextDouble() * 16);
  }
  return _padLeft(result, length);
}

/// 字符串左填充0到指定长度
String _padLeft(String str, int length) {
  String padding = '';
  if (str.length < length) {
    for (int i = 0; i < length - str.length; i++) {
      padding += '0';
    }
  }
  return padding + str;
}

/// 将数字向上取整，转为16进制字符串，并转为大写
String _toHex(double value) {
  return value.ceil().toRadixString(16).toUpperCase();
}

String getLevelIconPath(int level) {
  return level == 7 ? 'assets/images/lv6p.svg' : 'assets/images/lv$level.svg';
}

abstract class WebLocation {
  /// 个人空间
  static const String userSpace = '333.1387';

  /// 稍后再看页面
  static const String watchLater = '333.881';

  /// 搜索页面
  static const String search = '1430654';

  /// 主页
  static const String home = '333.1007';

  /// 也是主页？
  static const String home_2 = '1430650';

  /// 视频播放页
  static const String videoDetail = '1315873';

  /// 带播放列表的视频详情
  static const String videoDetailWithPlaylist = '333.1245';

  /// 专栏首页
  static const String articleHome = '333.14';

  /// 专栏详情
  static const String articleDetail = '333.976';

  /// 动态详情
  static const String postDetail = '333.1369';

  /// 也是动态详情？
  static const String postDetail_2 = '333.1368';

  /// 动态主页(t.bilibili.com)
  static const String dynamicHome = '333.1365';

  /// 分区主页(bilibili.com/c/xxx)
  static const String categoryHome = '333.40138';

  /// 也是个人空间？
  static const String userSpace_2 = '1550101';

  /// 观看历史
  static const String watchHistory = '333.1391';

  /// 私信页面
  static const String message = '333.40164';
}

/// WBI 签名用字符顺序打乱表
// dart format off
const List<int> _mixinKeyEncTab = [
  46, 47, 18, 2, 53, 8, 23, 32, 15, 50, 10, 31, 58, 3, 45, 35, 27, 43, 5, 49,
  33, 9, 42, 19, 29, 28, 14, 39, 12, 38, 41, 13, 37, 48, 7, 16, 24, 55, 40,
  61, 26, 17, 0, 1, 60, 51, 30, 4, 22, 25, 54, 21, 56, 59, 6, 63, 57, 62, 11,
  36, 20, 34, 44, 52,
];
// dart format on

/// 对 imgKey 和 subKey 拼接后的字符串按 [_mixinKeyEncTab] 打乱并取前 32 位
String _getMixinKey(String orig) {
  final mixed = String.fromCharCodes(
    _mixinKeyEncTab.where((i) => i < orig.length).map((i) => orig.codeUnitAt(i)),
  );
  return mixed.length > 32 ? mixed.substring(0, 32) : mixed;
}

/// 为请求参数计算 WBI 签名
/// [params]：待签名参数
/// [imgKey]、[subKey]：WBI 的 img_key 与 sub_key
/// 返回 (wts 时间戳字符串, w_rid 签名值)
(String wts, String wbiSign) encWbi(
  Map<String, dynamic> params,
  String imgKey,
  String subKey,
) {
  final mixinKey = _getMixinKey(imgKey + subKey);
  final currTime = (DateTime.now().millisecondsSinceEpoch / 1000).round();
  final chrFilter = RegExp(r"[!'()*]");

  final paramsWithWts = Map<String, dynamic>.from(params)..['wts'] = currTime;
  final sortedKeys = paramsWithWts.keys.toList()..sort();

  final query = sortedKeys
      .map((key) {
        final value = paramsWithWts[key].toString().replaceAll(chrFilter, '');
        return '${Uri.encodeComponent(key)}=${Uri.encodeComponent(value)}';
      })
      .join('&');

  final wbiSign = md5.convert(utf8.encode(query + mixinKey)).toString();

  return (currTime.toString(), wbiSign);
}

Map<String, dynamic> buildWbiParams(Map<String, dynamic> params, String wbiImgKey, String wbiSubKey) {
  final (String wts, String wbiSign) = encWbi(params, wbiImgKey, wbiSubKey);
  return {
    ...params,
    'w_rid': wbiSign,
    'wts': wts,
  };
}

/// 生成指定长度的随机十六进制字符串
/// 例如传入 8，返回 6BC98EDF
String generateRandomHex(int length) {
  final random = Random();
  return List.generate(length, (_) => random.nextInt(16).toRadixString(16).toUpperCase()).join();
}

/// 生成一个长度 32，数字+小写字母的随机字符串
String generateBuvidFp() {
  return generateRandomString(32, useUpperCase: false);
}

/// 生成一个给部分 formdata post 请求使用的 boundary 名称
/// 此函数返回的前缀为 `----geckoformboundarydb`
String generateBoundaryName() {
  return '----geckoformboundarydb${generateRandomString(30, useUpperCase: false)}';
}

/// 生成一个给部分 formdata post 请求使用的 boundary 名称
/// 此函数返回的前缀为 `----WebKitFormBoundary`
String generateBoundaryName2() {
  return '----WebKitFormBoundary${generateRandomString(16)}';
}

/// 逆向出的代码：index.js`qvId:An(32,"0-9a-zA-Z")`，很明显是个随机字符串
/// 用于模拟网页端行为
String generateQvId() {
  return generateRandomString(32);
}

/// 一个较新的 firefox ua 列表，遵循 user_agent.md 中的要求
// ignore: constant_identifier_names
const List<String> UserAgentList = [
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:147.0) Gecko/20100101 Firefox/147.0',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:146.0) Gecko/20100101 Firefox/146.0',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:138.0) Gecko/20100101 Firefox/138.0',
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:137.0) Gecko/20100101 Firefox/137.0',
];

/// 随机获取一个 UserAgent
/// 只有 firefox 的，因为本项目所有网络请求只使用 firefox ua，有关这点详见项目文档 user_agent.md
String randomUserAgent() {
  return UserAgentList[Random().nextInt(UserAgentList.length)];
}

/// 在 firefox 上的 `GL_VERSION`，经过 dm_img.md 的测试，此值始终固定
// ignore: constant_identifier_names
const String GL_VERSION_ON_FIREFOX = 'WebGL 1.0';

/// 在 firefox 上的 `UNMASKED_RENDERER_WEBGL`，经过 dm_img.md 的测试，此值在n卡下始终固定
// ignore: constant_identifier_names
const String UNMASKED_RENDERER_WEBGL_ON_FIREFOX = 'ANGLE (NVIDIA, NVIDIA GeForce GTX 980 Direct3D11 vs_5_0 ps_5_0), or similar';

/// 在 firefox 上的 `UNMASKED_VENDOR`，经过 dm_img.md 的测试，此值在n卡下始终固定
// ignore: constant_identifier_names
const String UNMASKED_VENDOR_ON_FIREFOX = 'Google Inc. (NVIDIA)';

String getDmImgStr() => specialBase64(GL_VERSION_ON_FIREFOX);

String getDmCoverImgStr() => specialBase64(UNMASKED_RENDERER_WEBGL_ON_FIREFOX + UNMASKED_VENDOR_ON_FIREFOX);

/// 使用这段js来在网页中获取某个元素的数据
/// `rect = $0.getBoundingClientRect();console.log(`width: ${(rect.width / window.innerWidth).toFixed(3)}, height: ${(rect.height / window.innerHeight).toFixed(3)}, top: ${(rect.top / window.innerHeight).toFixed(3)}, left: ${(rect.left / window.innerWidth).toFixed(3)}, tagName: '${$0.tagName}', className: '${$0.className}',`);`
class FakeTarget {
  final double width;
  final double height;
  final double top;
  final double left;
  final String tagName;
  final String className;

  FakeTarget({
    required this.width,
    required this.height,
    required this.top,
    required this.left,
    required this.tagName,
    required this.className,
  });
}

class FingerprintLog {
  final int x;
  final int y;
  final int timestamp;
  final String type;
  final FakeTarget target;

  FingerprintLog({
    required this.x,
    required this.y,
    required this.timestamp,
    required this.type,
    required this.target,
  });
}

class PackagedFingerprintLog {
  final int x;
  final int y;
  final int z;
  final int timestamp;
  final int k;
  final int type;

  PackagedFingerprintLog({
    required this.x,
    required this.y,
    required this.z,
    required this.timestamp,
    required this.k,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
    'x': x,
    'y': y,
    'z': z,
    'timestamp': timestamp,
    'k': k,
    'type': type,
  };
}

(String, List<FingerprintLog>) getDmImgList({
  required int minLogCount,
  required int maxLogCount,
  required int windowWidth,
  required int windowHeight,
  required int maxTimestamp,

  /// 一个 0~1 之间的数，表示 log 中的鼠标应该在大约横轴的什么位置
  /// 例如传入 0.5，函数就只会取 50% ± 20%(此浮动值固定) 的位置
  required double mouseRangeX,

  /// 一个 0~1 之间的数，表示 log 中的鼠标应该在大约纵轴的什么位置
  required double mouseRangeY,
  bool useMouseMoveLog = true,
  bool useClickLog = true,

  /// 可选值 [VideoDetailPageElementList], [UserDetailPostElementList], [UserDetailVideoElementList]
  required List<List<FakeTarget>> useTargetList,
}) {
  final List<FingerprintLog> logs = generateFingerprintLogs(
    minCount: minLogCount,
    maxCount: maxLogCount,
    windowWidth: windowWidth,
    windowHeight: windowHeight,
    maxTimestamp: maxTimestamp,
    mouseRangeX: mouseRangeX,
    mouseRangeY: mouseRangeY,
    useTargetList: useTargetList,
  );

  final List<PackagedFingerprintLog> packedLogs = [];
  for (int i = 0; i < logs.length; i++) {
    final item = logs[i];

    packedLogs.add(
      packageLog(
        x: item.x,
        y: item.y,
        timestamp: item.timestamp,
        type: item.type,
        index: i,
      ),
    );
  }

  return (
    jsonEncode(packedLogs.map((e) => e.toJson()).toList()),
    logs,
  );
}

PackagedFingerprintLog packageLog({
  required int x,
  required int y,
  required int timestamp,
  required String type,
  required int index,
  String? key,
}) {
  if (!const ['mousemove', 'click'].contains(type)) {
    throw Exception('Invalid type: $type');
  }

  /// 生成一个最大值不超过 num * 114 的随机数
  int generateSalt(int num) {
    final random = Random();
    return (114 * random.nextDouble() * num).floor();
  }

  final Map<String, int> magicMap = {
    'mousemove': 0,
    'click': 1,
    'keydown': 2,
    'wheel': 3,
    'touch': 4,
    'focus': 5,
  };

  int salt = generateSalt(index);

  int result1;
  int result2;

  if (x != 0 && y != 0) {
    result1 = 3 * x + 2 * y + salt;
    result2 = 4 * x - 5 * y + salt;
  } else {
    result1 = 3 * salt + 2 * salt + salt;
    result2 = 4 * salt - 5 * salt;
  }

  int keyCode;
  if (key != null && key.isNotEmpty) {
    keyCode = key.codeUnitAt(0);
  } else {
    keyCode = Random().nextInt(67) + 60;
  }

  final typeCode = magicMap[type]!;

  return PackagedFingerprintLog(
    x: result1,
    y: result2,
    z: salt,
    timestamp: timestamp,
    k: keyCode,
    type: typeCode,
  );
}

/// 特殊的 base64 编码函数，会在编码后删除最后两个字符
String specialBase64(String str) {
  if (str.isEmpty) return '';

  final bytes = utf8.encode(str);
  final binaryStr = String.fromCharCodes(bytes);
  final base64Str = base64.encode(utf8.encode(binaryStr));
  // 这里原来的js代码是可以 `substring(0, -2)` 并且不报错的，但在 dart 就不行了
  return base64Str.substring(0, max(0, base64Str.length - 2));
}

/// 百分之多少的概率为第一个值，否则为后面的值
/// [probability] 范围 0~1 之间
T sometingOrElse<T>(double probability, T value1, T value2) {
  final random = Random();
  if (random.nextDouble() < probability) {
    return value1;
  }
  return value2;
}

/// 常见窗口大小列表
// ignore: constant_identifier_names
const List<(int width, int height)> WindowSizeList = [
  // edge 1920x1080 常规标签栏 隐藏书签栏 最大化窗口
  (1528, 860),

  // edge 1920x1080 常规标签栏 显示书签栏 最大化窗口
  (1528, 698),

  // edge 1920x1080 折叠侧边标签栏 隐藏书签栏 最大化窗口
  (1490, 738),

  // edge 1920x1080 折叠侧边标签栏 显示书签栏 最大化窗口
  (1490, 706),

  // edge 1920x1080 显示侧边标签栏 隐藏书签栏 最大化窗口
  (1451, 772),

  // edge 1920x1080 显示侧边标签栏 显示书签栏 最大化窗口
  (1451, 738),

  // chrome 2560x1440 常规标签栏 显示书签栏 最大化窗口
  (2560, 1271),

  // chrome 2560x1440 常规标签栏 隐藏书签栏 最大化窗口
  (2560, 1305),
];

/// 随机获取一个窗口大小
(int width, int height) randomWindowSize() {
  return WindowSizeList[Random().nextInt(WindowSizeList.length)];
}

/// 建议的日志时间戳最小值，函数内部使用此值当作最小值，避免时间戳过小导致两次时间间隔时间错误
// ignore: constant_identifier_names
const int RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM = 15;

/// log 在原函数中可空，但需要注意某些页面下存在"回退元素"，比如视频详情页的弹幕发送框会作为回退元素，
/// 具体情况见开发文档，也就是在这种情况下即使没有任何的用户事件log，dm_img_list 也不为空，个人认为这个细节非常重要，
/// 遇到这种页面建议不要生成0~1而是1~2个日志从而规避这个问题
///
/// 已知有回退元素的页面:
/// - 视频播放页: /video/xxxxx, 弹幕发送框
String getDmImgInter({
  /// dmImgList 的最后一项
  FingerprintLog? log,
  required int windowWidth,
  required int windowHeight,
  int scrollTop = 0,
  int scrollLeft = 0,
}) {
  /// 根据 tagName，从固定的 map 里返回对应的数字
  int tagNameToNumber(FakeTarget el) {
    const Map<String, int> magicMap = {
      'span': 1,
      'div': 2,
      'p': 3,
      'a': 4,
      'img': 5,
      'input': 6,
      'button': 7,
      'ul': 8,
      'ol': 9,
      'li': 10,
      'h1': 11,
      'h2': 12,
      'h3': 13,
      'h4': 14,
      'h5': 15,
      'h6': 16,
      'form': 17,
      'textarea': 18,
      'select': 19,
      'option': 20,
      'table': 21,
      'tr': 22,
      'td': 23,
      'th': 24,
      'label': 25,
      'strong': 26,
      'em': 27,
      'section': 28,
      'article': 29,
    };

    final tagName = el.tagName.toLowerCase();
    return magicMap[tagName] ?? 0;
  }

  // 对一个长度固定为2的数组进行简单的加盐混淆
  // 注：此函数返回盐值因此可逆
  List<int> encode1(int item1, int item2) {
    final salt = (114 * Random().nextDouble()).floor();
    return [
      2 * item1 + 2 * item2 + 3 * salt,
      4 * item1 - item2 + salt,
      salt,
    ];
  }

  // 对一个长度固定为2的数组进行简单的加盐混淆
  // 注：此函数返回盐值因此可逆
  List<int> encode2(int item1, int item2) {
    final salt = (514 * Random().nextDouble()).floor();
    return [
      3 * item1 + 2 * item2 + salt,
      4 * item1 - 4 * item2 + 2 * salt,
      salt,
    ];
  }

  dynamic getDs() {
    log!;

    final encodeTopLeft = encode1(
      log.target.top.toInt(),
      log.target.left.toInt(),
    );
    final encodeTop = encodeTopLeft[0];
    final encodeLeft = encodeTopLeft[1];
    final topLeftSlat = encodeTopLeft[2];
    final encodeWidthHeight = encode2(
      log.target.width.toInt(),
      log.target.height.toInt(),
    );
    final encodeWidth = encodeWidthHeight[0];
    final encodeHeight = encodeWidthHeight[1];
    final widthHeightSlat = encodeWidthHeight[2];

    return {
      't': tagNameToNumber(log.target),
      'c': log.target.className.isEmpty ? '' : specialBase64(log.target.className),
      'p': [encodeTop, topLeftSlat, encodeLeft],
      's': [widthHeightSlat, encodeWidth, encodeHeight],
    };
  }

  final result = {
    'ds': log != null ? getDs() : '[]',
    'wh': encode1(windowWidth, windowHeight),
    'of': encode2(scrollTop, scrollLeft),
  };

  return jsonEncode(result);
}

List<FingerprintLog> generateFingerprintLogs({
  required int minCount,
  required int maxCount,
  required int windowWidth,
  required int windowHeight,
  required int maxTimestamp,

  /// 一个 0~1 之间的数，表示 log 中的鼠标应该在大约横轴的什么位置
  /// 例如传入 0.5，函数就只会取 50% ± 20%(此浮动值固定) 的位置
  required double mouseRangeX,

  /// 一个 0~1 之间的数，表示 log 中的鼠标应该在大约纵轴的什么位置
  required double mouseRangeY,
  bool useMouseMoveLog = true,
  bool useClickLog = true,
  required List<List<FakeTarget>> useTargetList,
}) {
  final logCount = Random().nextInt(maxCount - minCount + 1) + minCount;
  if (logCount == 0) return [];

  final tsStep = (maxTimestamp - RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM) ~/ logCount;

  final List<FingerprintLog> logs = [];
  for (int i = 0; i < logCount; i++) {
    final timestamp = getRandomInt(
      RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM + i * tsStep,
      RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM + (i + 1) * tsStep,
    );
    final x = getRandomInt(
      max(0, windowWidth * max(0.0, mouseRangeX - 0.2)).toInt(),
      min(windowWidth, windowWidth * min(1.0, mouseRangeX + 0.2)).toInt(),
    );
    final y = getRandomInt(
      max(0, windowHeight * max(0.0, mouseRangeY - 0.2)).toInt(),
      min(windowHeight, windowHeight * min(1.0, mouseRangeY + 0.2)).toInt(),
    );

    if (useMouseMoveLog && useClickLog) {
      final moveOrClick = getRandomDouble(0.0, 1.0);

      logs.add(
        FingerprintLog(
          x: x,
          y: y,
          timestamp: timestamp,
          type: moveOrClick < 0.7 ? 'mousemove' : 'click',
          target: generateFakeTarget(
            windowWidth,
            windowHeight,
            useTargetList,
          ),
        ),
      );
    } else {
      logs.add(
        FingerprintLog(
          x: x,
          y: y,
          timestamp: timestamp,
          type: useMouseMoveLog ? 'mousemove' : 'click',
          target: generateFakeTarget(
            windowWidth,
            windowHeight,
            useTargetList,
          ),
        ),
      );
    }
  }

  return logs;
}

// ignore: non_constant_identifier_names
List<FakeTarget> VideoDetailPageElementList = [
  // 上方视频标题
  FakeTarget(
    width: 0.179,
    height: 0.027,
    top: 0.068,
    left: 0.08,
    tagName: 'H1',
    className: 'video-title special-text-indent',
  ),

  // 播放器
  FakeTarget(
    width: 0.66,
    height: 0.75,
    top: 0.14,
    left: 0.08,
    tagName: 'VIDEO',
    className: '',
  ),

  // 右侧推荐中的某个卡片
  FakeTarget(
    width: 0.08,
    height: 0.085,
    top: 0.58,
    left: 0.83,
    tagName: 'DIV',
    className: 'info',
  ),
];

// ignore: non_constant_identifier_names
List<FakeTarget> UserDetailPostElementList = [
  // 左侧选项
  FakeTarget(
    width: 0.082,
    height: 0.293,
    top: 0.078,
    left: 0.077,
    tagName: 'DIV',
    className: 'space-dynamic__left',
  ),

  // 命中率比较高的页面背景
  FakeTarget(
    width: 0.992,
    height: 12.005,
    top: -3.811,
    left: 0.000,
    tagName: 'MAIN',
    className: 'space-main route_dynamic',
  ),
];

// ignore: non_constant_identifier_names
List<FakeTarget> UserDetailVideoElementList = [
  // 左侧选项
  FakeTarget(
    width: 0.082,
    height: 0.293,
    top: 0.078,
    left: 0.077,
    tagName: 'DIV',
    className: 'upload-sidenav',
  ),

  // 命中率比较高的页面背景
  FakeTarget(
    width: 0.992,
    height: 1.665,
    top: -0.201,
    left: 0.000,
    tagName: 'MAIN',
    className: 'space-main route_uploadVideo',
  ),
];

FakeTarget generateFakeTarget(int windowWidth, int windowHeight, List<List<FakeTarget>> useTargetList) {
  final targets = useTargetList.expand((list) => list).toList();
  final target = targets[Random().nextInt(targets.length)];
  return FakeTarget(
    width: target.width * windowWidth,
    height: target.height * windowHeight,
    top: target.top * windowHeight,
    left: target.left * windowWidth,
    tagName: target.tagName,
    className: target.className,
  );
}

// ignore: non_constant_identifier_names
final BigInt _XOR_CODE = BigInt.from(23442827791579);
// ignore: non_constant_identifier_names
final BigInt _MASK_CODE = BigInt.from(2251799813685247);
// ignore: non_constant_identifier_names
final BigInt _MAX_AID = BigInt.one << 51;
// ignore: non_constant_identifier_names
final BigInt _BASE = BigInt.from(58);
// ignore: non_constant_identifier_names
final String _BV_ALPHABET = 'FcwAPNKTMug3GV5Lj7EJnHpWsx4tb8haYeviqBz6rkCy12mUSDQX9RdoZf';

String av2bv(String aid) {
  // Initialize bytes as ['B', 'V', '1', '0', ..., '0'] (12 chars)
  final bytes = List<String>.filled(12, '0');
  bytes[0] = 'B';
  bytes[1] = 'V';
  bytes[2] = '1';

  int bvIndex = bytes.length - 1;

  final tmp0 = BigInt.parse(aid);
  var tmp = (_MAX_AID | tmp0) ^ _XOR_CODE;

  while (tmp > BigInt.zero) {
    bytes[bvIndex] = _BV_ALPHABET[(tmp % _BASE).toInt()];
    tmp ~/= _BASE;
    bvIndex -= 1;
  }

  // swap [3]<->[9], [4]<->[7]
  final t3 = bytes[3];
  bytes[3] = bytes[9];
  bytes[9] = t3;

  final t4 = bytes[4];
  bytes[4] = bytes[7];
  bytes[7] = t4;

  return bytes.join('');
}

int bv2av(String bvid) {
  List<String> bvidArr = bvid.split('');

  // swap positions: [3]<->[9], [4]<->[7]
  String temp = bvidArr[3];
  bvidArr[3] = bvidArr[9];
  bvidArr[9] = temp;

  temp = bvidArr[4];
  bvidArr[4] = bvidArr[7];
  bvidArr[7] = temp;

  // remove first three characters ('B','V','1')
  bvidArr.removeRange(0, 3);

  BigInt tmp = BigInt.zero;
  for (final c in bvidArr) {
    tmp = tmp * _BASE + BigInt.from(_BV_ALPHABET.indexOf(c));
  }
  return ((tmp & _MASK_CODE) ^ _XOR_CODE).toInt();
}

List<int> getMd5SwappedInt32List(String input) {
  List<int> endian(List<int> lcdf) {
    int rotl32(int n, int bits) => ((n << bits) | (n >>> (32 - bits))) & 0xFFFFFFFF;
    for (int i = 0; i < lcdf.length; i++) {
      int e = lcdf[i];
      lcdf[i] = ((0x00FF00FF & rotl32(e, 8)) | (0xFF00FF00 & rotl32(e, 24))).toSigned(32);
    }
    return lcdf;
  }

  // Calculate the MD5 hash as bytes
  List<int> hashBytes = md5.convert(utf8.encode(input)).bytes;
  // Group the 16 bytes into four 4-byte integers, little-endian order
  ByteData byteData = ByteData.sublistView(Uint8List.fromList(hashBytes));
  return endian([
    byteData.getUint32(0, Endian.little),
    byteData.getUint32(4, Endian.little),
    byteData.getUint32(8, Endian.little),
    byteData.getUint32(12, Endian.little),
  ]);
}

String generateSession(String buvid3) {
  assert(buvid3.isNotEmpty);

  List<int> wordsToBytes(List<int> words) {
    List<int> t = [];
    for (int r = 0; r < 32 * words.length; r += 8) {
      t.add((words[r >>> 5] >> (24 - r % 32)) & 0xFF);
    }
    return t;
  }

  String bytesToHex(List<int> e) {
    List<String> t = [];
    for (int r = 0; r < e.length; r++) {
      t.add((e[r] >>> 4).toRadixString(16));
      t.add((e[r] & 15).toRadixString(16));
    }
    return t.join('');
  }

  return bytesToHex(wordsToBytes(getMd5SwappedInt32List(buvid3)));
}

@Deprecated('article is not supported anymore')
Delta parseArticleContentToDelta(List<dynamic> json) {
  final result = Delta();

  void handleNodes(List<Map<String, dynamic>> nodes, {bool isBlockquote = false}) {
    for (final node in nodes) {
      final nodeType = node['node_type'] as int;
      if (nodeType == 1) {
        // 普通文本
        result.insert(node['word']['words'], {
          // 默认大小是17，这里不处理17，默认大小直接返回null
          'font-size': node['word']['font_size'] == 17 ? null : node['word']['font_size'],
          'strike': node['word']['style']['strikethrough'],
          'color': node['word']['color'],
          'bold': node['word']['style']['bold'],
          'italic': node['word']['style']['italic'],
          'blockquote': node['word']['words'] == '\n' && isBlockquote ? true : null,
        });
      } else if (nodeType == 3 || nodeType == 4) {
        final linkType = node['link']['link_type'];
        if (linkType == 3 || linkType == 41) {
          result.insert(node['link']['show_text'], {
            'link': node['link']['link'],
          });
        } else if (linkType == 12) {
          result.insert(node['link']['video_ts']['title'], {
            'link': 'https://www.bilibili.com/video/${node['link']['video_ts']['key']}',
          });
        } else {}
      } else {}
    }
  }

  for (final item in json) {
    final paraType = item['para_type'] as int;
    if (paraType == 1) {
      // 1 = 普通文本
      final nodes = item['text']['nodes']?.cast<Map<String, dynamic>>();
      if (nodes == null) continue;

      handleNodes(nodes);

      result.insert('\n', {
        'align': ifs([
          (item['format']?['align'] == 1, 'center'),
          (item['format']?['align'] == 2, 'right'),
        ]),
      });
    } else if (paraType == 2) {
      // 2 = 图片
      result.insert(
        {
          'image': {'url': item['pic']['pics'].first['url'], 'alt': item['pic']['pics'].first['comment']},
        },
        {
          'height': item['pic']['pics'].first['height'],
        },
      );
      result.insert('\n');
    } else if (paraType == 4) {
      // 4 = 引用
      final nodes = item['text']['nodes']?.cast<Map<String, dynamic>>();
      if (nodes == null) continue;

      handleNodes(nodes, isBlockquote: true);

      result.insert('\n', {'blockquote': true});
    } else if (paraType == 5) {
      // 5 = 列表
      final nodes = item['text']['nodes']?.cast<Map<String, dynamic>>();
      if (nodes == null) continue;

      handleNodes(nodes);

      final level = item['format']['list_format']['level'] as int;
      result.insert('\n', {
        'list': item['format']['list_format']['theme'] == 'arabic_num' ? 'ordered' : 'unordered',
        'indent': level == 1 ? null : level - 1,
      });
    } else if (paraType == 9) {
      // 9 = 标题
      final nodes = item['text']['nodes']?.cast<Map<String, dynamic>>();
      if (nodes == null) continue;

      handleNodes(nodes);

      result.insert('\n', {
        'header': item['format']['heading_type'] + 1,
      });
    } else if (paraType == 7) {
      // 7 = 卡片，包括用户卡片、视频卡片，这里当 link 处理
      result.insert('\n');
      result.insert(item['link_card']['card']['show_text'] ?? '*无效卡片*', {
        'link': item['link_card']['card']['link'],
      });
      result.insert('\n', {'align': 'center'});
      result.insert('\n');
    } else if (paraType == 800) {
      // 8 = 代码块
      final List<String> lines = item['code']['content'].split('\n');
      for (final line in lines) {
        result.insert(line);
        result.insert('\n', {
          'code-block': true,
          'language': 'javascript',
        });
      }
    } else {}
  }

  result.insert('\n');
  return result;
}

Delta parsePostContentToDelta(List<dynamic> json) {
  final result = Delta();

  /// 有时 color 为变量 `var(--Re6, #E23D3D)`
  String handleColor(String str) {
    const colorMap = {
      '--Ga0': '#F6F7F8',
      '--Ga0_s': '#F6F7F8',
      '--Ga0_t': '#F6F7F8',
      '--Ga1': '#F1F2F3',
      '--Ga1_s': '#F1F2F3',
      '--Ga1_t': '#F1F2F3',
      '--Ga1_e': '#F1F2F3',
      '--Ga2': '#E3E5E7',
      '--Ga2_t': '#E3E5E7',
      '--Ga3': '#C9CCD0',
      '--Ga3_t': '#C9CCD0',
      '--Ga4': '#AEB3B9',
      '--Ga4_t': '#AEB3B9',
      '--Ga5': '#9499A0',
      '--Ga5_t': '#9499A0',
      '--Ga6': '#797F87',
      '--Ga6_t': '#797F87',
      '--Ga7': '#61666D',
      '--Ga7_t': '#61666D',
      '--Ga8': '#484C53',
      '--Ga8_t': '#484C53',
      '--Ga9': '#2F3238',
      '--Ga9_t': '#2F3238',
      '--Ga10': '#18191C',
      '--Ga10_t': '#18191C',
      '--Ga11': '#FFFFFF',
      '--Ga12': '#F1F2F3',
      '--Ga12_s': '#F6F7F8',
      '--Ga13': '#F1F2F3',
      '--Ga13_s': '#F1F2F3',
      '--Wh0': '#FFFFFF',
      '--Wh0_s': '#FFFFFF',
      '--Wh0_t': '#FFFFFF',
      '--Ba0': '#000000',
      '--Ba0_s': '#000000',
      '--Ba0_t': '#000000',
      '--Pi0': '#FFF3F6',
      '--Pi1': '#FFECF1',
      '--Pi2': '#FFD9E4',
      '--Pi3': '#FFB3CA',
      '--Pi4': '#FF8CB0',
      '--Pi5': '#FF6699',
      '--Pi5_t': '#FF6699',
      '--Pi6': '#E84B85',
      '--Pi7': '#D03171',
      '--Pi8': '#AD1C5B',
      '--Pi9': '#771141',
      '--Pi10': '#3F0723',
      '--Ma0': '#FEF3FC',
      '--Ma1': '#FDEBFA',
      '--Ma2': '#FBD7F4',
      '--Ma3': '#F7AEEB',
      '--Ma4': '#F286E2',
      '--Ma5': '#EE5DDB',
      '--Ma6': '#DA41CB',
      '--Ma7': '#C525BA',
      '--Ma8': '#9B1797',
      '--Ma9': '#670F67',
      '--Ma10': '#330834',
      '--Re0': '#FEF3F2',
      '--Re1': '#FEECEA',
      '--Re2': '#FDD7D4',
      '--Re3': '#FCAFAA',
      '--Re4': '#FA857F',
      '--Re5': '#F85A54',
      '--Re6': '#E23D3D',
      '--Re7': '#C9272C',
      '--Re8': '#9F1922',
      '--Re9': '#710E18',
      '--Re10': '#3B060D',
      '--Or0': '#FFF6EE',
      '--Or1': '#FFF0E3',
      '--Or2': '#FFE1C7',
      '--Or3': '#FFC18F',
      '--Or4': '#FFA058',
      '--Or5': '#FF7F24',
      '--Or6': '#E95B03',
      '--Or7': '#BB4100',
      '--Or8': '#8D2D00',
      '--Or9': '#5E1B00',
      '--Or10': '#2F0C00',
      '--Ye0': '#FFFAEF',
      '--Ye1': '#FFF6E4',
      '--Ye2': '#FFEEC9',
      '--Ye3': '#FFDB93',
      '--Ye4': '#FFC65D',
      '--Ye5': '#FFB027',
      '--Ye6': '#FA9600',
      '--Ye7': '#C26E00',
      '--Ye8': '#8A4A00',
      '--Ye9': '#5B2E00',
      '--Ye10': '#2F1600',
      '--Ly0': '#FFFCEC',
      '--Ly1': '#FFFADF',
      '--Ly2': '#FFF5BF',
      '--Ly3': '#FFEA80',
      '--Ly4': '#FFDC40',
      '--Ly5': '#FFCC00',
      '--Ly6': '#D5A300',
      '--Ly7': '#AA7D00',
      '--Ly8': '#805A00',
      '--Ly9': '#553900',
      '--Ly10': '#2B1B00',
      '--Lg0': '#F7FBEF',
      '--Lg1': '#F2F9E4',
      '--Lg2': '#E3F2C8',
      '--Lg3': '#C7E691',
      '--Lg4': '#A9D95B',
      '--Lg5': '#88CC24',
      '--Lg6': '#66B105',
      '--Lg7': '#4E8E04',
      '--Lg8': '#376A03',
      '--Lg9': '#224702',
      '--Lg10': '#102301',
      '--Gr0': '#EFFBF3',
      '--Gr1': '#E4F8EA',
      '--Gr2': '#CAF1D6',
      '--Gr3': '#95E4AF',
      '--Gr4': '#5FD689',
      '--Gr5': '#2AC864',
      '--Gr6': '#0EB350',
      '--Gr7': '#089043',
      '--Gr8': '#046E35',
      '--Gr9': '#034926',
      '--Gr10': '#012414',
      '--Cy0': '#EDFBFB',
      '--Cy1': '#E2F8F8',
      '--Cy2': '#C4EFF0',
      '--Cy3': '#89E1E1',
      '--Cy4': '#4FD3D1',
      '--Cy5': '#14C4BF',
      '--Cy6': '#02AAAA',
      '--Cy7': '#018488',
      '--Cy8': '#015F66',
      '--Cy9': '#013D44',
      '--Cy10': '#001D22',
      '--Lb0': '#ECFAFE',
      '--Lb1': '#DFF6FD',
      '--Lb2': '#BFEDFA',
      '--Lb3': '#80DAF6',
      '--Lb4': '#40C5F1',
      '--Lb5': '#00AEEC',
      '--Lb6': '#008AC5',
      '--Lb7': '#00699D',
      '--Lb8': '#004B76',
      '--Lb9': '#002F4F',
      '--Lb10': '#001627',
      '--Bl0': '#F3F5FF',
      '--Bl1': '#EBEFFF',
      '--Bl2': '#D7DFFF',
      '--Bl3': '#B0C1FF',
      '--Bl4': '#88A4FF',
      '--Bl5': '#6188FF',
      '--Bl6': '#4C6DE4',
      '--Bl7': '#3752C8',
      '--Bl8': '#2136AC',
      '--Bl9': '#121F7F',
      '--Bl10': '#080D41',
      '--Pu0': '#F9F4FF',
      '--Pu1': '#F6EDFF',
      '--Pu2': '#EDDBFF',
      '--Pu3': '#D8B6FF',
      '--Pu4': '#C392FF',
      '--Pu5': '#AC6DFF',
      '--Pu6': '#8F56E4',
      '--Pu7': '#723ECC',
      '--Pu8': '#5627B3',
      '--Pu9': '#371683',
      '--Pu10': '#190A44',
      '--Br0': '#FAF8F6',
      '--Br1': '#F7F3F0',
      '--Br2': '#EFE7E0',
      '--Br3': '#E0CFC1',
      '--Br4': '#D0B7A3',
      '--Br5': '#C19D84',
      '--Br6': '#A5816A',
      '--Br7': '#856553',
      '--Br8': '#634A3E',
      '--Br9': '#423029',
      '--Br10': '#211815',
      '--Si0': '#F9FBFC',
      '--Si1': '#F5F7FA',
      '--Si2': '#EBEFF4',
      '--Si3': '#D7E0EA',
      '--Si4': '#C3D0DF',
      '--Si5': '#AFC0D5',
      '--Si6': '#8D9FB9',
      '--Si7': '#6D7F9C',
      '--Si8': '#4D5D7C',
      '--Si9': '#323D54',
      '--Si10': '#191E2B',
      // Named color 4
      // https://www.w3.org/TR/css-color-4/#named-colors
      'aliceblue': '#f0f8ff',
      'antiquewhite': '#faebd7',
      'aqua': '#00ffff',
      'aquamarine': '#7fffd4',
      'azure': '#f0ffff',
      'beige': '#f5f5dc',
      'bisque': '#ffe4c4',
      'black': '#000000',
      'blanchedalmond': '#ffebcd',
      'blue': '#0000ff',
      'blueviolet': '#8a2be2',
      'brown': '#a52a2a',
      'burlywood': '#deb887',
      'cadetblue': '#5f9ea0',
      'chartreuse': '#7fff00',
      'chocolate': '#d2691e',
      'coral': '#ff7f50',
      'cornflowerblue': '#6495ed',
      'cornsilk': '#fff8dc',
      'crimson': '#dc143c',
      'cyan': '#00ffff',
      'darkblue': '#00008b',
      'darkcyan': '#008b8b',
      'darkgoldenrod': '#b8860b',
      'darkgray': '#a9a9a9',
      'darkgreen': '#006400',
      'darkgrey': '#a9a9a9',
      'darkkhaki': '#bdb76b',
      'darkmagenta': '#8b008b',
      'darkolivegreen': '#556b2f',
      'darkorange': '#ff8c00',
      'darkorchid': '#9932cc',
      'darkred': '#8b0000',
      'darksalmon': '#e9967a',
      'darkseagreen': '#8fbc8f',
      'darkslateblue': '#483d8b',
      'darkslategray': '#2f4f4f',
      'darkslategrey': '#2f4f4f',
      'darkturquoise': '#00ced1',
      'darkviolet': '#9400d3',
      'deeppink': '#ff1493',
      'deepskyblue': '#00bfff',
      'dimgray': '#696969',
      'dimgrey': '#696969',
      'dodgerblue': '#1e90ff',
      'firebrick': '#b22222',
      'floralwhite': '#fffaf0',
      'forestgreen': '#228b22',
      'fuchsia': '#ff00ff',
      'gainsboro': '#dcdcdc',
      'ghostwhite': '#f8f8ff',
      'gold': '#ffd700',
      'goldenrod': '#daa520',
      'gray': '#808080',
      'green': '#008000',
      'greenyellow': '#adff2f',
      'grey': '#808080',
      'honeydew': '#f0fff0',
      'hotpink': '#ff69b4',
      'indianred': '#cd5c5c',
      'indigo': '#4b0082',
      'ivory': '#fffff0',
      'khaki': '#f0e68c',
      'lavender': '#e6e6fa',
      'lavenderblush': '#fff0f5',
      'lawngreen': '#7cfc00',
      'lemonchiffon': '#fffacd',
      'lightblue': '#add8e6',
      'lightcoral': '#f08080',
      'lightcyan': '#e0ffff',
      'lightgoldenrodyellow': '#fafad2',
      'lightgray': '#d3d3d3',
      'lightgreen': '#90ee90',
      'lightgrey': '#d3d3d3',
      'lightpink': '#ffb6c1',
      'lightsalmon': '#ffa07a',
      'lightseagreen': '#20b2aa',
      'lightskyblue': '#87cefa',
      'lightslategray': '#778899',
      'lightslategrey': '#778899',
      'lightsteelblue': '#b0c4de',
      'lightyellow': '#ffffe0',
      'lime': '#00ff00',
      'limegreen': '#32cd32',
      'linen': '#faf0e6',
      'magenta': '#ff00ff',
      'maroon': '#800000',
      'mediumaquamarine': '#66cdaa',
      'mediumblue': '#0000cd',
      'mediumorchid': '#ba55d3',
      'mediumpurple': '#9370db',
      'mediumseagreen': '#3cb371',
      'mediumslateblue': '#7b68ee',
      'mediumspringgreen': '#00fa9a',
      'mediumturquoise': '#48d1cc',
      'mediumvioletred': '#c71585',
      'midnightblue': '#191970',
      'mintcream': '#f5fffa',
      'mistyrose': '#ffe4e1',
      'moccasin': '#ffe4b5',
      'navajowhite': '#ffdead',
      'navy': '#000080',
      'oldlace': '#fdf5e6',
      'olive': '#808000',
      'olivedrab': '#6b8e23',
      'orange': '#ffa500',
      'orangered': '#ff4500',
      'orchid': '#da70d6',
      'palegoldenrod': '#eee8aa',
      'palegreen': '#98fb98',
      'paleturquoise': '#afeeee',
      'palevioletred': '#db7093',
      'papayawhip': '#ffefd5',
      'peachpuff': '#ffdab9',
      'peru': '#cd853f',
      'pink': '#ffc0cb',
      'plum': '#dda0dd',
      'powderblue': '#b0e0e6',
      'purple': '#800080',
      'rebeccapurple': '#663399',
      'red': '#ff0000',
      'rosybrown': '#bc8f8f',
      'royalblue': '#4169e1',
      'saddlebrown': '#8b4513',
      'salmon': '#fa8072',
      'sandybrown': '#f4a460',
      'seagreen': '#2e8b57',
      'seashell': '#fff5ee',
      'sienna': '#a0522d',
      'silver': '#c0c0c0',
      'skyblue': '#87ceeb',
      'slateblue': '#6a5acd',
      'slategray': '#708090',
      'slategrey': '#708090',
      'snow': '#fffafa',
      'springgreen': '#00ff7f',
      'steelblue': '#4682b4',
      'tan': '#d2b48c',
      'teal': '#008080',
      'thistle': '#d8bfd8',
      'tomato': '#ff6347',
      'turquoise': '#40e0d0',
      'violet': '#ee82ee',
      'wheat': '#f5deb3',
      'white': '#ffffff',
      'whitesmoke': '#f5f5f5',
      'yellow': '#ffff00',
      'yellowgreen': '#9acd32',
    };

    if (str.startsWith('#')) {
      return str;
    }

    if (colorMap.containsKey(str)) {
      return colorMap[str]!;
    }

    // `/var\((--[^,)]+)/`
    // 可能的情况：
    // - `var(--Ga9, #xxxxxx)`
    // - `rgba(var(--Ga9_rgb), 0.6)`
    final match = RegExp(r'var\(\s*(--[^,)\s]+)').firstMatch(str);
    if (match != null) {
      String varName = match.group(1)!;
      if (varName.endsWith('_rgb')) {
        varName = varName.substring(0, varName.length - 4);
      }

      final color = colorMap[varName];
      if (color != null) return color;
    }

    print('未能解析的颜色: $str');
    return '#000000';
  }

  void handleTextNode(dynamic node) {
    final nodeType = node['type'] as String;

    if (nodeType == 'TEXT_NODE_TYPE_WORD') {
      final word = node['word'];

      final Map<String, dynamic> attr = {};
      if (word['font_size'] != 17) {
        attr.addAll({'font-size': word['font_size']});
      }
      if (word['style']['strikethrough'] == true) {
        attr.addAll({'strike': word['style']['strikethrough']});
      }
      if (word['color'] != null && word['color'].isNotEmpty) {
        attr.addAll({'color': handleColor(word['color'])});
      }
      if (word['style']['bold'] == true) {
        attr.addAll({'bold': word['style']['bold']});
      }
      if (word['style']['italic'] == true) {
        attr.addAll({'italic': word['style']['italic']});
      }

      result.insert(word['words'], attr.isNotEmpty ? attr : null);
    } else if (nodeType == 'TEXT_NODE_TYPE_RICH') {
      final rich = node['rich'];
      // result.insert(rich['orig_text'], {'link': rich['jump_url']});
      result.insert(rich['text'], {'link': rich['jump_url']});
    } else if (nodeType == 'TEXT_NODE_TYPE_USER') {
      result.insert({
        'inner_user': {
          'userId': node['user']['mid'],
          'avatar': node['user']['face'],
          'nickname': node['user']['name'],
        },
      });
    } else {
      print('未处理的 nodeType: $nodeType');
    }
  }

  void handlePara(dynamic para, {Map<String, dynamic> extra = const {}}) {
    final paraType = para['para_type'] as int;
    if (paraType == 1) {
      // 文本
      for (final node in para['text']['nodes']) {
        handleTextNode(node);
      }

      final Map<String, dynamic> attr = {};
      if (para['align'] != null) {
        attr.addAll({
          'align': ifs([
            (para['align'] == 1, 'center'),
            (para['align'] == 2, 'right'),
          ]),
        });
      }
      if (extra.isNotEmpty) attr.addAll(extra);

      result.insert('\n', attr.isNotEmpty ? attr : null);
    } else if (paraType == 2) {
      // 图片
      for (final pic in para['pic']['pics']) {
        result.insert({
          'image': {
            'url': pic['url'],
            'width': pic['width'].toDouble(),
            'height': pic['height'].toDouble(),
            'alt': pic['comment'],
          },
        });
      }
    } else if (paraType == 3) {
      // 分割线
      result.insert({'divider': 1});
    } else if (paraType == 4) {
      // 引用
      for (final item in para['blockquote']['children']) {
        handlePara(
          item,
          extra: {'blockquote': true},
        );
      }
    } else if (paraType == 5) {
      // 列表
      final listType = const ['dot', 'square', 'circle'].contains(para['list']['theme']) ? 'bullet' : 'ordered';
      for (final item in para['list']['children']) {
        final indent = item['level'] - 1;
        for (final p in item['children']) {
          final Map<String, dynamic> attr = {
            'list': listType,
          };
          if (indent != 0) {
            attr.addAll({'indent': indent});
          }

          handlePara(p, extra: attr);
        }
      }
    } else if (paraType == 6) {
      // 卡片
      final cardType = para['link_card']['card']['type'] as String;
      if (cardType == 'LINK_CARD_TYPE_EVA3_VIDEO') {
        final info = para['link_card']['card']['eva3_video']['info'];
        final viewCount = (info['stat_infos'] as List).firstWhere((v) => v['type'] == 1)?['count'];
        final danmakuCount = (info['stat_infos'] as List).firstWhere((v) => v['type'] == 2)?['count'];

        result.insert({
          'videoCard': {
            // 此处 info 字段均为 String
            'id': info['avid'],
            'bvid': info['bvid'],
            'episodeId': info['cid'],
            'title': info['title'],
            'cover': info['cover'],
            // 此处两个 count 为 0 时不存在 count 字段
            'viewCount': viewCount == null ? 0 : int.parse(viewCount),
            'danmakuCount': danmakuCount == null ? 0 : int.parse(danmakuCount),
            'duration': double.parse(info['video_ts']['duration']),
          },
        });
      } else if (cardType == 'LINK_CARD_TYPE_EVA3_USER') {
        final info = para['link_card']['card']['eva3_user']['info'];
        result.insert({
          'user': {
            // 同上均为 String
            'id': info['user']['mid'],
            'avatar': info['user']['face'],
            'nickname': info['user']['name'],
            'description': info['desc'],
            'isFollowed': info['user']['relation']['status'] == 2,
          },
        });
      } else if (cardType == 'LINK_CARD_TYPE_EVA3_OPUS') {
        final info = para['link_card']['card']['eva3_opus']['info'];
        result.insert({
          'postCard': {
            'id': info['opus_id'],
            'title': info['title'],
            'summary': info['content'],
            'cover': info['pics'].first['src'],
          },
        });
      } else {
        debugPrint('未处理的 cardType: $cardType');
      }
    } else if (paraType == 7) {
      // 代码块
      final lines = para['code']['content'].split('\n');
      for (final line in lines) {
        result.insert(line);
        result.insert('\n', {
          'code-block': true,
          'language': para['code']['lang'],
        });
      }
    } else if (paraType == 8) {
      // 标题
      for (final node in para['heading']['nodes']) {
        handleTextNode(node);
      }
      result.insert('\n', {
        'align': ifs([
          (para['align'] == 1, 'center'),
          (para['align'] == 2, 'right'),
        ]),
        // 这里按照 markdown 的习惯，h1 为文章大标题，内容标题从 h2 开始
        'header': para['heading']['level'] + 1,
      });
    } else {
      debugPrint('未处理的 paraType: $paraType');
    }
  }

  for (final para in json) {
    handlePara(para);
  }

  result.insert('\n');
  return result;
}

/// 用于将b站的弱智接口返回的 `<minutes>:<seconds>` 字符串转换为秒数
double durationStrToSec(String duration) {
  final List<String> parts = duration.split(':');
  final int minutes = int.parse(parts[0].trim());
  final int seconds = int.parse(parts[1].trim());
  return minutes.toDouble() * 60 + seconds.toDouble();
}

/// 用于处理文章摘要中的 "[图片]" 等无用元素
String? handleArticleSummary(String summary) {
  final temp = summary.replaceAll('[图片]', '').trim();
  return temp.isEmpty ? null : temp;
}

/// 用于将 "1.0万" 这样的字符串转换回数字
int countStrToInt(String text) {
  text = text.trim();
  if (text.isEmpty) return 0;

  final RegExp reg = RegExp(r'^([0-9.]+)(万)?$');
  final match = reg.firstMatch(text);

  if (match == null) {
    // 尝试直接转换
    return int.tryParse(text) ?? 0;
  }

  final numStr = match.group(1)!;
  final unit = match.group(2);

  double value = double.tryParse(numStr) ?? 0.0;

  if (unit == '万') {
    value *= 10000;
  }

  return value.floor();
}

/// https://github.com/KHwang9883/MobileModels
const List<(String, String)> phoneInfos = [
  ('Xiaomi', 'M2001J2E'), // Xiaomi 10 国行版
  ('Xiaomi', 'M2001J2C'), // Xiaomi 10 国行版
  ('Xiaomi', 'M2007J1SC'), // Xiaomi 10 至尊纪念版
  ('Xiaomi', 'M2011K2C'), // Xiaomi 11 国行版
  ('Xiaomi', 'M2011K2G'), // Xiaomi 11 国际版
  ('Xiaomi', 'M2102K1AC'), // Xiaomi 11 Pro
  ('Xiaomi', 'M2102K1C'), // Xiaomi 11 Ultra 国行版
  ('Xiaomi', 'M2102K1G'), // Xiaomi 11 Ultra 国际版
  ('Xiaomi', '2201123C'), // Xiaomi 12 国行版
  ('Xiaomi', '2201123G'), // Xiaomi 12 国际版
  ('Xiaomi', '2112123AC'), // Xiaomi 12X 国行版
  ('Xiaomi', '2112123AG'), // Xiaomi 12X 国际版
  ('Xiaomi', '2201122C'), // Xiaomi 12 Pro 国行版
  ('Xiaomi', '2201122G'), // Xiaomi 12 Pro 国际版
  ('Xiaomi', '2206123SC'), // Xiaomi 12S
  ('Xiaomi', '2206122SC'), // Xiaomi 12S Pro
  ('Xiaomi', '2203121C'), // Xiaomi 12S Ultra
  ('Xiaomi', '2211133C'), // Xiaomi 13 国行版
  ('Xiaomi', '2211133G'), // Xiaomi 13 国际版
  ('Xiaomi', '2210132C'), // Xiaomi 13 Pro 国行版
  ('Xiaomi', '2210132G'), // Xiaomi 13 Pro 国际版
  ('Xiaomi', '2304FPN6DC'), // Xiaomi 13 Ultra 国行版
  ('Xiaomi', '2304FPN6DG'), // Xiaomi 13 Ultra 国际版
  ('Xiaomi', '23127PN0CC'), // Xiaomi 14 国行版
  ('Xiaomi', '23127PN0CG'), // Xiaomi 14 国际版
  ('Xiaomi', '23116PN5BC'), // Xiaomi 14 Pro
  ('Xiaomi', '24031PN0DC'), // Xiaomi 14 Ultra 国行版
  ('Xiaomi', '24030PN60G'), // Xiaomi 14 Ultra 国际版
  ('Xiaomi', '24129PN74C'), // Xiaomi 15 国行版
  ('Xiaomi', '24129PN74G'), // Xiaomi 15 国际版
  ('Xiaomi', '2410DPN6CC'), // Xiaomi 15 Pro
  ('Xiaomi', '25019PNF3C'), // Xiaomi 15 Ultra 国行版
  ('Xiaomi', '25010PN30G'), // Xiaomi 15 Ultra 国际版
  ('Xiaomi', '25042PN24C'), // Xiaomi 15S Pro
  ('Xiaomi', '25069PTEBG'), // Xiaomi 15T 国际版
  ('Xiaomi', '2506BPN68G'), // Xiaomi 15T Pro 国际版
  ('Xiaomi', '25113PN0EC'), // Xiaomi 17 国行版
  ('Xiaomi', '25113PN0EG'), // Xiaomi 17 国际版
  ('Xiaomi', '25098PN5AC'), // Xiaomi 17 Pro
  ('Xiaomi', '2509FPN0BC'), // Xiaomi 17 Pro Max
  ('Xiaomi', '2512BPNDAC'), // Xiaomi 17 Ultra 国行版
  ('Xiaomi', '2512BPNDAG'), // Xiaomi 17 Ultra 国际版
  ('Xiaomi', '2605EPN8EC'), // Xiaomi 17 Max
  ('Xiaomi', 'M531DA'), // Xiaomi 17T 国行版
  ('Xiaomi', '2602DPT53G'), // Xiaomi 17T 国际版
  ('Xiaomi', 'M025EC'), // Xiaomi 17T Pro 国行版
  ('Xiaomi', '2602EPTC0G'), // Xiaomi 17T Pro 国际版
];

(String, String) randomPhoneInfo() {
  return phoneInfos[Random().nextInt(phoneInfos.length)];
}
