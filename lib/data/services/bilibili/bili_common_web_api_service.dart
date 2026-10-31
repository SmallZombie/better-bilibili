import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/exceptions/bili_http_exception.dart';
import 'package:better_bilibili/domain/exceptions/not_logged_in_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bilibili/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliCommonWebApiService {
  Future<Dio> Function() getClient;
  Future<Account> Function() getAccount;

  BiliCommonWebApiService({required this.getClient, required this.getAccount});

  Future<LoginedAccount> _getLoginedAccount() async {
    final account = await getAccount();
    if (account is! LoginedAccount) {
      throw const NotLoggedInException();
    }
    return account;
  }

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

  /// 用于动态的图片上传
  Future<Result<UploadedImage>> uploadImageForDynamic(String filePath) async {
    assert(filePath.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/dynamic/feed/draw/upload_bfs',
        data: FormData.fromMap({
          'file_up': MultipartFile.fromFileSync(filePath),
          'biz': 'new_dyn',
          'category': 'daily',
          'csrf': account.biliJct,
        }),
      );

      _checkResponse(resp);

      return Result.ok(UploadedImage.fromJson(resp.data['data']));
    } catch (e) {
      return _handleError(e);
    }
  }

  /// 用于收藏夹的图片上传
  Future<Result<String>> uploadImageForFavorites(String filePath) async {
    assert(filePath.isNotEmpty);

    final client = await getClient();

    try {
      final account = await _getLoginedAccount();
      final resp = await client.post(
        'https://api.bilibili.com/x/upload/web/image',
        options: Options(contentType: 'multipart/form-data; boundary=${generateBoundaryName2()}'),
        data: FormData.fromMap({
          'bucket': 'medialist',
          'dir': 'cover',
          'file': MultipartFile.fromFileSync(filePath),
          'csrf': account.biliJct,
        }),
      );

      _checkResponse(resp);

      return Result.ok(resp.data['data']['location'] as String);
    } catch (e) {
      return _handleError(e);
    }
  }
}
