import 'dart:convert';
import 'package:app_ruta/chofer/screens/login_chofer.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ServiceLogin {
  String url = 'http://192.168.3.13:3000';

  Future<Usuario?> login(String usuario, String contrasena) async {
    final url = Uri.parse('${this.url}/usuarios/login');
    final headers = {'Content-Type': 'application/json'};
    final body = json.encode({
      'usuario': usuario,
      'contraseña': contrasena,
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Usuario.fromJson(data['data']); // Mapear los datos del usuario
      } else if (response.statusCode == 401) {
        return null;
      } else {
        return null;
      }
    } catch (e) {
      print('Error al conectar con el servidor: $e');
      return null;
    }
  }

  // Método para enviar los datos al API
  Future<void> enviarDatos(BuildContext context, Map<String, dynamic> registro) async {
    try {
      final response = await http.post(
        Uri.parse('$url/usuarios/crear-datos'),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode(registro),
      );

      if (response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        print("datos de respuesta: $jsonResponse");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos registrados exitosamente')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar los datos: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la conexión: $e')),
      );
    }
  }
}
