// evaluacion_api_service.dart
import 'dart:convert';
import 'package:app_ruta/administrador/data/models/evaluation_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class EvaluationService {
  final String baseUrl = '${ApiService.url}/evaluaciones';

  /// GET: Obtener todas las evaluaciones
  Future<List<EvaluationModel>> getAllEvaluaciones() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => EvaluationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las evaluaciones');
    }
  }

  /// GET: Obtener una evaluación por id
  Future<EvaluationModel> getEvaluacion(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return EvaluationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la evaluación');
    }
  }

  /// POST: Crear una nueva evaluación
  /// El endpoint espera un objeto con { data: Partial<Evaluacion>, idCombi: string }
  Future<EvaluationModel> createEvaluacion(Map<String, dynamic> evaluacionData, String idCombi) async {
    final Map<String, dynamic> payload = {
      'data': evaluacionData,
      'idCombi': idCombi,
    };

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return EvaluationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la evaluación');
    }
  }

  /// PUT: Actualizar una evaluación existente
  Future<EvaluationModel> updateEvaluacion(String id, Map<String, dynamic> evaluacionData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(evaluacionData),
    );
    if (response.statusCode == 200) {
      return EvaluationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la evaluación');
    }
  }

  /// DELETE: Eliminar una evaluación
  /// Nota: En el controlador se espera que el parámetro id sea de tipo string para GET/PUT, pero DELETE lo define como número.
  /// Aquí lo tratamos como String para mantener consistencia.
  Future<void> deleteEvaluacion(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la evaluación');
    }
  }

  //Cantidad de registros
  Future<int> getEvaluationCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
