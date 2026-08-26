abstract final class Routes {
  static const home = '/';
  static const homeMovie = '/home/movie';
  static const homeSeries = '/home/series';
  static const homeLive = '/home/live';
  static const homeArticle = '/home/article';
  static const homeMusic = '/home/music';
  static const homeBook = '/home/book';
  static const homeCourse = '/home/course';
  static const homeGame = '/home/game';
  static const homeShop = '/home/shop';

  static const homePost = '/home/post';

  static const homeChat = '/home/chat';

  static const homeMe = '/home/me';

  static const search = '/search';

  static const userDetail = '/user/:userId';
  static const userFollowings = '/user/:userId/followings';
  static const userMutualFollowings = '/user/:userId/mutual_followings';
  static const userFans = '/user/:userId/fans';
  static const userRecentlyLiked = '/user/:userId/recently_liked';
  static const userRecentlyCoined = '/user/:userId/recently_coined';
  static const userSubscriptions = '/user/:userId/subscriptions';

  static const login = '/login';
  static const videoDetail = '/video/:videoId';
  static const watchHistory = '/watch_history';
  static const watchLater = '/watch_later';
  static const favorites = '/favorites';
  static const searchFavorites = '/search_favorites';
  static const favoritesDetail = '/favorites/:favoritesId';
  static const playlistDetail = '/playlist/:playlistId';
  static const webView = '/web_view';
  static const articleDetail = '/article/:articleId';
  static const postDetail = '/post/:postId';

  static const setting = '/setting';
  static const settingAccountManager = '/setting/account_manager';
  static const settingNotification = '/setting/notification';
  static const settingDeveloper = '/setting/developer';
  static const settingDevTestUsers = '/setting/developer/test_users';
  static const settingDevTestVideos = '/setting/developer/test_videos';
  static const settingDevTestArticles = '/setting/developer/test_articles';
  static const settingDevTestPosts = '/setting/developer/test_posts';
  static const settingDevTestAppTitleBar = '/setting/developer/test_app_title_bar';

  static const echoCave = '/echo_cave';

  static String buildUserDetail(String userId, {int? initTabIndex}) {
    final Map<String, dynamic> params = {};
    if (initTabIndex != null) {
      params['initTabIndex'] = initTabIndex;
    }

    final uri = Uri(
      path: userDetail.replaceAll(':userId', userId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildSearchFavorites(String favoritesId) {
    return '/search_favorites?favoritesId=$favoritesId';
  }

  static String buildFavoritesDetail(String favoritesId) {
    return favoritesDetail.replaceAll(':favoritesId', favoritesId);
  }

  static String buildPlaylistDetail(String playlistId) {
    return playlistDetail.replaceAll(':playlistId', playlistId);
  }

  static String buildVideoDetail({
    required String videoId,
    String? episodeId,
    String? initCover,
    String? playlistId,
  }) {
    final Map<String, dynamic> params = {};
    if (initCover != null) {
      params['initCover'] = initCover;
    }
    if (episodeId != null) {
      params['episodeId'] = episodeId;
    }
    if (playlistId != null) {
      params['playlistId'] = playlistId;
    }

    final uri = Uri(
      path: videoDetail.replaceAll(':videoId', videoId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildWebView(String url) {
    final uri = Uri(
      path: webView,
      queryParameters: {'url': url},
    );
    return uri.toString();
  }

  static String buildSearch(String keyword) {
    final uri = Uri(
      path: search,
      queryParameters: {'keyword': keyword},
    );
    return uri.toString();
  }

  static String buildArticleDetail(String articleId, {String? initCover}) {
    final Map<String, dynamic> params = {};
    if (initCover != null) {
      params['initCover'] = initCover;
    }

    final uri = Uri(
      path: articleDetail.replaceAll(':articleId', articleId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildPostDetail(String postId, {String? initCover}) {
    final Map<String, dynamic> params = {};
    if (initCover != null) {
      params['initCover'] = initCover;
    }

    final uri = Uri(
      path: postDetail.replaceAll(':postId', postId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildUserFollowings(String userId) {
    return userFollowings.replaceAll(':userId', userId);
  }

  static String buildUserMutualFollowings(String userId) {
    return userMutualFollowings.replaceAll(':userId', userId);
  }

  static String buildUserFans(String userId) {
    return userFans.replaceAll(':userId', userId);
  }

  static String buildUserRecentlyLiked(String userId, {String? nickname}) {
    final Map<String, dynamic> params = {};
    if (nickname != null) {
      params['nickname'] = nickname;
    }

    final uri = Uri(
      path: userRecentlyLiked.replaceAll(':userId', userId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildUserRecentlyCoined(String userId, {String? nickname}) {
    final Map<String, dynamic> params = {};
    if (nickname != null) {
      params['nickname'] = nickname;
    }

    final uri = Uri(
      path: userRecentlyCoined.replaceAll(':userId', userId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildUserSubscriptions(String userId, {int? initTabIndex}) {
    final Map<String, dynamic> params = {};
    if (initTabIndex != null) {
      params['initTabIndex'] = initTabIndex;
    }

    final uri = Uri(
      path: userSubscriptions.replaceAll(':userId', userId),
      queryParameters: params,
    );
    return uri.toString();
  }

  static String buildConversationDetail(String conversationId) {
    return '$homeChat?conversationId=$conversationId';
  }
}
