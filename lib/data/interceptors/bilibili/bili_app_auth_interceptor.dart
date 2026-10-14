import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:dio/dio.dart';

InterceptorsWrapper buildBiliAppAuthIntercrptor(Account account) {
  return InterceptorsWrapper(
    onRequest: (options, handler) {
      options.headers.addAll({
        'app-key': 'android64',
        'bili-http-engine': 'ignet',
        'buvid': '',
        'env': 'prod',
        'fp_local': '',
        'fp_remote': '',
        'guestid': '',
        // 'session_id': account.sid,
        'user-agent':
            'Mozilla/5.0 BiliDroid/9.4.0 (bbcallen@gmail.com) 9.4.0 os/android model/${account.model} mobi_app/android build/9040200 channel/bili innerVer/9040210 osVer/12 network/2',
        'x-bili-aurora-eid': '',
        'x-bili-locale-bin': '',
        'x-bili-metadata-ip-region': '',
        'x-bili-metadata-legal-region': '',
        'x-bili-metadata-recent-region': '',
        'x-bili-mid': 0,
        'x-bili-network-bin': '',
        'x-bili-redirect': 1,
        'x-bili-ticket': account.biliTicket,
        'x-bili-trace-id': '',
      });

      return handler.next(options);
    },
  );
}
