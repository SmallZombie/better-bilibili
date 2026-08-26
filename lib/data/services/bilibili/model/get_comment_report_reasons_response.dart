class ReportReasonItem {
  final int id;
  final String name;
  final bool requiresDescription;

  const ReportReasonItem({
    required this.id,
    required this.name,
    required this.requiresDescription,
  });

  factory ReportReasonItem.fromJson(Map<String, dynamic> obj) {
    return ReportReasonItem(
      id: obj['tag_id'] as int,
      name: obj['tag_name'],
      requiresDescription: obj['content_required'] == true,
    );
  }
}
