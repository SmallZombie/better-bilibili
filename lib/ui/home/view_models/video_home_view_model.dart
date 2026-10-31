import 'dart:async';

import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/services/bilibili/model/get_recommend_videos_response.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';
import 'package:logger/logger.dart';

class VideoHomeViewModel extends SafeChangeNotifier {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'VideoHomeView'));

  final VideoRepository videoRepository;
  final AuthRepository authRepository;

  late final StreamSubscription _accountChangeSubscription;

  VideoHomeViewModel({required this.videoRepository, required this.authRepository}) {
    loadData = Command0(
      _getRecommendVideos,
      onSuccess: _appendRecommendVideos,
      onCancel: () {},
    )..execute();

    _accountChangeSubscription = authRepository.stream.current.listen(_onAccountChanged);
  }

  @override
  void dispose() {
    _accountChangeSubscription.cancel();

    super.dispose();
  }

  late final Command0<List<RecommendVideo>> loadData;

  final List<RecommendVideo> _videos = [];
  List<RecommendVideo> get videos => List.unmodifiable(_videos);

  int _pn = 1;

  /// 分区我没找到有接口可以获取，就暂时写死了
  final List<(String name, String id)> _categoryList = [
    ('全部', '0'),
    ('动画', '1005'),
    ('游戏', '1008'),
    ('鬼畜', '1007'),
    ('音乐', '1003'),
    ('舞蹈', '1004'),
    ('影视', '1001'),
    ('娱乐', '1002'),
    ('知识', '1010'),
    ('科技数码', '1012'),
    ('资讯', '1009'),
    ('美食', '1020'),
    ('小剧场', '1021'),
    ('汽车', '1013'),
    ('时尚美妆', '1014'),
    ('体育运动', '1018'),
    ('动物', '1024'),
    ('vlog', '1029'),
    ('绘画', '1006'),
    ('人工智能', '1011'),
    ('家装房产', '1015'),
    ('户外潮流', '1016'),
    ('健身', '1017'),
    ('手工', '1019'),
    ('旅游出行', '1022'),
    ('三农', '1023'),
    ('亲子', '1025'),
    ('健康', '1026'),
    ('情感', '1027'),
    ('生活兴趣', '1030'),
    ('生活经验', '1031'),
    ('神秘学', '1028'),
  ];
  List<String> get categoryList => List.unmodifiable(_categoryList.map((v) => v.$1));
  int _selectedCategoryIndex = 0;
  int get selectedCategoryIndex => _selectedCategoryIndex;

  void onCategorySelected(int index) {
    if (index == _selectedCategoryIndex) {
      return;
    }

    _selectedCategoryIndex = index;
    _videos.clear();
    _pn = 1;
    loadData.cancel();
    loadData.execute();
    notifyListeners();
  }

  Future<Result<List<RecommendVideo>>> _getRecommendVideos() async {
    final categoryIndex = _selectedCategoryIndex;
    final pn = _pn;

    return categoryIndex == 0
        ? videoRepository.getRecommendVideos(pn: pn)
        : videoRepository.getRecommendVideosByCategory(
            categoryId: _categoryList[categoryIndex].$2,
            pn: pn,
          );
  }

  void _appendRecommendVideos(List<RecommendVideo> videos) {
    _videos.addAll(videos);
    _pn++;
    notifyListeners();
  }

  void _onAccountChanged(String event) {
    _log.i('reload with accountChanged accountId=$event');
    loadData.cancel();

    _pn = 1;
    _videos.clear();
    notifyListeners();

    loadData.execute();
  }
}
