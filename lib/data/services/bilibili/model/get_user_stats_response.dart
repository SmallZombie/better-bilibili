class GetUserStatsResponse {
  final int following;
  final int secretFollowing;
  final int fans;
  final int blocked;

  GetUserStatsResponse({
    required this.following,
    required this.secretFollowing,
    required this.fans,
    required this.blocked,
  });

  factory GetUserStatsResponse.fromJson(Map<String, dynamic> json) {
    return GetUserStatsResponse(
      following: json['following'],
      secretFollowing: json['whisper'],
      fans: json['follower'],
      blocked: json['black'],
    );
  }
}
