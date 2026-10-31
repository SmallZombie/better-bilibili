import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_articles_with_user_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_subscribed_series_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_collections_and_playlists_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_pinned_videos_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_profile_settings_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_videos_with_user_id_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserDetailHomeViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final VideoRepository _videoRepository;
  final ArticleRepository _articleRepository;

  final String userId;

  UserDetailHomeViewModel({
    required UserRepository userRepository,
    required VideoRepository videoRepository,
    required ArticleRepository articleRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _videoRepository = videoRepository,
       _articleRepository = articleRepository {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0 loadData;

  GetUserProfileSettingsResponse? _profileSettings;
  final List<PinnedVideo> _pinnedVideos = [];
  final List<VideoItem> _videos = [];
  final List<GetArticlesWithUserItem> _articles = [];
  final List<GetUserCollectionsAndPlaylistsItem> _playlists = [];
  final List<FavoriteFolder> _favoritesList = [];
  final List<SubscribedSeries> _series = [];
  final List<dynamic> _likedVideos = [];
  final List<dynamic> _coindVideos = [];
  GetUserProfileSettingsResponse? get profileSettings => _profileSettings;
  List<PinnedVideo> get pinnedVideos => List.unmodifiable(_pinnedVideos);
  List<VideoItem> get videos => List.unmodifiable(_videos);
  List<GetArticlesWithUserItem> get articles => List.unmodifiable(_articles);
  List<GetUserCollectionsAndPlaylistsItem> get playlists => List.unmodifiable(_playlists);
  List<FavoriteFolder> get favoritesList => List.unmodifiable(_favoritesList);
  List<SubscribedSeries> get series => List.unmodifiable(_series);
  List<dynamic> get likedVideos => List.unmodifiable(_likedVideos);
  List<dynamic> get coindVideos => List.unmodifiable(_coindVideos);

  Future<Result<void>> _loadData() async {
    final [
      settingResult as Result<GetUserProfileSettingsResponse>,
      _,
      _,
      _,
      _,
    ] = await Future.wait([
      _userRepository.getUserProfileSettings(userId),
      _loadPinnedVideos(),
      _loadVideos(),
      _loadArticles(),
      _loadPlaylists(),
    ]);
    switch (settingResult) {
      case Ok(:final value):
        _profileSettings = value;
      case Err():
        return settingResult;
    }

    final List<Future> futures = [];
    if (_profileSettings!.privacySetting.favorites) {
      futures.add(_loadFavorites());
    }
    if (_profileSettings!.privacySetting.subscribedMovie) {
      futures.add(_loadSubscribedSeries());
    }
    if (_profileSettings!.privacySetting.subscribedManga) {
      futures.add(_loadSubscribedManga());
    }
    if (_profileSettings!.privacySetting.likedVideo) {
      futures.add(_loadRecentlyLiked());
    }
    if (_profileSettings!.privacySetting.coinedVideo) {
      futures.add(_loadRecentlyCoind());
    }
    if (_profileSettings!.privacySetting.playedGame) {
      futures.add(_loadRecentlyPlay());
    }

    await Future.wait(futures);
    return Result.ok(null);
  }

  Future<void> _loadPinnedVideos() async {
    final result = await _userRepository.getUserPinnedVideos(userId);
    switch (result) {
      case Ok(:final value):
        _pinnedVideos.clear();
        _pinnedVideos.addAll(value);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadVideos() async {
    final result = await _videoRepository.getVideosWithUser(userId: userId);
    switch (result) {
      case Ok(:final value):
        _videos.clear();
        _videos.addAll(value.list);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadArticles() async {
    final result = await _articleRepository.getArticlesWithUser(userId: userId);
    switch (result) {
      case Ok(:final value):
        _articles.clear();
        _articles.addAll(value.list);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadPlaylists() async {
    final result = await _videoRepository.getUserCollectionsAndPlaylists(userId: userId);
    switch (result) {
      case Ok(:final value):
        _playlists.clear();
        _playlists.addAll(value.list);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadFavorites() async {
    final result = await _userRepository.getFavoritesList(userId: userId);
    switch (result) {
      case Ok(:final value):
        _favoritesList.clear();
        _favoritesList.addAll(value.list);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadSubscribedSeries() async {
    final result = await _userRepository.getSubscribedSeries(userId: userId);
    switch (result) {
      case Ok(:final value):
        _series.clear();
        _series.addAll(value.list);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadSubscribedManga() async {}

  Future<void> _loadRecentlyLiked() async {
    final result = await _userRepository.getLikedVideos(userId);
    switch (result) {
      case Ok(:final value):
        _likedVideos.clear();
        _likedVideos.addAll(value);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadRecentlyCoind() async {
    final result = await _userRepository.getCoinedVideos(userId);
    switch (result) {
      case Ok(:final value):
        _coindVideos.clear();
        _coindVideos.addAll(value);
      case Err(:final error):
        throw error;
    }
  }

  Future<void> _loadRecentlyPlay() async {}
}
