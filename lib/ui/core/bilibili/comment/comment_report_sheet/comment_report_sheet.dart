import 'package:better_bilibili/data/repositories/bilibili/comment_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_report_sheet/comment_report_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/center_error_message.dart';
import 'package:better_bilibili/ui/core/share/info_banner.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

extension CommentReportSheet on BuildContext {
  Future<void> showCommentReportSheet({
    required BiliContentTypeEnum contentType,
    required String contentId,
    required String commentId,
  }) async {
    final CommentReportSheetViewModel viewModel = read();
    viewModel.clear();
    viewModel.getReasonList.execute(contentType, contentId);

    ReportReasonItem? reason;
    String description = '';

    bool submitButtonEnabled() => reason != null && (!reason!.requiresDescription || description.isNotEmpty);

    final CommentRepository commentRepository = read();

    final submit = await showModalBottomSheet<bool>(
      context: this,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => BottomSheetWapper(
          title: Text('举报内容'),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: Text('取消'),
            ),
            FilledButton(
              onPressed: switch (submitButtonEnabled()) {
                true => () => context.pop(true),
                _ => null,
              },
              child: Text('提交'),
            ),
          ],
          child: RadioGroup<ReportReasonItem>(
            groupValue: reason,
            onChanged: (ReportReasonItem? value) {
              setState(() => reason = value);
            },
            child: ListenableBuilder(
              listenable: viewModel.getReasonList,
              builder: (context, child) {
                if (viewModel.getReasonList.running) {
                  return const Column(children: [LinearProgressIndicator()]);
                }

                if (viewModel.getReasonList.error) {
                  return CenterErrorMessage(
                    errorMessage: viewModel.getReasonList.result.toString(),
                    onRetry: () {
                      viewModel.getReasonList.execute(contentType, contentId);
                    },
                  );
                }

                if (viewModel.reasonList.isEmpty) {
                  return Center(child: Text('暂无内容'));
                }

                return ListView(
                  children: [
                    if (reason?.requiresDescription ?? false)
                      InfoBanner(
                        leading: const Icon(Icons.info_outline),
                        title: Text('所选类型必须填写说明'),
                      ),
                    ...viewModel.reasonList.map(
                      (v) => ListTile(
                        title: Text(v.name),
                        leading: Radio(value: v),
                        onTap: () => setState(() => reason = v),
                      ),
                    ),
                    Padding(
                      padding: const .fromLTRB(16.0, 6.0, 16.0, 24.0),
                      child: TextField(
                        enabled: reason?.requiresDescription ?? false,
                        maxLength: 200,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: '说明',
                          hintText: '请为举报类型补充详细说明',
                          border: OutlineInputBorder(),
                          floatingLabelBehavior: .always,
                        ),
                        onChanged: (value) => setState(() => description = value),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    if (submit != true || reason == null) {
      return;
    }

    final result = await commentRepository.report(
      contentType: contentType,
      contentId: contentId,
      commentId: commentId,
      reasonId: reason!.id,
      description: reason!.requiresDescription ? description : null,
    );
    switch (result) {
      case Ok():
        showInfo('已提交');
      case Error(:final error):
        showError('提交失败: $error');
    }
  }
}
