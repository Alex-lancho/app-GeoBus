class ShedulModel {
  final String idHorario;
  final String horaPartida;
  final String horaLlegada;
  final String tiempoLlegada;

  ShedulModel({
    required this.idHorario,
    required this.horaPartida,
    required this.horaLlegada,
    required this.tiempoLlegada,
  });

  // Método para construir un objeto Horario a partir de un JSON
  factory ShedulModel.fromJson(Map<String, dynamic> json) {
    return ShedulModel(
      idHorario: json['idHorario'],
      horaPartida: json['horaPartida'] ?? '',
      horaLlegada: json['horaLlegada'] ?? '',
      tiempoLlegada: json['tiempoLlegada'] ?? '',
    );
  }

  // Método para convertir el objeto a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idHorario': idHorario,
      'horaPartida': horaPartida,
      'horaLlegada': horaLlegada,
      'tiempoLlegada': tiempoLlegada,
    };
  }
}
