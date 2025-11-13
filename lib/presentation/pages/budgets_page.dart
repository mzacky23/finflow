// budgets_page.dart - VERSI SIMPLE
import 'package:finflow/core/routes/app_routes.dart';
import 'package:finflow/presentation/blocs/budget/budget_event.dart';
import 'package:finflow/presentation/blocs/budget/budget_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/presentation/blocs/budget/budget_bloc.dart';
import 'package:finflow/presentation/widgets/budget_card.dart';
import 'package:finflow/data/models/budget.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  void _showFilterDialog(BuildContext context, BudgetLoaded state) {
    bool tempShowAllTime = state.showAllTime;
    DateTime tempSelectedFilter = state.selectedFilter;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter Budgets'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Show All Time'),
                  const Spacer(),
                  Switch(
                    value: tempShowAllTime,
                    onChanged: (value) {
                      setDialogState(() {
                        tempShowAllTime = value;
                      });
                    },
                  ),
                ],
              ),

              if (!tempShowAllTime) ...[
                const SizedBox(height: 16),
                const Text('Select Month:'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<int>(
                        value: tempSelectedFilter.month,
                        items: List.generate(12, (index) => index + 1)
                            .map(
                              (month) => DropdownMenuItem<int>(
                                value: month,
                                child: Text(_getMonthName(month)),
                              ),
                            )
                            .toList(),
                        onChanged: (month) {
                          if (month != null) {
                            setDialogState(() {
                              tempSelectedFilter = DateTime(
                                tempSelectedFilter.year,
                                month,
                              );
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<int>(
                        value: tempSelectedFilter.year,
                        items:
                            List.generate(
                                  5,
                                  (index) => DateTime.now().year - 2 + index,
                                )
                                .map(
                                  (year) => DropdownMenuItem<int>(
                                    value: year,
                                    child: Text(year.toString()),
                                  ),
                                )
                                .toList(),
                        onChanged: (year) {
                          if (year != null) {
                            setDialogState(() {
                              tempSelectedFilter = DateTime(
                                year,
                                tempSelectedFilter.month,
                              );
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                context.read<BudgetBloc>().add(
                  UpdateBudgetFilter(
                    showAllTime: tempShowAllTime,
                    selectedFilter: tempSelectedFilter,
                  ),
                );
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  void _clearFilter(BuildContext context) {
    context.read<BudgetBloc>().add(
      UpdateBudgetFilter(showAllTime: true, selectedFilter: DateTime.now()),
    );
  }

  List<Budget> _filterBudgets(
    List<Budget> budgets,
    bool showAllTime,
    DateTime selectedFilter,
  ) {
    if (showAllTime) return budgets;

    return budgets.where((budget) {
      return budget.month.year == selectedFilter.year &&
          budget.month.month == selectedFilter.month;
    }).toList();
  }

  Map<String, List<Budget>> _groupBudgetsByMonth(List<Budget> budgets) {
    final Map<String, List<Budget>> grouped = {};

    for (final budget in budgets) {
      final key =
          '${budget.month.year}-${budget.month.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(budget);
    }

    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final Map<String, List<Budget>> sortedMap = {};
    for (final key in sortedKeys) {
      sortedMap[key] = grouped[key]!;
    }

    return sortedMap;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatGroupHeader(String key) {
    final parts = key.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    return '${_getMonthName(month)} $year';
  }

  String _getActiveFilterText(bool showAllTime, DateTime selectedFilter) {
    if (showAllTime) return 'All Time';
    return '${_getMonthName(selectedFilter.month)} ${selectedFilter.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Budgets'),
        actions: [
          BlocBuilder<BudgetBloc, BudgetState>(
            builder: (context, state) {
              if (state is! BudgetLoaded) return const SizedBox.shrink();

              return Row(
                children: [
                  if (!state.showAllTime)
                    IconButton(
                      icon: const Icon(Icons.clear_all),
                      onPressed: () => _clearFilter(context),
                      tooltip: 'Clear Filter',
                    ),
                  Badge(
                    isLabelVisible: !state.showAllTime,
                    child: IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: () => _showFilterDialog(context, state),
                      tooltip: 'Filter',
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.addBudget);
                    },
                    tooltip: 'Add Budget',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BudgetBloc, BudgetState>(
        builder: (context, state) {
          if (state is BudgetLoaded) {
            final filteredBudgets = _filterBudgets(
              state.budgets,
              state.showAllTime,
              state.selectedFilter,
            );
            final groupedBudgets = _groupBudgetsByMonth(filteredBudgets);

            // Filter Indicator
            Widget filterIndicator = const SizedBox.shrink();
            if (!state.showAllTime) {
              filterIndicator = Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.blue.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.filter_alt, size: 16, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Showing: ${_getActiveFilterText(state.showAllTime, state.selectedFilter)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => _clearFilter(context),
                      child: const Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (filteredBudgets.isEmpty) {
              return Column(
                children: [
                  filterIndicator,
                  Expanded(
                    child: _buildEmptyState(
                      context,
                      state.budgets.isEmpty,
                      state.showAllTime,
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                filterIndicator,
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedBudgets.length,
                    itemBuilder: (context, index) {
                      final key = groupedBudgets.keys.elementAt(index);
                      final budgets = groupedBudgets[key]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (groupedBudgets.length > 1 ||
                              !state.showAllTime) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: Text(
                                _formatGroupHeader(key),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],

                          ...budgets.map(
                            (budget) => BudgetCard(budget: budget),
                          ),

                          if (index < groupedBudgets.length - 1)
                            const Divider(height: 32, thickness: 1),
                        ],
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is BudgetError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    bool noBudgetsAtAll,
    bool showAllTime,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            noBudgetsAtAll
                ? 'No budgets yet'
                : 'No budgets for selected filter',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            noBudgetsAtAll
                ? 'Tap + to create your first budget'
                : 'Try changing your filter or create a new budget',
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          if (!noBudgetsAtAll && !showAllTime) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _clearFilter(context),
              child: const Text('Show All Budgets'),
            ),
          ],
        ],
      ),
    );
  }
}
