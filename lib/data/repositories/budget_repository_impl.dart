import 'package:finflow/data/models/budget.dart';
import 'package:finflow/data/datasources/local_storage_service.dart';
import 'package:finflow/data/repositories/budget_repository.dart';
import 'package:finflow/data/repositories/transaction_repository_impl.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final TransactionRepositoryImpl transactionRepository;

  BudgetRepositoryImpl({required this.transactionRepository});

  @override
  Future<List<Budget>> getAllBudgets() async {
    try {
      final budgets = LocalStorageService.budgetsBox.values.toList();
      budgets.sort((a, b) => a.category.name.compareTo(b.category.name));
      return budgets;
    } catch (e) {
      throw Exception('Failed to load budgets: $e');
    }
  }

  @override
  Future<void> addBudget(Budget budget) async {
    try {
      await LocalStorageService.budgetsBox.add(budget);
    } catch (e) {
      throw Exception('Failed to add budget: $e');
    }
  }

  @override
  Future<void> updateBudget(Budget budget) async {
    try {
      final budgetKey = _findBudgetKeyById(budget.id);
      await LocalStorageService.budgetsBox.put(budgetKey, budget);
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    try {
      final budgetKey = _findBudgetKeyById(budgetId);
      await LocalStorageService.budgetsBox.delete(budgetKey);
    } catch (e) {
      throw Exception('Failed to delete budget: $e');
    }
  }

  @override
  Future<Budget?> getBudgetByCategoryAndMonth(String categoryId, DateTime month) async {
    try {
      final budgets = LocalStorageService.budgetsBox.values;
      for (final budget in budgets) {
        if (budget.category.id == categoryId && 
            budget.monthYear == '${month.year}-${month.month.toString().padLeft(2, '0')}') {
          return budget;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<double> getSpentAmount(String categoryId, DateTime month) async {
    try {
      final startDate = DateTime(month.year, month.month, 1);
      final endDate = DateTime(month.year, month.month + 1, 0);
      
      final transactions = await transactionRepository.getTransactionsByDateRange(startDate, endDate);
      
      double totalSpent = 0.0;
      for (final transaction in transactions) {
        if (transaction.categoryId == categoryId && transaction.isExpense) {
          totalSpent += transaction.amount;
        }
      }
      
      return totalSpent;
    } catch (e) {
      return 0.0;
    }
  }

  int _findBudgetKeyById(String budgetId) {
    final budgetEntry = LocalStorageService.budgetsBox.toMap()
        .entries.firstWhere((entry) => entry.value.id == budgetId);
    return budgetEntry.key;
  }
}