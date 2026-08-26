import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/utils/command.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:better_bilibili/utils/safe_change_notifier.dart';

class SubscriptionCollectionTextButtonViewModel extends SafeChangeNotifier {
  final VideoRepository _videoRepository;

  String collectionId;
  bool subscribed;

  SubscriptionCollectionTextButtonViewModel({
    required VideoRepository videoRepository,
    required this.collectionId,
    required bool initState,
  }) : _videoRepository = videoRepository,
       subscribed = initState {
    subscription = Command0(_follow);
  }

  late final Command0<void> subscription;

  Future<Result<void>> _follow() async {
    final action = !subscribed;
    subscribed = action;
    notifyListeners();

    final result = await _videoRepository.subscriptionCollection(collectionId: collectionId, subscription: action);
    switch (result) {
      case Ok():
        return result;
      case Error():
        subscribed = !action;
    }

    notifyListeners();
    return result;
  }
}
