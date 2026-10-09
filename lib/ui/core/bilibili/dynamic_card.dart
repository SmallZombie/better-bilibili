import 'package:better_bilibili/data/services/bilibili/model/get_favorites_detail_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_liked_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_history.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_later.dart';
import 'package:better_bilibili/data/services/bilibili/model/search_response.dart';
import 'package:better_bilibili/ui/core/bilibili/article/article_card.dart';
import 'package:better_bilibili/ui/core/bilibili/bili_theme.dart';
import 'package:better_bilibili/ui/core/bilibili/course/course_card.dart';
import 'package:better_bilibili/ui/core/bilibili/live/live_room_card.dart';
import 'package:better_bilibili/ui/core/bilibili/movie/movie_card.dart';
import 'package:better_bilibili/ui/core/bilibili/series/series_card.dart';
import 'package:better_bilibili/ui/core/bilibili/unsupported_card.dart';
import 'package:better_bilibili/ui/core/bilibili/video/video_card.dart';
import 'package:flutter/material.dart';

/// 根据传入的数据类型动态决定要展示的卡片类型
class DynamicCard extends StatelessWidget {
  final dynamic data;
  final CardStyle? style;
  final List<PopupMenuEntry<String>> contextActions;
  final VoidCallback? onTap;

  const DynamicCard({
    super.key,
    required this.data,
    this.style,
    this.contextActions = const [],
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (data case WatchHistoryVideo()) {
      final video = data as WatchHistoryVideo;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        user: video.owner,
        duration: video.duration,
        watchTime: video.watchTime,
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case WatchHistoryLive()) {
      final live = data as WatchHistoryLive;
      return LiveRoomCard(
        liveId: live.id,
        cover: live.cover,
        title: live.title,
        user: live.owner,
        badge: '直播',
        watchTime: live.watchTime,
      );
    } else if (data case WatchHistoryArticle()) {
      final article = data as WatchHistoryArticle;
      return ArticleCard(
        articleId: article.id,
        title: article.title,
        cover: article.covers.first,
        nickname: article.owner.nickname,
        watchTime: article.watchTime,
        badge: '文章',
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case WatchHistoryMovie()) {
      final movie = data as WatchHistoryMovie;
      return MovieCard(
        movieId: movie.id,
        title: movie.title,
        cover: movie.cover,
        duration: movie.duration,
        watchTime: movie.watchTime,
        badge: '番剧',
        contextActions: contextActions,
        onTap: onTap,
      );
    }
    // else if (data case WatchHistoryAnthology()) {
    //   final anthology = data as WatchHistoryAnthology;
    //   return AnthologyCard(
    //     anthologyId: anthology.id,
    //     name: anthology.title,
    //     cover: anthology.covers.first,
    //     nickname: anthology.owner.nickname,
    //     watchTime: anthology.watchTime,
    //     badge: '文集',
    //   );
    // }

    if (data case WatchLaterVideo()) {
      final video = data as WatchLaterVideo;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        user: video.owner,
        duration: video.duration,
        watchLaterTime: video.watchLaterTime,
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case WatchLaterMovie()) {
      final movie = data as WatchLaterMovie;
      return MovieCard(
        movieId: movie.id,
        title: movie.title,
        cover: movie.cover,
        duration: movie.duration,
        watchLaterTime: movie.watchLaterTime,
        badge: '番剧',
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case WatchHistoryCourse()) {
      final course = data as WatchHistoryCourse;
      return CourseCard(
        courseId: course.id,
        title: course.title,
        cover: course.cover,
        duration: course.duration,
        badge: '课程',
      );
    }

    if (data case FavoritesVideo()) {
      final video = data as FavoritesVideo;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        user: video.owner,
        duration: video.duration,
        favoriteTime: video.favoriteTime,
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case FavoritesMovie()) {
      final movie = data as FavoritesMovie;
      return MovieCard(
        movieId: movie.id,
        title: movie.title,
        cover: movie.cover,
        duration: movie.duration,
        favoriteTime: movie.favoriteTime,
        badge: '番剧',
        contextActions: contextActions,
        onTap: onTap,
      );
    }

    if (data case SearchResultVideo()) {
      final video = data as SearchResultVideo;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        user: video.owner,
        duration: video.duration,
        uploadTime: video.releaseTime,
        viewCount: video.stats.view,
        danmakuCount: video.stats.danmaku,
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case SearchResultLive()) {
      final live = data as SearchResultLive;
      return LiveRoomCard(
        liveId: live.id,
        cover: live.cover,
        title: live.title,
        user: live.owner,
        badge: '直播',
      );
    } else if (data case SearchResultArticle()) {
      final article = data as SearchResultArticle;
      return ArticleCard(
        articleId: article.id,
        title: article.title,
        cover: article.covers.first,
        nickname: article.owner.nickname,
        releaseTime: article.releaseTime,
        badge: '文章',
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case SearchResultMovie()) {
      final movie = data as SearchResultMovie;
      return MovieCard(
        movieId: movie.id,
        title: movie.title,
        cover: movie.cover,
        badge: '番剧',
        contextActions: contextActions,
        onTap: onTap,
      );
    }

    if (data case SearchResultUserVideos()) {
      final video = data as SearchResultUserVideos;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        duration: video.duration,
        uploadTime: video.releaseTime,
        viewCount: video.viewCount,
        danmakuCount: video.danmakuCount,
        contextActions: contextActions,
        onTap: onTap,
      );
    }

    if (data case LikedVideo()) {
      final video = data as LikedVideo;
      return VideoCard(
        videoId: video.id,
        title: video.title,
        cover: video.cover,
        duration: video.duration,
        user: video.owner,
        viewCount: video.stats.view,
        danmakuCount: video.stats.danmaku,
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case LikedMovie()) {
      final movie = data as LikedMovie;
      return MovieCard(
        movieId: movie.episodeId,
        title: movie.title,
        cover: movie.cover,
        badge: '电影',
        contextActions: contextActions,
        onTap: onTap,
      );
    } else if (data case LikedSeries()) {
      final series = data as LikedSeries;
      return SeriesCard(
        seriesId: series.episodeId,
        title: series.title,
        cover: series.cover,
        badge: '剧集',
      );
    }

    return UnsupportedCard(title: data.runtimeType.toString());
  }
}
