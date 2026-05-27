import 'package:uuid/uuid.dart';

class DocumentModel {
  final String id;
  String name;
  final String pdfPath;
  final List<String> pageImagePaths;
  int pageCount;
  String folder;
  bool isFavorite;
  int sizeBytes;
  final DateTime createdAt;
  DateTime updatedAt;
  String? thumbnailPath;

  DocumentModel({
    String? id,
    required this.name,
    required this.pdfPath,
    required this.pageImagePaths,
    required this.pageCount,
    this.folder = 'Others',
    this.isFavorite = false,
    this.sizeBytes = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.thumbnailPath,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  DocumentModel copyWith({
    String? name,
    String? pdfPath,
    List<String>? pageImagePaths,
    int? pageCount,
    String? folder,
    bool? isFavorite,
    int? sizeBytes,
    DateTime? updatedAt,
    String? thumbnailPath,
  }) {
    return DocumentModel(
      id: id,
      name: name ?? this.name,
      pdfPath: pdfPath ?? this.pdfPath,
      pageImagePaths: pageImagePaths ?? this.pageImagePaths,
      pageCount: pageCount ?? this.pageCount,
      folder: folder ?? this.folder,
      isFavorite: isFavorite ?? this.isFavorite,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'pdfPath': pdfPath,
        'pageImagePaths': pageImagePaths,
        'pageCount': pageCount,
        'folder': folder,
        'isFavorite': isFavorite,
        'sizeBytes': sizeBytes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'thumbnailPath': thumbnailPath,
      };

  factory DocumentModel.fromJson(Map<String, dynamic> json) => DocumentModel(
        id: json['id'] as String,
        name: json['name'] as String,
        pdfPath: json['pdfPath'] as String,
        pageImagePaths: List<String>.from(json['pageImagePaths'] as List),
        pageCount: json['pageCount'] as int,
        folder: (json['folder'] as String?) ?? 'Others',
        isFavorite: (json['isFavorite'] as bool?) ?? false,
        sizeBytes: (json['sizeBytes'] as int?) ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        thumbnailPath: json['thumbnailPath'] as String?,
      );
}
