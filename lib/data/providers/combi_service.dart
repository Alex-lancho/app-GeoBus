// combi_api_service.dart
import 'dart:convert';
import 'package:app_ruta/data/models/combi_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class CombiService {
  final String baseUrl = '${ApiService.url}/combis';

  /// GET: Obtener todas las combis
  Future<List<CombiModel>> getAllCombis() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => CombiModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las combis');
    }
  }

  /// GET: Obtener una combi por id
  Future<CombiModel> getCombi(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return CombiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la combi');
    }
  }

  /// POST: Crear una nueva combi
  Future<CombiModel> createCombi(Map<String, dynamic> combiData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(combiData),
    );
    // Ajusta la verificación según el código de estado que retorne tu API (200 o 201)
    if (response.statusCode == 200 || response.statusCode == 201) {
      return CombiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la combi');
    }
  }

  /// PUT: Actualizar una combi existente
  Future<CombiModel> updateCombi(String id, Map<String, dynamic> combiData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(combiData),
    );
    if (response.statusCode == 200) {
      return CombiModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la combi');
    }
  }

  /// DELETE: Eliminar una combi
  Future<void> deleteCombi(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la combi');
    }
  }

  //Cantidad de registros
  Future<int> getCombiCount() async {
    final response = await http.get(Uri.parse('$baseUrl/total'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
