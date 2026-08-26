import 'package:better_bilibili/data/services/bilibili/model/get_post_list_response.dart';

enum GetUserPostsTypeEnum {
  all,
  video,
}

extension GetUserPostsTypeEnumExtension on GetUserPostsTypeEnum {
  String get value => switch (this) {
    .all => throw Exception('You should not call value of \'all\', in the API it should be empty.'),
    .video => 'video',
  };
}

class GetUserPostsResponse {
  final List<Post> list;
  final bool hasMore;
  final String? nextOffset;

  GetUserPostsResponse({required this.list, required this.hasMore, this.nextOffset});
}
