import 'dart:convert';
import 'package:app_ruta/administrador/data/models/driver_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class DriverService {
  final String baseUrl = '${ApiService.url}/choferes';

  // GET: Obtener todos los choferes
  Future<List<DriverModel>> getChoferes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => DriverModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los choferes');
    }
  }

  // GET: Obtener un chofer por id
  Future<DriverModel> getChofer(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return DriverModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar el chofer');
    }
  }

  // POST: Crear un nuevo chofer
  Future<DriverModel> createChofer(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return DriverModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el chofer');
    }
  }

  // PUT: Actualizar un chofer existente
  Future<DriverModel> updateChofer(String id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(data),
    );
    if (response.statusCode == 200) {
      return DriverModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar el chofer');
    }
  }

  // DELETE: Eliminar un chofer
  Future<void> deleteChofer(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el chofer');
    }
  }

  //Cantidad de registros
  Future<int> getDriverCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
