// ruta.dart
class RouteModel {
  final int idRuta;
  final double ejeX;
  final double ejeY;
  final String nombreLugar;
  final String paradero;
  // Si es necesario, podrías agregar información de la combi,
  // por ejemplo, su identificador o un objeto anidado

  RouteModel({
    required this.idRuta,
    required this.ejeX,
    required this.ejeY,
    required this.nombreLugar,
    required this.paradero,
  });

  // Construir el objeto a partir de un JSON
  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      idRuta: json['idRuta'],
      ejeX: double.tryParse(json['ejeX'].toString()) ?? 0.0,
      ejeY: double.tryParse(json['ejeY'].toString()) ?? 0.0,
      nombreLugar: json['nombreLugar'] ?? '',
      paradero: json['paradero'] ?? '',
    );
  }

  // Convertir el objeto a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idRuta': idRuta,
      'ejeX': ejeX,
      'ejeY': ejeY,
      'nombreLugar': nombreLugar,
      'paradero': paradero,
    };
  }
}
