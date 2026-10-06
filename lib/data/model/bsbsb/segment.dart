class Segment {
  final String id;
  final String episodeId;
  final SegmentCategoryEnum category;
  final String actionType;
  final Duration start;
  final Duration end;
  final Duration videoDuration;
  final bool locked;
  final int votes;
  final String description;

  const Segment({
    required this.id,
    required this.episodeId,
    required this.category,
    required this.actionType,
    required this.start,
    required this.end,
    required this.videoDuration,
    required this.locked,
    required this.votes,
    required this.description,
  });

  factory Segment.fromJson(Map<String, dynamic> json) {
    return Segment(
      id: json['UUID'] as String,
      episodeId: json['cid'] as String,
      category: SegmentCategoryEnum.fromString(json['category'] as String),
      actionType: json['actionType'] as String,
      // 返回的是 double 秒
      start: Duration(milliseconds: (json['segment'][0] * 1000).toInt()),
      end: Duration(milliseconds: (json['segment'][1] * 1000).toInt()),
      videoDuration: Duration(milliseconds: (json['videoDuration'] * 1000).toInt()),
      locked: json['locked'] == 1,
      votes: json['votes'] as int,
      description: json['description'] as String,
    );
  }
}

enum SegmentCategoryEnum {
  sponsor,
  selfpromo,
  exclusiveAccess,
  interaction,
  pointsOfInterest,
  intro,
  outro,
  preview,
  padding,
  filler,
  musicOfftopic;

  String stringOf() => switch (this) {
    .sponsor => 'sponsor',
    .selfpromo => 'selfpromo',
    .exclusiveAccess => 'exclusive_access',
    .interaction => 'interaction',
    .pointsOfInterest => 'poi_highlight',
    .intro => 'intro',
    .outro => 'outro',
    .preview => 'preview',
    .padding => 'padding',
    .filler => 'filler',
    .musicOfftopic => 'music_offtopic',
  };

  static SegmentCategoryEnum fromString(String value) => switch (value) {
    'sponsor' => .sponsor,
    'selfpromo' => .selfpromo,
    'exclusive_access' => .exclusiveAccess,
    'interaction' => .interaction,
    'poi_highlight' => .pointsOfInterest,
    'intro' => .intro,
    'outro' => .outro,
    'preview' => .preview,
    'padding' => .padding,
    'filler' => .filler,
    'music_offtopic' => .musicOfftopic,
    _ => throw Exception('Invaild SegmentCategoryEnum value: $value'),
  };
}
