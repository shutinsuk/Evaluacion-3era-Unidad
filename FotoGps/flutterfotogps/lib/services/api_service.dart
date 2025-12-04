import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = "http://localhost:8000"; // para android emulator usar 10.0.2.2
  
  String? _accessToken;

  Future<void> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/token'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _accessToken = data['access_token'];
    } else {
      throw Exception('Error en login');
    }
  }

  Future<List<dynamic>> getAssignedPackages() async {
    final response = await http.get(
      Uri.parse('$baseUrl/packages/assigned'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error obteniendo paquetes');
    }
  }

  Future<void> submitDelivery(int packageId, double lat, double lng, dynamic imageFile) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/deliveries/'));
    request.headers['Authorization'] = 'Bearer $_accessToken';
    
    request.fields['package_id'] = packageId.toString();
    request.fields['gps_latitude'] = lat.toString();
    request.fields['gps_longitude'] = lng.toString();
    
    // manejo compatible web/móvil
    if (imageFile != null) {
      // imageFile debe ser XFile
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: imageFile.name,
        ),
      );
    }
    
    final response = await request.send();
    if (response.statusCode != 200) {
      final respStr = await response.stream.bytesToString();
      print('Error submitDelivery: ${response.statusCode} - $respStr');
      throw Exception('Error enviando entrega: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getDeliveryHistory() async {
    final response = await http.get(
      Uri.parse('$baseUrl/deliveries/history'),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error obteniendo historial');
    }
  }
}
