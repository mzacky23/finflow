import 'package:hive/hive.dart';

part 'transaction_type.g.dart'; 

@HiveType(typeId: 2) 
enum TransactionType {
  @HiveField(0)
  expense,
  
  @HiveField(1)
  income;

  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }

  String get emoji => this == TransactionType.income ? '💰' : '💸';
}