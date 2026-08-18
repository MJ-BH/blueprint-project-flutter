import '../logging/logger.dart';

abstract class BaseRepository {
  Future<T> handleRepositoryCall<T>({
    required Future<T> Function() call,
    required String logTag,
  }) async {
    try {
      logger.info('Handling repository execution', tag: logTag);
      return await call();
    } catch (e, stack) {
      logger.error('Repository Error', error: e, stackTrace: stack, tag: logTag);
      rethrow;
    }
  }
}
