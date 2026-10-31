import 'dart:async';
import 'dart:convert';

import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/interceptors/base_rate_limiter_intercrptor.dart';
import 'package:better_bilibili/data/interceptors/debug_logger_interceptor.dart';
import 'package:better_bilibili/data/interceptors/base_url_fallback_interceptor.dart';
import 'package:better_bilibili/data/model/bsbsb/leaderboard_entry.dart';
import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/model/bsbsb/video.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/data/services/bsbsb/bsbsb_api_service.dart';
import 'package:better_bilibili/data/services/bsbsb/model/get_leaderboard_request.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/duration_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class BsbsbRepositoryRemote implements BsbsbRepository {
  final BsbsbConfig config;
  final AppConfig appConfig;
  late final BsbsbApiService bsbsbApiService = BsbsbApiService(
    getClient: getClient,
    getPrivateId: getPrivateId,
  );

  late final StreamSubscription _subscription;

  BsbsbRepositoryRemote({required this.config, required this.appConfig}) {
    _subscription = config.baseUrls.stream.listen((_) => _disposeClient());
  }

  void dispose() {
    _subscription.cancel();
  }

  void _disposeClient() {
    _client?.close();
    _client = null;
  }

  Dio? _client;

  @override
  Future<Dio> getClient() async {
    if (_client != null) {
      return _client!;
    }

    final baseUrls = config.baseUrls.value.split(',');

    final client = Dio(
      BaseOptions(
        headers: {'origin': appConfig.appPackageName, 'x-ext-version': appConfig.fullVersion},
      ),
    );
    client.interceptors.add(BaseUrlFallbackInterceptor(dio: client, baseUrls: baseUrls));
    client.interceptors.add(BaseRateLimiterInterceptor());

    if (kDebugMode) {
      client.interceptors.add(debugLoggerInterceptor);
    }

    _client = client;

    return client;
  }

  @override
  Future<String> getPrivateId() {
    return config.privateId.get();
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
      case Err(:final error):
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

  @override
  Future<Result<void>> modifyUsername(String username) {
    return bsbsbApiService.modifyUsername(username);
  }

  @override
  Future<Result<List<LeaderboardEntry>>> getLeaderboard({
    GetLeaderboardOrderEnum order = .submitCount,
    GetLeaderboardTypeEnum type = .all,
    int ps = 20,
  }) {
    return bsbsbApiService.getLeaderboard(order: order, type: type, ps: ps);
  }

  @override
  Future<Result<int>> getMyLeaderboardRank(String username, Duration saveTime) async {
    final result = await bsbsbApiService.getLeaderboard();
    switch (result) {
      case Ok(:final value):
        final index = value.indexWhere((v) => v.username == username && v.saveTime.isCloseTo(saveTime));
        return Result.ok(index);
      case Err(:final error):
        return Result.error(error);
    }
  }
}
