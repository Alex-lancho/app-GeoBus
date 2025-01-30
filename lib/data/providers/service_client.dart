import 'dart:convert';
import 'package:http/http.dart' as http;

class ServiceClient {
  String url = 'http://192.168.3.12:3000';

  Future<List<dynamic>> combi() async {
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
}
