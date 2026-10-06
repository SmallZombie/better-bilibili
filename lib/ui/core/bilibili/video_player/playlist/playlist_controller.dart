import 'package:flutter/material.dart';

/// 负责告诉播放器是否存在上一个或下一个，并提供他们的简单信息用于显示可能的预览
abstract interface class PlaylistController implements Listenable {
  bool get hasPrevious;
  bool get hasNext;
  PlaylistItemMetadata? get previousMetadata;
  PlaylistItemMetadata? get nextMetadata;
  void next();
  void previous();
}

class PlaylistItemMetadata {
  final String title;
  final String cover;

  const PlaylistItemMetadata({required this.title, required this.cover});
}
