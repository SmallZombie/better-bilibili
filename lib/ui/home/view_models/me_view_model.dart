import 'dart:async';

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

  final AuthRepository authRepository;
  final UserRepository userRepository;

  late final StreamSubscription _accountChangeSubscription;

  MeViewModel({required this.authRepository, required this.userRepository}) {
    getHeaderData = Command0(_getHeaderData);
    getContentData = Command0(_getContentData);

    if (authRepository.hasLogin) {
      getHeaderData.execute();
      getContentData.execute();
    }

    _accountChangeSubscription = authRepository.stream.current.listen(_onAccountChange);
  }

  @override
  void dispose() {
    _accountChangeSubscription.cancel();

    super.dispose();
  }

  bool get hasLogin => authRepository.hasLogin;

  void _onAccountChange(String event) {
    _log.i('reload with accountChanged accountId=$event hasLogin=${authRepository.hasLogin}');

    _headerData = null;
    _contentData = null;
    notifyListeners();

    if (authRepository.hasLogin) {
      getHeaderData.execute();
      getContentData.execute();
    }
  }

  HeaderData? _headerData;
  HeaderData? get headerData => _headerData;

  late final Command0<HeaderData> getHeaderData;
  Future<Result<HeaderData>> _getHeaderData() async {
    assert(authRepository.hasLogin);

    final account = await authRepository.getAccount();
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
      userRepository.getLocalUserData(userId, 'nickname'),
      userRepository.getLocalUserData(userId, 'avatar'),
      userRepository.getLocalUserData(userId, 'avatarFrame'),
      userRepository.getLocalUserData(userId, 'banner'),
      userRepository.getLocalUserData(userId, 'level'),
      userRepository.getLocalUserData(userId, 'vipIcon'),
      userRepository.getLocalUserData(userId, 'bcoinCount'),
      userRepository.getLocalUserData(userId, 'coinCount'),
      userRepository.getLocalUserData(userId, 'dynamicCount'),
      userRepository.getLocalUserData(userId, 'followCount'),
      userRepository.getLocalUserData(userId, 'fansCount'),
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
      userRepository.getSelfInfo(),
      userRepository.getUserInfo(userId),
      userRepository.getSelfStats(),
    ]);

    if (selfInfoResult case Err()) {
      return Result.error(selfInfoResult.error);
    }
    if (userInfoResult case Err()) {
      return Result.error(userInfoResult.error);
    }
    if (selfStatsResult case Err()) {
      return Result.error(selfStatsResult.error);
    }

    selfInfoResult as Ok<GetSelfInfoResponse>;
    userInfoResult as Ok<GetUserInfoResponse>;
    selfStatsResult as Ok<GetSelfStatsResponse>;

    final selfInfo = selfInfoResult.value as GetSelfInfoLogginResponse;

    await userRepository.setLocalUserData(userId, 'nickname', selfInfo.nickname);
    await userRepository.setLocalUserData(userId, 'avatar', selfInfo.avatar);

    if (selfInfo.avatarFrame != null) {
      await userRepository.setLocalUserData(userId, 'avatarFrame', selfInfo.avatarFrame!);
    } else {
      await userRepository.removeLocalUserData(userId, 'avatarFrame');
    }

    await Future.wait([
      userRepository.setLocalUserData(userId, 'banner', userInfoResult.value.banner),
      userRepository.setLocalUserData(userId, 'level', selfInfo.level.currentLevel.toString()),
      userRepository.setLocalUserData(userId, 'vipIcon', selfInfo.vip.labelImage),
      userRepository.setLocalUserData(userId, 'bcoinCount', selfInfo.wallet.bcoin.toString()),
      userRepository.setLocalUserData(userId, 'coinCount', selfInfo.wallet.coin.toString()),
      userRepository.setLocalUserData(userId, 'dynamicCount', selfStatsResult.value.dynamicCount.toString()),
      userRepository.setLocalUserData(userId, 'followCount', selfStatsResult.value.followCount.toString()),
      userRepository.setLocalUserData(userId, 'fansCount', selfStatsResult.value.fansCount.toString()),
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
    assert(authRepository.hasLogin);

    final account = await authRepository.getAccount();

    final [
      watchHistoryResult,
      watchLaterResult,
      favoritesResult,
    ] = await Future.wait([
      userRepository.getWatchHistory(),
      userRepository.getWatchLater(),
      userRepository.getFavoritesList(userId: account.userId),
    ]);

    if (watchHistoryResult case Err()) {
      return Result.error(watchHistoryResult.error);
    }
    if (watchLaterResult case Err()) {
      return Result.error(watchLaterResult.error);
    }
    if (favoritesResult case Err()) {
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
  final List<FavoriteFolder> favorites;

  ContentData({
    required this.watchHistory,
    required this.watchLater,
    required this.favorites,
  });
}
