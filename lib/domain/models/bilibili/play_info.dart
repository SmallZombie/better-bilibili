class PlayInfo {
  final String id;
  final String session;
  final String videoId;
  final String bvid;
  final String episodeId;
  final Duration duration;
  final List<MediaTrack> videoTracks;
  final List<MediaTrack> audioTracks;

  PlayInfo({
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

class MediaTrack {
  final int id;
  final String url;
  final CodecEnum codec;
  final String codecProfile;
  final String mimeType;

  MediaTrack({
    required this.id,
    required this.url,
    required this.codec,
    required this.codecProfile,
    required this.mimeType,
  });

  factory MediaTrack.fromJson(Map<String, dynamic> json) {
    return MediaTrack(
      id: switch (json['id']) {
        // 给Hi-Res 和 DolbyAtmos 提一下 id, 方面后面对质量进行排序
        30251 => 40251,
        30250 => 40250,
        _ => json['id'],
      },
      url: json['baseUrl'],
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
