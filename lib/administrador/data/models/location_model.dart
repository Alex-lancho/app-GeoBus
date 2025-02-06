// ubicacion.dart
class LocationModel {
  final int idUbicacion;
  final double ejeX;
  final double ejeY;
  final String nombreLugar;
  final String tiempoTranscurrido;

  // Si lo requieres, puedes agregar una propiedad opcional para el idCombi o datos relacionados.
  // final String idCombi;

  LocationModel({
    required this.idUbicacion,
    required this.ejeX,
    required this.ejeY,
    required this.nombreLugar,
    required this.tiempoTranscurrido,
  });

  // Construir el objeto a partir de un JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      idUbicacion: json['idUbicacion'],
      ejeX: double.tryParse(json['ejeX'].toString()) ?? 0.0,
      ejeY: double.tryParse(json['ejeY'].toString()) ?? 0.0,
      nombreLugar: json['nombreLugar'] ?? '',
      tiempoTranscurrido: json['tiempoTranscurrido'] ?? '',
    );
  }

  // Convertir el objeto a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      // Al crear, en algunos casos no se envía el id, pues lo genera el backend.
      'idUbicacion': idUbicacion,
      'ejeX': ejeX,
      'ejeY': ejeY,
      'nombreLugar': nombreLugar,
      'tiempoTranscurrido': tiempoTranscurrido,
    };
  }
}
