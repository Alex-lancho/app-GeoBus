class NotificationModel {
  final String idNotificacion;
  final String tipo;
  final String descripcion;
  final String nombreCompleto;
  final String dni;

  NotificationModel({
    required this.idNotificacion,
    required this.tipo,
    required this.descripcion,
    required this.nombreCompleto,
    required this.dni,
  });

  // Método para construir un objeto Notificacion a partir de un JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotificacion: json['idNotificacion'],
      tipo: json['tipo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      nombreCompleto: json['tipoUsuario'] ?? '',
      dni: json['MacMovil'] ?? '',
    );
  }

  // Método para convertir el objeto Notificacion a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idNotificacion': idNotificacion,
      'tipo': tipo,
      'descripcion': descripcion,
      'tipoUsuario': nombreCompleto,
      'MacMovil': dni,
    };
  }
}
