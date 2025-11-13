import 'package:finflow/data/models/transaction_type.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'category.dart';

part 'transaction.g.dart';

@HiveType(typeId: 1)
class Transaction {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double amount;

  @HiveField(2)
  final Category category;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String description;

  @HiveField(5)
  final String? note;

  Transaction({
    String? id,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
    this.note,
  }) : id = id ?? const Uuid().v4();

  TransactionType get type => category.type;

  Transaction copyWith({
    double? amount,
    Category? category,
    DateTime? date,
    String? description,
    String? note,
  }) {
    return Transaction(
      id: id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      note: note ?? this.note,
    );
  }
}
