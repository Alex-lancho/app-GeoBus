class Ruta {
  final String ejeX;
  final String ejeY;
  final String nombreLugar;
  final String paradero;

  Ruta({
    required this.ejeX,
    required this.ejeY,
    required this.nombreLugar,
    required this.paradero,
  });

  // Método para convertir JSON a un objeto Usuario
  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      ejeX: json['ejeX'],
      ejeY: json['ejeY'],
      nombreLugar: json['nombreLugar'],
      paradero: json['paradero'],
    );
  }
}
