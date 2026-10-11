import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/data/model/bsbsb/user_info.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:material_ui/material_ui.dart';

class BsbsbSettingsViewModel extends ChangeNotifier {
  final BsbsbConfig config;
  final BsbsbRepository bsbsbRepository;

  BsbsbSettingsViewModel({required this.config, required this.bsbsbRepository}) {
    loadData.execute();
  }

  late Command0 loadData = Command0(_loadData);

  UserInfo? userInfo;

  Future<Result<void>> _loadData() async {
    final result = await bsbsbRepository.getUserInfo();
    switch (result) {
      case Ok(:final value):
        userInfo = value;
      case Error():
    }

    notifyListeners();
    return result;
  }
}
