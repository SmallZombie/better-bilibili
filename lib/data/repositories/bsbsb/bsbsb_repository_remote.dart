import 'dart:convert';

import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/data/interceptors/debug_logger_interceptor.dart';
import 'package:better_bilibili/data/interceptors/fallback_base_url_interceptor.dart';
import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/model/bsbsb/video.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/data/services/bsbsb/bsbsb_api_service.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BsbsbRepositoryRemote implements BsbsbRepository {
  final BsbsbConfig config;
  late final BsbsbApiService bsbsbApiService = BsbsbApiService(getClient: getClient);

  BsbsbRepositoryRemote({required this.config});

  Dio? _client;

  @override
  Dio getClient() {
    if (_client != null) {
      return _client!;
    }

    final baseUrlsStr = config.baseUrls.value;
    final baseUrls = baseUrlsStr.split(',');

    final client = Dio(
      BaseOptions(
        baseUrl: baseUrls.first,
        headers: {'origin': kAppId, 'x-ext-version': kAppVersion},
      ),
    );
    client.interceptors.add(FallbackBaseUrlInterceptor(dio: client, baseUrls: baseUrls));

    if (kDebugMode) {
      client.interceptors.add(debugLoggerInterceptor);
    }

    _client = client;

    return client;
  }

  @override
  Future<Result<UserInfo>> getUserInfo([String? publicUserId]) async {
    final privateId = await config.privateId.get();
    return await bsbsbApiService.getUserInfo(publicUserId ?? BsbsbRepository.getPublicId(privateId));
  }

  @override
  /// 返回由 episodeId 到 Segment 列表的 Map
  Future<Result<Map<String, List<Segment>>>> getSegments(String videoId) async {
    final bvid = av2bv(videoId);

    final bytes = utf8.encode(bvid); // data being hashed
    final digest = sha256.convert(bytes);

    final result = await bsbsbApiService.getSegments(digest.toString().substring(0, 4));
    final List<Video> data;
    switch (result) {
      case Ok(:final value):
        data = value;
      case Error(:final error):
        return Result.error(error);
    }

    final video = data.where((v) => v.bvid == bvid).firstOrNull;
    if (video == null) return Result.ok({});

    final Map<String, List<Segment>> segmentsMap = {};
    for (final segment in video.segments) {
      final list = segmentsMap[segment.episodeId] ?? [];
      list.add(segment);
      segmentsMap[segment.episodeId] = list;
    }
    return Result.ok(segmentsMap);
  }
}
