import 'package:flutter/foundation.dart' show kIsWeb;
// Importa kIsWeb, una constante booleana que indica si la aplicación se está ejecutando en Web.

import 'package:flutter/material.dart';
// Importa el framework de Material Design para construir la interfaz gráfica.

import 'package:image_picker/image_picker.dart';
// Importa la librería para acceder a la cámara o galería y seleccionar imágenes.

// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
// Importa la librería http para realizar peticiones a la API. Se usa con alias 'http'.

import 'dart:typed_data';
// Importa Uint8List, que es una lista de bytes sin signo. Se usa para manejar imágenes en memoria.

import 'dart:convert';
// Importa funciones para convertir entre cadenas y JSON, como json.decode.

void main() => runApp(const MyApp());
// Función principal. runApp inicia la aplicación y renderiza el widget MyApp.

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // Constructor constante, recibe una clave opcional.

  @override
  Widget build(BuildContext context) {
    // build construye la interfaz de este widget.
    return const MaterialApp(
      home: FotoPage(), // Define la pantalla inicial como FotoPage.
      debugShowCheckedModeBanner:
          false, // Oculta la etiqueta de debug en la esquina.
    );
  }
}

class FotoPage extends StatefulWidget {
  const FotoPage({super.key}); // Constructor constante.

  @override
  _FotoPageState createState() => _FotoPageState();
  // Crea el estado asociado a este widget.
}

class _FotoPageState extends State<FotoPage> {
  Uint8List?
  _imageBytes; // Variable para guardar los bytes de la imagen en memoria.
  XFile?
  _pickedFile; // Variable para guardar el archivo seleccionado por ImagePicker.
  final picker = ImagePicker(); // Instancia de ImagePicker para tomar fotos.
  final descripcionController = TextEditingController();
  // Controlador para el campo de texto de descripción.

  String? uploadedImageUrl; // URL de la imagen subida al servidor.

  Future getImage() async {
    // Función asíncrona para tomar una foto con la cámara.
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    // pickImage abre la cámara y devuelve un XFile si se toma una foto.
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      // Convierte la foto en bytes para poder mostrarla en memoria.
      setState(() {
        _imageBytes = bytes; // Guarda los bytes de la imagen.
        _pickedFile = pickedFile; // Guarda el archivo seleccionado.
      });
      print("Foto tomada: ${pickedFile.name}");
      // Muestra un mensaje en consola con el nombre del archivo.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Foto tomada correctamente ✅")),
      );
      // Muestra un SnackBar en pantalla confirmando que se tomó la foto.
    } else {
      print("No se tomó ninguna foto");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se tomó ninguna foto ❌")),
      );
      // Muestra un SnackBar indicando que no se tomó foto.
    }
  }

  Future subirFoto() async {
    // Función asíncrona para subir la foto al servidor.
    if (_pickedFile == null || _imageBytes == null) {
      // Verifica que haya una foto seleccionada.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Primero toma una foto 🫠")));
      return; // Si no hay foto, termina la función.
    }

    var request = http.MultipartRequest(
      'POST', // Método HTTP para enviar datos.
      Uri.parse('http://localhost:8000/fotos/'), // URL del endpoint de la API.
    );

    request.fields['descripcion'] = descripcionController.text;
    // Agrega el campo de texto 'descripcion' al formulario.

    request.files.add(
      http.MultipartFile.fromBytes(
        'file', // Nombre del campo esperado por la API.
        _imageBytes!, // Los bytes de la imagen.
        filename: _pickedFile!.name, // Nombre del archivo original.
      ),
    );

    var response = await request.send();
    // Envía la petición al servidor.
    var respStr = await response.stream.bytesToString();
    // Convierte la respuesta en cadena.

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa.
      var data = json.decode(respStr);
      // Decodifica la respuesta JSON.
      setState(() {
        uploadedImageUrl = data['foto']['ruta_foto'];
        // Guarda la ruta de la foto subida.
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Foto subida correctamente ✅"),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      // Si hubo error en la subida.
      print("Error al subir la foto: ${response.statusCode}");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error al subir la foto ❌"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget mostrarImagenLocal() {
    // Función que devuelve un widget para mostrar la imagen local.
    if (_imageBytes == null) return const Text("No hay imagen seleccionada");
    // Si no hay imagen, muestra texto.
    return Image.memory(_imageBytes!, width: 300);
    // Si hay imagen, la muestra desde memoria con ancho de 300 píxeles.
  }

  @override
  Widget build(BuildContext context) {
    // Método build que construye la interfaz de la pantalla.
    return Scaffold(
      appBar: AppBar(title: const Text("Subir foto")),
      // Barra superior con título.
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        // Padding alrededor del contenido.
        child: Column(
          children: [
            mostrarImagenLocal(), // Muestra la imagen tomada.
            const SizedBox(height: 10), // Espacio vertical.
            TextField(
              controller: descripcionController,
              // Campo de texto para escribir la descripción.
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: getImage,
              child: const Text("Tomar Foto"),
            ),
            // Botón para tomar foto.
            ElevatedButton(
              onPressed: subirFoto,
              child: const Text("Subir a API"),
            ),
            // Botón para subir foto a la API.
          ],
        ),
      ),
    );
  }
}
