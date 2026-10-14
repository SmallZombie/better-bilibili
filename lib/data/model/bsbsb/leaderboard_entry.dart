class LeaderboardEntry {
  final String username;
  final int submitCount;
  final Duration saveTime;
  final int likeCount;
  final int skipCount;
  final int bindvideoSourceCount;

  const LeaderboardEntry({
    required this.username,
    required this.submitCount,
    required this.saveTime,
    required this.likeCount,
    required this.skipCount,
    required this.bindvideoSourceCount,
  });
}
