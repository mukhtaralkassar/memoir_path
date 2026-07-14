import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/dio_client.dart';
import '../api/storefolio_api.dart';

final dioProvider = Provider((ref) => DioClient.instance);

final apiProvider = Provider<StorefolioApi>((ref) {
  final dio = ref.watch(dioProvider);
  return StorefolioApi(dio);
});
