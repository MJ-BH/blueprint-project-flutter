import 'package:equatable/equatable.dart';

enum FileItemType { folder, document, image, pdf, archive }

class FileItem extends Equatable {
  final String id;
  final String name;
  final FileItemType type;
  final int sizeInBytes;
  final DateTime lastModified;
  final String? parentId;

  const FileItem({
    required this.id,
    required this.name,
    required this.type,
    required this.sizeInBytes,
    required this.lastModified,
    this.parentId,
  });

  bool get isFolder => type == FileItemType.folder;

  @override
  List<Object?> get props => [id, name, type, sizeInBytes, lastModified, parentId];
}
