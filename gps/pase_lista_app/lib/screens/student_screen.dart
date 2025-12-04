import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StudentScreen extends StatefulWidget {
  const StudentScreen({super.key});

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  String result = "";
  bool isLoading = false;

  Future<void> registerAttendance(int userId) async {
    setState(() => isLoading = true);

    try {
      // 1. Verificar permisos de GPS
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => result = "Permiso de ubicación denegado");
          return;
        }
      }

      // 2. Obtener ubicación
      Position pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 3. Enviar a FastAPI
      // Ajusta la URL según tu entorno (localhost, 10.0.2.2, IP local)
      var url = Uri.parse("http://127.0.0.1:8000/attendance/");

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "user_id": userId,
          "latitude": pos.latitude,
          "longitude": pos.longitude,
        }),
      );

      // 4. Decodificar respuesta
      if (response.statusCode == 200) {
        var decoded = utf8.decode(response.bodyBytes);
        var data = json.decode(decoded);
        setState(() {
          result = "📍 ${data['address']}";
        });
      } else {
        setState(() => result = "Error del servidor: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        result = "❌ Error al registrar asistencia: $e";
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Modo Estudiante")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Registrar Asistencia",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                icon: const Icon(Icons.location_on),
                label: const Text("Enviar Ubicación"),
                onPressed: isLoading ? null : () => registerAttendance(1),
              ),
              const SizedBox(height: 30),
              isLoading
                  ? const CircularProgressIndicator()
                  : result.isNotEmpty
                      ? Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              result,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        )
                      : const Text(
                          "Presiona el botón para registrar tu ubicación.",
                          style: TextStyle(color: Colors.grey),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
