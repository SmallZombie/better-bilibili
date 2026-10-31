import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/widgets.dart';

class CommentReportSheetViewModel extends ChangeNotifier {
  final CommentRepository commentRepository;

  CommentReportSheetViewModel({required this.commentRepository}) {
    getReasonList = Command1(_getReasonList);
  }

  late final Command1<void, GetReasonListOptions> getReasonList;

  final List<ReportReasonItem> _reasonList = [];
  List<ReportReasonItem> get reasonList => List.unmodifiable(_reasonList);

  Future<Result<void>> _getReasonList(GetReasonListOptions options) async {
    final result = await commentRepository.getReportReasons(
      contentType: options.contentType,
      contentId: options.contentId,
    );
    switch (result) {
      case Ok(:final value):
        _reasonList.addAll(value);
      case Err():
    }

    notifyListeners();
    return result;
  }

  void clear() {
    _reasonList.clear();
    notifyListeners();
  }
}

class GetReasonListOptions {
  final BiliContentTypeEnum contentType;
  final String contentId;

  const GetReasonListOptions(this.contentType, this.contentId);
}
