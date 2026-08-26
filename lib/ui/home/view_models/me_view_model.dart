import 'dart:math';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_favorites_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_self_status_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_history.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_watch_later.dart';
import 'package:better_bilibili/data/services/cache_service.dart';
import 'package:better_bilibili/domain/models/bilibili/user.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logging/logging.dart';

class MeViewModel extends SafeChangeNotifier {
  final Logger _log = Logger('MeViewModel');
  final AuthRepository _authRepository;
  final UserRepository _userRepository;
  final CacheService _cacheService;

  MeViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required CacheService cacheService,
  }) : _authRepository = authRepository,
       _userRepository = userRepository,
       _cacheService = cacheService {
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

  String getRandomNotLoggedInText() {
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

    final [
      cachedAvatarFrame as String?,
      cachedBanner as String?,
      cachedLevel as int?,
      cachedVipIcon as String?,
      cachedBCoinNum as int?,
      cachedCoinNum as int?,
      cachedDynamicNum as int?,
      cachedFollowNum as int?,
      cachedFansNum as int?,
    ] = await Future.wait([
      _cacheService.getString('user.${account.uid}.avatarFrame'),
      _cacheService.getString('user.${account.uid}.banner'),
      _cacheService.getInt('user.${account.uid}.level'),
      _cacheService.getString('user.${account.uid}.vipIcon'),
      _cacheService.getInt('user.${account.uid}.bcoinNum'),
      _cacheService.getInt('user.${account.uid}.coinNum'),
      _cacheService.getInt('user.${account.uid}.dynamicNum'),
      _cacheService.getInt('user.${account.uid}.followNum'),
      _cacheService.getInt('user.${account.uid}.fansNum'),
    ]);

    if (![
      account.nickname,
      account.avatar,
      cachedBanner,
      cachedLevel,
      cachedVipIcon,
      cachedBCoinNum,
      cachedCoinNum,
      cachedDynamicNum,
      cachedFollowNum,
      cachedFansNum,
    ].any((e) => e == null)) {
      _log.info('Load headerData from cache. (uid: ${account.uid})');
      _headerData = HeaderData(
        id: account.uid,
        nickname: account.nickname!,
        avatar: account.avatar!,
        avatarFrame: cachedAvatarFrame,
        level: SelfLevel(currentLevel: cachedLevel!, currentXp: 0, maxXp: 0),
        vip: UserVip(type: UserVipType.normal, expiredAt: 0, labelImage: cachedVipIcon!),
        wallet: UserWallet(coin: cachedCoinNum!.toDouble(), bcoin: cachedBCoinNum!.toDouble()),
        banner: cachedBanner!,
        dynamicNum: cachedDynamicNum!,
        followNum: cachedFollowNum!,
        fansNum: cachedFansNum!,
      );
      notifyListeners();
    }

    final [
      selfInfoResult as Result<GetSelfInfoResponse>,
      userInfoResult as Result<GetUserInfoResponse>,
      selfStatsResult as Result<GetSelfStatsResponse>,
    ] = await Future.wait([
      _authRepository.getSelfInfo(),
      _userRepository.getUserInfo(userId: account.uid),
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

    account.nickname = selfInfo.nickname;
    account.avatar = selfInfo.avatar;
    await _authRepository.updateAccount(account);
    if (selfInfo.avatarFrame != null) {
      await _cacheService.setString('user.${account.uid}.avatarFrame', selfInfo.avatarFrame!);
    } else {
      await _cacheService.remove('user.${account.uid}.avatarFrame');
    }
    await _cacheService.setString('user.${account.uid}.banner', userInfoResult.value.banner);
    await _cacheService.setInt('user.${account.uid}.level', selfInfo.level.currentLevel);
    await _cacheService.setString('user.${account.uid}.vipIcon', selfInfo.vip.labelImage);
    await _cacheService.setInt('user.${account.uid}.bcoinNum', selfInfo.wallet.bcoin.toInt());
    await _cacheService.setInt('user.${account.uid}.coinNum', selfInfo.wallet.coin.toInt());
    await _cacheService.setInt('user.${account.uid}.dynamicNum', selfStatsResult.value.dynamicCount);
    await _cacheService.setInt('user.${account.uid}.followNum', selfStatsResult.value.followCount);
    await _cacheService.setInt('user.${account.uid}.fansNum', selfStatsResult.value.fansCount);

    _headerData = HeaderData(
      id: account.uid,
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

    final [
      watchHistoryResult,
      watchLaterResult,
      favoritesResult,
    ] = await Future.wait([
      _userRepository.getWatchHistory(),
      _userRepository.getWatchLater(),
      _userRepository.getFavoritesList(),
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
