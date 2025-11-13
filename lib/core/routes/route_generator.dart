import 'package:flutter/material.dart';
import 'package:finflow/core/routes/app_routes.dart';
import 'package:finflow/presentation/pages/home_page.dart';
import 'package:finflow/presentation/pages/add_transaction_page.dart';
import 'package:finflow/presentation/pages/edit_transaction_page.dart';
import 'package:finflow/presentation/pages/budgets_page.dart';
import 'package:finflow/presentation/pages/add_budget_page.dart';
import 'package:finflow/presentation/pages/edit_budget_page.dart'; 
import 'package:finflow/presentation/pages/reports_page.dart';
import 'package:finflow/presentation/pages/goals_page.dart';
import 'package:finflow/presentation/pages/add_goal_page.dart'; 
import 'package:finflow/domain/entities/transaction_entity.dart';
import 'package:finflow/data/models/budget.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      
      case AppRoutes.addTransaction:
        return MaterialPageRoute(builder: (_) => const AddTransactionPage());
      
      case AppRoutes.editTransaction:
        if (args is TransactionEntity) {
          return MaterialPageRoute(
            builder: (_) => EditTransactionPage(transaction: args),
          );
        }
        return _errorRoute();
      
      case AppRoutes.budgets:
        return MaterialPageRoute(builder: (_) => const BudgetsPage());
      
      case AppRoutes.addBudget:
        return MaterialPageRoute(builder: (_) => const AddBudgetPage());
      
      case AppRoutes.editBudget: 
        if (args is Budget) {
          return MaterialPageRoute(
            builder: (_) => EditBudgetPage(budget: args),
          );
        }
        return _errorRoute();
      
      case AppRoutes.reports:
        return MaterialPageRoute(builder: (_) => const ReportsPage());
      
      case AppRoutes.goals:
        return MaterialPageRoute(builder: (_) => const GoalsPage());
      
      case AppRoutes.addGoal:
        return MaterialPageRoute(builder: (_) => const AddGoalPage());

      case AppRoutes.settings:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Settings')),
            body: const Center(child: Text('Settings coming soon!')),
          ),
        );
      
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Page not found!')),
      );
    });
  }
}