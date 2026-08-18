import 'models/file_item.dart';

abstract class ExplorerRepository {
  Future<List<FileItem>> getItems({String? folderId});
  Future<FileItem> createFolder(String name, {String? parentId});
  Future<void> deleteItem(String id);
  Future<FileItem> uploadFile(String name, FileItemType type, int size, {String? parentId});
}

class MockExplorerRepository implements ExplorerRepository {
  final List<FileItem> _mockDatabase = [
    FileItem(id: 'f1', name: 'Documents', type: FileItemType.folder, sizeInBytes: 0, lastModified: DateTime.now().subtract(const Duration(days: 2))),
    FileItem(id: 'f2', name: 'Images & Design', type: FileItemType.folder, sizeInBytes: 0, lastModified: DateTime.now().subtract(const Duration(days: 5))),
    FileItem(id: 'f3', name: 'Travel_Voucher_2026.pdf', type: FileItemType.pdf, sizeInBytes: 2450000, lastModified: DateTime.now().subtract(const Duration(hours: 4))),
    FileItem(id: 'f4', name: 'Architecture_Rules.doc', type: FileItemType.document, sizeInBytes: 120000, lastModified: DateTime.now().subtract(const Duration(days: 1))),
    
    // Items inside 'Documents' (f1)
    FileItem(id: 'f1_1', name: 'Hera_Maquettes_Dev_v7.pdf', type: FileItemType.pdf, sizeInBytes: 5400000, lastModified: DateTime.now(), parentId: 'f1'),
    FileItem(id: 'f1_2', name: 'Oolab_Kotlin_Challenge.doc', type: FileItemType.document, sizeInBytes: 310000, lastModified: DateTime.now(), parentId: 'f1'),
    
    // Items inside 'Images & Design' (f2)
    FileItem(id: 'f2_1', name: 'hero_banner_preview.png', type: FileItemType.image, sizeInBytes: 1800000, lastModified: DateTime.now(), parentId: 'f2'),
  ];

  @override
  Future<List<FileItem>> getItems({String? folderId}) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _mockDatabase.where((item) => item.parentId == folderId).toList();
  }

  @override
  Future<FileItem> createFolder(String name, {String? parentId}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final newFolder = FileItem(
      id: 'folder_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: FileItemType.folder,
      sizeInBytes: 0,
      lastModified: DateTime.now(),
      parentId: parentId,
    );
    _mockDatabase.add(newFolder);
    return newFolder;
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _mockDatabase.removeWhere((item) => item.id == id || item.parentId == id);
  }

  @override
  Future<FileItem> uploadFile(String name, FileItemType type, int size, {String? parentId}) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final newFile = FileItem(
      id: 'file_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      type: type,
      sizeInBytes: size,
      lastModified: DateTime.now(),
      parentId: parentId,
    );
    _mockDatabase.add(newFile);
    return newFile;
  }
}
