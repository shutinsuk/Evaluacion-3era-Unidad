import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona tu Rol")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.person),
              label: const Text("Modo Estudiante"),
              onPressed: () {
                Navigator.pushNamed(context, '/student');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.admin_panel_settings),
              label: const Text("Modo Admin"),
              onPressed: () {
                Navigator.pushNamed(context, '/admin');
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                textStyle: const TextStyle(fontSize: 20),
                backgroundColor: Colors.orange, // Diferenciar admin
              ),
            ),
          ],
        ),
      ),
    );
  }
}
