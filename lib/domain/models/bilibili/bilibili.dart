import 'package:better_bilibili/utils/bilibili/bili_util.dart';

enum BiliContentTypeEnum {
  unknown,
  video,
  post,
  article,
  series,
  movie,
  coures,
}

extension BiliContentTypeEnumExtension on BiliContentTypeEnum {
  int get value => switch (this) {
    .unknown => 0,
    .video => 1,
    .post => 11,
    .article => 12,
    .series => 0, // TODO
    .movie => 0,
    .coures => 0,
  };

  String get webLocation => switch (this) {
    .unknown => throw Exception('Unknown content type'),
    .video => WebLocation.videoDetail,
    .post => WebLocation.postDetail,
    .article => WebLocation.articleDetail,
    .series => WebLocation.videoDetail,
    .movie => WebLocation.videoDetail,
    .coures => WebLocation.videoDetail,
  };

  static BiliContentTypeEnum fromNumber(int number) {
    return switch (number) {
      1 => .video,
      11 => .post,
      12 => .article,
      _ => .unknown,
    };
  }
}

class TrackingInfo {
  final String id;
  final String goto;

  const TrackingInfo({required this.id, required this.goto});
}
