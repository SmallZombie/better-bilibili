import 'dart:math';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_history.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_later.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logger/logger.dart';

class MeViewModel extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'MeViewModel'));

  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  MeViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _authRepository = authRepository,
       _userRepository = userRepository {
    getHeaderData = Command0(_getHeaderData);
    getContentData = Command0(_getContentData);

    if (_authRepository.hasLogin) {
      getHeaderData.execute();
      getContentData.execute();
    }

    _authRepository.addListener(_onAuthRepositoryChanged);
  }

  @override
  void dispose() {
    _authRepository.removeListener(_onAuthRepositoryChanged);

    super.dispose();
  }

  bool get hasLogin => _authRepository.hasLogin;

  String getRandomLogoutText() {
    final texts = [
      '未登录',
      '角色未解锁',
      '干员未解锁',
      'Nya~',
    ];
    return texts[Random().nextInt(texts.length)];
  }

  void _onAuthRepositoryChanged() {
    if (_authRepository.hasLogin) {
      getHeaderData.execute();
      getContentData.execute();
    } else {
      _headerData = null;
      _contentData = null;
      notifyListeners();
    }
  }

  HeaderData? _headerData;
  HeaderData? get headerData => _headerData;

  late final Command0<HeaderData> getHeaderData;
  Future<Result<HeaderData>> _getHeaderData() async {
    assert(_authRepository.hasLogin);

    final account = await _authRepository.getAccount();
    final userId = account.userId;

    var [
      cachedNickname,
      cachedAvatar,
      cachedAvatarFrame,
      cachedBanner,
      cachedLevel,
      cachedVipIcon,
      cachedBCoinCount,
      cachedCoinCount,
      cachedDynamicCount,
      cachedFollowCount,
      cachedFansCount,
    ] = await Future.wait<String?>([
      _userRepository.getLocalUserData(userId, 'nickname'),
      _userRepository.getLocalUserData(userId, 'avatar'),
      _userRepository.getLocalUserData(userId, 'avatarFrame'),
      _userRepository.getLocalUserData(userId, 'banner'),
      _userRepository.getLocalUserData(userId, 'level'),
      _userRepository.getLocalUserData(userId, 'vipIcon'),
      _userRepository.getLocalUserData(userId, 'bcoinCount'),
      _userRepository.getLocalUserData(userId, 'coinCount'),
      _userRepository.getLocalUserData(userId, 'dynamicCount'),
      _userRepository.getLocalUserData(userId, 'followCount'),
      _userRepository.getLocalUserData(userId, 'fansCount'),
    ]);

    try {
      if ([
        cachedNickname,
        cachedAvatar,
        cachedBanner,
        cachedLevel,
        cachedVipIcon,
        cachedBCoinCount,
        cachedCoinCount,
        cachedDynamicCount,
        cachedFollowCount,
        cachedFansCount,
      ].every((e) => e != null)) {
        final level = int.parse(cachedLevel!);
        final coinCount = double.parse(cachedCoinCount!);
        final bcoinCount = double.parse(cachedBCoinCount!);
        final dynamicCount = int.parse(cachedDynamicCount!);
        final followCount = int.parse(cachedFollowCount!);
        final fansCount = int.parse(cachedFansCount!);

        _log.i('Load headerData from cache. uid=$userId');
        _headerData = HeaderData(
          id: userId,
          nickname: cachedNickname!,
          avatar: cachedAvatar!,
          avatarFrame: cachedAvatarFrame,
          level: SelfLevel(currentLevel: level, currentXp: 0, maxXp: 0),
          vip: UserVip(type: UserVipType.normal, expiredAt: 0, labelImage: cachedVipIcon!),
          wallet: UserWallet(coin: coinCount, bcoin: bcoinCount),
          banner: cachedBanner!,
          dynamicNum: dynamicCount,
          followNum: followCount,
          fansNum: fansCount,
        );
        notifyListeners();
      }
    } catch (_) {}

    final [
      selfInfoResult as Result<GetSelfInfoResponse>,
      userInfoResult as Result<GetUserInfoResponse>,
      selfStatsResult as Result<GetSelfStatsResponse>,
    ] = await Future.wait([
      _userRepository.getSelfInfo(),
      _userRepository.getUserInfo(userId),
      _userRepository.getSelfStats(),
    ]);

    if (selfInfoResult case Error()) {
      return Result.error(selfInfoResult.error);
    }
    if (userInfoResult case Error()) {
      return Result.error(userInfoResult.error);
    }
    if (selfStatsResult case Error()) {
      return Result.error(selfStatsResult.error);
    }

    selfInfoResult as Ok<GetSelfInfoResponse>;
    userInfoResult as Ok<GetUserInfoResponse>;
    selfStatsResult as Ok<GetSelfStatsResponse>;

    final selfInfo = selfInfoResult.value as GetSelfInfoLogginResponse;

    await _userRepository.setLocalUserData(userId, 'nickname', selfInfo.nickname);
    await _userRepository.setLocalUserData(userId, 'avatar', selfInfo.avatar);

    if (selfInfo.avatarFrame != null) {
      await _userRepository.setLocalUserData(userId, 'avatarFrame', selfInfo.avatarFrame!);
    } else {
      await _userRepository.removeLocalUserData(userId, 'avatarFrame');
    }

    await Future.wait([
      _userRepository.setLocalUserData(userId, 'banner', userInfoResult.value.banner),
      _userRepository.setLocalUserData(userId, 'level', selfInfo.level.currentLevel.toString()),
      _userRepository.setLocalUserData(userId, 'vipIcon', selfInfo.vip.labelImage),
      _userRepository.setLocalUserData(userId, 'bcoinNum', selfInfo.wallet.bcoin.toString()),
      _userRepository.setLocalUserData(userId, 'coinNum', selfInfo.wallet.coin.toString()),
      _userRepository.setLocalUserData(userId, 'dynamicNum', selfStatsResult.value.dynamicCount.toString()),
      _userRepository.setLocalUserData(userId, 'followNum', selfStatsResult.value.followCount.toString()),
      _userRepository.setLocalUserData(userId, 'fansNum', selfStatsResult.value.fansCount.toString()),
    ]);

    _headerData = HeaderData(
      id: userId,
      nickname: selfInfo.nickname,
      avatar: selfInfo.avatar,
      avatarFrame: selfInfo.avatarFrame,
      level: selfInfo.level,
      vip: selfInfo.vip,
      wallet: selfInfo.wallet,
      banner: userInfoResult.value.banner,
      dynamicNum: selfStatsResult.value.dynamicCount,
      followNum: selfStatsResult.value.followCount,
      fansNum: selfStatsResult.value.fansCount,
    );
    notifyListeners();
    return Result.ok(_headerData!);
  }

  ContentData? _contentData;
  ContentData? get contentData => _contentData;

  late final Command0<ContentData> getContentData;
  Future<Result<ContentData>> _getContentData() async {
    assert(_authRepository.hasLogin);

    final account = await _authRepository.getAccount();

    final [
      watchHistoryResult,
      watchLaterResult,
      favoritesResult,
    ] = await Future.wait([
      _userRepository.getWatchHistory(),
      _userRepository.getWatchLater(),
      _userRepository.getFavoritesList(userId: account.userId),
    ]);

    if (watchHistoryResult case Error()) {
      return Result.error(watchHistoryResult.error);
    }
    if (watchLaterResult case Error()) {
      return Result.error(watchLaterResult.error);
    }
    if (favoritesResult case Error()) {
      return Result.error(favoritesResult.error);
    }

    watchHistoryResult as Ok<GetWatchHistoryResponse>;
    watchLaterResult as Ok<GetWatchLaterResponse>;
    favoritesResult as Ok<GetFavoritesResponse>;

    _contentData = ContentData(
      watchHistory: watchHistoryResult.value.list,
      watchLater: watchLaterResult.value.list,
      favorites: favoritesResult.value.list,
    );
    notifyListeners();
    return Result.ok(_contentData!);
  }
}

class HeaderData extends User {
  final String? avatarFrame;
  final SelfLevel level;
  final UserVip vip;
  final UserWallet wallet;
  final String banner;
  final int dynamicNum;
  final int followNum;
  final int fansNum;

  HeaderData({
    required super.id,
    required super.nickname,
    required super.avatar,
    this.avatarFrame,
    required this.level,
    required this.vip,
    required this.wallet,
    required this.banner,
    required this.dynamicNum,
    required this.followNum,
    required this.fansNum,
  });
}

class ContentData {
  final List<dynamic> watchHistory;
  final List<dynamic> watchLater;
  final List<Favorites> favorites;

  ContentData({
    required this.watchHistory,
    required this.watchLater,
    required this.favorites,
  });
}
