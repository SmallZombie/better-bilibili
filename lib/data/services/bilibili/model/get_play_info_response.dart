import 'package:better_bilibili/domain/models/bilibili/play_info.dart';

class GetPlayInfoResponse {
  final String id;
  final String session;
  final String videoId;
  final String bvid;
  final String episodeId;
  final Duration duration;
  final List<MediaTrack> videoTracks;
  final List<MediaTrack> audioTracks;

  GetPlayInfoResponse({
    required this.id,
    required this.session,
    required this.videoId,
    required this.bvid,
    required this.episodeId,
    required this.duration,
    required this.videoTracks,
    required this.audioTracks,
  });
}
