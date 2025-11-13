import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  /// Get all transactions sorted by date (newest first)
  Future<List<TransactionEntity>> getAllTransactions();
  
  /// Add a new transaction
  Future<void> addTransaction(TransactionEntity transaction);
  
  /// Update an existing transaction
  Future<void> updateTransaction(TransactionEntity transaction);
  
  /// Delete a transaction by ID
  Future<void> deleteTransaction(String transactionId);
  
  /// Get transactions within a date range
  Future<List<TransactionEntity>> getTransactionsByDateRange(
    DateTime start, 
    DateTime end
  );
  
  /// Get transactions by category
  Future<List<TransactionEntity>> getTransactionsByCategory(String categoryId);
  
  /// Get total income for a period
  Future<double> getTotalIncome(DateTime start, DateTime end);
  
  /// Get total expenses for a period  
  Future<double> getTotalExpenses(DateTime start, DateTime end);
}