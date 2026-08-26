class User {
  final String id;
  final String nickname;
  final String avatar;
  final UserStats? stats;

  const User({
    required this.id,
    required this.nickname,
    required this.avatar,
    this.stats,
  });

  User copyWith({
    String? id,
    String? nickname,
    String? avatar,
    UserStats? stats,
  }) {
    return User(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      stats: stats ?? this.stats,
    );
  }
}

class UserStats {
  final int following;
  final int fans;
  final int? dynamics;

  UserStats({required this.following, required this.fans, this.dynamics});

  UserStats copyWith({
    int? following,
    int? fans,
    int? dynamics,
  }) {
    return UserStats(
      following: following ?? this.following,
      fans: fans ?? this.fans,
      dynamics: dynamics ?? this.dynamics,
    );
  }
}

class SelfLevel {
  final int currentLevel;
  final int currentXp;
  final int maxXp;

  SelfLevel({required this.currentLevel, required this.currentXp, required this.maxXp});
}

class UserVip {
  final UserVipType type;
  final int expiredAt;
  final String labelImage;

  UserVip({required this.type, required this.expiredAt, required this.labelImage});
}

enum UserVipType { none, normal, year, overAYear }

class UserWallet {
  final double coin;
  final double bcoin;

  UserWallet({required this.coin, required this.bcoin});
}

class VideoInteraction {
  final bool hasLiked;
  final bool hasDisliked;
  final bool hasFavorited;
  final int coinCount;
  final bool hasFollowed;
  final bool isSubscribedCollection;

  VideoInteraction({
    required this.hasLiked,
    required this.hasDisliked,
    required this.hasFavorited,
    required this.coinCount,
    required this.hasFollowed,
    required this.isSubscribedCollection,
  });

  VideoInteraction copyWith({
    bool? hasLiked,
    bool? hasDisliked,
    bool? hasFavorited,
    int? coinCount,
    bool? hasFollowed,
    bool? isSubscribedCollection,
  }) {
    return VideoInteraction(
      hasLiked: hasLiked ?? this.hasLiked,
      hasDisliked: hasDisliked ?? this.hasDisliked,
      hasFavorited: hasFavorited ?? this.hasFavorited,
      coinCount: coinCount ?? this.coinCount,
      hasFollowed: hasFollowed ?? this.hasFollowed,
      isSubscribedCollection: isSubscribedCollection ?? this.isSubscribedCollection,
    );
  }
}

class ArticleInteraction {
  final bool hasLiked;
  final bool hasFavorited;
  final int coinCount;
  final bool hasFollowed;

  ArticleInteraction({
    required this.hasLiked,
    required this.hasFavorited,
    required this.coinCount,
    required this.hasFollowed,
  });

  ArticleInteraction copyWith({
    bool? hasLiked,
    bool? hasFavorited,
    int? coinCount,
    bool? hasFollowed,
  }) {
    return ArticleInteraction(
      hasLiked: hasLiked ?? this.hasLiked,
      hasFavorited: hasFavorited ?? this.hasFavorited,
      coinCount: coinCount ?? this.coinCount,
      hasFollowed: hasFollowed ?? this.hasFollowed,
    );
  }
}

enum UserLevel {
  lv0,
  lv1,
  lv2,
  lv3,
  lv4,
  lv5,
  lv6,
  lv6p,
}

extension UserLevelExtension on UserLevel {
  int get level => switch (this) {
    UserLevel.lv0 => 0,
    UserLevel.lv1 => 1,
    UserLevel.lv2 => 2,
    UserLevel.lv3 => 3,
    UserLevel.lv4 => 4,
    UserLevel.lv5 => 5,
    UserLevel.lv6 => 6,
    UserLevel.lv6p => 7,
  };
}

class UserGroup {
  final String id;
  final String name;
  final int count;

  UserGroup({required this.id, required this.name, required this.count});

  UserGroup copyWith({
    String? id,
    String? name,
    int? count,
  }) {
    return UserGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      count: count ?? this.count,
    );
  }
}
