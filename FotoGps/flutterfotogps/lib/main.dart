import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/delivery_screen.dart';
import 'screens/history_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(const MyApp());
}

final apiService = ApiService();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FotoGps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/delivery': (context) => const DeliveryScreen(),
        '/history': (context) => const HistoryScreen(),
      },
    );
  }
}
