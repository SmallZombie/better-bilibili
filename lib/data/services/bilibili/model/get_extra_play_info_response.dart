import 'package:better_bilibili/domain/models/bilibili/play_info.dart';

class GetExtraPlayInfoResponse {
  final List<Subtitle> subtitles;
  final Duration lastPosition;
  final String? lastEpisodeId;
  final List<Chapter> chapters;
  final String? maskUrl;

  const GetExtraPlayInfoResponse({
    required this.subtitles,
    required this.lastPosition,
    required this.lastEpisodeId,
    required this.chapters,
    this.maskUrl,
  });
}
