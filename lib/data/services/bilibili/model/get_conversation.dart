enum ConversationListType {
  userAndSystem(value: 1),
  unFollowing(value: 2),
  fansGroup(value: 3),
  all(value: 4),
  blocked(value: 5),
  huahuo(value: 6),
  systeam(value: 7),
  // 8: 陌生人(不包含官方账号的消息)
  followingAndSystem(value: 9);

  const ConversationListType({required this.value});

  final int value;
}
