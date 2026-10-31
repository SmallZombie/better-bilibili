class GetFavoriteArticlesResponse {
  final int total;
  final bool hasMore;
  final List<FavoriteArticle> list;

  GetFavoriteArticlesResponse({
    required this.total,
    required this.hasMore,
    required this.list,
  });
}

class FavoriteArticle {
  final String postId;
  final String? cover;
  final String title;
  final String? summary;
  final int favoriteTime;

  FavoriteArticle({
    required this.postId,
    this.cover,
    required this.title,
    this.summary,
    required this.favoriteTime,
  });

  factory FavoriteArticle.fromJson(Map<String, dynamic> json) {
    /// 用于将字符串形式的 `time_text` 转回秒级时间戳
    /// 可能出现的情况：`刚刚`、`57分钟前`、`1小时前`、`昨天 14:32`、`2天前`、`04月28日`、`2025年04月29日`、`2小时前`、`6月11日`
    /// 10/17: 这怎么之前还是对其到2长度的现在又不对其了
    int coverTimeStrToInt(String str) {
      final now = DateTime.now();

      if (str == '刚刚') return now.millisecondsSinceEpoch ~/ 1000;

      // xx分钟前
      final minuteReg = RegExp(r'^(\d+)分钟前$');
      final matchMinute = minuteReg.firstMatch(str);
      if (matchMinute != null) {
        final minutes = int.tryParse(matchMinute.group(1)!);
        if (minutes != null) {
          return now.subtract(Duration(minutes: minutes)).millisecondsSinceEpoch ~/ 1000;
        }
      }

      // x小时前
      final hourReg = RegExp(r'^(\d+)小时前$');
      final matchHour = hourReg.firstMatch(str);
      if (matchHour != null) {
        final hours = int.tryParse(matchHour.group(1)!);
        if (hours != null) {
          return now.subtract(Duration(hours: hours)).millisecondsSinceEpoch ~/ 1000;
        }
      }

      // x天前
      final dayReg = RegExp(r'^(\d+)天前$');
      final matchDay = dayReg.firstMatch(str);
      if (matchDay != null) {
        final days = int.tryParse(matchDay.group(1)!);
        if (days != null) {
          return now.subtract(Duration(days: days)).millisecondsSinceEpoch ~/ 1000;
        }
      }

      // 昨天 xx:xx
      final yesterdayReg = RegExp(r'^昨天\s+(\d{1,2}):(\d{2})$');
      final matchYesterday = yesterdayReg.firstMatch(str);
      if (matchYesterday != null) {
        final hour = int.tryParse(matchYesterday.group(1)!);
        final minute = int.tryParse(matchYesterday.group(2)!);
        if (hour != null && minute != null) {
          final yesterday = DateTime(now.year, now.month, now.day).subtract(Duration(days: 1));
          final dt = DateTime(yesterday.year, yesterday.month, yesterday.day, hour, minute);
          return dt.millisecondsSinceEpoch ~/ 1000;
        }
      }

      // [x]x月[x]x日
      final monthDayReg = RegExp(r'^(\d{1,2})月(\d{1,2})日$');
      final matchMonthDay = monthDayReg.firstMatch(str);
      if (matchMonthDay != null) {
        final month = int.tryParse(matchMonthDay.group(1)!);
        final day = int.tryParse(matchMonthDay.group(2)!);
        if (month != null && day != null) {
          final dt = DateTime(now.year, month, day);
          return dt.millisecondsSinceEpoch ~/ 1000;
        }
      }

      // xxxx年[x]x月[x]x日
      final yearMonthDayReg = RegExp(r'^(\d{4})年(\d{1,2})月(\d{1,2})日$');
      final matchYearMonthDay = yearMonthDayReg.firstMatch(str);
      if (matchYearMonthDay != null) {
        final year = int.tryParse(matchYearMonthDay.group(1)!);
        final month = int.tryParse(matchYearMonthDay.group(2)!);
        final day = int.tryParse(matchYearMonthDay.group(3)!);
        if (year != null && month != null && day != null) {
          final dt = DateTime(year, month, day);
          return dt.millisecondsSinceEpoch ~/ 1000;
        }
      }

      throw FormatException('Unparseable time: $str');
    }

    return FavoriteArticle(
      postId: json['opus_id'],
      cover: json['cover'].isEmpty ? null : json['cover'],
      title: json['title'].isEmpty ? '此内容不再可用' : json['title'],
      summary: json['content'],
      favoriteTime: coverTimeStrToInt(json['time_text'].substring(3)),
    );
  }
}
