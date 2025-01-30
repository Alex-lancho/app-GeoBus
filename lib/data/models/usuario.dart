class Usuario {
  final String idChofer;
  final String idCombi;
  final String usuario;
  final String tipo;
  final String nombre;
  final String apellidos;
  final String dni;
  final String placa;
  final String modelo;
  final String linea;
  final String horaPartida;
  final String horaLlegada;
  final String tiempoLlegada;

  Usuario(
      {required this.idChofer,
      required this.idCombi,
      required this.usuario,
      required this.tipo,
      required this.nombre,
      required this.apellidos,
      required this.dni,
      required this.placa,
      required this.modelo,
      required this.linea,
      required this.horaPartida,
      required this.horaLlegada,
      required this.tiempoLlegada});

  // Método para convertir JSON a un objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      idChofer: json['idChofer'],
      idCombi: json['idCombi'],
      usuario: json['usuario'],
      tipo: json['tipo'],
      nombre: json['nombre'],
      apellidos: json['apellidos'],
      dni: json['dni'],
      placa: json['placa'],
      modelo: json['modelo'],
      linea: json['linea'],
      horaPartida: json['horaPartida'],
      horaLlegada: json['horaLlegada'],
      tiempoLlegada: json['tiempoLlegada'],
    );
  }
}
