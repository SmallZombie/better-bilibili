import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:flutter/material.dart';

class BiliRecommendController extends ChangeNotifier {
  final List<RecommendVideo> videos;
  final ValueChanged<RecommendVideo>? onPlay;

  BiliRecommendController({required this.videos, this.onPlay});

  int get length => videos.length;

  void play(RecommendVideo video) {}
}
