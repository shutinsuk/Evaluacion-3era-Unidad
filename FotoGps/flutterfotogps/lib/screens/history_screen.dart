import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<dynamic> history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() async {
    try {
      final data = await apiService.getDeliveryHistory();
      setState(() {
        history = data;
      });
    } catch (e) {
      // Error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de Entregas')),
      body: ListView.builder(
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          // convertir coordenadas
          final double lat = (item['gps_latitude'] is String) ? double.parse(item['gps_latitude']) : item['gps_latitude'].toDouble();
          final double lng = (item['gps_longitude'] is String) ? double.parse(item['gps_longitude']) : item['gps_longitude'].toDouble();
          final LatLng point = LatLng(lat, lng);

          return Card(
            margin: const EdgeInsets.all(8),
            child: ExpansionTile(
              title: Text('Entrega #${item['id']}'),
              subtitle: Text('Fecha: ${item['delivered_at']}'),
              children: [
                SizedBox(
                  height: 200,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: point,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.flutterfotogps',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: point,
                            width: 80,
                            height: 80,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.network(
                    item['photo_url'],
                    height: 150,
                    errorBuilder: (c, e, s) => const Text('Error cargando foto'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
