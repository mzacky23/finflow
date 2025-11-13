import 'package:finflow/presentation/blocs/goal/goal_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/presentation/blocs/goal/goal_bloc.dart';

class BalanceCard extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const BalanceCard({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final totalIncome = _calculateTotalIncome();
    final totalExpense = _calculateTotalExpense();
    final balance = totalIncome - totalExpense;

    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, goalState) {
        double totalGoalsAmount = 0;
        double totalGoalsSaved = 0;
        
        if (goalState is GoalLoaded) {
          final activeGoals = goalState.goals.where((goal) => !goal.isCompleted);
          totalGoalsAmount = activeGoals.fold(0.0, (sum, goal) => sum + goal.targetAmount);
          totalGoalsSaved = activeGoals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
        }

        return Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  'Current Balance',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Rp ${balance.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: balance >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                
                // Income vs Expense
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildAmountColumn('Income', totalIncome, Colors.green),
                    _buildAmountColumn('Expense', totalExpense, Colors.red),
                  ],
                ),
                
                // Goals Progress (jika ada goals)
                if (totalGoalsAmount > 0) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAmountColumn('Goals Target', totalGoalsAmount, Colors.blue),
                      _buildAmountColumn('Goals Saved', totalGoalsSaved, Colors.purple),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((totalGoalsSaved / totalGoalsAmount) * 100).toStringAsFixed(1)}% of goals saved',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountColumn(String title, double amount, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  double _calculateTotalIncome() {
    return transactions
        .where((transaction) => !transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }

  double _calculateTotalExpense() {
    return transactions
        .where((transaction) => transaction.isExpense)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
  }
}