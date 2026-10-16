import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_comment_report_reasons_response.dart';
import 'package:better_bilibili/domain/models/bilibili/bilibili.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:flutter/widgets.dart';

class CommentReportSheetViewModel extends ChangeNotifier {
  final CommentRepository _commentRepository;

  CommentReportSheetViewModel({required CommentRepository commentRepository}) : _commentRepository = commentRepository {
    getReasonList = Command2(_getReasonList);
  }

  late final Command2<void, BiliContentTypeEnum, String> getReasonList;

  final List<ReportReasonItem> _reasonList = [];
  List<ReportReasonItem> get reasonList => List.unmodifiable(_reasonList);

  Future<Result<void>> _getReasonList(BiliContentTypeEnum contentType, String contentId) async {
    final result = await _commentRepository.getReportReasons(
      contentType: contentType,
      contentId: contentId,
    );
    switch (result) {
      case Ok(:final value):
        _reasonList.addAll(value);
      case Error():
    }

    notifyListeners();
    return result;
  }

  void clear() {
    _reasonList.clear();
    notifyListeners();
  }
}
