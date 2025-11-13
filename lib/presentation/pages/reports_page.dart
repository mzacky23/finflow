import 'package:finflow/presentation/blocs/transaction/transaction_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_bloc.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime _selectedMonth = DateTime.now();

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  List<TransactionEntity> _getTransactionsForMonth(
    List<TransactionEntity> transactions,
  ) {
    final startDate = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final endDate = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    return transactions.where((transaction) {
      return transaction.date.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          transaction.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reports & Analytics')),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoaded) {
            final monthTransactions = _getTransactionsForMonth(
              state.transactions,
            );

            if (state.transactions.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.analytics, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No transaction data yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      'Add some transactions to see reports',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Month Selector
                  _buildMonthSelector(),
                  const SizedBox(height: 20),

                  // Selected Month Summary
                  _buildMonthSummary(monthTransactions),
                  const SizedBox(height: 20),

                  // All Time Summary
                  _buildAllTimeSummary(state.transactions),
                  const SizedBox(height: 20),

                  // Expense by Category Chart
                  if (monthTransactions.isNotEmpty &&
                      _calculateTotalExpense(monthTransactions) > 0)
                    _buildExpenseByCategoryChart(monthTransactions),

                  if (monthTransactions.isNotEmpty &&
                      _calculateTotalExpense(monthTransactions) > 0)
                    const SizedBox(height: 20),

                  // Income vs Expense Chart
                  if (monthTransactions.isNotEmpty)
                    _buildIncomeExpenseChart(monthTransactions),

                  if (monthTransactions.isNotEmpty) const SizedBox(height: 20),

                  // Quick Insights
                  _buildQuickInsights(monthTransactions, state.transactions),
                ],
              ),
            );
          } else if (state is TransactionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: Colors.blue),
        title: const Text('Viewing Report For'),
        subtitle: Text(
          '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        trailing: const Icon(Icons.arrow_drop_down),
        onTap: () => _selectMonth(context),
      ),
    );
  }

  Widget _buildMonthSummary(List<TransactionEntity> transactions) {
    final totalIncome = _calculateTotalIncome(transactions);
    final totalExpense = _calculateTotalExpense(transactions);
    final netAmount = totalIncome - totalExpense;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year} Summary',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Income',
                    totalIncome,
                    Colors.green,
                    Icons.arrow_upward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Expense',
                    totalExpense,
                    Colors.red,
                    Icons.arrow_downward,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Net',
                    netAmount,
                    netAmount >= 0 ? Colors.blue : Colors.orange,
                    netAmount >= 0 ? Icons.trending_up : Icons.trending_down,
                  ),
                ),
              ],
            ),
            if (transactions.isEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'No transactions for selected month',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAllTimeSummary(List<TransactionEntity> transactions) {
    final totalIncome = _calculateTotalIncome(transactions);
    final totalExpense = _calculateTotalExpense(transactions);
    final netAmount = totalIncome - totalExpense;
    final transactionCount = transactions.length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'All Time Overview',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Income',
                    totalIncome,
                    Colors.green,
                    Icons.attach_money,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryItem(
                    'Total Expense',
                    totalExpense,
                    Colors.red,
                    Icons.money_off,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Net Balance',
                    netAmount,
                    netAmount >= 0 ? Colors.blue : Colors.orange,
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      const Icon(
                        Icons.receipt_long,
                        color: Colors.grey,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Transactions',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transactionCount.toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    String title,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: color),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${amount.toStringAsFixed(0)}',
          style: TextStyle(
            fontSize: 14,
            color: color,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildExpenseByCategoryChart(List<TransactionEntity> transactions) {
    final expenseData = _getExpenseDataByCategory(transactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expenses by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: SfCircularChart(
                legend: const Legend(
                  isVisible: true,
                  position: LegendPosition.bottom,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                series: <CircularSeries>[
                  DoughnutSeries<ChartData, String>(
                    dataSource: expenseData,
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.amount,
                    dataLabelMapper: (ChartData data, _) =>
                        'Rp ${data.amount.toStringAsFixed(0)}',
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelPosition: ChartDataLabelPosition.outside,
                    ),
                    pointColorMapper: (ChartData data, _) => data.color,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseChart(List<TransactionEntity> transactions) {
    final income = _calculateTotalIncome(transactions);
    final expense = _calculateTotalExpense(transactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income vs Expense',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: const CategoryAxis(),
                series: <CartesianSeries<ChartData, String>>[
                  ColumnSeries<ChartData, String>(
                    dataSource: [
                      ChartData('Income', income, Colors.green),
                      ChartData('Expense', expense, Colors.red),
                    ],
                    xValueMapper: (ChartData data, _) => data.category,
                    yValueMapper: (ChartData data, _) => data.amount,
                    pointColorMapper: (ChartData data, _) => data.color,
                    dataLabelSettings: const DataLabelSettings(isVisible: true),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickInsights(
    List<TransactionEntity> monthTransactions,
    List<TransactionEntity> allTransactions,
  ) {
    final largestExpense = _getLargestExpense(monthTransactions);
    final topCategory = _getTopExpenseCategory(monthTransactions);
    final savingsRate = _calculateSavingsRate(monthTransactions);
    final avgMonthlySpending = _calculateAvgMonthlySpending(allTransactions);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Insights',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (largestExpense != null)
              _buildInsightItem(
                Icons.warning,
                'Largest Expense',
                '${largestExpense.categoryName}: Rp ${largestExpense.amount.toStringAsFixed(0)}',
                Colors.orange,
              ),

            if (topCategory != null) ...[
              if (largestExpense != null) const SizedBox(height: 12),
              _buildInsightItem(
                Icons.category,
                'Top Spending Category',
                topCategory,
                Colors.purple,
              ),
            ],

            if (monthTransactions.isNotEmpty) ...[
              if (topCategory != null || largestExpense != null)
                const SizedBox(height: 12),
              _buildInsightItem(
                Icons.savings,
                'Savings Rate',
                '${savingsRate.toStringAsFixed(1)}%',
                savingsRate >= 20 ? Colors.green : Colors.orange,
              ),
            ],

            if (avgMonthlySpending > 0) ...[
              if (monthTransactions.isNotEmpty) const SizedBox(height: 12),
              _buildInsightItem(
                Icons.timeline,
                'Avg Monthly Spending',
                'Rp ${avgMonthlySpending.toStringAsFixed(0)}',
                Colors.blue,
              ),
            ],

            if (largestExpense == null &&
                topCategory == null &&
                monthTransactions.isEmpty)
              const Text(
                'No insights available for selected month',
                style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(value, style: TextStyle(fontSize: 12, color: color)),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Methods
  double _calculateTotalIncome(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _calculateTotalExpense(List<TransactionEntity> transactions) {
    return transactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  List<ChartData> _getExpenseDataByCategory(
    List<TransactionEntity> transactions,
  ) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    final categoryMap = <String, double>{};

    for (final expense in expenses) {
      categoryMap[expense.categoryName] =
          (categoryMap[expense.categoryName] ?? 0) + expense.amount;
    }

    return categoryMap.entries.map((entry) {
      return ChartData(entry.key, entry.value, _getCategoryColor(entry.key));
    }).toList();
  }

  TransactionEntity? _getLargestExpense(List<TransactionEntity> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) return null;

    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses.first;
  }

  String? _getTopExpenseCategory(List<TransactionEntity> transactions) {
    final expenseData = _getExpenseDataByCategory(transactions);
    if (expenseData.isEmpty) return null;

    expenseData.sort((a, b) => b.amount.compareTo(a.amount));
    return expenseData.first.category;
  }

  double _calculateSavingsRate(List<TransactionEntity> transactions) {
    final income = _calculateTotalIncome(transactions);
    final expense = _calculateTotalExpense(transactions);

    if (income == 0) return 0.0;
    return ((income - expense) / income) * 100;
  }

  double _calculateAvgMonthlySpending(List<TransactionEntity> transactions) {
    final expenses = transactions.where((t) => t.isExpense).toList();
    if (expenses.isEmpty) return 0.0;

    // Group by month
    final monthlySpending = <String, double>{};
    for (final expense in expenses) {
      final key = '${expense.date.year}-${expense.date.month}';
      monthlySpending[key] = (monthlySpending[key] ?? 0) + expense.amount;
    }

    if (monthlySpending.isEmpty) return 0.0;

    final totalSpending = monthlySpending.values.fold(
      0.0,
      (sum, amount) => sum + amount,
    );
    return totalSpending / monthlySpending.length;
  }

  Color _getCategoryColor(String categoryName) {
    final colors = {
      'Food & Drink': Colors.red,
      'Transport': Colors.blue,
      'Shopping': Colors.orange,
      'Entertainment': Colors.purple,
      'Bills': Colors.green,
      'Salary': Colors.green,
      'Freelance': Colors.blue,
      'Investment': Colors.teal,
    };
    return colors[categoryName] ?? Colors.grey;
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}

// Chart Data Model
class ChartData {
  final String category;
  final double amount;
  final Color color;

  ChartData(this.category, this.amount, this.color);
}
