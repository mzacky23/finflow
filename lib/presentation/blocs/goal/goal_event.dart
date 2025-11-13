import 'package:equatable/equatable.dart';
import 'package:finflow/data/models/goal.dart';

abstract class GoalEvent extends Equatable {
  const GoalEvent();

  @override
  List<Object> get props => [];
}

class LoadGoals extends GoalEvent {}

class AddGoal extends GoalEvent {
  final Goal goal;

  const AddGoal(this.goal);

  @override
  List<Object> get props => [goal];
}

class UpdateGoal extends GoalEvent {
  final Goal goal;

  const UpdateGoal(this.goal);

  @override
  List<Object> get props => [goal];
}

class DeleteGoal extends GoalEvent {
  final String goalId;

  const DeleteGoal(this.goalId);

  @override
  List<Object> get props => [goalId];
}

class AddToGoal extends GoalEvent {
  final String goalId;
  final double amount;

  const AddToGoal(this.goalId, this.amount);

  @override
  List<Object> get props => [goalId, amount];
}