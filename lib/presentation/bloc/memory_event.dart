import 'package:equatable/equatable.dart';
import '../../domain/entities/memory.dart';

abstract class MemoryEvent extends Equatable {
  const MemoryEvent();

  @override
  List<Object> get props => [];
}

/// Event triggered when the application needs to load all memories
class LoadMemories extends MemoryEvent {}

/// Event triggered when a user adds a new memory
class AddMemory extends MemoryEvent {
  final Memory memory;

  const AddMemory(this.memory);

  @override
  List<Object> get props => [memory];
}