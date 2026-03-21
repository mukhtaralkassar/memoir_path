import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../bloc/memory_bloc.dart';
import '../bloc/memory_state.dart';
import '../widgets/timeline/journey_timeline_node.dart';
import 'add_memory_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.warmSand,
      appBar: AppBar(
        title: const Text(
          'Memoir Path',
          style: TextStyle(
            color: AppColors.deepNavy,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocBuilder<MemoryBloc, MemoryState>(
        builder: (context, state) {
          if (state is MemoryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.terracotta),
            );
          } else if (state is MemoryLoaded) {
            if (state.memories.isEmpty) {
              return const Center(
                child: Text(
                  'Your path is empty.\nAdd your first memory!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.deepNavy, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              itemCount: state.memories.length,
              itemBuilder: (context, index) {
                final memory = state.memories[index];
                return JourneyTimelineNode(
                  memory: memory,
                  isFirstNode: index == 0,
                  isLastNode: index == state.memories.length - 1,
                  alignLeft: index % 2 == 0,
                );
              },
            );
          } else if (state is MemoryError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddMemoryPage()),
          );
        },
        backgroundColor: AppColors.deepNavy,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }
}