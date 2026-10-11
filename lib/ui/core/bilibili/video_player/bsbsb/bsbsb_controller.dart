import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/model/bsbsb/segment.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class BsbsbController extends ChangeNotifier {
  final BsbsbRepository bsbsbRepository;
  final BsbsbConfig config;
  final String videoId;

  BsbsbController({
    required this.bsbsbRepository,
    required this.config,
    required this.videoId,
  }) {
    loadData.execute();
  }

  Map<String, List<Segment>> data = {};
  late Command0 loadData = Command0(_loadData);

  Future<Result<void>> _loadData() async {
    final result = await bsbsbRepository.getSegments(videoId);
    if (_disposed) return result;

    switch (result) {
      case Ok(:final value):
        data = value;
      case Error():
    }

    notifyListeners();
    return result;
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
