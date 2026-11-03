import 'package:better_bilibili/config/app_config.dart';
import 'package:better_bilibili/config/constants.dart';
import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class UpdateService {
  final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'UpdateService'));

  final AppConfig config;

  UpdateService({required this.config});

  late final Dio _client = Dio();

  Future<UpdateInfo?> checkForUpdates() async {
    final url = config.enablePreReleaseUpdate.value ? kPreReleaseUpdateUrl : kReleaseUpdateUrl;

    try {
      final resp = await _client.get(url);

      final currentVersion = '${config.appVersion}${config.appPrerelease.isNotEmpty ? '-${config.appPrerelease}' : ''}';

      for (final i in resp.data as List) {
        final info = UpdateInfo.fromJson(i);
        if (info.isPreRelease && !config.enablePreReleaseUpdate.value) {
          continue;
        }
        if (info.version != currentVersion) {
          return info;
        } else {
          return null;
        }
      }

      return null;
    } on DioException catch (e, stackTrace) {
      final response = e.response;
      String message;

      if (response != null) {
        message = '${response.data?['status']} ${response.data?['message']}';
      } else {
        message = e.message.toString();
      }

      _log.e('Failed to check for updates: $message', error: e, stackTrace: stackTrace);
      throw Exception(message);
    } catch (e, stackTrace) {
      _log.e('Failed to check for updates: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> downloadAndInstall(String url, ProgressCallback onReceiveProgress) async {
    final tempDir = await getTemporaryDirectory();
    final fullPath = join(tempDir.path, '${config.appPackageName}_update.exe');

    try {
      await _client.downloadUri(
        Uri.parse(url),
        fullPath,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e, stackTrace) {
      _log.e('Failed to download update: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }

    try {
      await launchUrl(Uri.file(fullPath));
    } catch (e, stackTrace) {
      _log.e('Failed to open update file: $e', error: e, stackTrace: stackTrace);
      rethrow;
    }

    await windowManager.close();
  }
}

class UpdateInfo {
  final String version;
  final String downloadUrl;
  final String releaseNotes;
  final bool isPreRelease;
  final bool isMandatory;

  UpdateInfo({
    required this.version,
    required this.downloadUrl,
    required this.releaseNotes,
    this.isPreRelease = false,
    this.isMandatory = false,
  });

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      version: (json['tag_name'] as String).substring(1), // remove "v" prefix
      downloadUrl: (json['assets'] as List).firstWhere((v) => v['name'].endsWith('.exe'))['browser_download_url'] as String,
      releaseNotes: json['body'] as String,
      isPreRelease: json['prerelease'] as bool,
      isMandatory: json['body'].split('\n').first.contains('!!!'),
    );
  }
}
