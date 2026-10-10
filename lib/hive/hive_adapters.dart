import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/bsbsb_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/domain/models/bilibili/play_info.dart';
import 'package:hive_ce/hive_ce.dart';

@GenerateAdapters([
  AdapterSpec<CodecEnum>(),
  AdapterSpec<SkipOptionsEnum>(),
  AdapterSpec<ViewOriginalImageEnum>(),
  AdapterSpec<LoudnessNormalizationEnum>(),
])
part 'hive_adapters.g.dart';
