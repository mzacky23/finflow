import 'package:finflow/presentation/blocs/goal/goal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/core/routes/app_routes.dart';
import 'package:finflow/presentation/blocs/goal/goal_bloc.dart';
import 'package:finflow/presentation/widgets/goal_card.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.addGoal);
            },
          ),
        ],
      ),
      body: BlocBuilder<GoalBloc, GoalState>(
        builder: (context, state) {
          if (state is GoalLoaded) {
            final activeGoals = state.goals.where((goal) => !goal.isCompleted).toList();
            final completedGoals = state.goals.where((goal) => goal.isCompleted).toList();

            return CustomScrollView(
              slivers: [
                if (activeGoals.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Active Goals',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = activeGoals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GoalCard(goal: goal),
                        );
                      },
                      childCount: activeGoals.length,
                    ),
                  ),
                ],

                // Completed Goals Section
                if (completedGoals.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Completed Goals 🎉',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = completedGoals[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GoalCard(goal: goal),
                        );
                      },
                      childCount: completedGoals.length,
                    ),
                  ),
                ],

                // Empty State
                if (state.goals.isEmpty)
                  const SliverFillRemaining(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.flag, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No goals yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          'Tap + to create your first financial goal',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          } else if (state is GoalError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}