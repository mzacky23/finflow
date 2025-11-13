import 'package:finflow/presentation/blocs/goal/goal_event.dart';
import 'package:finflow/presentation/blocs/goal/goal_state.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_bloc.dart';
import 'package:finflow/presentation/blocs/goal/goal_bloc.dart';
import 'package:finflow/data/datasources/local_storage_service.dart';
import 'package:finflow/data/models/category.dart';
import 'package:finflow/data/models/goal.dart';
import 'package:finflow/data/models/transaction_type.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _addToGoal = false;
  String? _selectedGoalId;

  List<Category> get _filteredCategories {
    return LocalStorageService.categoriesBox.values
        .where((category) => category.type == _selectedType)
        .toList();
  }

  List<Goal> _getAvailableGoals() {
    try {
      final goalState = BlocProvider.of<GoalBloc>(context).state;
      if (goalState is GoalLoaded) {
        return goalState.goals.where((goal) => !goal.isCompleted).toList();
      }
    } catch (e) {
      print('Error getting goals: $e');
    }
    return [];
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.tryParse(_amountController.text) ?? 0.0;
      final description = _descriptionController.text;
      final notes = _notesController.text.isNotEmpty
          ? _notesController.text
          : null;

      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Amount must be greater than 0')),
        );
        return;
      }

      final transaction = TransactionEntity(
        id: '',
        amount: amount,
        categoryId: _selectedCategory!.id,
        categoryName: _selectedCategory!.name,
        categoryIcon: _selectedCategory!.icon,
        categoryColor: _selectedCategory!.color,
        date: _selectedDate,
        description: description,
        note: notes,
        isExpense: _selectedType == TransactionType.expense,
      );

      // Add transaction via BLoC
      context.read<TransactionBloc>().add(AddTransaction(transaction));

      // Add to goal if selected (only for income)
      if (_addToGoal &&
          _selectedGoalId != null &&
          _selectedType == TransactionType.income) {
        context.read<GoalBloc>().add(AddToGoal(_selectedGoalId!, amount));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Added Rp ${amount.toStringAsFixed(0)} to goal!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        // Regular success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${_selectedType == TransactionType.income ? 'Income' : 'Expense'} added successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.of(context).pop();
    } else if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
    }
  }

  void _clearForm() {
    _amountController.clear();
    _descriptionController.clear();
    _notesController.clear();
    setState(() {
      _selectedCategory = null;
      _selectedDate = DateTime.now();
      _addToGoal = false;
      _selectedGoalId = null;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final availableGoals = _getAvailableGoals();
    final hasActiveGoals = availableGoals.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearForm,
            tooltip: 'Clear Form',
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
            tooltip: 'Save Transaction',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Info
              Card(
                color: _selectedType == TransactionType.income
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        _selectedType == TransactionType.income
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        color: _selectedType == TransactionType.income
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedType == TransactionType.income
                              ? 'Adding Income Transaction'
                              : 'Adding Expense Transaction',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _selectedType == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Transaction Type Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Expense'),
                              selected:
                                  _selectedType == TransactionType.expense,
                              selectedColor: Colors.red.withOpacity(0.2),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = TransactionType.expense;
                                  _selectedCategory = null;
                                  _addToGoal = false;
                                  _selectedGoalId = null;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Income'),
                              selected: _selectedType == TransactionType.income,
                              selectedColor: Colors.green.withOpacity(0.2),
                              onSelected: (selected) {
                                setState(() {
                                  _selectedType = TransactionType.income;
                                  _selectedCategory = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Category Selection
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<Category>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          hintText: 'Select a category',
                          border: OutlineInputBorder(),
                        ),
                        items: _filteredCategories.map((category) {
                          return DropdownMenuItem<Category>(
                            value: category,
                            child: Row(
                              children: [
                                Text(
                                  category.icon,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 12),
                                Text(category.name),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (category) {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(
                          prefixText: 'Rp ',
                          hintText: 'Enter amount...',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter valid amount';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Description Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          hintText: 'Enter description...',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          if (value.length < 3) {
                            return 'Description must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedType == TransactionType.income &&
                  hasActiveGoals) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add to Goal',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),

                        SwitchListTile(
                          title: const Text('Add this amount to a goal'),
                          value: _addToGoal,
                          onChanged: (value) {
                            setState(() {
                              _addToGoal = value;
                              if (!_addToGoal) _selectedGoalId = null;
                            });
                          },
                        ),

                        // Goal Selection (only show if toggle is on)
                        if (_addToGoal) ...[
                          const SizedBox(height: 12),
                          const Text('Select Goal:'),
                          const SizedBox(height: 8),

                          // Simple Radio List for goals
                          ...availableGoals.map((goal) {
                            return RadioListTile<String>(
                              title: Text('${goal.icon} ${goal.title}'),
                              subtitle: Text(
                                'Progress: ${(goal.progress * 100).toStringAsFixed(0)}% (Rp ${goal.currentAmount.toStringAsFixed(0)} / Rp ${goal.targetAmount.toStringAsFixed(0)})',
                              ),
                              value: goal.id,
                              groupValue: _selectedGoalId,
                              onChanged: (value) {
                                setState(() {
                                  _selectedGoalId = value;
                                });
                              },
                            );
                          }).toList(),

                          // Info text
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'This amount will be added to your goal savings',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Date Picker
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Date',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Select Date'),
                        subtitle: Text(
                          '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        ),
                        trailing: const Icon(Icons.arrow_drop_down),
                        onTap: () => _selectDate(context),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Input
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes (Optional)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Additional notes...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      child: const Text('Clear Form'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _submitForm,
                      child: const Text('Save Transaction'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (_selectedCategory == null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please select a category to save the transaction',
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
