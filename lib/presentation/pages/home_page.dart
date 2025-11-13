import 'package:finflow/data/models/goal.dart';
import 'package:finflow/presentation/blocs/goal/goal_state.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_event.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/core/routes/app_routes.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:finflow/presentation/blocs/goal/goal_bloc.dart';
import 'package:finflow/presentation/widgets/balance_card.dart';
import 'package:finflow/presentation/widgets/transaction_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _navigateToAddTransaction(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.addTransaction);
  }

  void _navigateToGoals(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.goals);
  }

  void _navigateToBudgets(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.budgets);
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 80), // FIXED HEIGHT
        child: Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.receipt_long,
                title: 'Transaction',
                color: Colors.blue,
                onTap: () => _navigateToAddTransaction(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.flag,
                title: 'Goals',
                color: Colors.purple,
                onTap: () => _navigateToGoals(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildQuickActionCard(
                icon: Icons.account_balance_wallet,
                title: 'Budgets',
                color: Colors.orange,
                onTap: () => _navigateToBudgets(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12), // REDUCED PADDING
          height: 80, // FIXED HEIGHT
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32, // SMALLER ICON
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16), // SMALLER ICON
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11, // SMALLER TEXT
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Goals Overview - SUPER COMPACT
  Widget _buildGoalsOverview(BuildContext context) {
    return BlocBuilder<GoalBloc, GoalState>(
      builder: (context, state) {
        if (state is GoalLoaded && state.goals.isNotEmpty) {
          final activeGoals = state.goals
              .where((goal) => !goal.isCompleted)
              .take(1)
              .toList();

          if (activeGoals.isEmpty) return const SizedBox.shrink();

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Goal',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () => _navigateToGoals(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'View All',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildCompactGoalItem(activeGoals.first),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCompactGoalItem(Goal goal) {
    return Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.all(12), // REDUCED PADDING
        height: 70, // FIXED HEIGHT
        child: Row(
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Color(goal.color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(goal.icon, style: const TextStyle(fontSize: 14)),
              ),
            ),
            const SizedBox(width: 10),

            // Progress Info
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: goal.progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(goal.color),
                    ),
                    minHeight: 4, // THINNER PROGRESS BAR
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(goal.progress * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        'Rp ${goal.currentAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Recent Transactions Header
  Widget _buildTransactionsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              final count = state is TransactionLoaded
                  ? state.transactions.length
                  : 0;
              return Text(
                '$count transactions',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinFlow'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            return CustomScrollView(
              slivers: [
                // Balance Card
                SliverToBoxAdapter(
                  child: BalanceCard(transactions: state.transactions),
                ),

                // Quick Actions
                SliverToBoxAdapter(child: _buildQuickActions(context)),

                // Goals Overview
                SliverToBoxAdapter(child: _buildGoalsOverview(context)),

                // Transactions Header
                SliverToBoxAdapter(child: _buildTransactionsHeader(context)),

                TransactionList(transactions: state.transactions),

                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            );
          } else if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(LoadTransactions());
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 12),
                Text('Loading your finances...'),
              ],
            ),
          );
        },
      ),
      // Floating Action Button dihapus sesuai permintaan
    );
  }
}
