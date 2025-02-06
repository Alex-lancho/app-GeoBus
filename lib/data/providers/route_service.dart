// ruta_api_service.dart
import 'dart:convert';
import 'package:app_ruta/data/models/route_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class RouteService {
  final String baseUrl = '${ApiService.url}/ruta';

  /// GET: Obtener todas las rutas
  Future<List<RouteModel>> getAllRutas() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => RouteModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las rutas');
    }
  }

  /// GET: Obtener rutas filtradas por query (por ejemplo: idUsuario e idCombi)
  Future<List<RouteModel>> getRutasByQuery({String? idUsuario, String? idCombi}) async {
    Map<String, String> queryParams = {};
    if (idUsuario != null) queryParams['idUsuario'] = idUsuario;
    if (idCombi != null) queryParams['idCombi'] = idCombi;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => RouteModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener rutas con query');
    }
  }

  /// GET: Obtener rutas por idCombi (en la ruta: /:idCombi)
  Future<List<RouteModel>> getRutasByCombi(String idCombi) async {
    final url = '$baseUrl/$idCombi';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => RouteModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las rutas de la combi');
    }
  }

  /// POST: Crear una nueva ruta
  Future<RouteModel> createRuta(Map<String, dynamic> rutaData, String idCombi) async {
    final url = '$baseUrl/createRuta';
    final Map<String, dynamic> payload = {
      'data': rutaData,
      'idCombi': idCombi,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(payload),
    );

    // Se asume que el backend retorna 201 o 200 si se crea correctamente
    if (response.statusCode == 201 || response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la ruta');
    }
  }

  /// PUT: Actualizar una ruta existente
  Future<RouteModel> updateRuta(int id, Map<String, dynamic> rutaData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(rutaData),
    );
    if (response.statusCode == 200) {
      return RouteModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la ruta');
    }
  }

  /// DELETE: Eliminar una ruta por su id
  Future<void> deleteRuta(int id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la ruta');
    }
  }

  //Cantidad de registros
  Future<int> getRouteCount() async {
    final response = await http.get(Uri.parse('$baseUrl/total'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
