class GetUserRelationResponse {
  final bool isFans;
  final bool imFans;

  GetUserRelationResponse({
    required this.isFans,
    required this.imFans,
  });

  factory GetUserRelationResponse.fromJson(Map<String, dynamic> json) {
    return GetUserRelationResponse(
      isFans: json['be_relation']['attribute'] == 2,
      imFans: json['relation']['attribute'] == 2,
    );
  }
}
