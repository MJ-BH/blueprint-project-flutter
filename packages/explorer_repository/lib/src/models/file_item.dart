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

  factory FileItem.fromJson(Map<String, dynamic> json) {
    return FileItem(
      id: json['id'] as String,
      name: json['name'] as String,
      type: _parseType(json['type'] as String),
      sizeInBytes: (json['sizeInBytes'] as num?)?.toInt() ?? 0,
      lastModified: DateTime.parse(json['lastModified'] as String),
      parentId: json['parentId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'sizeInBytes': sizeInBytes,
      'lastModified': lastModified.toIso8601String(),
      'parentId': parentId,
    };
  }

  static FileItemType _parseType(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'folder': return FileItemType.folder;
      case 'pdf': return FileItemType.pdf;
      case 'image': return FileItemType.image;
      case 'archive': return FileItemType.archive;
      case 'document':
      default:
        return FileItemType.document;
    }
  }

  @override
  List<Object?> get props => [id, name, type, sizeInBytes, lastModified, parentId];
}
