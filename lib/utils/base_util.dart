import 'dart:math';

/// 按顺序检查多个 (条件, 值) 对，返回第一个为 true 的条件的值
/// 例如: ifs([(a == 1, 'x'), (b == 2, 'y')], defaultValue: 'z')
T? ifs<T>(List<(bool, T)> pairs, {T? defaultValue}) {
  for (final pair in pairs) {
    if (pair.$1) return pair.$2;
  }
  return defaultValue;
}

T? ifsFun<T>(List<(bool, T Function())> pairs, {T? defaultValue}) {
  for (final pair in pairs) {
    if (pair.$1) return pair.$2();
  }
  return defaultValue;
}

/// 生成指定长度的随机字符串
/// 默认启用数字、大写字母和小写字母
String generateRandomString(
  int length, {
  bool useUpperCase = true,
  bool useLowerCase = true,
  bool useNumbers = true,
  List<String> useCustomChars = const [],
}) {
  if (length <= 0) return '';

  final buffer = StringBuffer();
  String chars = '';

  if (useUpperCase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  if (useLowerCase) chars += 'abcdefghijklmnopqrstuvwxyz';
  if (useNumbers) chars += '0123456789';
  if (useCustomChars.isNotEmpty) chars += useCustomChars.join();

  if (chars.isEmpty) {
    throw ArgumentError('至少需要启用一种字符集或提供自定义字符');
  }

  final rnd = Random();
  for (int i = 0; i < length; i++) {
    buffer.write(chars[rnd.nextInt(chars.length)]);
  }

  return buffer.toString();
}

/// 格式化整数到更易读的字符串格式
/// 例如 "1.0万" 或 "1.1亿"
@Deprecated('Use context.lCompatNumber instead.')
String formatCountToHumanReadable(int count) {
  if (count >= 100000000) {
    return '${(count / 100000000).toStringAsFixed(1)}亿';
  }
  if (count >= 10000) {
    return '${(count / 10000).toStringAsFixed(1)}万';
  }
  return count.toString();
}

/// 格式化秒到 `mm:ss` 格式
String formatSeconds(double duration) {
  int minutes = duration.toInt() ~/ 60;
  int seconds = duration.toInt() % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

String formatDuration(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60);

  final mm = minutes.toString().padLeft(2, '0');
  final ss = seconds.toString().padLeft(2, '0');

  if (hours > 0) {
    final hh = hours.toString().padLeft(2, '0');
    return '$hh:$mm:$ss';
  }

  return '$mm:$ss';
}

/// 格式化秒级时间戳到更易读的字符串格式
/// 比如 "1天前"，"1小时前"，"1分钟前"，"1秒前"
///
/// [useTime] 为 true 时，会在后面加上12小时制的时间
String formatTimeToHumanReadable(int ts, {bool useTime = false}) {
  final now = DateTime.now();
  final uploadDate = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  final difference = now.difference(uploadDate);

  String timeStr = '';
  if (useTime) {
    int hour = uploadDate.hour % 12 == 0 ? 12 : uploadDate.hour % 12;
    String ampm = uploadDate.hour < 12 ? '上午' : '下午';
    String minute = uploadDate.minute.toString().padLeft(2, '0');
    timeStr = ' $ampm$hour:$minute';
  }

  // <1min：x秒前
  if (difference.inSeconds < 60) {
    return '${difference.inSeconds}秒前$timeStr';
  }

  // <1h：x分钟前
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分钟前$timeStr';
  }

  // <1天：x小时前
  if (difference.inHours < 24) {
    return '${difference.inHours}小时前$timeStr';
  }

  // <1周：x天前
  if (difference.inDays < 7) {
    return '${difference.inDays}天前$timeStr';
  }

  // 同月：x月x日
  if (now.year == uploadDate.year && now.month == uploadDate.month) {
    return '${uploadDate.month}月${uploadDate.day}日$timeStr';
  }

  // 同年：x月x日
  if (now.year == uploadDate.year) {
    return '${uploadDate.month}月${uploadDate.day}日$timeStr';
  }

  // 否则：x年x月x日
  return '${uploadDate.year}年${uploadDate.month}月${uploadDate.day}日$timeStr';
}

/// 格式化秒级时间戳为 `yyyy-MM-dd HH:mm:ss` 格式
String formatTime(int ts) {
  final DateTime date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
}

/// 随机获取一个在 [min, max] 之间的整数
int getRandomInt(int min, int max) {
  final random = Random();
  return random.nextInt(max - min + 1) + min;
}

/// 随机获取一个在 [min, max] 之间的浮点数
double getRandomDouble(double min, double max) {
  final random = Random();
  return random.nextDouble() * (max - min) + min;
}

/// 清理字符串，去除标点符号、空格，并转换为小写
String cleanString(String input) {
  return input.replaceAll(RegExp(r'[\p{P}\p{S}\s]', unicode: true), '').toLowerCase();
}

T getRandomItem<T>(List<T> list) {
  final random = Random();
  return list[random.nextInt(list.length)];
}
