import 'package:flutter_bloc/flutter_bloc.dart';
import 'goal_event.dart';
import 'goal_state.dart';
import 'package:finflow/data/repositories/goal_repository.dart';

class GoalBloc extends Bloc<GoalEvent, GoalState> {
  final GoalRepository goalRepository;

  GoalBloc({required this.goalRepository}) : super(GoalInitial()) {
    on<LoadGoals>(_onLoadGoals);
    on<AddGoal>(_onAddGoal);
    on<UpdateGoal>(_onUpdateGoal);
    on<DeleteGoal>(_onDeleteGoal);
    on<AddToGoal>(_onAddToGoal);
  }

  Future<void> _onLoadGoals(
    LoadGoals event,
    Emitter<GoalState> emit,
  ) async {
    emit(GoalLoading());
    try {
      final goals = await goalRepository.getAllGoals();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAddGoal(
    AddGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.addGoal(event.goal);
      final goals = await goalRepository.getAllGoals();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onUpdateGoal(
    UpdateGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.updateGoal(event.goal);
      final goals = await goalRepository.getAllGoals();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onDeleteGoal(
    DeleteGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.deleteGoal(event.goalId);
      final goals = await goalRepository.getAllGoals();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }

  Future<void> _onAddToGoal(
    AddToGoal event,
    Emitter<GoalState> emit,
  ) async {
    try {
      await goalRepository.addToGoal(event.goalId, event.amount);
      final goals = await goalRepository.getAllGoals();
      emit(GoalLoaded(goals));
    } catch (e) {
      emit(GoalError(e.toString()));
    }
  }
}