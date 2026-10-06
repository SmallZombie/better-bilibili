import 'package:better_bilibili/data/repositories/bilibili/audio_repository/audio_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/utils/result.dart';

class AudioRepositoryMoke implements AudioRepository {
  @override
  Future<Result<GetUserAudiosResponse>> getUserAudios({
    required String userId,
    int pn = 1,
    int ps = 42,
    GetUserAudiosOrderEnum order = .releaseTimeDesc,
  }) {
    // TODO: implement getUserAudios
    throw UnimplementedError();
  }
}
