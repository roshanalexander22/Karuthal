import 'package:logger/logger.dart';

class AppLogger {
  final String? _tag;
  const AppLogger([this._tag]);
  factory AppLogger.forName(String name) => AppLogger(name);

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
  );

  void d(String message) => _logger.d(_tag != null ? '[$_tag] $message' : message);
  void i(String message) => _logger.i(_tag != null ? '[$_tag] $message' : message);
  void w(String message) => _logger.w(_tag != null ? '[$_tag] $message' : message);
  void e(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(_tag != null ? '[$_tag] $message' : message, error: error, stackTrace: stackTrace);

  static void staticD(String message) => _logger.d(message);
  static void staticI(String message) => _logger.i(message);
  static void staticW(String message) => _logger.w(message);
  static void staticE(String message, [dynamic error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
