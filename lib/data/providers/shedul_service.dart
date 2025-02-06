// horario_api_service.dart
import 'dart:convert';
import 'package:app_ruta/data/models/shedul_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class ShedulService {
  // URL base de la API para horarios.
  final String baseUrl = '${ApiService.url}/horarios';

  /// GET: Obtener todos los horarios
  Future<List<ShedulModel>> getAllHorarios() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => ShedulModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los horarios');
    }
  }

  /// GET: Obtener un horario por id
  Future<ShedulModel> getHorario(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return ShedulModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar el horario');
    }
  }

  /// POST: Crear un nuevo horario
  Future<ShedulModel> createHorario(Map<String, dynamic> horarioData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(horarioData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ShedulModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear el horario');
    }
  }

  /// PUT: Actualizar un horario existente
  Future<ShedulModel> updateHorario(String id, Map<String, dynamic> horarioData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(horarioData),
    );
    if (response.statusCode == 200) {
      return ShedulModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar el horario');
    }
  }

  /// DELETE: Eliminar un horario
  Future<void> deleteHorario(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar el horario');
    }
  }

  //Cantidad de registros
  Future<int> getShedulesCount() async {
    final response = await http.get(Uri.parse('$baseUrl/total'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
