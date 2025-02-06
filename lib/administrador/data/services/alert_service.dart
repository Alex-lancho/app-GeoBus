// alerta_api_service.dart
import 'dart:convert';
import 'package:app_ruta/administrador/data/models/alert_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class AlertService {
  final String baseUrl = '${ApiService.url}/alertas';

  // GET: Obtener todas las alertas
  Future<List<AlertModel>> getAlertas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => AlertModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las alertas');
    }
  }

  // GET: Obtener una alerta por id
  Future<AlertModel> getAlerta(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/$id'));
    if (response.statusCode == 200) {
      return AlertModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la alerta');
    }
  }

  // POST: Crear una nueva alerta
  Future<AlertModel> createAlerta(Map<String, dynamic> alertaData, String idCombi) async {
    final Map<String, dynamic> payload = {
      'data': alertaData,
      'idCombi': idCombi,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    // Se asume que el backend retorna 201 o 200 al crear correctamente
    if (response.statusCode == 201 || response.statusCode == 200) {
      return AlertModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la alerta');
    }
  }

  // PUT: Actualizar una alerta existente
  Future<AlertModel> updateAlerta(String id, Map<String, dynamic> alertaData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(alertaData),
    );

    if (response.statusCode == 200) {
      return AlertModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la alerta');
    }
  }

  // DELETE: Eliminar una alerta
  Future<void> deleteAlerta(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la alerta');
    }
  }

  //Cantidad de Alertas
  Future<int> getAlertaCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
