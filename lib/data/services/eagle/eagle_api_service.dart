import 'dart:convert';

import 'package:better_bilibili/data/model/eagle/folder.dart';
import 'package:better_bilibili/utils/result.dart';
import 'package:dio/dio.dart';

class EagleApiService {
  final Future<Dio> Function() getClient;

  const EagleApiService({required this.getClient});

  Future<Result<List<Folder>>> getRecentFolderList() async {
    final client = await getClient();
    try {
      final resp = await client.get('/api/folder/listRecent');

      return Result.ok((resp.data['data'] as List).map((e) => Folder.fromJson(e)).toList());
    } on DioException catch (e) {
      final resp = e.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${e.message}'));
      }
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }
  }

  Future<Result<void>> saveImage({required String imageUrl, required String sourceUrl, required String name}) async {
    final client = await getClient();

    try {
      await client.post(
        '/api/item/addFromURL',
        options: Options(contentType: 'application/json'),
        data: jsonEncode({
          'name': name,
          'website': sourceUrl,
          'notification': true,
          'url': imageUrl,
          'tags': [],
          'folderIDs': [],
          'modificationTime': DateTime.now().millisecondsSinceEpoch,
        }),
      );

      return Result.ok(null);
    } on DioException catch (e) {
      final resp = e.response;
      if (resp == null) {
        return Result.error(Exception('Unknown error: ${e.message}'));
      }
      return Result.error(Exception('${resp.data['code']}: ${resp.data['message']}'));
    }
  }
}
