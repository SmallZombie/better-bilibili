class GetUserTotalLikeAndViewCountResponse {
  final int likeCount;
  final int viewCount;

  GetUserTotalLikeAndViewCountResponse({required this.likeCount, required this.viewCount});

  factory GetUserTotalLikeAndViewCountResponse.fromJson(Map<String, dynamic> json) {
    return GetUserTotalLikeAndViewCountResponse(
      likeCount: json['likes'],
      viewCount: json['archive']['view'] + json['article']['view'],
    );
  }
}
