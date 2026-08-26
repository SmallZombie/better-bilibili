class GetVideoCardsItem {
  final String videoId;
  final String bvid;
  final String cover;
  final String title;
  final String nickname;
  final int viewCount;
  final int danmakuCount;
  final double duration;

  const GetVideoCardsItem({
    required this.videoId,
    required this.bvid,
    required this.cover,
    required this.title,
    required this.nickname,
    required this.viewCount,
    required this.danmakuCount,
    required this.duration,
  });
}
