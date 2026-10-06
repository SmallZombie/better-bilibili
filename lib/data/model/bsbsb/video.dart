import 'package:better_bilibili/data/model/bsbsb/segment.dart';

class Video {
  final String bvid;
  final List<Segment> segments;

  const Video({required this.bvid, required this.segments});

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      bvid: json['videoID'] as String,
      segments: (json['segments'] as List<dynamic>).map((e) {
        return Segment.fromJson(e as Map<String, dynamic>);
      }).toList(),
    );
  }
}
