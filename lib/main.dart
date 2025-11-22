import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/auth_service.dart';
import 'package:padel_one/firebase_options.dart';
import 'package:padel_one/padel_time_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ro_RO', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthService(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Padel Time',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.primaryColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppStyles.darkText,
          foregroundColor: AppStyles.lightText, // For title and icons
        ),
      ),
      home: const PadelTimePage(),
    );
  }
}