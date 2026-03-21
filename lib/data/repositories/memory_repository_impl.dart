import '../../domain/entities/memory.dart';
import '../../domain/repositories/memory_repository.dart';
import '../data_sources/local/memory_local_data_source.dart';
import '../models/memory_model.dart';

/// Implementation of the MemoryRepository connecting domain to data source
class MemoryRepositoryImpl implements MemoryRepository {
  final MemoryLocalDataSource localDataSource;

  MemoryRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Memory>> getMemories() async {
    return await localDataSource.getMemories();
  }

  @override
  Future<void> addMemory(Memory memory) async {
    final model = MemoryModel.fromEntity(memory);
    await localDataSource.saveMemory(model);
  }
}