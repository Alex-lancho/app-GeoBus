import 'package:app_ruta/data/models/alert_model.dart';
import 'package:app_ruta/data/providers/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:app_ruta/data/providers/evaluation_service.dart';

/// ===========================================================================
/// Widget principal que muestra la información de la combi y las acciones
/// ===========================================================================
class BusData extends StatelessWidget {
  final String title;
  final List<dynamic> combisData;
  final String selectedRoute;

  const BusData({
    Key? key,
    required this.title,
    required this.combisData,
    required this.selectedRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtra las combis según la línea seleccionada (se espera algo tipo "Línea X").
    List<dynamic> filteredCombis = [];
    if (selectedRoute.isNotEmpty) {
      final String selectedLine = selectedRoute.split(" ").last;
      filteredCombis = combisData.where((combi) => combi['linea'].toString() == selectedLine).toList();
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: filteredCombis.isEmpty
          ? Center(
              child: Text(
                "Seleccione una línea para ver los datos del móvil.",
                style: theme.textTheme.bodyMedium,
              ),
            )
          : _buildSingleView(context, filteredCombis.first),
    );
  }

  Widget _buildSingleView(BuildContext context, dynamic combi) {
    final theme = Theme.of(context);
    final chofer = combi['chofer'];
    final horario = combi['horario'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Encabezado con icono y título
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_circle_outlined,
                size: 60,
              ),
              const SizedBox(height: 8),
              Text(
                "Datos Del Conductor",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          const SizedBox(height: 24),
          // Card principal con los datos del conductor y combi
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: const Color.fromARGB(227, 29, 146, 144),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Datos del conductor a la izquierda
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Conductor: ${chofer['nombre']} ${chofer['apellidos']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Modelo: ${combi['modelo']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Horario: ${horario['horaPartida']} - ${horario['horaLlegada']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Tiempo de llegada: ${horario['tiempoLlegada']}",
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                        if (combi['ubicaciones'] != null && combi['ubicaciones'].isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              "Última ubicación: ${combi['ubicaciones'].last['nombreLugar']}",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icono del bus a la derecha
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.directions_bus_filled_outlined,
                      size: 36,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Sección de acciones
          Text(
            'Acciones a Realizar',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _AccionBoton(
                iconData: Icons.warning_amber_rounded,
                label: 'Alertas',
                onPressed: () {
                  // Abre el modal de alertas que consulta getAlertasByChofer.
                  // Se asume que en el objeto 'chofer' se encuentra el id, por ejemplo, chofer['idChofer']
                  showDialog(
                    context: context,
                    builder: (context) => AlertasDialog(idChofer: chofer['idChofer']),
                  );
                },
              ),
              _AccionBoton(
                iconData: Icons.star_border,
                label: 'Evaluar',
                onPressed: () {
                  // Abre el modal de evaluación directamente
                  showDialog(
                    context: context,
                    builder: (context) => EvaluationDialog(idCombi: combi['idCombi']),
                  );
                },
              ),
              _AccionBoton(
                iconData: Icons.notifications,
                label: 'Notificación',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationScreen(idCombi: combi['idCombi']),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Botón de acción reutilizable
class _AccionBoton extends StatelessWidget {
  final IconData iconData;
  final String label;
  final VoidCallback onPressed;

  const _AccionBoton({
    Key? key,
    required this.iconData,
    required this.label,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return FilledButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      onPressed: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, color: colorScheme.onPrimary),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// Diálogo de Alertas
/// Consulta getAlertasByChofer y muestra la lista de alertas asociadas al chofer
/// ===========================================================================
class AlertasDialog extends StatelessWidget {
  final String idChofer;

  const AlertasDialog({Key? key, required this.idChofer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Colors.orange),
          SizedBox(width: 8),
          Text('Alertas'),
        ],
      ),
      content: FutureBuilder<List<AlertModel>>(
        future: AlertService().getAlertasByChofer(idChofer),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.hasData) {
            final alertas = snapshot.data!;
            if (alertas.isEmpty) {
              return const Text('No hay alertas disponibles.');
            }
            return SizedBox(
              // Ajusta el alto según tus necesidades
              height: 200,
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: alertas.length,
                itemBuilder: (context, index) {
                  final alerta = alertas[index];
                  return ListTile(
                    title: Text(alerta.hora.toString()),
                    subtitle: Text(alerta.descripcion),
                  );
                },
              ),
            );
          }
          return const Text('No hay datos.');
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// Diálogo de Evaluación
/// Al enviar la evaluación se muestra un resumen de los datos enviados
/// ===========================================================================
class EvaluationDialog extends StatefulWidget {
  final String idCombi;

  const EvaluationDialog({Key? key, required this.idCombi}) : super(key: key);

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  final _formKey = GlobalKey<FormState>();
  String? puntualidad;
  double comodidad = 3;
  DateTime? fecha;
  final TextEditingController descripcionController = TextEditingController();

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }

  void _submitEvaluation() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final data = {
        'puntualidad': puntualidad,
        'comodidad': comodidad.toStringAsFixed(0),
        'fecha': fecha != null ? DateFormat('yyyy-MM-dd').format(fecha!) : '',
        'descripcion': descripcionController.text,
      };

      try {
        await EvaluationService().createEvaluacion(data, widget.idCombi);
        // Mostrar resumen de lo enviado en un diálogo adicional
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Evaluación Enviada'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Puntualidad: $puntualidad"),
                Text("Comodidad: ${comodidad.toStringAsFixed(0)}"),
                Text("Fecha: ${fecha != null ? DateFormat('yyyy-MM-dd').format(fecha!) : ''}"),
                Text("Descripción: ${descripcionController.text}"),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el resumen
                  Navigator.of(context).pop(); // Cierra el diálogo de evaluación
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar evaluación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nueva Evaluación'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Selección de puntualidad ("Sí" o "No")
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Puntualidad',
                  border: OutlineInputBorder(),
                ),
                value: puntualidad,
                items: ['Sí', 'No'].map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    puntualidad = value;
                  });
                },
                validator: (value) => value == null || value.isEmpty ? 'Seleccione una opción' : null,
              ),
              const SizedBox(height: 16),
              // Slider para comodidad
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Comodidad: ${comodidad.toStringAsFixed(0)}'),
                  Slider(
                    value: comodidad,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: comodidad.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        comodidad = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Selector de fecha (read-only)
              TextFormField(
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: fecha != null ? DateFormat('yyyy-MM-dd').format(fecha!) : '',
                ),
                onTap: () async {
                  DateTime now = DateTime.now();
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: fecha ?? now,
                    firstDate: DateTime(now.year - 5),
                    lastDate: DateTime(now.year + 5),
                  );
                  if (picked != null) {
                    setState(() {
                      fecha = picked;
                    });
                  }
                },
                validator: (value) => fecha == null ? 'Seleccione la fecha' : null,
              ),
              const SizedBox(height: 16),
              // Campo de descripción
              TextFormField(
                controller: descripcionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese la descripción' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submitEvaluation,
          child: const Text('Enviar Evaluación'),
        ),
      ],
    );
  }
}

/// ===========================================================================
/// Pantalla para Notificación (se mantiene igual, solo se muestra por ejemplo)
/// ===========================================================================
class NotificationScreen extends StatefulWidget {
  final String idCombi;

  const NotificationScreen({Key? key, required this.idCombi}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _formKey = GlobalKey<FormState>();
  String tipo = '';
  String descripcion = '';
  String nombreCompleto = '';
  String dni = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enviar Notificación'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(Icons.notifications_active, size: 60, color: Colors.lightBlue),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Tipo',
                        border: OutlineInputBorder(),
                      ),
                      onSaved: (value) => tipo = value ?? '',
                      validator: (value) => value == null || value.isEmpty ? 'Ingrese el tipo de notificación' : null,
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
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          // Aquí se llamaría al NotificationService.createNotificacion con los datos recopilados.
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Notificación enviada'),
                              content: const Text('La notificación se envió correctamente.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('OK'),
                                )
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Enviar Notificación'),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
