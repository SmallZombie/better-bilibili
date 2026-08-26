import 'package:better_bilibili/data/services/bilibili/bili_common_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/utils/result.dart';

class CommonRepository {
  final BiliCommonApiService _biliCommonApiService;

  CommonRepository({
    required BiliCommonApiService biliCommonApiService,
  }) : _biliCommonApiService = biliCommonApiService;

  Future<Result<UploadedImage>> uploadImageForDynamic({required String filePath}) async {
    return _biliCommonApiService.uploadImageForDynamic(filePath: filePath);
  }

  Future<Result<String>> uploadImageForFavorites({required String filePath}) async {
    return _biliCommonApiService.uploadImageForFavorites(filePath: filePath);
  }
}
