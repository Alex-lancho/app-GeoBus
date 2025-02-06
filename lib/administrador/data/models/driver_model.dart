class DriverModel {
  final String idChofer;
  final String nombre;
  final String apellidos;
  final String dni;

  DriverModel({
    required this.idChofer,
    required this.nombre,
    required this.apellidos,
    required this.dni,
  });

  // Método para construir el objeto a partir de un JSON
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      idChofer: json['idChofer'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      dni: json['dni'],
    );
  }

  // Método para convertir el objeto a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idChofer': idChofer,
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
    };
  }
}
