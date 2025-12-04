import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/student_screen.dart';
import 'screens/admin_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pase de Lista',
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1),
        scaffoldBackgroundColor: const Color(0xFFE3F2FD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1565C0),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/student': (context) => const StudentScreen(),
        '/admin': (context) => const AdminScreen(),
      },
    );
  }
}
