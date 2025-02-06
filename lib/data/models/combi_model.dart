// combi.dart
class CombiModel {
  final String idCombi;
  final String placa;
  final String modelo;
  final String linea;

  CombiModel({
    required this.idCombi,
    required this.placa,
    required this.modelo,
    required this.linea,
  });

  // Construir un objeto Combi a partir de un JSON
  factory CombiModel.fromJson(Map<String, dynamic> json) {
    return CombiModel(
      idCombi: json['idCombi'],
      placa: json['placa'] ?? '',
      modelo: json['modelo'] ?? '',
      linea: json['linea'] ?? '',
    );
  }

  // Convertir el objeto Combi a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idCombi': idCombi,
      'placa': placa,
      'modelo': modelo,
      'linea': linea,
    };
  }
}
