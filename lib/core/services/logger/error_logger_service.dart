import '../../utilities/console_logger.dart';
import '../../utilities/debug_mode_wrapper.dart';

class ErrorLoggerService {
  final DebugModeWrapper _debugMode;

  ErrorLoggerService({
    DebugModeWrapper? debugMode,
  }) : _debugMode = debugMode ?? DebugModeWrapper();

  void log({
    required Object error,
    StackTrace? stackTrace,
    String? title,
    String? message,
    String? state,
  }) {
    ce(error, title: title, message: message, state: state);
  }
}
