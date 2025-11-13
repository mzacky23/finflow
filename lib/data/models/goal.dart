import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

@HiveType(typeId: 4)
class Goal {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final double targetAmount;

  @HiveField(4)
  final double currentAmount;

  @HiveField(5)
  final DateTime targetDate;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String icon;

  @HiveField(8)
  final int color;

  Goal({
    String? id,
    required this.title,
    required this.description,
    required this.targetAmount,
    required this.targetDate,
    this.currentAmount = 0.0,
    DateTime? createdAt,
    this.icon = '🎯',
    this.color = 0xFF6366F1, // Default indigo color
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  // Progress percentage (0.0 to 1.0)
  double get progress => targetAmount > 0 ? currentAmount / targetAmount : 0.0;

  int get daysRemaining => targetDate.difference(DateTime.now()).inDays;

  bool get isCompleted => progress >= 1.0;

  bool get isOverdue => DateTime.now().isAfter(targetDate) && !isCompleted;

  double get amountNeeded => targetAmount - currentAmount;

  Goal copyWith({
    String? title,
    String? description,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    String? icon,
    int? color,
  }) {
    return Goal(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Goal addAmount(double amount) {
    return copyWith(currentAmount: currentAmount + amount);
  }
}
