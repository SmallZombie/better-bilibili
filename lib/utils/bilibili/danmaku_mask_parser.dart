import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

// 参考仓库：
// - bilibili-API-collect/src/branch/master/docs/danmaku/webmask.md
// - https://github.com/andrewvy/webmask-renderer
class BiliDanmakuMaskParser {
  static const _supportedVersion = 1;
  static const _magic = [0x4D, 0x41, 0x53, 0x4B]; // MASK
  static const _svgUriPrefix = 'data:image/svg+xml;base64,';
  static const _emptyContentLength = 518;

  static Future<DanmakuMask> parseFile(File file, {bool dropEmptyFrame = true}) async {
    return parse(await file.readAsBytes(), dropEmptyFrame: dropEmptyFrame);
  }

  static DanmakuMask parse(List<int> bytes, {bool dropEmptyFrame = true}) {
    final data = Uint8List.fromList(bytes);

    if (data.length < _magic.length) {
      throw const FormatException('Invalid MASK file');
    }

    for (var i = 0; i < _magic.length; i++) {
      if (data[i] != _magic[i]) {
        throw const FormatException('Invalid MASK file');
      }
    }

    final view = ByteData.sublistView(data);
    int offset = _magic.length;

    final version = view.getInt32(offset, .big);
    if (version != _supportedVersion) {
      throw FormatException('Unsupported MASK version: $version');
    }
    offset += 4;

    // 不知道干什么的
    // bilibili-API-collect/src/branch/master/docs/danmaku/webmask.md
    final vu = Uint8List.fromList(data.sublist(8, 12));
    offset += 4;

    final segmentCount = view.getInt32(offset, .big);
    if (segmentCount < 0) {
      throw FormatException('Invalid segment count: $segmentCount');
    }
    offset += 4;

    final List<_SegmentHeader> segmentHeaders = [];
    for (var i = 0; i < segmentCount; i++) {
      // 此处跳过两个未知字段
      // https://github.com/andrewvy/webmask-renderer/blob/8ca7c5eb5e35cefb627f12a3e1c696deeb7b8221/src/main.rs#L164
      final startTime = view.getInt32(offset + 4, .big);
      offset += 8;

      final segmentOffset = view.getInt32(offset + 4, .big);
      offset += 8;

      segmentHeaders.add(
        _SegmentHeader(startTime: startTime, offset: segmentOffset),
      );
    }

    final List<DanmakuMaskSegment> segments = [];
    for (var i = 0; i < segmentCount; i++) {
      final header = segmentHeaders[i];

      final endOffset = i + 1 < segmentCount ? segmentHeaders[i + 1].offset : data.length;
      final compressed = data.sublist(header.offset, endOffset);

      Uint8List decompressed;
      try {
        decompressed = Uint8List.fromList(gzip.decode(compressed));
      } catch (e) {
        throw FormatException('An error occurred while decompressing the data in segment $i: $e');
      }

      final frames = _parseFrames(decompressed);
      segments.add(
        DanmakuMaskSegment(
          index: i,
          startTime: header.startTime,
          frames: frames,
        ),
      );
    }

    return DanmakuMask(version: version, vu: vu, segments: segments);
  }

  static List<DanmakuMaskFrame> _parseFrames(Uint8List data, {bool dropEmptyFrame = true}) {
    final view = ByteData.sublistView(data);
    int offset = 0;

    final List<DanmakuMaskFrame> frames = [];
    while (offset < data.length) {
      // 此处 bac 的文档是错的
      // 参考 https://github.com/andrewvy/webmask-renderer/blob/8ca7c5eb5e35cefb627f12a3e1c696deeb7b8221/src/main.rs#L175
      final contentLength = view.getInt32(offset, .big);
      offset += 4;

      // 跳过一个未知字段
      // final wdf = view.getInt32(offset, .big);
      offset += 4;

      final timestamp = view.getInt32(offset, .big);
      offset += 4;

      final content = data.sublist(offset, offset + contentLength);
      offset += contentLength;

      if (dropEmptyFrame && content.length == _emptyContentLength) {
        continue;
      }

      final decodedContent = ascii.decode(content);
      final base64Content = decodedContent.substring(_svgUriPrefix.length).replaceAll(RegExp(r'\s+'), '');

      frames.add(
        DanmakuMaskFrame(timestamp: timestamp, base64Data: base64Content),
      );
    }

    return List.unmodifiable(frames);
  }
}

class DanmakuMask {
  final int version;
  final Uint8List vu;
  final List<DanmakuMaskSegment> segments;

  DanmakuMask({
    required this.version,
    required this.vu,
    required List<DanmakuMaskSegment> segments,
  }) : segments = List.unmodifiable(segments);

  @override
  String toString() => 'DanmakuMask(version: $version, vu: $vu, segments: $segments)';
}

class DanmakuMaskSegment {
  final int index;
  final int startTime;
  final List<DanmakuMaskFrame> frames;

  DanmakuMaskSegment({
    required this.index,
    required this.startTime,
    required List<DanmakuMaskFrame> frames,
  }) : frames = List.unmodifiable(frames);

  @override
  String toString() => 'DanmakuMaskSegment(index: $index, startTime: $startTime, frames: $frames)';
}

class DanmakuMaskFrame {
  /// 毫秒时间戳
  final int timestamp;
  final String base64Data;

  const DanmakuMaskFrame({required this.timestamp, required this.base64Data});

  Uint8List get svgBytes {
    return Uint8List.fromList(base64.decode(base64Data));
  }

  String get svgText {
    return utf8.decode(svgBytes, allowMalformed: true);
  }

  @override
  String toString() => 'DanmakuMaskFrame(timestamp: $timestamp, base64Data: $base64Data)';
}

class _SegmentHeader {
  final int startTime;
  final int offset;

  const _SegmentHeader({required this.startTime, required this.offset});
}
