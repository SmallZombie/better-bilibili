import 'package:better_bilibili/data/repositories/bilibili/common_repository/common_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/utils/result.dart';

class CommonRepositoryMock implements CommonRepository {
  @override
  Future<Result<UploadedImage>> uploadImageForDynamic(String filePath) {
    // TODO: implement uploadImageForDynamic
    throw UnimplementedError();
  }

  @override
  Future<Result<String>> uploadImageForFavorites(String filePath) {
    // TODO: implement uploadImageForFavorites
    throw UnimplementedError();
  }
}
