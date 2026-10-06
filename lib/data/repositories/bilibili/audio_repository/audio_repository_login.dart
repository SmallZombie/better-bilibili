import 'package:better_bilibili/data/repositories/bilibili/audio_repository/audio_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/services/bilibili/bili_audio_web_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_audios_response.dart';
import 'package:better_bilibili/utils/result.dart';

class AudioRepositoryLogin implements AudioRepository {
  final AuthRepository authRepository;
  late final BiliAudioWebApiService audioApiService = BiliAudioWebApiService(
    getClient: () => authRepository.getClient(type: .web),
    getAccount: authRepository.getAccount,
  );

  AudioRepositoryLogin({required this.authRepository});

  @override
  Future<Result<GetUserAudiosResponse>> getUserAudios({
    required String userId,
    int pn = 1,
    int ps = 42,
    GetUserAudiosOrderEnum order = .releaseTimeDesc,
  }) {
    return audioApiService.getUserAudios(userId: userId, pn: pn, ps: ps, order: order);
  }
}
