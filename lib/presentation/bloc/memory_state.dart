import 'package:equatable/equatable.dart';
import '../../domain/entities/memory.dart';

abstract class MemoryState extends Equatable {
  const MemoryState();
  
  @override
  List<Object> get props => [];
}

/// Initial state before any data is loaded
class MemoryInitial extends MemoryState {}

/// State when memories are being fetched
class MemoryLoading extends MemoryState {}

/// State when memories have been successfully loaded
class MemoryLoaded extends MemoryState {
  final List<Memory> memories;

  const MemoryLoaded(this.memories);

  @override
  List<Object> get props => [memories];
}

/// State when an error occurs
class MemoryError extends MemoryState {
  final String message;

  const MemoryError(this.message);

  @override
  List<Object> get props => [message];
}