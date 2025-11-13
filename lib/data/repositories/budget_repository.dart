import 'package:finflow/data/models/budget.dart';

abstract class BudgetRepository {
  Future<List<Budget>> getAllBudgets();
  Future<void> addBudget(Budget budget);
  Future<void> updateBudget(Budget budget);
  Future<void> deleteBudget(String budgetId);
  Future<Budget?> getBudgetByCategoryAndMonth(String categoryId, DateTime month);
  Future<double> getSpentAmount(String categoryId, DateTime month);
}