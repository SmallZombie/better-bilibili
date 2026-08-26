import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => null,
        builder: (_, _) => const PlayerTest1(),
      ),
    ),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(
    MaterialApp.router(
      routerConfig: _router,
    ),
  );
}

class PlayerTest1 extends StatelessWidget {
  const PlayerTest1({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(accountConfig: AccountConfig());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Test 1'),
      ),
      // body: Center(
      //   child: SizedBox(
      //     width: 700,
      //     child: ChangeNotifierProvider(
      //       create: (_) => BiliVideoPlayerViewModel(
      //         userRepository: authRepository,
      //         videoRepository: VideoRepository(videoApiClient: BiliVideoApiService(authRepository: authRepository)),
      //         playerConfig: PlayerConfig(),
      //         playInfo: PlayInfo(
      //           videoId: '116542427629500',
      //           bvid: 'BV1BzRSB3EWB',
      //           episodeId: '38201067065',
      //           videoTracks: [
      //             MediaTrack(
      //               id: 120,
      //               url:
      //                   'https://upos-sz-estgcos.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30120.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&og=cos&deadline=1778923103&trid=3e67ef52c98f4c77a327b19e74263ceu&oi=2079658362&mid=321983926&gen=playurlv3&os=estgcos&nbs=1&uipk=5&platform=pc&upsig=fa0eb87790d3fed7cd9164b7e65b16ad&uparams=e,og,deadline,trid,oi,mid,gen,os,nbs,uipk,platform&bvc=vod&nettype=0&bw=10943847&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&agrr=1&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&build=0&dl=0&f=u_0_0&orderid=0,3',
      //               codec: .av1,
      //               codecProfile: 'avc1.640034',
      //               mimeType: 'video/mp4',
      //             ),
      //             MediaTrack(
      //               id: 120,
      //               url:
      //                   'https://upos-sz-mirrorbd.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30121.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&mid=321983926&nbs=1&trid=3e67ef52c98f4c77a327b19e74263ceu&oi=2079658362&uipk=5&platform=pc&os=bdbv&og=hw&deadline=1778923103&gen=playurlv3&upsig=81b39bf423eed013d42126596056746e&uparams=e,mid,nbs,trid,oi,uipk,platform,os,og,deadline,gen&bvc=vod&nettype=0&bw=5242555&build=0&dl=0&f=u_0_0&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&agrr=1&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&orderid=0,3',
      //               codec: .h264,
      //               codecProfile: 'hev1.1.6.L153.90',
      //               mimeType: 'video/mp4',
      //             ),
      //             MediaTrack(
      //               id: 116,
      //               url:
      //                   'https://upos-sz-estgcos.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30116.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&nbs=1&trid=3e67ef52c98f4c77a327b19e74263ceu&oi=2079658362&platform=pc&deadline=1778923103&os=estgcos&uipk=5&mid=321983926&gen=playurlv3&og=cos&upsig=79364bf1965d8a01c847b76a3022d65a&uparams=e,nbs,trid,oi,platform,deadline,os,uipk,mid,gen,og&bvc=vod&nettype=0&bw=2593516&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&agrr=1&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&build=0&dl=0&f=u_0_0&orderid=0,3',
      //               codec: .h265,
      //               codecProfile: 'avc1.640032',
      //               mimeType: 'video/mp4',
      //             ),
      //           ],
      //           audioTracks: [
      //             MediaTrack(
      //               id: 30280,
      //               url:
      //                   'https://upos-sz-estgcos.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30280.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&platform=pc&deadline=1778923103&nbs=1&trid=3e67ef52c98f4c77a327b19e74263ceu&oi=2079658362&uipk=5&gen=playurlv3&os=estgcos&og=cos&mid=321983926&upsig=7471e7f8133f62d256bdd4dc6e719e15&uparams=e,platform,deadline,nbs,trid,oi,uipk,gen,os,og,mid&bvc=vod&nettype=0&bw=128959&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&build=0&dl=0&f=u_0_0&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&agrr=1&orderid=0,3',
      //               codec: .mp4,
      //               codecProfile: 'mp4a.40.2',
      //               mimeType: 'audio/mp4',
      //             ),
      //             MediaTrack(
      //               id: 30216,
      //               url:
      //                   'https://upos-sz-estghw.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30216.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&deadline=1778923103&nbs=1&oi=2079658362&mid=321983926&trid=3e67ef52c98f4c77a327b19e74263ceu&uipk=5&platform=pc&gen=playurlv3&os=estghw&og=hw&upsig=9d62039c4220066f132c938d02b1232f&uparams=e,deadline,nbs,oi,mid,trid,uipk,platform,gen,os,og&bvc=vod&nettype=0&bw=66920&build=0&dl=0&f=u_0_0&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&agrr=1&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&orderid=0,3',
      //               codec: .mp4,
      //               codecProfile: 'mp4a.40.2',
      //               mimeType: 'audio/mp4',
      //             ),
      //             MediaTrack(
      //               id: 30232,
      //               url:
      //                   'https://upos-sz-mirror08c.bilivideo.com/upgcxcode/65/70/38201067065/38201067065-1-30232.m4s?e=ig8euxZM2rNcNbdlhoNvNC8BqJIzNbfqXBvEqxTEto8BTrNvN0GvT90W5JZMkX_YN0MvXg8gNEV4NC8xNEV4N03eN0B5tZlqNxTEto8BTrNvNeZVuJ10Kj_g2UB02J0mN0B5tZlqNCNEto8BTrNvNC7MTX502C8f2jmMQJ6mqF2fka1mqx6gqj0eN0B599M=&nbs=1&trid=3e67ef52c98f4c77a327b19e74263ceu&oi=2079658362&os=08cbv&deadline=1778923103&uipk=5&gen=playurlv3&og=hw&platform=pc&mid=321983926&upsig=7305f794b35afdf0cc0f7a0f03dc7758&uparams=e,nbs,trid,oi,os,deadline,uipk,gen,og,platform,mid&bvc=vod&nettype=0&bw=100086&agrr=1&buvid=115FE2F1-B903-FDF6-EF35-285A743EA4E895118infoc&build=0&dl=0&f=u_0_0&qn_dyeid=bedef6f7ec939515002458fe6a081a3f&orderid=0,3',
      //               codec: .mp4,
      //               codecProfile: 'mp4a.40.2',
      //               mimeType: 'audio/mp4',
      //             ),
      //           ],
      //         ),
      //       ),
      //       builder: (context, _) => BiliVideoPlayer(
      //         playerViewModel: context.read(),
      //         panelViewModel: VideoPlayerPanelViewModel(playerConfig: PlayerConfig()),
      //         aspectRatio: 16 / 9,
      //       ),
      //     ),
      //   ),
      // ),
    );
  }
}
