import 'package:better_bilibili/data/model/bsbsb/leaderboard_entry.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/model/bsbsb/video.dart';
import 'package:better_bilibili/data/services/bsbsb/model/get_leaderboard_request.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class BsbsbApiService {
  final Future<Dio> Function() getClient;
  final Future<String> Function() getPrivateId;

  const BsbsbApiService({required this.getClient, required this.getPrivateId});

  Result<T> _handleError<T>(Object error) {
    if (error is DioException) {
      final resp = error.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${error.message}'));
      }
      return Result.error(Exception('${resp.statusCode}: ${resp.data}'));
    } else if (error is Exception) {
      return Result.error(error);
    } else if (error is Error) {
      assert(false, 'Something went wrong');
      return Result.error(Exception(error.toString()));
    } else {
      assert(false, 'What did you throw?');
      return Result.error(Exception('Unknown error'));
    }
  }

  Future<Result<UserInfo>> getUserInfo(String publicUserId) async {
    final client = await getClient();

    try {
      final resp = await client.get(
        '/userInfo',
        queryParameters: {
          'publicUserID': publicUserId,
          'values': '["userName","minutesSaved","segmentCount","ignoredSegmentCount","viewCount","ignoredViewCount"]',
        },
      );

      return Result.ok(UserInfo.fromJson(resp.data));
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<Video>>> getSegments(String bvidHashPrefix) async {
    final client = await getClient();

    try {
      final resp = await client.get('/skipSegments/$bvidHashPrefix');
      return Result.ok((resp.data as List).map((e) => Video.fromJson(e)).toList());
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<void>> modifyUsername(String username) async {
    final client = await getClient();
    final privateId = await getPrivateId();

    try {
      await client.post(
        '/setUsername',
        queryParameters: {
          'userID': privateId,
          'username': username,
        },
      );
      return Result.ok(null);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Result<List<LeaderboardEntry>>> getLeaderboard({
    GetLeaderboardOrderEnum order = .submitCount,
    GetLeaderboardTypeEnum type = .all,
    int ps = 20,
  }) async {
    assert(ps > 0 && ps <= 100);
    final client = await getClient();

    try {
      final resp = await client.get('https://bsbsb.top/stats/api/top-users?sortType=${order.value}&category=${type.value}');

      final usernames = resp.data['userNames'] as List;
      final viewCounts = resp.data['viewCounts'] as List;
      final totalSubmissions = resp.data['totalSubmissions'] as List;
      final minutesSaved = resp.data['minutesSaved'] as List;
      final votes = resp.data['votes'] as List;
      final bindvideoSourceCounts = resp.data['portVideo'] as List;

      if ([
        viewCounts.length,
        totalSubmissions.length,
        minutesSaved.length,
        votes.length,
        bindvideoSourceCounts.length,
      ].any((v) => v != usernames.length)) {
        return Result.error(throw Exception('Invaild response'));
      }

      final List<LeaderboardEntry> result = [];
      for (int i = 0; i < usernames.length; i++) {
        if (i >= ps) break;

        result.add(
          LeaderboardEntry(
            username: usernames[i],
            submitCount: totalSubmissions[i],
            saveTime: Duration(milliseconds: (minutesSaved[i] * Duration.millisecondsPerMinute).round()),
            likeCount: votes[i],
            skipCount: viewCounts[i],
            bindvideoSourceCount: bindvideoSourceCounts[i],
          ),
        );
      }

      return Result.ok(result);
    } catch (e) {
      return _handleError(e);
    }
  }
}
