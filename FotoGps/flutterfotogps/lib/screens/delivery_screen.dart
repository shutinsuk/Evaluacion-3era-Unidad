import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../main.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  dynamic package;
  XFile? _image; // cambiado de File a XFile para soporte Web
  Position? _currentPosition;
  final ImagePicker _picker = ImagePicker();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    package = ModalRoute.of(context)!.settings.arguments;
  }

  Future<void> _takePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(source: source);
      if (photo != null) {
        setState(() {
          _image = photo;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al tomar foto: $e')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      
      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error GPS: $e')),
      );
    }
  }

  void _submitDelivery() async {
    if (_image == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falta foto o ubicación')),
      );
      return;
    }

    try {
      await apiService.submitDelivery(
        package['id'],
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        _image!,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paquete entregado')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al entregar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (package == null) return const Scaffold();

    final double lat = (package['latitude'] is String) ? double.parse(package['latitude']) : package['latitude'].toDouble();
    final double lng = (package['longitude'] is String) ? double.parse(package['longitude']) : package['longitude'].toDouble();
    final LatLng destination = LatLng(lat, lng);

    return Scaffold(
      appBar: AppBar(title: const Text('Entrega de Paquete')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
              title: Text('ID: ${package['id']}'),
              subtitle: Text(package['address']),
            ),
            SizedBox(
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: destination,
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
                        point: destination,
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_image != null)
              kIsWeb 
                  ? Image.network(_image!.path, height: 150) 
                  : Image.file(File(_image!.path), height: 150),
            ElevatedButton.icon(
              onPressed: () => _takePhoto(ImageSource.gallery),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Adjuntar Foto'),
            ),
            const SizedBox(height: 10),
            if (_currentPosition != null)
              Text('Ubicación: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}'),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Obtener Ubicación Actual'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitDelivery,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Paquete Entregado', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
