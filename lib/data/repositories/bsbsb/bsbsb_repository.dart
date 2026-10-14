import 'dart:convert';

import 'package:better_bilibili/data/model/bsbsb/leaderboard_entry.dart';
import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/services/bsbsb/model/get_leaderboard_request.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

abstract interface class BsbsbRepository {
  static String getPublicId(String privateId) {
    String str = privateId;
    for (var i = 0; i < 5000; i++) {
      str = sha256.convert(utf8.encode(str)).toString();
    }
    return str;
  }

  Dio getClient();
  Future<String> getPrivateId();

  Future<Result<UserInfo>> getUserInfo([String? publicUserId]);
  Future<Result<Map<String, List<Segment>>>> getSegments(String videoId);
  Future<Result<void>> modifyUsername(String username);
  Future<Result<List<LeaderboardEntry>>> getLeaderboard({
    GetLeaderboardOrderEnum order = .submitCount,
    GetLeaderboardTypeEnum type = .all,
    int ps = 20,
  });

  /// 通过用户名和总节省时间尝试从排行榜上找到自身排名，未找到则为 -1
  Future<Result<int>> getMyLeaderboardRank(String username, Duration saveTime);
}
