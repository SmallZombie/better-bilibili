import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:dio/dio.dart';

InterceptorsWrapper buildBiliWebAuthIntercrptor(Account account) {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers.addAll({
        'user-agent': account.userAgent,
        'referer': 'https://www.bilibili.com/',
      });

      final List<String> cookies = [];

      // b_nut: 固定为当前秒级 unix 时间戳
      cookies.add('b_nut=${DateTime.now().millisecondsSinceEpoch ~/ 1000}');
      // browser_resolution 固定即可
      cookies.add('browser_resolution=2560-1305');
      // home_feed_column 首页一行能展示几个视频卡片，根据观察最大为 5，这里固定即可
      cookies.add('home_feed_column=5');
      // b_lsid 一段客户端生成的随机字符串，格式: {8位十六进制随机字符}_{当前毫秒时间戳的十六进制}，每次请求都要生成一个新的
      cookies.add(
        'b_lsid=${generateRandomHex(8)}_${DateTime.now().millisecondsSinceEpoch.toRadixString(16).toUpperCase()}',
      );
      // theme_style 网页端的主题，可选值为 light / dark
      cookies.add('theme_style=light');
      // 这些不知道干嘛的，初步判断固定即可
      cookies.add('theme-avatar-tip-show=SHOWED');
      cookies.add('theme-switch-show=SHOWED');
      cookies.add('theme-tip-show=SHOWED');
      cookies.add('timeMachine=0');
      // historyviewmode 进一次历史记录页后生成
      cookies.add('historyviewmode=grid');

      // _uuid
      if (account.uuid.isNotEmpty) {
        cookies.add('_uuid=${account.uuid}');
      }

      if (account is LoginedAccount) {
        // SESSDATA
        cookies.add('SESSDATA=${account.accessToken}');

        // bili_jct
        cookies.add('bili_jct=${account.biliJct}');

        // DedeUserID
        cookies.add('DedeUserID=${account.dedeUserID}');

        // DedeUserID__ckMd5
        cookies.add('DedeUserID__ckMd5=${account.dedeUserIdCkMd5}');

        // sid
        cookies.add('sid=${account.sid}');
      }

      // buvid3
      if (account.buvid3.isNotEmpty) {
        cookies.add('buvid3=${account.buvid3}');
      }

      // buvid4
      if (account.buvid4.isNotEmpty) {
        cookies.add('buvid4=${account.buvid4}');
      }

      // buvidFp
      if (account.buvidFp.isNotEmpty) {
        cookies.add('buvidFp=${account.buvidFp}');
      }

      // bili_ticket & bili_ticket_expires
      if (account.biliTicket.isNotEmpty && account.biliTicketExpiredAt > 0) {
        cookies.add('bili_ticket=${account.biliTicket}');
        cookies.add('bili_ticket_expires=${account.biliTicketExpiredAt}');
      }

      options.headers['Cookie'] = cookies.join('; ');

      return handler.next(options);
    },
  );
}
