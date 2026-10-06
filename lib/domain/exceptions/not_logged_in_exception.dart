class NotLoggedInException implements Exception {
  const NotLoggedInException();

  @override
  String toString() => 'Not logged in';
}
