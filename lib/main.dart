import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/constants/app_colors.dart';
import 'data/data_sources/local/memory_local_data_source.dart';
import 'data/repositories/memory_repository_impl.dart';
import 'presentation/bloc/memory_bloc.dart';
import 'presentation/bloc/memory_event.dart';
import 'presentation/pages/home_page.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences (Local Storage)
  final sharedPreferences = await SharedPreferences.getInstance();

  // Setup Dependency Injection manually (Clean Architecture flow)
  final localDataSource = MemoryLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  final repository = MemoryRepositoryImpl(localDataSource: localDataSource);

  runApp(MemoirPathApp(repository: repository));
}

class MemoirPathApp extends StatelessWidget {
  final MemoryRepositoryImpl repository;

  const MemoirPathApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<MemoryBloc>(
          // Initialize Bloc and trigger the first load event
          create: (context) => MemoryBloc(repository: repository)..add(LoadMemories()),
        ),
      ],
      child: MaterialApp(
        title: 'Memoir Path',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: AppColors.terracotta,
          scaffoldBackgroundColor: AppColors.warmSand,
          colorScheme: const ColorScheme.light(
            primary: AppColors.terracotta,
            secondary: AppColors.deepNavy,
          ),
          fontFamily: 'Roboto', // Change this to any custom font you add in pubspec
        ),
        home: const HomePage(),
      ),
    );
  }
}