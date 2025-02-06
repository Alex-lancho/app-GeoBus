// alerta.dart
class AlertModel {
  final String idAlerta;
  final String descripcion;
  final DateTime hora;

  AlertModel({
    required this.idAlerta,
    required this.descripcion,
    required this.hora,
  });

  // Construir el objeto a partir de un JSON
  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      idAlerta: json['idAlerta'],
      descripcion: json['descripcion'],
      // Se asume que el formato de fecha es ISO 8601; ajusta según tu backend
      hora: DateTime.parse(json['hora']),
    );
  }

  // Convertir el objeto a JSON (útil para enviar datos en POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idAlerta': idAlerta,
      'descripcion': descripcion,
      // Se envía la fecha en formato ISO 8601
      'hora': hora.toIso8601String(),
    };
  }
}
