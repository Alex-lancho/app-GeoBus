import 'dart:convert';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class ServiceRuta {
  String url = ApiService.url;

  Future<Map<String, dynamic>> createRuta({
    required double ejeX,
    required double ejeY,
    required String nombreLugar,
    required String paradero,
    required String idCombi,
  }) async {
    final uri = Uri.parse('$url/ruta/createRuta');
    final headers = {'Content-Type': 'application/json'};

    final body = {
      "data": {
        "ejeX": ejeX,
        "ejeY": ejeY,
        "nombreLugar": nombreLugar,
        "paradero": paradero,
      },
      "idCombi": idCombi,
    };

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error: Código de estado ${response.statusCode}. Mensaje: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// **Actualiza un punto existente en la ruta**
  Future<Map<String, dynamic>> updateRuta({
    required String idRuta,
    required double ejeX,
    required double ejeY,
    required String nombreLugar,
    required String paradero,
  }) async {
    final uri = Uri.parse('$url/ruta/$idRuta');
    final headers = {'Content-Type': 'application/json'};

    final body = {
      "ejeX": ejeX,
      "ejeY": ejeY,
      "nombreLugar": nombreLugar,
      "paradero": paradero,
    };

    try {
      final response = await http.put(
        uri,
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Error al actualizar la ruta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  /// **Elimina un punto de la ruta**
  Future<void> deleteRuta(String idRuta) async {
    final uri = Uri.parse('$url/ruta/$idRuta');

    try {
      final response = await http.delete(uri);

      if (response.statusCode != 200) {
        throw Exception('Error al eliminar la ruta: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error al conectar con el servidor: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRutaById(String idCombi) async {
    final uri = Uri.parse('$url/ruta/$idCombi');

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
