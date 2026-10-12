import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:better_bilibili/utils/bili/bili_danmaku_mask_parser.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  runApp(MaterialApp(home: DanmakuMaskTest1()));
}

class DanmakuMaskTest1 extends StatefulWidget {
  const DanmakuMaskTest1({super.key});

  @override
  State<DanmakuMaskTest1> createState() => _DanmakuMaskTest1State();
}

class _DanmakuMaskTest1State extends State<DanmakuMaskTest1> {
  Picture? mask;
  Size? maskSize;

  @override
  void initState() {
    super.initState();

    loadMask();
  }

  late final DanmakuMask webMask;
  int segmentIndex = 15;
  int frameIndex = 230;

  void loadMask() async {
    webMask = await BiliDanmakuMaskParser.parseFile(File(r'test\assets\mask.dat'));
    reload();
  }

  int lastReloadTime = 0;

  void reload() async {
    mask?.dispose();
    final stopwatch = Stopwatch()..start();
    final pictureInfo = await vg.loadPicture(
      SvgStringLoader(
        webMask.segments[segmentIndex].frames[frameIndex].svgText,
        // colorMapper: MyColorMapper(),
      ),
      null,
    );
    stopwatch.stop();

    setState(() {
      mask = pictureInfo.picture;
      maskSize = pictureInfo.size;
      lastReloadTime = stopwatch.elapsedMicroseconds;
    });
  }

  void prevSegment() {
    if (segmentIndex == 0) return;
    segmentIndex--;
    frameIndex = 0;
    reload();
  }

  void nextSegment() async {
    if (segmentIndex == webMask.segments.length - 1) return;
    segmentIndex++;
    frameIndex = 0;
    reload();
  }

  void prevFrame() {
    if (frameIndex == 0) return;
    frameIndex--;
    reload();
  }

  void nextFrame() async {
    if (frameIndex == webMask.segments[segmentIndex].frames.length - 1) return;
    frameIndex++;
    reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DanmakuMaskTest1'),
        actions: [
          IconButton(
            onPressed: prevSegment,
            icon: const Icon(Icons.skip_previous_rounded),
            tooltip: '上一段',
          ),
          IconButton(
            onPressed: prevFrame,
            icon: const Icon(Icons.skip_previous_rounded),
            tooltip: '上一帧',
          ),
          IconButton(
            onPressed: nextFrame,
            icon: const Icon(Icons.skip_next_rounded),
            tooltip: '下一帧',
          ),
          IconButton(
            onPressed: nextSegment,
            icon: const Icon(Icons.skip_next_rounded),
            tooltip: '下一段',
          ),
        ],
      ),
      body: Center(
        child: mask != null
            ? Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: 6.0,
                children: [
                  Text(
                    '段 $segmentIndex, 帧 $frameIndex, ts ${webMask.segments[segmentIndex].frames[frameIndex].timestamp}, 耗时 $lastReloadTime μs',
                  ),
                  SizedBox(
                    width: 1920 / 2,
                    height: 1080 / 2,
                    child: Container(
                      color: Colors.blue,
                      // decoration: BoxDecoration(
                      //   border: .all(color: Colors.red, width: 4),
                      //   color: Colors.blue,
                      // ),
                      child: CustomPaint(
                        painter: MyPainter(mask: mask!, maskSize: maskSize!),
                      ),
                    ),
                  ),
                ],
              )
            : CircularProgressIndicator(),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  final Picture mask;
  final Size maskSize;

  const MyPainter({required this.mask, required this.maskSize});

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;

    canvas.save();
    canvas.saveLayer(bounds, Paint());

    final tp = TextPainter(
      text: TextSpan(
        text: '弹幕',
        style: TextStyle(
          fontSize: 460.0,
          color: Colors.black,
          fontWeight: .bold,
        ),
      ),
      textDirection: .ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset.zero);

    // 内层图层：使用遮罩的 Alpha 通道裁剪外层文字。
    canvas.saveLayer(
      bounds,
      Paint()..blendMode = BlendMode.dstIn,
    );

    final scale = min(
      size.width / maskSize.width,
      size.height / maskSize.height,
    ).toDouble();

    canvas.save();
    canvas.scale(scale, scale);
    canvas.drawPicture(mask);
    canvas.restore();

    canvas.restore(); // 将遮罩以 dstIn 模式合成到文字图层
    canvas.restore(); // 将处理完的文字图层合成到画布

    canvas.restore(); // 恢复裁剪状态
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
