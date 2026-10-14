enum GetLeaderboardOrderEnum {
  submitCount(2),
  saveTime(0),
  likeCount(3),
  skipCount(1);

  final int value;

  const GetLeaderboardOrderEnum(this.value);
}

enum GetLeaderboardTypeEnum {
  all('all'),
  sponsor('sponsor'),
  selfpromo('selfpromo'),
  exclusiveAccess('exclusive_access'),
  interaction('interaction'),
  pointsOfInterest('poi_highlight'),
  intro('intro'),
  outro('outro'),
  preview('preview'),
  padding('padding'),
  filler('filler'),
  musicOfftopic('music_offtopic');

  final String value;

  const GetLeaderboardTypeEnum(this.value);
}
