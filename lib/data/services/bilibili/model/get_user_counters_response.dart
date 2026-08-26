class GetUserCountersResponse {
  final int videoCount;
  final int articleCount;
  final int audioCount;
  final int collectionAndPlaylistCount;

  GetUserCountersResponse({
    required this.videoCount,
    required this.articleCount,
    required this.audioCount,
    required this.collectionAndPlaylistCount,
  });

  factory GetUserCountersResponse.fromJson(Map<String, dynamic> json) {
    return GetUserCountersResponse(
      videoCount: json['video'],
      articleCount: json['article'],
      audioCount: json['audio'],
      collectionAndPlaylistCount: json['season_num'] + json['channel']['master'],
    );
  }
}
