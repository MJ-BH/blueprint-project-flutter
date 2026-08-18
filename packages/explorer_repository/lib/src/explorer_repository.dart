import 'package:core/core.dart';
import 'api/fake_explorer_api.dart';
import 'models/file_item.dart';

abstract class ExplorerRepository {
  Future<Result<List<FileItem>, Exception>> getItems({String? folderId});
  Future<Result<FileItem, Exception>> createFolder(String name, {String? parentId});
  Future<Result<bool, Exception>> deleteItem(String id);
}

class ExplorerRepositoryImpl extends BaseRepository implements ExplorerRepository {
  final FakeExplorerApi _api;

  ExplorerRepositoryImpl({FakeExplorerApi? api})
      : _api = api ?? FakeExplorerApi();

  @override
  Future<Result<List<FileItem>, Exception>> getItems({String? folderId}) async {
    return handleRepositoryCall(
      call: () async {
        final result = await _api.fetchItems(folderId: folderId);
        return result.fold(
          (jsonList) {
            final items = jsonList.map((json) => FileItem.fromJson(json)).toList();
            return Result.success(items);
          },
          (failure) => Result.failure(failure),
        );
      },
      logTag: 'ExplorerRepositoryImpl.getItems',
    );
  }

  @override
  Future<Result<FileItem, Exception>> createFolder(String name, {String? parentId}) async {
    return handleRepositoryCall(
      call: () async {
        final result = await _api.createFolder(name: name, parentId: parentId);
        return result.fold(
          (json) => Result.success(FileItem.fromJson(json)),
          (failure) => Result.failure(failure),
        );
      },
      logTag: 'ExplorerRepositoryImpl.createFolder',
    );
  }

  @override
  Future<Result<bool, Exception>> deleteItem(String id) async {
    return handleRepositoryCall(
      call: () async {
        return await _api.deleteItem(id: id);
      },
      logTag: 'ExplorerRepositoryImpl.deleteItem',
    );
  }
}
