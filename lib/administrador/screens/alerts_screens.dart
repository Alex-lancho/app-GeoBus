import 'package:app_ruta/data/models/alert_model.dart';
import 'package:app_ruta/data/models/driver_model.dart';
import 'package:app_ruta/data/providers/alert_service.dart';
import 'package:app_ruta/data/providers/driver_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class AlertsScreens extends StatefulWidget {
  @override
  _AlertsScreensState createState() => _AlertsScreensState();
}

class _AlertsScreensState extends State<AlertsScreens> {
  // Lista de alertas
  List<AlertModel> alerts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAlerts();
  }

  // Método para cargar las alertas desde la API
  Future<void> fetchAlerts() async {
    setState(() {
      isLoading = true;
    });
    try {
      alerts = await AlertService().getAlertas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las alertas: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Método para abrir el formulario de creación/edición de alerta (ya implementado)
  void _openAlertForm([AlertModel? alert]) {
    final bool isEditing = alert != null;
    final formKey = GlobalKey<FormState>();

    // Campo para descripción
    final TextEditingController descripcionController = TextEditingController(text: isEditing ? alert.descripcion : '');

    // Variable para la hora seleccionada (usaremos TimeOfDay)
    TimeOfDay? selectedTime = isEditing ? TimeOfDay.fromDateTime(alert.hora) : null;
    // Para mostrar en el TextFormField (readOnly)
    final TextEditingController horaController =
        TextEditingController(text: selectedTime != null ? selectedTime.format(context) : '');

    // Variable local para almacenar el id de la combi seleccionada (solo en creación)
    String? selectedChoferId;

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para actualizar el estado local del diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Alerta' : 'Nueva Alerta'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Si estamos creando, se muestra el dropdown para seleccionar combi
                      if (!isEditing)
                        FutureBuilder<List<DriverModel>>(
                          future: DriverService().getChoferes(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<DriverModel> combis = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Chofer',
                                  border: OutlineInputBorder(),
                                ),
                                items: combis.map((chofer) {
                                  return DropdownMenuItem<String>(
                                    value: chofer.idChofer,
                                    child: Text('${chofer.nombre} ${chofer.apellidos}'),
                                  );
                                }).toList(),
                                value: selectedChoferId,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    selectedChoferId = value;
                                  });
                                },
                                validator: (value) => (value == null || value.isEmpty) ? 'Seleccione un chofer' : null,
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error al cargar chofer');
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      if (!isEditing) SizedBox(height: 16),
                      // Campo para la descripción
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
                      // Campo para seleccionar la hora (readOnly)
                      TextFormField(
                        readOnly: true,
                        controller: horaController,
                        decoration: InputDecoration(
                          labelText: 'Hora',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        onTap: () async {
                          TimeOfDay now = TimeOfDay.now();
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? now,
                          );
                          if (picked != null) {
                            setStateDialog(() {
                              selectedTime = picked;
                              horaController.text = picked.format(context);
                            });
                          }
                        },
                        validator: (value) => (selectedTime == null) ? 'Seleccione la hora' : null,
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
                      // Preparamos los datos a enviar.
                      // Para la hora, combinamos la fecha actual con el TimeOfDay seleccionado.
                      DateTime now = DateTime.now();
                      DateTime horaFinal =
                          DateTime(now.year, now.month, now.day, selectedTime!.hour, selectedTime!.minute);
                      final Map<String, dynamic> data = {
                        'descripcion': descripcionController.text,
                        'hora': horaFinal.toIso8601String(),
                      };

                      try {
                        if (isEditing) {
                          await AlertService().updateAlerta(alert.idAlerta, data);
                        } else {
                          // En creación, es obligatorio haber seleccionado una combi
                          if (selectedChoferId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Seleccione una combi')),
                            );
                            return;
                          }
                          await AlertService().createAlerta(data, selectedChoferId!);
                        }
                        Navigator.of(context).pop();
                        fetchAlerts();
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

  // Método para eliminar una alerta con confirmación
  void _deleteAlert(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Alerta'),
        content: Text('¿Está seguro de eliminar esta alerta?'),
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
        await AlertService().deleteAlerta(id);
        fetchAlerts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la alerta: $e')),
        );
      }
    }
  }

  // Método para mostrar los detalles de una alerta en una ventana modal y poder marcarla como leída
  void _showAlertDetails(AlertModel alert) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalle de la Alerta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Descripción:'),
              Text(alert.descripcion),
              SizedBox(height: 12),
              Text('Hora:'),
              Text(DateFormat('yyyy-MM-dd HH:mm').format(alert.hora)),
              SizedBox(height: 12),
              // Si deseas mostrar si está leída, suponiendo que existe una propiedad "leido"
              // Text('Leída: ${alert.leido ? "Sí" : "No"}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
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
        title: Text('Alertas'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : alerts.isEmpty
              ? Center(child: Text('No hay alertas registradas.'))
              : ListView.builder(
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    return InkWell(
                      onTap: () => _showAlertDetails(alert),
                      child: Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.notification_important_outlined),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          title: Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(alert.hora),
                          ),
                          subtitle: Text(alert.descripcion),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openAlertForm(alert),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteAlert(alert.idAlerta),
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
        tooltip: 'Crear Nueva Alerta',
        onPressed: () => _openAlertForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
