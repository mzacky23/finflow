import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final int categoryColor;
  final DateTime date;
  final String description;
  final String? note;
  final bool isExpense;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.date,
    required this.description,
    this.note,
    required this.isExpense,
  });

  @override
  List<Object?> get props => [
        id,
        amount,
        categoryId,
        categoryName,
        categoryIcon,
        categoryColor,
        date,
        description,
        note,
        isExpense,
      ];
}