import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/utils/bili_util.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BiliCommonApiService {
  final AuthRepository _authRepository;
  const BiliCommonApiService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  /// 用于动态的图片上传
  Future<Result<UploadedImage>> uploadImageForDynamic({required String filePath}) async {
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/dynamic/feed/draw/upload_bfs',
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
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
    final account = await _authRepository.getAccount();
    final client = await _authRepository.getClient();

    final resp = await client.post(
      'https://api.bilibili.com/x/upload/web/image',
      options: Options(headers: {'Content-Type': 'multipart/form-data; boundary=${generateBoundaryName2()}'}),
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
