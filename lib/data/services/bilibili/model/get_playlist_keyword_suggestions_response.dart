class PlaylistKeywordSuggestion {
  final String keyword;
  final String videoCount;

  PlaylistKeywordSuggestion({required this.keyword, required this.videoCount});

  factory PlaylistKeywordSuggestion.fromJson(Map<String, dynamic> json) {
    return PlaylistKeywordSuggestion(
      keyword: json['meta']['name'],
      videoCount: json['meta']['total'],
    );
  }
}
