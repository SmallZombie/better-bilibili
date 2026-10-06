class GetTimelinePreviewResponse {
  final int imageWidth;
  final int imageHeight;
  final int rowCount;
  final int columnCount;
  final List<String> images;
  final String indexFile;

  const GetTimelinePreviewResponse({
    required this.imageWidth,
    required this.imageHeight,
    required this.rowCount,
    required this.columnCount,
    required this.images,
    required this.indexFile,
  });

  factory GetTimelinePreviewResponse.fromJson(Map<String, dynamic> obj) {
    return GetTimelinePreviewResponse(
      imageWidth: obj['data']['img_x_size'],
      imageHeight: obj['data']['img_y_size'],
      rowCount: obj['data']['img_x_len'],
      columnCount: obj['data']['img_y_len'],
      images: (obj['data']['image'] as List).map((v) => 'https:$v').toList(),
      indexFile: 'https:${obj['data']['pvdata']}',
    );
  }
}
