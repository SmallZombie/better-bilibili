class UserInfo {
  /// 如果未设置，则为 PublicId
  final String userName;

  /// 为所有人节省的分钟数
  final Duration minutesSaved;

  /// 总段数，不包括被忽略/隐藏的段
  final int segmentCount;

  /// 被忽略/隐藏的段总数
  final int ignoredSegmentCount;

  /// 总浏览量，不包括被忽略/隐藏段的浏览量
  final int viewCount;

  /// 被忽略/隐藏段的总浏览量
  final int ignoredViewCount;

  const UserInfo({
    required this.userName,
    required this.minutesSaved,
    required this.segmentCount,
    required this.ignoredSegmentCount,
    required this.viewCount,
    required this.ignoredViewCount,
  });

  UserInfo copyWith({
    String? userName,
    Duration? minutesSaved,
    int? segmentCount,
    int? ignoredSegmentCount,
    int? viewCount,
    int? ignoredViewCount,
  }) {
    return UserInfo(
      userName: userName ?? this.userName,
      minutesSaved: minutesSaved ?? this.minutesSaved,
      segmentCount: segmentCount ?? this.segmentCount,
      ignoredSegmentCount: ignoredSegmentCount ?? this.ignoredSegmentCount,
      viewCount: viewCount ?? this.viewCount,
      ignoredViewCount: ignoredViewCount ?? this.ignoredViewCount,
    );
  }

  factory UserInfo.fromJson(Map<String, dynamic> obj) {
    return UserInfo(
      userName: obj['userName'],
      minutesSaved: Duration(
        milliseconds: (obj['minutesSaved'] * Duration.millisecondsPerMinute).round(),
      ),
      segmentCount: obj['segmentCount'],
      ignoredSegmentCount: obj['ignoredSegmentCount'],
      viewCount: obj['viewCount'],
      ignoredViewCount: obj['ignoredViewCount'],
    );
  }
}
