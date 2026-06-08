import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';


import 'app.dart';

import 'data/firebase/firestore_database_adapter.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/records_repository.dart';
import 'data/repositories/users_repository.dart';
import 'features/auth/auth_controller.dart';
import 'features/dashboard/dashboard_controller.dart';
import 'features/reports/reports_controller.dart';
import 'features/users/users_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();



  // Inicializar Firebase antes de acceder a Auth o Firestore.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inicializar base de datos (Firestore)
  final database = FirestoreDatabaseAdapter();
  await database.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: database),

        Provider<AuthRepository>(
          create: (_) => AuthRepository(),
        ),

        Provider<UsersRepository>(
          create: (_) => UsersRepository(),
        ),

        Provider<RecordsRepository>(
          create: (_) => RecordsRepository(),
        ),

        ChangeNotifierProvider<AuthController>(
          create: (context) =>
              AuthController(context.read<AuthRepository>()),
        ),

        ChangeNotifierProvider<UsersController>(
          create: (context) =>
              UsersController(context.read<UsersRepository>()),
        ),

        ChangeNotifierProvider<DashboardController>(
          create: (context) =>
              DashboardController(context.read<RecordsRepository>()),
        ),

        ChangeNotifierProvider<ReportsController>(
          create: (context) =>
              ReportsController(context.read<RecordsRepository>()),
        ),
      ],
      child: const SIGEJApp(),
    ),
  );
}