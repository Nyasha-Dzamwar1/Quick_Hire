import 'package:flutter/material.dart';
import 'package:quick_hire/pages/job_seeker_home_page.dart';
import 'package:quick_hire/pages/splash_page.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorageService();
  final repo = AppRepository(storage: storage);
  await repo.init();

  runApp(
    ChangeNotifierProvider<AppRepository>.value(value: repo, child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = Provider.of<AppRepository>(context, listen: false);

    return MaterialApp(
      home: repo.currentUser == null ? SplashPage() : JobSeekerHomePage(),
      theme: ThemeData(
        useMaterial3: true,

        fontFamily: 'Lato',

        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(0, 45, 114, 1.0),
          primary: Color.fromRGBO(0, 45, 114, 1.0),
          secondary: Color.fromRGBO(255, 193, 7, 1.0),
        ),

        scaffoldBackgroundColor: Colors.white,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromRGBO(0, 45, 114, 1),
          unselectedItemColor: Colors.grey,
        ),

        //textTheme
        textTheme: TextTheme(
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
