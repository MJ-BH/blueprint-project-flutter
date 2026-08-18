import '../logging/logger.dart';

abstract class BaseApiService {
  final dynamic client;
  BaseApiService(this.client);

  Future<T> handleResponse<T>({
    required Future<dynamic> Function() apiCall,
    required T Function(dynamic data) onSuccess,
    required String logTag,
  }) async {
    try {
      logger.info('Executing API Call', tag: logTag);
      final rawResponse = await apiCall();
      return onSuccess(rawResponse);
    } catch (e, stack) {
      logger.error('API Error encountered', error: e, stackTrace: stack, tag: logTag);
      rethrow;
    }
  }
}
