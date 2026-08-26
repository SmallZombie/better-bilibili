import 'package:better_bilibili/config/account_config.dart';
import 'package:better_bilibili/config/danmaku_config.dart';
import 'package:better_bilibili/config/player_config.dart';
import 'package:better_bilibili/data/repositories/bilibili/article_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/audio_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/comment_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/common_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/post_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/search_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository.dart';
import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_article_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_audio_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_chat_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_comment_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_common_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_post_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_search_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_user_api_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_video_api_service.dart';
import 'package:better_bilibili/data/services/cache_service.dart';
import 'package:better_bilibili/ui/core/app_shell/app_title_bar_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_report_sheet/comment_report_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/user/user_dialog/user_dialog_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersOnline => [
  Provider<AccountConfig>.value(value: AccountConfig()),
  Provider<StorageService>.value(value: StorageService()),
  Provider<CacheService>.value(value: CacheService()),
  ChangeNotifierProvider<AuthRepository>(
    create: (context) => AuthRepository(accountConfig: context.read()),
  ),
  Provider<BiliUserApiService>(
    create: (context) => BiliUserApiService(authRepository: context.read()),
  ),
  Provider<BiliVideoApiService>(
    create: (context) => BiliVideoApiService(authRepository: context.read()),
  ),
  Provider<BiliSearchApiService>(
    create: (context) => BiliSearchApiService(authRepository: context.read()),
  ),
  Provider<VideoRepository>(
    create: (context) => VideoRepository(videoApiClient: context.read()),
  ),
  Provider<UserRepository>(
    create: (context) => UserRepository(
      biliUserApiService: context.read(),
      cacheService: context.read(),
      authRepository: context.read(),
    ),
  ),
  Provider<SearchRepository>(
    create: (context) => SearchRepository(biliSearchApiService: context.read()),
  ),
  Provider<BiliCommonApiService>(
    create: (context) => BiliCommonApiService(authRepository: context.read()),
  ),
  Provider<CommonRepository>(
    create: (context) => CommonRepository(biliCommonApiService: context.read()),
  ),
  Provider<BiliCommentApiService>(
    create: (context) => BiliCommentApiService(authRepository: context.read()),
  ),
  Provider<CommentRepository>(
    create: (context) => CommentRepository(commentApiService: context.read()),
  ),
  Provider<BiliArticleApiService>(
    create: (context) => BiliArticleApiService(authRepository: context.read()),
  ),
  Provider<ArticleRepository>(
    create: (context) => ArticleRepository(articleApiService: context.read()),
  ),
  Provider<BiliPostApiService>(
    create: (context) => BiliPostApiService(authRepository: context.read()),
  ),
  Provider<PostRepository>(
    create: (context) => PostRepository(postApiService: context.read()),
  ),
  Provider<BiliAudioApiService>(
    create: (context) => BiliAudioApiService(authRepository: context.read()),
  ),
  Provider<AudioRepository>(
    create: (context) => AudioRepository(audioApiService: context.read()),
  ),
  Provider<BiliChatApiService>(
    create: (context) => BiliChatApiService(authRepository: context.read()),
  ),
  Provider<ChatRepository>(
    create: (context) => ChatRepository(
      chatRepository: context.read(),
      userRepository: context.read(),
    ),
  ),
  ChangeNotifierProvider<EditVideoInFavoriteFolderSheetViewModel>(
    create: (context) => EditVideoInFavoriteFolderSheetViewModel(userRepository: context.read()),
  ),
  ChangeNotifierProvider<BiliBackgroundService>(
    create: (context) => BiliBackgroundService(
      userRepository: context.read(),
      authRepository: context.read(),
      chatRepository: context.read(),
    ),
  ),
  ChangeNotifierProvider<UserDialogViewModel>(
    create: (context) => UserDialogViewModel(userRepository: context.read()),
  ),
  ChangeNotifierProvider<PlayerConfig>(create: (context) => PlayerConfig()),
  Provider<DanmakuConfig>(create: (context) => DanmakuConfig()),
  ChangeNotifierProvider<AppTitleBarController>(create: (context) => AppTitleBarController()),
  ChangeNotifierProvider<CommentReportSheetViewModel>(
    create: (context) => CommentReportSheetViewModel(commentRepository: context.read()),
  ),
];
