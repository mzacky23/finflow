import 'package:flutter_bloc/flutter_bloc.dart';
import 'budget_event.dart';
import 'budget_state.dart';
import 'package:finflow/data/repositories/budget_repository.dart';

class BudgetBloc extends Bloc<BudgetEvent, BudgetState> {
  final BudgetRepository budgetRepository;

  BudgetBloc({required this.budgetRepository}) : super(BudgetInitial()) {
    on<LoadBudgets>(_onLoadBudgets);
    on<AddBudget>(_onAddBudget);
    on<UpdateBudget>(_onUpdateBudget);
    on<DeleteBudget>(_onDeleteBudget);
    on<UpdateBudgetFilter>(_onUpdateBudgetFilter);
  }

  BudgetRepository get budgetRepo => budgetRepository;

  Future<void> _onLoadBudgets(
    LoadBudgets event,
    Emitter<BudgetState> emit,
  ) async {
    emit(BudgetLoading());
    try {
      final budgets = await budgetRepository.getAllBudgets();
      emit(
        BudgetLoaded(
          budgets: budgets,
          showAllTime: true,
          selectedFilter: DateTime.now(),
        ),
      );
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onAddBudget(AddBudget event, Emitter<BudgetState> emit) async {
    try {
      await budgetRepository.addBudget(event.budget);
      final budgets = await budgetRepository.getAllBudgets();

      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        emit(currentState.copyWith(budgets: budgets));
      } else {
        emit(
          BudgetLoaded(
            budgets: budgets,
            showAllTime: true,
            selectedFilter: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onUpdateBudget(
    UpdateBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.updateBudget(event.budget);
      final budgets = await budgetRepository.getAllBudgets();

      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        emit(currentState.copyWith(budgets: budgets));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  Future<void> _onDeleteBudget(
    DeleteBudget event,
    Emitter<BudgetState> emit,
  ) async {
    try {
      await budgetRepository.deleteBudget(event.budgetId);
      final budgets = await budgetRepository.getAllBudgets();

      // Pertahankan filter state yang sama
      if (state is BudgetLoaded) {
        final currentState = state as BudgetLoaded;
        emit(currentState.copyWith(budgets: budgets));
      }
    } catch (e) {
      emit(BudgetError(e.toString()));
    }
  }

  void _onUpdateBudgetFilter(
    UpdateBudgetFilter event,
    Emitter<BudgetState> emit,
  ) {
    if (state is BudgetLoaded) {
      final currentState = state as BudgetLoaded;
      emit(
        currentState.copyWith(
          showAllTime: event.showAllTime,
          selectedFilter: event.selectedFilter,
        ),
      );
    }
  }
}
