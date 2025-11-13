import 'package:hive/hive.dart';
import 'transaction_type.dart';

part 'category.g.dart';

@HiveType(typeId: 0)
class Category {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String icon;
  
  @HiveField(3)
  final int color;
  
  @HiveField(4)
  final TransactionType type;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
  });

  // Predefined categories
  static List<Category> get defaultCategories => [
    // Expense Categories
    Category(id: '1', name: 'Food & Drink', icon: '🍔', color: 0xFFFF6B6B, type: TransactionType.expense),
    Category(id: '2', name: 'Transport', icon: '🚗', color: 0xFF4ECDC4, type: TransactionType.expense),
    Category(id: '3', name: 'Shopping', icon: '🛍️', color: 0xFFFFD166, type: TransactionType.expense),
    Category(id: '4', name: 'Entertainment', icon: '🎬', color: 0xFF6A0572, type: TransactionType.expense),
    Category(id: '5', name: 'Bills', icon: '📱', color: 0xFF118AB2, type: TransactionType.expense),
    
    // Income Categories  
    Category(id: '6', name: 'Salary', icon: '💼', color: 0xFF06D6A0, type: TransactionType.income),
    Category(id: '7', name: 'Freelance', icon: '💻', color: 0xFF1A936F, type: TransactionType.income),
    Category(id: '8', name: 'Investment', icon: '📈', color: 0xFF114B5F, type: TransactionType.income),
  ];
}