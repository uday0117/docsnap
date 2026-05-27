import 'package:uuid/uuid.dart';

class SignatureModel {
  final String id;
  String name;
  final String imagePath;
  final DateTime createdAt;

  SignatureModel({
    String? id,
    required this.name,
    required this.imagePath,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imagePath': imagePath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory SignatureModel.fromJson(Map<String, dynamic> json) => SignatureModel(
        id: json['id'] as String,
        name: json['name'] as String,
        imagePath: json['imagePath'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
