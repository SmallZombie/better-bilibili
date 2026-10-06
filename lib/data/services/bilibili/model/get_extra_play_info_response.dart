import 'package:better_bilibili/domain/models/bilibili/play_info.dart';

class GetExtraPlayInfoResponse {
  final List<Subtitle> subtitles;
  final Duration lastPosition;
  final String? lastEpisodeId;
  final List<Chapter> chapters;

  const GetExtraPlayInfoResponse({
    required this.subtitles,
    required this.lastPosition,
    required this.lastEpisodeId,
    required this.chapters,
  });
}
