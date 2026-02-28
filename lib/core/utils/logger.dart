import 'package:flutter/foundation.dart';

class Logger {
  void log(String message, {String level = 'DEBUG'}) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      debugPrint('[$timestamp] [$level] $message');
    }
  }

  void debug(String message) => log(message, level: 'DEBUG');
  void info(String message) => log(message, level: 'INFO');
  void warning(String message) => log(message, level: 'WARNING');
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    log('$message${error != null ? ': $error' : ''}', level: 'ERROR');
    if (kDebugMode && stackTrace != null) {
      debugPrint(stackTrace.toString());
    }
  }
}
