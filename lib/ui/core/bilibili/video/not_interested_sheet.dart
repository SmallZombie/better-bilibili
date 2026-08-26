import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

extension NotInterestedSheet on BuildContext {
  Future<String?> showVideoNotInterestedSheet({
    required String videoId,
    required String userId,
    required TrackingInfo track,
    required String videoTitle,
  }) async {
    late final VideoRepository videoRepository;
    try {
      videoRepository = read<VideoRepository>();
    } on Exception {
      showError('服务不可用');
    }

    final reasonId = await showModalBottomSheet<String>(
      context: this,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => BottomSheetWapper(
        title: Text('不感兴趣'),
        subtitle: Text('您对 "$videoTitle" 的哪部分内容不感兴趣？'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text('取消'),
          ),
        ],
        child: ListView(
          children: [
            ListTile(
              title: Text('内容本身'),
              subtitle: Text('我对内容本身不感兴趣'),
              onTap: () => context.pop('1'),
            ),
            ListTile(
              title: Text('上传者'),
              subtitle: Text('我不喜欢与此上传者有关的内容'),
              onTap: () => context.pop('4'),
            ),
          ],
        ),
      ),
    );

    if (reasonId == null) {
      return null;
    }

    final result = await videoRepository.markNotInterested(
      videoId: videoId,
      userId: userId,
      reasonId: reasonId,
      trackingInfo: track,
    );
    switch (result) {
      case Ok():
        showInfo('已提交');
        return reasonId;
      case Error(:final error):
        showError('提交失败: $error');
        return null;
    }
  }
}
