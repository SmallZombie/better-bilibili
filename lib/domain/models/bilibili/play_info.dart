import 'package:better_bilibili/data/services/bilibili/model/get_extra_play_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_play_info_response.dart';

class PlayInfo {
  final String id;
  final String session;
  final String videoId;
  final String bvid;
  final String episodeId;
  final Duration duration;
  final List<MediaStream> videoStreams;
  final List<MediaStream> audioStreams;
  final List<Subtitle> subtitles;
  // lastPosition 总是与 lastEpisodeId 一起出现
  final String? lastEpisodeId;
  final Duration lastPosition;
  final List<Chapter> chapters;

  const PlayInfo({
    required this.id,
    required this.session,
    required this.videoId,
    required this.bvid,
    required this.episodeId,
    required this.duration,
    required this.videoStreams,
    required this.audioStreams,
    this.subtitles = const [],
    required this.lastEpisodeId,
    required this.lastPosition,
    this.chapters = const [],
  });

  factory PlayInfo.assembly(GetPlayInfoResponse playInfoResp, GetExtraPlayInfoResponse extraPlayInfoResp) {
    return PlayInfo(
      id: playInfoResp.id,
      session: playInfoResp.session,
      videoId: playInfoResp.videoId,
      bvid: playInfoResp.bvid,
      episodeId: playInfoResp.episodeId,
      duration: playInfoResp.duration,
      videoStreams: playInfoResp.videoTracks,
      audioStreams: playInfoResp.audioTracks,
      subtitles: extraPlayInfoResp.subtitles,
      lastEpisodeId: extraPlayInfoResp.lastEpisodeId,
      lastPosition: extraPlayInfoResp.lastPosition,
      chapters: extraPlayInfoResp.chapters,
    );
  }
}

class MediaStream {
  final int id;
  final List<String> urls;
  final CodecEnum codec;
  final String codecProfile;
  final String mimeType;

  MediaStream({
    required this.id,
    required this.urls,
    required this.codec,
    required this.codecProfile,
    required this.mimeType,
  });

  factory MediaStream.fromJson(Map<String, dynamic> json) {
    final List<String> urls = [json['baseUrl'] as String];
    urls.addAll((json['backupUrl'] as List).cast<String>());

    return MediaStream(
      id: switch (json['id']) {
        // 给Hi-Res 和 DolbyAtmos 提一下 id, 方面后面对质量进行排序
        30251 => 40251,
        30250 => 40250,
        _ => json['id'],
      },
      urls: urls,
      // h.264(7), h.265(12), av1(13)
      codec: switch (json['codecid']) {
        7 => .h264,
        12 => .h265,
        13 => .av1,
        0 => .mp4,
        _ => throw Exception('Unsupported codec: ${json['codecid']}, ${json['codecProfile']}'),
      },
      codecProfile: json['codecs'],
      mimeType: json['mimeType'],
    );
  }

  @override
  String toString() {
    return 'MediaStream(id: $id, urls: ${urls.join(',')}, codec: $codec, codecProfile: $codecProfile, mimeType: $mimeType)';
  }
}

enum CodecEnum {
  h264('H.264'),
  h265('H.265'),
  h266('H.266'),
  av1('AV1'),
  mp4('MP4');

  final String value;
  const CodecEnum(this.value);

  factory CodecEnum.fromString(String str) {
    return CodecEnum.values.firstWhere(
      (e) => e.value == str,
      orElse: () => throw Exception('Unsupported codec: $str'),
    );
  }

  @override
  String toString() => value;
}

class Subtitle {
  final String id;
  final String code;
  final bool isAigc;
  final String url;

  const Subtitle({
    required this.id,
    required this.code,
    required this.isAigc,
    required this.url,
  });

  factory Subtitle.fromJson(Map<String, dynamic> json) {
    return Subtitle(
      id: json['id_str'],
      code: json['lan'],
      isAigc: json['ai_type'] == 1,
      url: 'https:${json['subtitle_url']}',
    );
  }
}

class Chapter {
  final String name;
  final String cover;
  final Duration start;
  final Duration end;

  const Chapter({
    required this.name,
    required this.cover,
    required this.start,
    required this.end,
  });

  factory Chapter.fromJson(Map<String, dynamic> obj) {
    return Chapter(
      name: obj['content'],
      cover: obj['imgUrl'],
      start: Duration(seconds: obj['from']),
      end: Duration(seconds: obj['to']) - Duration(milliseconds: 1),
    );
  }
}
