import 'package:finflow/data/repositories/goal_repository_impl.dart';
import 'package:finflow/presentation/blocs/budget/budget_event.dart';
import 'package:finflow/presentation/blocs/goal/goal_bloc.dart';
import 'package:finflow/presentation/blocs/goal/goal_event.dart';
import 'package:finflow/presentation/blocs/transaction/transaction_event.dart';
import 'package:finflow/presentation/pages/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/app_theme.dart';
import 'core/routes/route_generator.dart';
import 'data/datasources/local_storage_service.dart';
import 'presentation/blocs/transaction/transaction_bloc.dart';
import 'presentation/blocs/budget/budget_bloc.dart';
import 'data/repositories/transaction_repository_impl.dart';
import 'data/repositories/budget_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStorageService.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final transactionRepository = TransactionRepositoryImpl();
    final budgetRepository = BudgetRepositoryImpl(
      transactionRepository: transactionRepository,
    );
    final goalRepository = GoalRepositoryImpl();

    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>(
          create: (context) =>
              TransactionBloc(transactionRepository: transactionRepository)
                ..add(LoadTransactions()),
        ),
        BlocProvider<BudgetBloc>(
          create: (context) =>
              BudgetBloc(budgetRepository: budgetRepository)
                ..add(LoadBudgets()),
        ),
        BlocProvider<GoalBloc>(
          create: (context) =>
              GoalBloc(goalRepository: goalRepository)..add(LoadGoals()),
        ),
      ],
      child: MaterialApp(
        title: 'FinFlow',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainLayout(), 
        onGenerateRoute: RouteGenerator.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
