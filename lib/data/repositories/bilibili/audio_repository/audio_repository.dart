import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/utils/result.dart';

abstract interface class AudioRepository {
  Future<Result<GetUserAudiosResponse>> getUserAudios({
    required String userId,
    int pn = 1,
    // 此处对其网页端默认42
    int ps = 42,
    GetUserAudiosOrderEnum order = .releaseTimeDesc,
  });
}
