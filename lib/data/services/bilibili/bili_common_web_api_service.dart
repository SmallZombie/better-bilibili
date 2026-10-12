import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/domain/exceptions/not_logged_in_exception.dart';
import 'package:better_bilibili/domain/models/bilibili/account.dart';
import 'package:better_bilibili/utils/bili/bili_util.dart';
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

  /// 用于动态的图片上传
  Future<Result<UploadedImage>> uploadImageForDynamic({required String filePath}) async {
    assert(filePath.isNotEmpty);

    final account = await _getLoginedAccount();
    final client = await getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/dynamic/feed/draw/upload_bfs',
      options: Options(contentType: 'multipart/form-data'),
      data: FormData.fromMap({
        'file_up': MultipartFile.fromFileSync(filePath),
        'biz': 'new_dyn',
        'category': 'daily',
        'csrf': account.biliJct,
      }),
    );

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(UploadedImage.fromJson(resp.data['data']));
  }

  /// 用于收藏夹的图片上传
  Future<Result<String>> uploadImageForFavorites({required String filePath}) async {
    assert(filePath.isNotEmpty);

    final account = await _getLoginedAccount();
    final client = await getClient();

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

    if (resp.data['code'] != 0) {
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }

    return Result.ok(resp.data['data']['location'] as String);
  }
}
