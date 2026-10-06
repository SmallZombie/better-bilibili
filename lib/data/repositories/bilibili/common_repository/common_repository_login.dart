import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/common_repository/common_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_common_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/utils/result.dart';

class CommonRepositoryLogin implements CommonRepository {
  final AuthRepository authRepository;
  late final BiliCommonWebApiService commonApiService = BiliCommonWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );

  CommonRepositoryLogin({required this.authRepository});

  @override
  Future<Result<UploadedImage>> uploadImageForDynamic({required String filePath}) {
    return commonApiService.uploadImageForDynamic(filePath: filePath);
  }

  @override
  Future<Result<String>> uploadImageForFavorites({required String filePath}) {
    return commonApiService.uploadImageForFavorites(filePath: filePath);
  }
}
