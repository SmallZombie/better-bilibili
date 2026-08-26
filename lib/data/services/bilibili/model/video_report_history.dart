enum ReportHistoryActionTypeEnum {
  // 首次开始播放和播放结束后的首次开始播放
  start,
  // 继续播放
  resume,
  // 播放中的心跳
  heartbeat,
  // 暂停
  pause,
  // 播放结束
  end,
}

extension ReportHistoryActionTypeEnumExtension on ReportHistoryActionTypeEnum {
  int get value => switch (this) {
    .start => 1,
    .resume => 3,
    .heartbeat => 0,
    .pause => 2,
    .end => 4,
  };
}
