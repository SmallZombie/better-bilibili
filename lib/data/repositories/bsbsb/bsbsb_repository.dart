import 'dart:convert';

import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
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

  Future<Result<UserInfo>> getUserInfo([String? publicUserId]);

  Future<Result<Map<String, List<Segment>>>> getSegments(String videoId);
}
