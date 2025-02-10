import 'package:app_ruta/data/providers/notification_service.dart';
import 'package:flutter/material.dart';

class NotificationDialog extends StatefulWidget {
  const NotificationDialog({super.key});

  @override
  State<NotificationDialog> createState() => _NotificationDialogState();
}

class _NotificationDialogState extends State<NotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  String tipo = 'Emergencia'; // Valor por defecto
  String descripcion = '';
  String nombreCompleto = '';
  String dni = '';

  // Lista de tipos de alerta disponibles
  final List<String> tiposAlerta = [
    'Emergencia',
    'Información',
    'Advertencia',
    'Error',
    'Mantenimiento',
  ];

  // Función para obtener el ícono según el tipo
  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Emergencia':
        return Icons.warning_amber_rounded;
      case 'Información':
        return Icons.info_outline;
      case 'Advertencia':
        return Icons.warning_outlined;
      case 'Error':
        return Icons.error_outline;
      case 'Mantenimiento':
        return Icons.build_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  // Función para obtener el color según el tipo
  Color _getColorForTipo(String tipo) {
    switch (tipo) {
      case 'Emergencia':
        return Colors.red;
      case 'Información':
        return Colors.blue;
      case 'Advertencia':
        return Colors.orange;
      case 'Error':
        return Colors.red[700] ?? Colors.red;
      case 'Mantenimiento':
        return Colors.grey[700] ?? Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          const Icon(Icons.notifications_active, size: 40, color: Colors.lightBlue),
          const SizedBox(height: 8),
          const Text('Enviar Notificación'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: tipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Alerta',
                  border: OutlineInputBorder(),
                ),
                items: tiposAlerta.map((String tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Row(
                      children: [
                        Icon(
                          _getIconForTipo(tipo),
                          color: _getColorForTipo(tipo),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(tipo),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    tipo = newValue ?? 'Emergencia';
                  });
                },
                validator: (value) => value == null ? 'Seleccione un tipo de alerta' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => descripcion = value ?? '',
                validator: (value) => value == null || value.isEmpty ? 'Ingrese una descripción' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre Completo',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => nombreCompleto = value ?? '',
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el nombre' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'DNI',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => dni = value ?? '',
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el DNI' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final Map<String, dynamic> data = {
                'tipo': tipo,
                'descripcion': descripcion,
                'nombreCompleto': nombreCompleto,
                'dni': dni,
              };

              try {
                NotificationService().createNotificacion(data);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('La notificacion se registro exitosamente!!!')),
                );
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error al registra la notificacion: $e')),
                );
              }
            }
          },
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}
