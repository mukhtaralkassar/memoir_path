import 'package:equatable/equatable.dart';

/// Represents a single memory or journey node in the domain layer.
/// Now supports an optional image path.
class Memory extends Equatable {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String? imagePath; // Added to support local image storage

  const Memory({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.imagePath,
  });

  @override
  List<Object?> get props => [id, title, description, date, imagePath];
}