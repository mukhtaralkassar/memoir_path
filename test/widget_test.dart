// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:memoir_path/data/data_sources/local/memory_local_data_source.dart';
import 'package:memoir_path/data/repositories/memory_repository_impl.dart';

import 'package:memoir_path/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App initialization test', (WidgetTester tester) async {
    // 1. Initialize Mock SharedPreferences for the testing environment
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();
    
    // 2. Set up the required dependencies
    final localDataSource = MemoryLocalDataSourceImpl(sharedPreferences: sharedPreferences);
    final repository = MemoryRepositoryImpl(localDataSource: localDataSource);

    // 3. Build our app and trigger a frame, passing the repository
    await tester.pumpWidget(MemoirPathApp(repository: repository));

    // 4. Verify that the app's title 'Memoir Path' is found on the screen
    expect(find.text('Memoir Path'), findsWidgets);
  });
}