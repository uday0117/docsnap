import 'package:uuid/uuid.dart';

class ScannedPage {
  final String id;
  final String imagePath;
  String filter;
  double rotation;
  final DateTime createdAt;

  ScannedPage({
    String? id,
    required this.imagePath,
    this.filter = 'Original',
    this.rotation = 0,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  ScannedPage copyWith({
    String? imagePath,
    String? filter,
    double? rotation,
  }) {
    return ScannedPage(
      id: id,
      imagePath: imagePath ?? this.imagePath,
      filter: filter ?? this.filter,
      rotation: rotation ?? this.rotation,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'filter': filter,
        'rotation': rotation,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ScannedPage.fromJson(Map<String, dynamic> json) => ScannedPage(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String,
        filter: (json['filter'] as String?) ?? 'Original',
        rotation: (json['rotation'] as num?)?.toDouble() ?? 0,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
