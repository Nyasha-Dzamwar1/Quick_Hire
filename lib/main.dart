import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/navigation/seeker_navigation.dart';
import 'package:quick_hire/pages/my_jobs_page.dart';
import 'package:quick_hire/pages/poster_login_page.dart';
import 'package:quick_hire/pages/seeker_login_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppRepository(), // Firebase repo
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SeekerNavigation(),
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Lato',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromRGBO(0, 45, 114, 1),
          primary: const Color.fromRGBO(0, 45, 114, 1),
          secondary: const Color.fromRGBO(255, 193, 7, 1),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromRGBO(0, 45, 114, 1),
          unselectedItemColor: Colors.grey,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(0, 45, 114, 1),
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(fontSize: 25),
          bodyMedium: TextStyle(fontSize: 14),
          bodySmall: TextStyle(fontSize: 12),
          labelLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
