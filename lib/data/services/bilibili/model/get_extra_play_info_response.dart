class GetExtraPlayInfoResponse {
  final List<ExtraPlayInfoSubtitle> subtitles;

  const GetExtraPlayInfoResponse({required this.subtitles});
}

class ExtraPlayInfoSubtitle {
  final String id;
  final String code;
  final bool isAigc;
  final String url;

  const ExtraPlayInfoSubtitle({
    required this.id,
    required this.code,
    required this.isAigc,
    required this.url,
  });

  factory ExtraPlayInfoSubtitle.fromJson(Map<String, dynamic> json) {
    return ExtraPlayInfoSubtitle(
      id: json['id_str'],
      code: json['lan'],
      isAigc: json['ai_type'] == 1,
      url: 'https:${json['subtitle_url']}',
    );
  }
}
