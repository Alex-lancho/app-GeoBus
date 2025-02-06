// ubicacion_api_service.dart
import 'dart:convert';
import 'package:app_ruta/data/models/location_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class LocationService {
  // URL base para la entidad Ubicacion.
  final String baseUrl = '${ApiService.url}/ubicacion';

  /// GET: Obtener todas las ubicaciones
  Future<List<LocationModel>> getAllUbicaciones() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => LocationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las ubicaciones');
    }
  }

  /// GET: Obtener una ubicación por id
  Future<LocationModel> getUbicacion(int id) async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return LocationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la ubicación');
    }
  }

  /// GET: Obtener ubicaciones por id de Combi
  Future<List<LocationModel>> getUbicacionesPorCombi(String idCombi) async {
    final url = '$baseUrl/obtenerUbicacionPorCombi/$idCombi';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => LocationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener ubicaciones para la combi');
    }
  }

  /// POST: Crear una nueva ubicación
  /// Se espera enviar un objeto con { data: Partial<Ubicacion>, idCombi: string }
  Future<LocationModel> createUbicacion(Map<String, dynamic> ubicacionData, String idCombi) async {
    final url = '$baseUrl/createUbicacion';
    final Map<String, dynamic> payload = {
      'data': ubicacionData,
      'idCombi': idCombi,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return LocationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la ubicación');
    }
  }

  /// PUT: Actualizar una ubicación existente
  Future<LocationModel> updateUbicacion(int id, Map<String, dynamic> ubicacionData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(ubicacionData),
    );
    if (response.statusCode == 200) {
      return LocationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la ubicación');
    }
  }

  /// DELETE: Eliminar una ubicación
  Future<void> deleteUbicacion(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la ubicación');
    }
  }

  //Cantidad de registros
  Future<int> getLocationCount() async {
    final response = await http.get(Uri.parse('$baseUrl/total'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
