class RegistrationData {
  String nombre = '';
  String apellidos = '';
  String dni = '';

  String usuario = '';
  String contrasenia = '';
  String confirmacionContrasenia = '';

  String placa = '';
  String modelo = '';
  String horaInicio = '';
  String horaFin = '';
  String tiempoLlegada = '';
  String linea = '';

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'apellidos': apellidos,
      'dni': dni,
      'usuario': usuario,
      'contrasenia': contrasenia,
      'placa': placa,
      'modelo': modelo,
      'hora_inicio': horaInicio,
      'linea': linea,
      'hora_fin': horaFin,
      'tiempo_llegada': tiempoLlegada,
    };
  }
}
