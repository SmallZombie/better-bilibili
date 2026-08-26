class Topic {
  final String id;
  final String name;

  Topic({
    required this.id,
    required this.name,
  });
}

class PostStats {
  final int like;
  final int favorite;
  final int coin;
  final int comment;
  final int share;

  PostStats({
    required this.like,
    required this.favorite,
    required this.coin,
    required this.comment,
    required this.share,
  });

  PostStats copyWith({
    int? like,
    int? favorite,
    int? coin,
    int? comment,
    int? share,
  }) {
    return PostStats(
      like: like ?? this.like,
      favorite: favorite ?? this.favorite,
      coin: coin ?? this.coin,
      comment: comment ?? this.comment,
      share: share ?? this.share,
    );
  }
}

class HashTag {
  final String id;
  final String name;

  HashTag({
    required this.id,
    required this.name,
  });
}
