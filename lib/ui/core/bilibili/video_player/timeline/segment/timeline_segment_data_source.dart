import 'package:better_bilibili/ui/core/bilibili/video_player/timeline/segment/timeline_segment.dart';
import 'package:material_ui/material_ui.dart';

class TimelineSegmentDataSource extends ChangeNotifier {
  List<TimelineSegment> _data = [];

  List<TimelineSegment> get data => List.unmodifiable(_data);
  set data(List<TimelineSegment> newData) {
    _data = newData;
    notifyListeners();
  }
}
