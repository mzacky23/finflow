import 'package:finflow/data/models/goal.dart';
import 'package:finflow/data/datasources/local_storage_service.dart';
import 'package:finflow/data/repositories/goal_repository.dart';

class GoalRepositoryImpl implements GoalRepository {
  @override
  Future<List<Goal>> getAllGoals() async {
    try {
      final goals = LocalStorageService.goalsBox.values.toList();
      // Sort by: overdue first, then by target date
      goals.sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return a.targetDate.compareTo(b.targetDate);
      });
      return goals;
    } catch (e) {
      throw Exception('Failed to load goals: $e');
    }
  }

  @override
  Future<void> addGoal(Goal goal) async {
    try {
      await LocalStorageService.goalsBox.add(goal);
    } catch (e) {
      throw Exception('Failed to add goal: $e');
    }
  }

  @override
  Future<void> updateGoal(Goal goal) async {
    try {
      final goalKey = _findGoalKeyById(goal.id);
      await LocalStorageService.goalsBox.put(goalKey, goal);
    } catch (e) {
      throw Exception('Failed to update goal: $e');
    }
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    try {
      final goalKey = _findGoalKeyById(goalId);
      await LocalStorageService.goalsBox.delete(goalKey);
    } catch (e) {
      throw Exception('Failed to delete goal: $e');
    }
  }

  @override
  Future<void> addToGoal(String goalId, double amount) async {
    try {
      final goalKey = _findGoalKeyById(goalId);
      final goal = LocalStorageService.goalsBox.get(goalKey);
      if (goal != null) {
        final updatedGoal = goal.addAmount(amount);
        await LocalStorageService.goalsBox.put(goalKey, updatedGoal);
      }
    } catch (e) {
      throw Exception('Failed to add to goal: $e');
    }
  }

  @override
  Future<List<Goal>> getActiveGoals() async {
    final goals = await getAllGoals();
    return goals.where((goal) => !goal.isCompleted).toList();
  }

  @override
  Future<List<Goal>> getCompletedGoals() async {
    final goals = await getAllGoals();
    return goals.where((goal) => goal.isCompleted).toList();
  }

  int _findGoalKeyById(String goalId) {
    final goalEntry = LocalStorageService.goalsBox.toMap()
        .entries.firstWhere((entry) => entry.value.id == goalId);
    return goalEntry.key;
  }
}