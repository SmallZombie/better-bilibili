import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/model/bsbsb/video.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BsbsbApiService {
  final Dio Function() getClient;

  const BsbsbApiService({required this.getClient});

  Future<Result<UserInfo>> getUserInfo(String publicUserId) async {
    final client = getClient();

    final resp = await client.get(
      '/userInfo',
      queryParameters: {
        'publicUserID': publicUserId,
        'values': '["userName","minutesSaved","segmentCount","ignoredSegmentCount","viewCount","ignoredViewCount"]',
      },
    );

    return Result.ok(UserInfo.fromJson(resp.data));
  }

  Future<Result<List<Video>>> getSegments(String bvidHashPrefix) async {
    final client = getClient();
    final resp = await client.get('/skipSegments/$bvidHashPrefix');

    return Result.ok((resp.data as List).map((e) => Video.fromJson(e)).toList());
  }
}
