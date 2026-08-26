class GetReportOptionsItem {
  final String id;
  final String nameKey;
  final String descripionKey;
  final bool allowInput;
  final String? redirectTo;

  const GetReportOptionsItem({
    required this.id,
    required this.nameKey,
    required this.descripionKey,
    required this.allowInput,
    this.redirectTo,
  });
}
