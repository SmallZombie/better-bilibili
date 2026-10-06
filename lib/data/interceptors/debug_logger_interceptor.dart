import 'dart:convert';
import 'dart:io';

import 'package:better_bilibili/utils/composable_prefix_printer.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final Logger _log = Logger(printer: ComposablePrefixPrinter(prefix: 'debugLoggerInterceptor'));

final debugLoggerInterceptor = InterceptorsWrapper(
  onResponse: (response, handler) async {
    await _persistHttpTraffic(requestOptions: response.requestOptions, response: response);
    return handler.next(response);
  },
  onError: (error, handler) async {
    await _persistHttpTraffic(
      requestOptions: error.requestOptions,
      response: error.response,
      error: error,
    );
    return handler.next(error);
  },
);

Future<void> _persistHttpTraffic({
  required RequestOptions requestOptions,
  Response<dynamic>? response,
  DioException? error,
}) async {
  try {
    final logsDir = Directory('${Directory.systemTemp.path}\\better_bilibili_http_logs');
    if (!await logsDir.exists()) {
      await logsDir.create(recursive: true);
    }

    final urlPath = requestOptions.uri.path.isEmpty ? 'root' : requestOptions.uri.path;
    final safeName = urlPath.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${safeName.isEmpty ? 'request' : safeName}_$timestamp.txt';
    final logFile = File('${logsDir.path}\\$fileName');

    final requestInfo = StringBuffer()
      ..writeln('==== REQUEST ====')
      ..writeln('time: ${DateTime.now().toIso8601String()}')
      ..writeln('method: ${requestOptions.method}')
      ..writeln('uri: ${requestOptions.uri}')
      ..writeln('baseUrl: ${requestOptions.baseUrl}')
      ..writeln('path: ${requestOptions.path}')
      ..writeln('queryParameters: ${_encodePretty(requestOptions.queryParameters)}')
      ..writeln('headers: ${_encodePretty(requestOptions.headers)}')
      ..writeln('extra: ${_encodePretty(requestOptions.extra)}')
      ..writeln('contentType: ${requestOptions.contentType}')
      ..writeln('responseType: ${requestOptions.responseType}')
      ..writeln('followRedirects: ${requestOptions.followRedirects}')
      ..writeln('connectTimeout: ${requestOptions.connectTimeout}')
      ..writeln('sendTimeout: ${requestOptions.sendTimeout}')
      ..writeln('receiveTimeout: ${requestOptions.receiveTimeout}')
      ..writeln('requestBody: ${_encodePretty(requestOptions.data)}');

    final responseInfo = StringBuffer()..writeln('==== RESPONSE ====');
    if (response != null) {
      responseInfo
        ..writeln('statusCode: ${response.statusCode}')
        ..writeln('statusMessage: ${response.statusMessage}')
        ..writeln('isRedirect: ${response.isRedirect}')
        ..writeln('realUri: ${response.realUri}')
        ..writeln('extra: ${_encodePretty(response.extra)}')
        ..writeln('headers: ${_encodePretty(response.headers.map)}')
        ..writeln('responseBody: ${_encodePretty(response.data)}');
    } else {
      responseInfo.writeln('status: no response');
    }

    if (error != null) {
      responseInfo
        ..writeln('errorType: ${error.type}')
        ..writeln('errorMessage: ${error.message}')
        ..writeln('error: ${_encodePretty(error.error)}')
        ..writeln('stackTrace: ${error.stackTrace}');
    }

    await logFile.writeAsString('${requestInfo.toString()}\n\n${responseInfo.toString()}');
  } catch (e, stackTrace) {
    _log.e('Save http log failed', error: e, stackTrace: stackTrace);
  }
}

String _encodePretty(dynamic value) {
  if (value == null) {
    return 'null';
  }
  try {
    if (value is String) {
      final maybeJson = jsonDecode(value);
      return const JsonEncoder.withIndent('  ').convert(maybeJson);
    }
    if (value is List<int>) {
      return value.toString();
    }
    return const JsonEncoder.withIndent('  ').convert(value);
  } catch (_) {
    return value.toString();
  }
}
