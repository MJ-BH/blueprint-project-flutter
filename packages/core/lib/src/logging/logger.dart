import 'package:flutter/foundation.dart';

enum LoggerLevel { debug, info, warning, error }

class LogOptions {
  final bool showTime;
  final bool showEmoji;
  final bool logInRelease;
  final LoggerLevel level;

  const LogOptions({
    this.showTime = true,
    this.showEmoji = true,
    this.logInRelease = false,
    this.level = LoggerLevel.debug,
  });
}

class Logger {
  final LogOptions options;
  const Logger({this.options = const LogOptions()});

  void debug(String message, {String? tag}) {
    _log(LoggerLevel.debug, '🐛 $message', tag: tag);
  }

  void info(String message, {String? tag}) {
    _log(LoggerLevel.info, 'ℹ️ $message', tag: tag);
  }

  void warning(String message, {String? tag}) {
    _log(LoggerLevel.warning, '⚠️ $message', tag: tag);
  }

  void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LoggerLevel.error, '🔴 $message ${error ?? ""}', tag: tag);
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }

  void _log(LoggerLevel level, String message, {String? tag}) {
    if (!kDebugMode && !options.logInRelease) return;
    final tagPrefix = tag != null ? '[$tag] ' : '';
    final timestamp = options.showTime ? '[${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)}] ' : '';
    debugPrint('$timestamp$tagPrefix$message');
  }
}

final Logger logger = const Logger();
