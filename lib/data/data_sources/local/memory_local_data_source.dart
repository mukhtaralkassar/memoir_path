import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/memory_model.dart';

abstract class MemoryLocalDataSource {
  Future<List<MemoryModel>> getMemories();
  Future<void> saveMemory(MemoryModel memory);
}

const String cachedMemoriesKey = 'CACHED_MEMORIES';

/// Implementation of the local data source using SharedPreferences
class MemoryLocalDataSourceImpl implements MemoryLocalDataSource {
  final SharedPreferences sharedPreferences;

  MemoryLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MemoryModel>> getMemories() async {
    final jsonStringList = sharedPreferences.getStringList(cachedMemoriesKey);
    if (jsonStringList != null) {
      return jsonStringList
          .map((jsonStr) => MemoryModel.fromJson(jsonDecode(jsonStr)))
          .toList()
        // Sort descending by exact date and time
        ..sort((a, b) => b.date.compareTo(a.date)); 
    } else {
      return [];
    }
  }

  @override
  Future<void> saveMemory(MemoryModel memory) async {
    final memories = await getMemories();
    memories.add(memory);
    
    final jsonStringList = memories
        .map((model) => jsonEncode(model.toJson()))
        .toList();
        
    await sharedPreferences.setStringList(cachedMemoriesKey, jsonStringList);
  }
}