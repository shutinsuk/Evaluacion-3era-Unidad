import 'package:flutter/material.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> packages = [];

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  void _loadPackages() async {
    try {
      final data = await apiService.getAssignedPackages();
      setState(() {
        packages = data;
      });
    } catch (e) {
      // error handling simple
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paquetes Asignados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final pkg = packages[index];
          return ListTile(
            title: Text('Guía: ${pkg['tracking_number']}'),
            subtitle: Text(pkg['address']),
            trailing: Text(pkg['status']),
            onTap: () {
              Navigator.pushNamed(context, '/delivery', arguments: pkg)
                  .then((_) => _loadPackages());
            },
          );
        },
      ),
    );
  }
}
