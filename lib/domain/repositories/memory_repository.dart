import '../entities/memory.dart';

/// Abstract repository defining memory operations
abstract class MemoryRepository {
  Future<List<Memory>> getMemories();
  Future<void> addMemory(Memory memory);
}