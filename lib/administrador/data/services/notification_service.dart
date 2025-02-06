// notificacion_api_service.dart
import 'dart:convert';
import 'package:app_ruta/administrador/data/models/notification_model.dart';
import 'package:app_ruta/services/api_service.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final String baseUrl = '${ApiService.url}/notificaciones';

  /// GET: Obtener todas las notificaciones
  Future<List<NotificationModel>> getAllNotificaciones() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List<dynamic> body = jsonDecode(response.body);
      return body.map((json) => NotificationModel.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las notificaciones');
    }
  }

  /// GET: Obtener una notificacion por id
  Future<NotificationModel> getNotificacion(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al cargar la notificación');
    }
  }

  /// POST: Crear una nueva notificación
  Future<NotificationModel> createNotificacion(Map<String, dynamic> notificacionData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(notificacionData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return NotificationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al crear la notificación');
    }
  }

  /// PUT: Actualizar una notificación existente
  Future<NotificationModel> updateNotificacion(String id, Map<String, dynamic> notificacionData) async {
    final url = '$baseUrl/$id';
    final response = await http.put(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(notificacionData),
    );
    if (response.statusCode == 200) {
      return NotificationModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Error al actualizar la notificación');
    }
  }

  /// DELETE: Eliminar una notificación
  Future<void> deleteNotificacion(String id) async {
    final url = '$baseUrl/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Error al eliminar la notificación');
    }
  }

  //Cantidad de registros
  Future<int> getNotificationCount() async {
    final response = await http.get(Uri.parse('$baseUrl/count'));
    if (response.statusCode == 200) {
      // Se asume que el endpoint retorna un número en formato JSON, por ejemplo: 42
      return jsonDecode(response.body) as int;
    } else {
      throw Exception('Error al obtener la cantidad de ubicaciones');
    }
  }
}
