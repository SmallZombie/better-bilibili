import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliAudioWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliAudioWebApiService({required this.getClient, required this.getAccount});

  void _checkResponse(Response resp) {
    if (resp.data['code'] != 0) {
      throw BiliHttpException(resp.data['code'], resp.data['message']);
    }
  }

  Result<T> _handleError<T>(Object error) {
    if (error is DioException) {
      final resp = error.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${error.message}'));
      }
      return Result.error(Exception('${resp.statusCode}: ${resp.data}'));
    } else if (error is Exception) {
      return Result.error(error);
    } else if (error is Error) {
      assert(false, 'Something went wrong');
      return Result.error(Exception(error.toString()));
    } else {
      assert(false, 'What did you throw?');
      return Result.error(Exception('Unknown error'));
    }
  }

  /// 获取用户发布的音频
  ///
  /// 使用 pn+ps+total 分页
  Future<Result<GetUserAudiosResponse>> getUserAudios({
    required String userId,
    int pn = 1,
    // 此处对其网页端默认42
    int ps = 42,
    GetUserAudiosOrderEnum order = .releaseTimeDesc,
  }) async {
    assert(userId.isNotEmpty);
    assert(pn > 0 && ps > 0);

    final client = await getClient();

    try {
      final resp = await client.get(
        'https://api.bilibili.com/audio/music-service/web/song/upper',
        queryParameters: {
          'pn': pn,
          'ps': ps,
          'order': order.value,
          'uid': userId,
          'web_location': WebLocation.userSpace,
        },
      );

      _checkResponse(resp);

      return Result.ok(
        GetUserAudiosResponse(
          list: (resp.data['data']['data'] as List).map((v) => GetUserAudiosItem.fromJson(v)).toList(),
          total: resp.data['data']['totalSize'] as int,
        ),
      );
    } catch (e) {
      return _handleError(e);
    }
  }
}
