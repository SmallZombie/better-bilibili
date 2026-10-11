import 'dart:ui';

import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  runApp(
    MaterialApp(
      theme: ThemeData(primaryColor: Colors.blue),
      home: AmbientLightTest1(),
    ),
  );
}

class AmbientLightTest1 extends StatefulWidget {
  const AmbientLightTest1({super.key});

  @override
  State<AmbientLightTest1> createState() => _AmbientLightTest1State();
}

class _AmbientLightTest1State extends State<AmbientLightTest1> {
  late final player = Player();
  late final controller = VideoController(player);

  @override
  void initState() {
    super.initState();

    player.setVolume(50);

    // player.stream.position.listen((event) {
    //   debugPrint('position stream: $event');
    // });
  }

  // List<double> _calcMatrix(double contrast) {
  //   final double t = (1.0 - contrast) * 255.0 / 2.0;
  //   // dart format off
  //   return <double>[
  //     contrast, 0, 0, 0, t,
  //     0, contrast, 0, 0, t,
  //     0, 0, contrast, 0, t,
  //     0, 0, 0, 1, 0,
  //   ];
  //   // dart format on
  // }

  // [saturation]: 饱和度倍率
  // [brightness]: 亮度倍率
  List<double> _calcMatrix({required double saturation, required double brightness}) {
    // Rec.709
    const double rLum = 0.2126;
    const double gLum = 0.7152;
    const double bLum = 0.0722;

    final double sr = (1 - saturation) * rLum;
    final double sg = (1 - saturation) * gLum;
    final double sb = (1 - saturation) * bLum;

    // dart format off
    return <double>[
      (sr + saturation) * brightness, sg * brightness, sb * brightness, 0, 0,
      sr * brightness, (sg + saturation) * brightness, sb * brightness, 0, 0,
      sr * brightness, sg * brightness, (sb + saturation) * brightness, 0, 0,
      0, 0, 0, 1, 0,
    ];
    // dart format on
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101010),
      appBar: AppBar(
        title: const Text('AmbientLightTest1'),
        actions: [
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test1.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频1',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test2.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频2',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test3.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频3',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test4.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频4',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test5.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频5',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test6.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频6',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test7.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频7',
          ),
          IconButton(
            onPressed: () {
              player.open(Media('http://127.0.0.1:5500/videos/test8.mp4'));
            },
            icon: const Icon(Icons.play_arrow_outlined),
            tooltip: '测试视频8',
          ),
        ],
      ),
      body: Padding(
        padding: const .all(64.0),
        child: SizedBox(
          // width: 1920 / 2,
          // height: 1080 / 2,
          width: 1900,
          height: 1900 * (9 / 16),
          child: Stack(
            alignment: .center,
            clipBehavior: .none,
            children: [
              ImageFiltered(
                imageFilter: ImageFilter.blur(
                  sigmaX: 1900 / 16, // 120.0
                  sigmaY: 1900 * (9 / 16) / 16,
                  tileMode: TileMode.decal,
                ),
                child: ColorFiltered(
                  colorFilter: ColorFilter.matrix(_calcMatrix(saturation: 3, brightness: 0.5)),
                  child: Video(controller: controller),
                ),
              ),
              ClipRRect(
                borderRadius: .all(.circular(18.0)),
                child: Video(controller: controller),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
