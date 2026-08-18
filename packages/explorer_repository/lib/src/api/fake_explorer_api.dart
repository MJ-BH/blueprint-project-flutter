import 'dart:async';
import 'package:core/core.dart';

class FakeExplorerApi extends BaseApiService {
  final bool simulateNetworkError;

  FakeExplorerApi({
    this.simulateNetworkError = false,
  }) : super(null);

  final List<Map<String, dynamic>> _mockDatabase = [
    {
      'id': 'f1',
      'name': 'Documents',
      'type': 'folder',
      'sizeInBytes': 0,
      'lastModified': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'parentId': null,
    },
    {
      'id': 'f2',
      'name': 'Images & Design',
      'type': 'folder',
      'sizeInBytes': 0,
      'lastModified': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
      'parentId': null,
    },
    {
      'id': 'f3',
      'name': 'Travel_Voucher_2026.pdf',
      'type': 'pdf',
      'sizeInBytes': 2450000,
      'lastModified': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
      'parentId': null,
    },
    {
      'id': 'f4',
      'name': 'Architecture_Rules.doc',
      'type': 'document',
      'sizeInBytes': 120000,
      'lastModified': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
      'parentId': null,
    },
    // Sub-items inside 'Documents' (f1)
    {
      'id': 'f1_1',
      'name': 'Hera_Maquettes_Dev_v7.pdf',
      'type': 'pdf',
      'sizeInBytes': 5400000,
      'lastModified': DateTime.now().toIso8601String(),
      'parentId': 'f1',
    },
    {
      'id': 'f1_2',
      'name': 'Oolab_Kotlin_Challenge.doc',
      'type': 'document',
      'sizeInBytes': 310000,
      'lastModified': DateTime.now().toIso8601String(),
      'parentId': 'f1',
    },
  ];

  Future<Result<List<Map<String, dynamic>>, Exception>> fetchItems({String? folderId}) async {
    return handleResponse(
      apiCall: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        if (simulateNetworkError) {
          throw const NetworkFailure('Simulated HTTP 500: Internal Server Error');
        }
        final filtered = _mockDatabase.where((item) => item['parentId'] == folderId).toList();
        return Result.success<List<Map<String, dynamic>>, Exception>(filtered);
      },
      onSuccess: (result) => result as Result<List<Map<String, dynamic>>, Exception>,
      logTag: 'FakeExplorerApi.fetchItems',
    );
  }

  Future<Result<Map<String, dynamic>, Exception>> createFolder({
    required String name,
    String? parentId,
  }) async {
    return handleResponse(
      apiCall: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        final newItem = {
          'id': 'folder_${DateTime.now().millisecondsSinceEpoch}',
          'name': name,
          'type': 'folder',
          'sizeInBytes': 0,
          'lastModified': DateTime.now().toIso8601String(),
          'parentId': parentId,
        };
        _mockDatabase.add(newItem);
        return Result.success<Map<String, dynamic>, Exception>(newItem);
      },
      onSuccess: (result) => result as Result<Map<String, dynamic>, Exception>,
      logTag: 'FakeExplorerApi.createFolder',
    );
  }

  Future<Result<bool, Exception>> deleteItem({required String id}) async {
    return handleResponse(
      apiCall: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        _mockDatabase.removeWhere((item) => item['id'] == id || item['parentId'] == id);
        return Result.success<bool, Exception>(true);
      },
      onSuccess: (result) => result as Result<bool, Exception>,
      logTag: 'FakeExplorerApi.deleteItem',
    );
  }
}
