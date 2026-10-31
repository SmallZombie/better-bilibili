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
  final UserRepository userRepository;
  final AuthRepository authRepository;

  final String userId;

  UserDetailViewModel({
    required this.userRepository,
    required this.authRepository,
    required this.userId,
  }) {
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
    _isCurrentAccount = (await authRepository.getAccount()).userId == userId;

    final [
      userInfoResult,
      userStatsResult,
      userTotalLikeAndViewCountResult,
      userCountersResult,
      userRelationResult,
    ] = await Future.wait([
      userRepository.getUserInfo(userId),
      userRepository.getUserStats(userId),
      userRepository.getUserTotalLikeAndViewCount(userId),
      userRepository.getUserCounters(userId),
      userRepository.getUserRelation(userId),
    ]);

    if (userInfoResult case Err()) {
      return Result.error(userInfoResult.error);
    }
    if (userStatsResult case Err()) {
      return Result.error(userStatsResult.error);
    }
    if (userTotalLikeAndViewCountResult case Err()) {
      return Result.error(userTotalLikeAndViewCountResult.error);
    }
    if (userCountersResult case Err()) {
      return Result.error(userCountersResult.error);
    }
    if (userRelationResult case Err()) {
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
