import 'dart:convert';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class ServiceClient {
  String url = ApiService.url;

  Future<List<dynamic>> combis() async {
    final url = Uri.parse('${this.url}/combis');
    final headers = {'Content-Type': 'application/json'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error: Código de estado ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUbicacionById(String idCombi) async {
    final uri = Uri.parse('$url/ubicacion/obtenerUbicacionPorCombi/$idCombi');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        // Decodificar la respuesta JSON como una lista
        final List<dynamic> data = json.decode(response.body);
        // Asegurarse de que cada elemento sea un mapa
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Error: Código de estado ${response.statusCode}. Mensaje: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }
}
