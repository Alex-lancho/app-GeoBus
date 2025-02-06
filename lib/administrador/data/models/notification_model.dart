class NotificationModel {
  final String idNotificacion;
  final String tipo;
  final String descripcion;
  final String tipoUsuario;
  final String macMovil;

  NotificationModel({
    required this.idNotificacion,
    required this.tipo,
    required this.descripcion,
    required this.tipoUsuario,
    required this.macMovil,
  });

  // Método para construir un objeto Notificacion a partir de un JSON
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      idNotificacion: json['idNotificacion'],
      tipo: json['tipo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      tipoUsuario: json['tipoUsuario'] ?? '',
      macMovil: json['MacMovil'] ?? '',
    );
  }

  // Método para convertir el objeto Notificacion a JSON (útil para POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'idNotificacion': idNotificacion,
      'tipo': tipo,
      'descripcion': descripcion,
      'tipoUsuario': tipoUsuario,
      'MacMovil': macMovil,
    };
  }
}
