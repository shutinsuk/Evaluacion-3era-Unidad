import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List<dynamic> attendanceRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    try {
      var url = Uri.parse("http://127.0.0.1:8000/attendance/");
      var response = await http.get(url);

      if (response.statusCode == 200) {
        setState(() {
          attendanceRecords = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Historial de Asistencias")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: attendanceRecords.length,
              itemBuilder: (context, index) {
                var record = attendanceRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text("Usuario ID: ${record['user_id']}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(record['address'] ?? "Sin dirección"),
                        Text(
                          record['registered_at'] ?? "",
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapDetailScreen(record: record),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class MapDetailScreen extends StatelessWidget {
  final dynamic record;

  const MapDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    double lat = double.parse(record['latitude'].toString());
    double lng = double.parse(record['longitude'].toString());

    return Scaffold(
      appBar: AppBar(title: const Text("Detalle de Ubicación")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  "Usuario: ${record['user_id']}",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  record['address'] ?? "Sin dirección",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text("Fecha: ${record['registered_at']}"),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(lat, lng),
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(lat, lng),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
