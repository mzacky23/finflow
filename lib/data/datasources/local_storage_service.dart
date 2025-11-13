import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../models/budget.dart';
import '../models/goal.dart';

class LocalStorageService {
  static Future<void> init() async {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path);

    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(CategoryAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(GoalAdapter());

    await Hive.openBox<Transaction>('transactions');
    await Hive.openBox<Category>('categories');
    await Hive.openBox<Budget>('budgets');
    await Hive.openBox<Goal>('goals');

    await _seedInitialCategories();
  }

  static Future<void> _seedInitialCategories() async {
    final categoriesBox = Hive.box<Category>('categories');
    if (categoriesBox.isEmpty) {
      for (final category in Category.defaultCategories) {
        await categoriesBox.put(category.id, category);
      }
    }
  }

  static Box<Transaction> get transactionsBox =>
      Hive.box<Transaction>('transactions');
  static Box<Category> get categoriesBox => Hive.box<Category>('categories');
  static Box<Budget> get budgetsBox => Hive.box<Budget>('budgets');
  static Box<Goal> get goalsBox => Hive.box<Goal>('goals');
}
