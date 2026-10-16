class BiliHttpException implements Exception {
  final int code;
  final String message;

  const BiliHttpException(this.code, this.message);

  @override
  String toString() => '$code: $message';
}
