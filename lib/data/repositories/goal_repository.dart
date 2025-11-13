import 'package:finflow/data/models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> getAllGoals();
  Future<void> addGoal(Goal goal);
  Future<void> updateGoal(Goal goal);
  Future<void> deleteGoal(String goalId);
  Future<void> addToGoal(String goalId, double amount);
  Future<List<Goal>> getActiveGoals();
  Future<List<Goal>> getCompletedGoals();
}