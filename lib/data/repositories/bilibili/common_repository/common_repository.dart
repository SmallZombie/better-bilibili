import 'package:better_bilibili/data/services/bilibili/model/uploaded_image.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class CommonRepository {
  Future<Result<UploadedImage>> uploadImageForDynamic({required String filePath});

  Future<Result<String>> uploadImageForFavorites({required String filePath});
}
