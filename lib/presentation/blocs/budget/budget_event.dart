import 'package:equatable/equatable.dart';
import 'package:finflow/data/models/budget.dart';

abstract class BudgetEvent extends Equatable {
  const BudgetEvent();

  @override
  List<Object> get props => [];
}

class LoadBudgets extends BudgetEvent {}

class AddBudget extends BudgetEvent {
  final Budget budget;

  const AddBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class UpdateBudget extends BudgetEvent {
  final Budget budget;

  const UpdateBudget(this.budget);

  @override
  List<Object> get props => [budget];
}

class DeleteBudget extends BudgetEvent {
  final String budgetId;

  const DeleteBudget(this.budgetId);

  @override
  List<Object> get props => [budgetId];
}

class UpdateBudgetFilter extends BudgetEvent {
  final bool showAllTime;
  final DateTime selectedFilter;

  const UpdateBudgetFilter({
    required this.showAllTime,
    required this.selectedFilter,
  });

  @override
  List<Object> get props => [showAllTime, selectedFilter];
}