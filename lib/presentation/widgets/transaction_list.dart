import 'package:finflow/core/routes/app_routes.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_bloc.dart';

class TransactionList extends StatelessWidget {
  final List<TransactionEntity> transactions;

  const TransactionList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No transactions yet',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                'Tap Transaction to add your first transaction',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final transaction = transactions[index];
          return _TransactionItem(
            transaction: transaction,
            onEdit: () => _showEditOptions(context, transaction),
          );
        },
        childCount: transactions.length,
      ),
    );
  }

  void _showEditOptions(BuildContext context, TransactionEntity transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(
                  context,
                  AppRoutes.editTransaction,
                  arguments: transaction,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title: Text('Delete Transaction'),
              onTap: () {
                Navigator.pop(context);
                _showDeleteConfirmation(context, transaction);
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    TransactionEntity transaction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Transaction?'),
        content: Text(
          'Are you sure you want to delete "${transaction.description}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionBloc>().add(
                DeleteTransaction(transaction.id),
              );
              Navigator.pop(context);
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final TransactionEntity transaction;
  final VoidCallback onEdit;

  const _TransactionItem({required this.transaction, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(transaction.categoryColor).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              transaction.categoryIcon,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
        title: Text(
          transaction.description,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${transaction.categoryName} • ${_formatDate(transaction.date)}',
        ),
        trailing: Text(
          '${transaction.isExpense ? '-' : '+'} Rp ${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: transaction.isExpense ? Colors.red : Colors.green,
          ),
        ),
        onTap: () => onEdit(),
        onLongPress: () => onEdit(),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}