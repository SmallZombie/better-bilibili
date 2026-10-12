import 'dart:io';

import 'package:better_bilibili/utils/bili/bili_danmaku_mask_parser.dart';

void main() async {
  final mask = await BiliDanmakuMaskParser.parseFile(File(r'test\assets\mask.dat'));

  print('version=${mask.version}');
  print('segments.length=${mask.segments.length}');

  for (final segment in mask.segments) {
    print(
      'segment ${segment.index}: '
      'time=${segment.startTime}, '
      'frames=${segment.frames.length}',
    );

    if (segment.frames.isNotEmpty) {
      print('  first.timestamp=${segment.frames.first.timestamp}');
      print('  first.svgText=${segment.frames.first.svgText}');
      print('  first.svgBytes.length=${segment.frames.first.svgBytes.length}');
    }
  }

  final List<DanmakuMaskFrame> _frames = List.unmodifiable(
    mask.segments.expand((segment) => segment.frames),
  );

  // O(log N)
  DanmakuMaskFrame? findNextFrame(int timestamp) {
    final frames = _frames;
    var low = 0;
    var high = frames.length;

    while (low < high) {
      final mid = low + ((high - low) >> 1);

      if (frames[mid].timestamp < timestamp) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }

    return low < frames.length ? frames[low] : null;
  }

  // final stopwatch = Stopwatch()..start();
  // final frame = findNextFrame(158000);
  // stopwatch.stop();
  // print(
  //   'timestamp=${frame?.timestamp}, '
  //   'frame=$frame,'
  //   'svg=${frame?.svgText},'
  //   '耗时=${stopwatch.elapsedMicroseconds}μs',
  // );
}
