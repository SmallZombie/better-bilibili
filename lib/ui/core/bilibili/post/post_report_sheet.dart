import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/ui/core/share/bottom_sheet_wapper.dart';
import 'package:better_bilibili/ui/core/share/simple_snackbar.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class _ReportReason {
  final int id;
  final String name;
  final String? description;

  const _ReportReason({
    required this.id,
    required this.name,
    this.description,
  });
}

extension PostReportSheet on BuildContext {
  Future<void> showPostReportSheet(String postId, String userId) async {
    final options = [
      // 垃圾广告 4
      _ReportReason(
        id: 4,
        name: '广告',
        description: '包含推广、营销或其他商业宣传内容',
      ),

      // 引战 8
      _ReportReason(
        id: 8,
        name: '引战',
        description: '故意挑起争端、对立或群体冲突',
      ),

      // 色情 1
      _ReportReason(
        id: 1,
        name: '淫秽色情',
        description: '包含色情、淫秽或低俗内容',
      ),

      // 人身攻击 5
      _ReportReason(
        id: 5,
        name: '人身攻击',
        description: '侮辱、谩骂、骚扰或恶意攻击他人',
      ),

      // 违法信息 3
      // 违法信息外链 13
      _ReportReason(
        id: 3,
        name: '违反法律',
        description: '包含违反法律法规的内容',
      ),

      // 涉政谣言 9
      _ReportReason(
        id: 9,
        name: '涉政',
        description: '涉及政治敏感或相关违规内容',
      ),

      // 涉社会事件谣言 10
      // 虚假不实信息 12
      _ReportReason(
        id: 12,
        name: '散播谣言/虚假信息',
        description: '传播未经证实或与事实不符的信息',
      ),

      // 其他 0
      _ReportReason(
        id: 0,
        name: '其他',
        description: '单击此处填写',
      ),
    ];

    int? reasonId;
    String reason = '';

    bool submitButtonEnabled() => reasonId != null && (reasonId != 0 || reason.isNotEmpty);

    final PostRepository postRepository = read();

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
          child: RadioGroup<int>(
            groupValue: reasonId,
            onChanged: (int? value) {
              setState(() {
                reasonId = value;
              });
            },
            child: ListView(
              children: [
                ...options.map(
                  (v) => ListTile(
                    title: Text(v.name),
                    subtitle: v.description != null ? Text(v.description!) : null,
                    leading: Radio(value: v.id),
                    onTap: () => setState(() => reasonId = v.id),
                  ),
                ),
                Padding(
                  padding: const .fromLTRB(16.0, 6.0, 16.0, 24.0),
                  child: TextField(
                    enabled: reasonId == 0,
                    maxLength: 60,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: '其他',
                      hintText: '请详细说明举报原因以及出现问题的位置',
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: .always,
                    ),
                    onChanged: (value) => setState(() => reason = value),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (submit != true || reasonId == null) {
      return;
    }

    final result = await postRepository.report(
      postId: postId,
      userId: userId,
      reasonId: reasonId!,
      reason: reasonId == 0 ? reason : null,
    );
    switch (result) {
      case Ok():
        showInfo('已提交');
      case Err(:final error):
        showError('提交失败: $error');
    }
  }
}
