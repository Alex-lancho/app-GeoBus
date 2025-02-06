// evaluacion.dart
class EvaluationModel {
  final String idEvaluacion;
  final String puntualidad;
  final String comodidad;
  final String fecha;
  final String descripcion;

  EvaluationModel({
    required this.idEvaluacion,
    required this.puntualidad,
    required this.comodidad,
    required this.fecha,
    required this.descripcion,
  });

  // Construir un objeto Evaluacion a partir de un JSON
  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      idEvaluacion: json['idEvaluacion'],
      puntualidad: json['puntualidad'] ?? '',
      comodidad: json['comodidad'] ?? '',
      fecha: json['fecha'] ?? '',
      descripcion: json['descripcion'] ?? '',
    );
  }

  // Convertir el objeto a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idEvaluacion': idEvaluacion,
      'puntualidad': puntualidad,
      'comodidad': comodidad,
      'fecha': fecha,
      'descripcion': descripcion,
    };
  }
}
