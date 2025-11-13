import 'package:equatable/equatable.dart';
import 'package:finflow/data/models/budget.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<Budget> budgets;
  final bool showAllTime;
  final DateTime selectedFilter;

  const BudgetLoaded({
    required this.budgets,
    this.showAllTime = true, // DEFAULT ALL TIME
    required this.selectedFilter, // DEFAULT CURRENT MONTH
  });

  @override
  List<Object> get props => [budgets, showAllTime, selectedFilter];

  BudgetLoaded copyWith({
    List<Budget>? budgets,
    bool? showAllTime,
    DateTime? selectedFilter,
  }) {
    return BudgetLoaded(
      budgets: budgets ?? this.budgets,
      showAllTime: showAllTime ?? this.showAllTime,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object> get props => [message];
}