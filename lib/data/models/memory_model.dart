import '../../domain/entities/memory.dart';

/// Represents the data model of a memory, adding serialization logic.
class MemoryModel extends Memory {
  const MemoryModel({
    required super.id,
    required super.title,
    required super.description,
    required super.date,
    super.imagePath,
  });

  /// Creates a model from a JSON map
  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      imagePath: json['imagePath'] as String?,
    );
  }

  /// Converts the model to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'imagePath': imagePath,
    };
  }

  /// Creates a model from a domain entity
  factory MemoryModel.fromEntity(Memory entity) {
    return MemoryModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      date: entity.date,
      imagePath: entity.imagePath,
    );
  }
}