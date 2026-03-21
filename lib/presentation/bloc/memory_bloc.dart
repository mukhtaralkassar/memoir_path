import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/memory_repository.dart';
import 'memory_event.dart';
import 'memory_state.dart';

/// BLoC handling the business logic for memory operations
class MemoryBloc extends Bloc<MemoryEvent, MemoryState> {
  final MemoryRepository repository;

  MemoryBloc({required this.repository}) : super(MemoryInitial()) {
    on<LoadMemories>(_onLoadMemories);
    on<AddMemory>(_onAddMemory);
  }

  Future<void> _onLoadMemories(LoadMemories event, Emitter<MemoryState> emit) async {
    emit(MemoryLoading());
    try {
      final memories = await repository.getMemories();
      emit(MemoryLoaded(memories));
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> _onAddMemory(AddMemory event, Emitter<MemoryState> emit) async {
    try {
      await repository.addMemory(event.memory);
      // Reload the memories after adding a new one
      add(LoadMemories());
    } catch (e) {
      emit(MemoryError(e.toString()));
    }
  }
}