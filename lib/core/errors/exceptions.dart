class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'لا يوجد اتصال بالإنترنت']);

  @override
  String toString() => message;
}
