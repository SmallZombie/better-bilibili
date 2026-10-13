import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/article_repository/article_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/audio_repository/audio_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/audio_repository/audio_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/auth_repository/auth_repository_remote.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/chat_repository/chat_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/comment_repository/comment_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/common_repository/common_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/common_repository/common_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/post_repository/post_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/search_repository/search_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/search_repository/search_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/user_repository/user_repository_login.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository.dart';
import 'package:better_bilibili/data/repositories/bilibili/video_repository/video_repository_login.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository.dart';
import 'package:better_bilibili/data/repositories/bsbsb/bsbsb_repository_remote.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository.dart';
import 'package:better_bilibili/data/repositories/eagle/eagle_repository_remote.dart';
import 'package:better_bilibili/data/services/network_manager.dart';
import 'package:better_bilibili/data/services/storage_service.dart';
import 'package:better_bilibili/data/services/bilibili/bili_background_service.dart';
import 'package:better_bilibili/ui/core/app/app_controller.dart';
import 'package:better_bilibili/ui/core/app/media_session_controller.dart';
import 'package:better_bilibili/ui/core/bilibili/comment/comment_report_sheet/comment_report_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/favorite_folder/edit_video_in_favorite_folder_sheet/edit_video_in_favorite_folder_sheet_view_model.dart';
import 'package:better_bilibili/ui/core/bilibili/user/user_dialog/user_dialog_view_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> get providersOnline => [
  Provider.value(value: StorageService()),
  ListenableProvider(
    create: (context) => AuthRepositoryRemote(config: context.read()) as AuthRepository,
    dispose: (context, value) {
      if (value is AuthRepositoryRemote) {
        value.dispose();
      }
    },
  ),
  Provider(
    create: (context) => VideoRepositoryLogin(authRepository: context.read()) as VideoRepository,
  ),
  Provider(
    // dart format off
    create: (context) => UserRepositoryLogin(
      authRepository: context.read(),
      accountConfig: context.read(),
    ) as UserRepository,
    // dart format on
  ),
  Provider(
    create: (context) => SearchRepositoryLogin(authRepository: context.read()) as SearchRepository,
  ),
  Provider(
    create: (context) => CommonRepositoryLogin(authRepository: context.read()) as CommonRepository,
  ),
  Provider(
    create: (context) => CommentRepositoryLogin(authRepository: context.read()) as CommentRepository,
  ),
  Provider(
    create: (context) => ArticleRepositoryLogin(authRepository: context.read()) as ArticleRepository,
  ),
  Provider(
    create: (context) => PostRepositoryLogin(authRepository: context.read()) as PostRepository,
  ),
  Provider(
    create: (context) => AudioRepositoryLogin(authRepository: context.read()) as AudioRepository,
  ),
  Provider(
    // dart format off
    create: (context) => ChatRepositoryLogin(
      authRepository: context.read(),
      userRepository: context.read(),
    ) as ChatRepository,
    // dart format on
  ),
  Provider(
    create: (context) => BsbsbRepositoryRemote(config: context.read()) as BsbsbRepository,
  ),
  Provider(
    create: (context) => EagleRepositoryRemote(config: context.read()) as EagleRepository,
  ),

  ChangeNotifierProvider(
    create: (context) => EditVideoInFavoriteFolderSheetViewModel(userRepository: context.read()),
  ),
  ChangeNotifierProvider(
    create: (context) => BiliBackgroundService(
      userRepository: context.read(),
      authRepository: context.read(),
      chatRepository: context.read(),
    ),
  ),
  ChangeNotifierProvider(
    create: (context) => UserDialogViewModel(userRepository: context.read()),
  ),
  ChangeNotifierProvider(create: (context) => AppController()),
  Provider.value(value: MediaSessionController()),
  ChangeNotifierProvider(
    create: (context) => CommentReportSheetViewModel(commentRepository: context.read()),
  ),
  Provider(
    create: (_) => NetworkManager(),
    dispose: (_, value) => value.dispose(),
    lazy: false,
  ),
];
