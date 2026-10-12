import 'dart:convert';

import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getDmImgList', () {
    const minLogCount = 10;
    const maxLogCount = 30;
    final (int windowWidth, int windowHeight) = randomWindowSize();
    const maxTimestamp = 10000;
    const mouseRangeX = 0.5;
    const mouseRangeY = 0.5;

    test('返回合法 JSON 字符串', () {
      final result = getDmImgList(
        minLogCount: minLogCount,
        maxLogCount: maxLogCount,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );
      expect(() => jsonDecode(result.$1), returnsNormally);
    });

    test('解析后为 List，且长度在 [minLogCount, maxLogCount] 之间', () {
      final result = getDmImgList(
        minLogCount: minLogCount,
        maxLogCount: maxLogCount,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      expect(list.length, greaterThanOrEqualTo(minLogCount));
      expect(list.length, lessThanOrEqualTo(maxLogCount));
    });

    test('当 minLogCount == maxLogCount 时，列表长度等于该值', () {
      const count = 3;
      final result = getDmImgList(
        minLogCount: count,
        maxLogCount: count,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      expect(list.length, count);
    });

    test('timestamp 不小于 RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM', () {
      final result = getDmImgList(
        minLogCount: 2,
        maxLogCount: 2,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      for (final item in list) {
        final map = item as Map<String, dynamic>;
        expect(
          map['timestamp'] as int,
          greaterThanOrEqualTo(RECOMMENDED_FINGERORINT_EVENT_TS_MINIMUM),
        );
      }
    });

    test('解出每个 log 并校验 x 和 y 的合法性', () {
      Map<String, dynamic> decodePackage(
        int encodedX,
        int encodedY,
        int salt,
        int timestamp,
        int keyChar,
        int typeIndex,
      ) {
        final a = encodedX - salt;
        final b = encodedY - salt;

        if (a == 5 * salt && b == -2 * salt) {
          return {
            'x': null,
            'y': null,
            'timestamp': timestamp,
            'keyChar': String.fromCharCode(keyChar),
            'typeIndex': typeIndex,
            'isDefaultPath': true,
          };
        }

        final double x = (5 * a + 2 * b) / 23;
        final double y = (4 * a - 3 * b) / 23;

        const eventRevMap = ['mousemove', 'click', 'keydown', 'wheel', 'touch', 'focus'];

        return {
          'x': double.parse((x * 100).roundToDouble().toStringAsFixed(2)) / 100,
          'y': double.parse((y * 100).roundToDouble().toStringAsFixed(2)) / 100,
          'timestamp': timestamp,
          'key': String.fromCharCode(keyChar),
          'type': (typeIndex >= 0 && typeIndex < eventRevMap.length) ? eventRevMap[typeIndex] : 'unknown',
        };
      }

      final result = getDmImgList(
        minLogCount: 4,
        maxLogCount: 4,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useMouseMoveLog: true,
        useClickLog: true,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      for (final item in list) {
        final result = decodePackage(item['x'], item['y'], item['z'], item['timestamp'], item['k'], item['type']);
        expect(result['x'], greaterThanOrEqualTo(0));
        expect(result['x'], lessThanOrEqualTo(windowWidth));
        expect(result['y'], greaterThanOrEqualTo(0));
        expect(result['y'], lessThanOrEqualTo(windowHeight));
      }
    });

    test('仅 mousemove 时 type 均为 0', () {
      final result = getDmImgList(
        minLogCount: 2,
        maxLogCount: 2,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useMouseMoveLog: true,
        useClickLog: false,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      for (final item in list) {
        expect((item as Map<String, dynamic>)['type'], 0);
      }
    });

    test('仅 click 时 type 均为 1', () {
      final result = getDmImgList(
        minLogCount: 2,
        maxLogCount: 2,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useMouseMoveLog: false,
        useClickLog: true,
        useTargetList: [VideoDetailPageElementList],
      );
      final list = jsonDecode(result.$1) as List<dynamic>;
      for (final item in list) {
        expect((item as Map<String, dynamic>)['type'], 1);
      }
    });

    test('前一个 timestamp 永远比后一个小', () {
      debugPrint('windowWidth: $windowWidth, windowHeight: $windowHeight');

      final result = getDmImgList(
        minLogCount: minLogCount,
        maxLogCount: maxLogCount,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );

      final list = jsonDecode(result.$1) as List<dynamic>;
      debugPrint('list: $list');

      for (int i = 0; i < list.length - 1; i++) {
        expect(
          (list[i] as Map<String, dynamic>)['timestamp'] as int,
          lessThan(
            (list[i + 1] as Map<String, dynamic>)['timestamp'] as int,
          ),
        );
      }
    });

    test('生成 0 个 log', () {
      final result = getDmImgList(
        minLogCount: 0,
        maxLogCount: 0,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );

      debugPrint('result: ${result.$1}');
    });

    test('生成 0~1 个 log', () {
      final result = getDmImgList(
        minLogCount: 0,
        maxLogCount: 1,
        windowWidth: windowWidth,
        windowHeight: windowHeight,
        maxTimestamp: maxTimestamp,
        mouseRangeX: mouseRangeX,
        mouseRangeY: mouseRangeY,
        useTargetList: [VideoDetailPageElementList],
      );

      debugPrint('result: ${result.$1}');
    });
  });

  group('av & bv', () {
    test('av2bv', () {
      expect(av2bv('116120329652133'), 'BV1HNfzBbEkj');
    });

    test('bv2av', () {
      expect(bv2av('BV1HNfzBbEkj'), 116120329652133);
    });
  });

  group('session generate', () {
    test('getMd5SwappedInt32List', () {
      expect(
        getMd5SwappedInt32List('E139E2EE-28DB-70EC-CB71-FC900F54AD7591406infoc1772853273634'),
        [1704887724, 1809468044, 668642004, -1416245157],
      );
      expect(
        getMd5SwappedInt32List('awa'),
        [459223336, -1904390651, 1011643372, 63153846],
      );
      expect(
        getMd5SwappedInt32List('E139E2EE-28DB-70EC-CB71-FC900F54AD7591406infoc1772854251711'),
        [504869567, -1223204997, -1303062132, -414454791],
      );
      expect(
        getMd5SwappedInt32List('E139E2EE-28DB-70EC-CB71-FC900F54AD7591406infoc1772854394377'),
        [-397540929, 1908565343, 982073690, 1266406430],
      );
      expect(
        getMd5SwappedInt32List('E139E2EE-28DB-70EC-CB71-FC900F54AD7591406infoc1772854410391'),
        [-1222535315, 1015712678, 1867329792, 299349963],
      );
      expect(
        getMd5SwappedInt32List('E139E2EE-28DB-70EC-CB71-FC900F54AD7591406infoc1772854427129'),
        [-1367546524, -831686693, 554914198, 1822201133],
      );
    });
  });
}
