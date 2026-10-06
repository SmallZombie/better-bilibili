import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_counters_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_info_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_relation_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_stats_response.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_user_total_like_and_view_count_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class UserDetailViewModel extends SafeChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  final String userId;

  UserDetailViewModel({
    required UserRepository userRepository,
    required AuthRepository authRepository,
    required this.userId,
  }) : _userRepository = userRepository,
       _authRepository = authRepository {
    loadData = Command0(_loadData)..execute();
  }

  late final Command0 loadData;

  GetUserInfoResponse? _userInfo;
  GetUserStatsResponse? _userStats;
  GetUserTotalLikeAndViewCountResponse? _userTotalLikeAndViewCount;
  GetUserCountersResponse? _userCounters;
  GetUserRelationResponse? _userRelation;
  bool _isCurrentAccount = false;

  GetUserInfoResponse? get userInfo => _userInfo;
  GetUserStatsResponse? get userStats => _userStats;
  GetUserTotalLikeAndViewCountResponse? get userTotalLikeAndViewCount => _userTotalLikeAndViewCount;
  GetUserCountersResponse? get userCounters => _userCounters;
  GetUserRelationResponse? get userRelation => _userRelation;
  bool get isCurrentAccount => _isCurrentAccount;

  Future<Result<void>> _loadData() async {
    _isCurrentAccount = (await _authRepository.getAccount()).userId == userId;

    final [
      userInfoResult,
      userStatsResult,
      userTotalLikeAndViewCountResult,
      userCountersResult,
      userRelationResult,
    ] = await Future.wait([
      _userRepository.getUserInfo(userId: userId),
      _userRepository.getUserStats(userId: userId),
      _userRepository.getUserTotalLikeAndViewCount(userId: userId),
      _userRepository.getUserCounters(userId: userId),
      _userRepository.getUserRelation(userId: userId),
    ]);

    if (userInfoResult case Error()) {
      return Result.error(userInfoResult.error);
    }
    if (userStatsResult case Error()) {
      return Result.error(userStatsResult.error);
    }
    if (userTotalLikeAndViewCountResult case Error()) {
      return Result.error(userTotalLikeAndViewCountResult.error);
    }
    if (userCountersResult case Error()) {
      return Result.error(userCountersResult.error);
    }
    if (userRelationResult case Error()) {
      return Result.error(userRelationResult.error);
    }

    userInfoResult as Ok<GetUserInfoResponse>;
    userStatsResult as Ok<GetUserStatsResponse>;
    userTotalLikeAndViewCountResult as Ok<GetUserTotalLikeAndViewCountResponse>;
    userCountersResult as Ok<GetUserCountersResponse>;
    userRelationResult as Ok<GetUserRelationResponse>;

    _userInfo = userInfoResult.value;
    _userStats = userStatsResult.value;
    _userTotalLikeAndViewCount = userTotalLikeAndViewCountResult.value;
    _userCounters = userCountersResult.value;
    _userRelation = userRelationResult.value;

    return Result.ok(null);
  }
}
