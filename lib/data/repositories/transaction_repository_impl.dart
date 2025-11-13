import 'package:finflow/data/models/transaction_type.dart';
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/domain/repositories/transaction_repository.dart';
import 'package:finflow/data/datasources/local_storage_service.dart';
import 'package:finflow/data/models/transaction.dart' as model;
import 'package:finflow/data/models/category.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  @override
  Future<List<TransactionEntity>> getAllTransactions() async {
    try {
      final transactions = LocalStorageService.transactionsBox.values.toList();
      
      // Sort by date (newest first)
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      return transactions.map(_toEntity).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  @override
  Future<void> addTransaction(TransactionEntity entity) async {
    try {
      final category = _findCategoryById(entity.categoryId);
      final transaction = model.Transaction(
        amount: entity.amount,
        category: category,
        date: entity.date,
        description: entity.description,
        note: entity.note,
      );
      
      await LocalStorageService.transactionsBox.add(transaction);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity entity) async {
    try {
      final transactionKey = _findTransactionKeyById(entity.id);
      final category = _findCategoryById(entity.categoryId);
      
      final updatedTransaction = model.Transaction(
        id: entity.id,
        amount: entity.amount,
        category: category,
        date: entity.date,
        description: entity.description,
        note: entity.note,
      );
      
      await LocalStorageService.transactionsBox.put(transactionKey, updatedTransaction);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<void> deleteTransaction(String transactionId) async {
    try {
      final transactionKey = _findTransactionKeyById(transactionId);
      await LocalStorageService.transactionsBox.delete(transactionKey);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start, 
    DateTime end,
  ) async {
    try {
      final transactions = LocalStorageService.transactionsBox.values
          .where((t) => t.date.isAfter(start.subtract(const Duration(days: 1))) && 
                        t.date.isBefore(end.add(const Duration(days: 1))))
          .toList();
      
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      return transactions.map(_toEntity).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId) async {
    try {
      final transactions = LocalStorageService.transactionsBox.values
          .where((t) => t.category.id == categoryId)
          .toList();
      
      transactions.sort((a, b) => b.date.compareTo(a.date));
      
      return transactions.map(_toEntity).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by category: $e');
    }
  }

  @override
  Future<double> getTotalIncome(DateTime start, DateTime end) async {
    try {
      final transactions = await getTransactionsByDateRange(start, end);
      double total = 0.0;
      for (final transaction in transactions) {
        if (!transaction.isExpense) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Failed to calculate total income: $e');
    }
  }

  @override
  Future<double> getTotalExpenses(DateTime start, DateTime end) async {
    try {
      final transactions = await getTransactionsByDateRange(start, end);
      double total = 0.0;
      for (final transaction in transactions) {
        if (transaction.isExpense) {
          total += transaction.amount;
        }
      }
      return total;
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  // ============ HELPER METHODS ============

  /// Convert model.Transaction to TransactionEntity
  TransactionEntity _toEntity(model.Transaction transaction) {
    return TransactionEntity(
      id: transaction.id,
      amount: transaction.amount,
      categoryId: transaction.category.id,
      categoryName: transaction.category.name,
      categoryIcon: transaction.category.icon,
      categoryColor: transaction.category.color,
      date: transaction.date,
      description: transaction.description,
      note: transaction.note,
      isExpense: transaction.type == TransactionType.expense,
    );
  }

  /// Find category by ID
  Category _findCategoryById(String categoryId) {
    try {
      final category = LocalStorageService.categoriesBox.values
          .firstWhere((c) => c.id == categoryId);
      return category;
    } catch (e) {
      throw Exception('Category not found: $categoryId');
    }
  }

  /// Find Hive key for transaction by ID
  int _findTransactionKeyById(String transactionId) {
    try {
      final transactionEntry = LocalStorageService.transactionsBox.toMap()
          .entries.firstWhere((entry) => entry.value.id == transactionId);
      return transactionEntry.key;
    } catch (e) {
      throw Exception('Transaction not found: $transactionId');
    }
  }

  /// Get all available categories
  List<Category> getAvailableCategories() {
    return LocalStorageService.categoriesBox.values.toList();
  }

  /// Get categories by type (expense/income)
  List<Category> getCategoriesByType(TransactionType type) {
    return LocalStorageService.categoriesBox.values
        .where((category) => category.type == type)
        .toList();
  }
}