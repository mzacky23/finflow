import 'package:hive/hive.dart';
import 'package:finflow/data/models/category.dart';

part 'budget.g.dart';

@HiveType(typeId: 3)
class Budget {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final Category category;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime month;

  Budget({
    required this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  String get monthYear =>
      '${month.year}-${month.month.toString().padLeft(2, '0')}';

  Budget copyWith({
    String? id,
    Category? category,
    double? amount,
    DateTime? month,
  }) {
    return Budget(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      month: month ?? this.month,
    );
  }
}
