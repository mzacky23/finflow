import 'package:finflow/presentation/blocs/budget/budget_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finflow/data/models/budget.dart';
import 'package:finflow/presentation/blocs/budget/budget_bloc.dart';

class EditBudgetPage extends StatefulWidget {
  final Budget budget;

  const EditBudgetPage({super.key, required this.budget});

  @override
  State<EditBudgetPage> createState() => _EditBudgetPageState();
}

class _EditBudgetPageState extends State<EditBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  
  late Budget _budget;
  double _amount = 0.0;
  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _budget = widget.budget;
    _amount = _budget.amount;
    _selectedMonth = _budget.month;
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialEntryMode: DatePickerEntryMode.input,
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      
      final updatedBudget = _budget.copyWith(
        amount: _amount,
        month: _selectedMonth,
      );

      // Update budget via BLoC
      context.read<BudgetBloc>().add(UpdateBudget(updatedBudget));
      
      Navigator.of(context).pop();
    }
  }

  void _deleteBudget() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: Text(
          'Are you sure you want to delete budget for "${_budget.category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<BudgetBloc>().add(DeleteBudget(_budget.id));
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close edit page
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Budget'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteBudget,
            color: Colors.red,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _submitForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Category Info (Read-only)
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(_budget.category.color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      _budget.category.icon,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                title: Text(
                  _budget.category.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text('Category'),
              ),
              const SizedBox(height: 20),
              
              // Amount Input
              TextFormField(
                initialValue: _amount.toStringAsFixed(0),
                decoration: const InputDecoration(
                  labelText: 'Budget Amount',
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter budget amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid amount';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Amount must be greater than 0';
                  }
                  return null;
                },
                onSaved: (value) {
                  _amount = double.parse(value!);
                },
              ),
              const SizedBox(height: 20),
              
              // Month Picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Month'),
                subtitle: Text(
                  '${_selectedMonth.month}/${_selectedMonth.year}',
                ),
                trailing: const Icon(Icons.arrow_drop_down),
                onTap: () => _selectMonth(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}