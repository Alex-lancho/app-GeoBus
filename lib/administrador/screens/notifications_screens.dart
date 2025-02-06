import 'package:app_ruta/data/models/notification_model.dart';
import 'package:app_ruta/data/providers/notification_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class NotificationsScreens extends StatefulWidget {
  @override
  _NotificationsScreensState createState() => _NotificationsScreensState();
}

class _NotificationsScreensState extends State<NotificationsScreens> {
  // Lista de notificaciones
  List<NotificationModel> notifications = [];
  bool isLoading = true;

  // Opciones para el campo "Tipo" en el desplegable.
  final List<String> tipoOptions = ['Alerta', 'Warning', 'Emergencia', 'Info'];

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  // Método para cargar las notificaciones desde la API
  Future<void> fetchNotifications() async {
    setState(() {
      isLoading = true;
    });
    try {
      notifications = await NotificationService().getAllNotificaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las notificaciones: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Abre el formulario para crear o editar una notificación
  void _openNotificationForm([NotificationModel? notification]) {
    final bool isEditing = notification != null;
    final formKey = GlobalKey<FormState>();

    // Para "Tipo" usaremos un desplegable
    String? selectedTipo = isEditing ? notification.tipo : null;
    // Controladores para los demás campos:
    final TextEditingController descripcionController =
        TextEditingController(text: isEditing ? notification.descripcion : '');
    final TextEditingController nombreCompletoController =
        TextEditingController(text: isEditing ? notification.nombreCompleto : '');
    final TextEditingController dniController = TextEditingController(text: isEditing ? notification.dni : '');
    // Si manejas MAC y otros campos, puedes agregarlos

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Notificación' : 'Nueva Notificación'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Dropdown para Tipo (desplegable)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Tipo',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedTipo,
                        items: tipoOptions.map((option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedTipo = value;
                          });
                        },
                        validator: (value) => (value == null || value.isEmpty) ? 'Seleccione el tipo' : null,
                      ),
                      SizedBox(height: 16),
                      // Campo para Descripción
                      TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la descripción' : null,
                      ),
                      SizedBox(height: 16),
                      // Campo para Nombre Completo
                      TextFormField(
                        controller: nombreCompletoController,
                        decoration: InputDecoration(
                          labelText: 'Nombre Completo',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el nombre completo' : null,
                      ),
                      SizedBox(height: 16),
                      // Campo para DNI
                      TextFormField(
                        controller: dniController,
                        decoration: InputDecoration(
                          labelText: 'DNI',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el DNI' : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      // Preparamos los datos a enviar
                      final Map<String, dynamic> data = {
                        'tipo': selectedTipo,
                        'descripcion': descripcionController.text,
                        'nombreCompleto': nombreCompletoController.text,
                        'dni': dniController.text,
                      };

                      try {
                        if (isEditing) {
                          await NotificationService().updateNotificacion(notification!.idNotificacion, data);
                        } else {
                          await NotificationService().createNotificacion(data);
                        }
                        Navigator.of(context).pop();
                        fetchNotifications();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                  child: Text(isEditing ? 'Guardar' : 'Crear'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Método para eliminar una notificación con confirmación
  void _deleteNotification(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Notificación'),
        content: Text('¿Está seguro de eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await NotificationService().deleteNotificacion(id);
        fetchNotifications();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la notificación: $e')),
        );
      }
    }
  }

  // Método para mostrar los detalles de una notificación en una ventana modal y permitir marcarla como leída
  void _showNotificationDetails(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle de la Notificación'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tipo: ${notification.tipo}'),
              SizedBox(height: 8),
              Text('Descripción:'),
              Text(notification.descripcion),
              SizedBox(height: 8),
              Text('Nombre Completo: ${notification.nombreCompleto}'),
              SizedBox(height: 8),
              Text('DNI: ${notification.dni}'),
              // Puedes mostrar más campos si lo deseas.
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  // Se asume que marcar como leída se realiza actualizando un campo "leido" a true.
                  await NotificationService().updateNotificacion(
                    notification.idNotificacion,
                    {'leido': true},
                  );
                  Navigator.of(context).pop();
                  fetchNotifications();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al marcar como leída: $e')),
                  );
                }
              },
              child: Text('Marcar como Leída'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(child: Text('No hay notificaciones registradas.'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return InkWell(
                      onTap: () => _showNotificationDetails(notification),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.notifications),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          title: Text(notification.tipo),
                          subtitle: Text(notification.descripcion),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openNotificationForm(notification),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteNotification(notification.idNotificacion),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Crear Nueva Notificación',
        onPressed: () => _openNotificationForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
