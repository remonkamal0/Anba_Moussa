class Logger {
  void debug(String message) {
    print('[DEBUG] $message');
  }

  void info(String message) {
    print('[INFO] $message');
  }

  void warning(String message) {
    print('[WARNING] $message');
  }

  void error(String message) {
    print('[ERROR] $message');
  }

  void log(String message, {String level = 'INFO'}) {
    print('[$level] $message');
  }
}
