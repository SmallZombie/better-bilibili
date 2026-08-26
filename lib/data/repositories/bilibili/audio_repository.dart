import 'package:better_bilibili/data/services/bilibili/bili_audio_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/utils/result.dart';

class AudioRepository {
  final BiliAudioApiService _biliAudioApiService;

  AudioRepository({
    required BiliAudioApiService audioApiService,
  }) : _biliAudioApiService = audioApiService;

  Future<Result<GetUserAudiosResponse>> getUserAudios({
    required String userId,
    int pn = 1,
    // 此处对其网页端默认42
    int ps = 42,
    GetUserAudiosOrderEnum order = .releaseTimeDesc,
  }) async {
    return _biliAudioApiService.getUserAudios(userId: userId, pn: pn, ps: ps, order: order);
  }
}
