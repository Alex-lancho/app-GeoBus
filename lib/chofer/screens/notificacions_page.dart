import 'package:app_ruta/data/models/alert_model.dart';
import 'package:app_ruta/data/models/evaluation_model.dart';
import 'package:app_ruta/data/providers/alert_service.dart';
import 'package:app_ruta/data/providers/evaluation_service.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  final String idChofer;
  const NotificationsPage({Key? key, required this.idChofer}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      EvaluationsPage(idChofer: widget.idChofer),
      AlertsPage(idChofer: widget.idChofer),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.star_outline),
            selectedIcon: Icon(Icons.star),
            label: 'Evaluaciones',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
        ],
      ),
    );
  }
}

class EvaluationsPage extends StatefulWidget {
  final String idChofer;
  const EvaluationsPage({Key? key, required this.idChofer}) : super(key: key);

  @override
  State<EvaluationsPage> createState() => _EvaluationsPageState();
}

class _EvaluationsPageState extends State<EvaluationsPage> {
  late Future<List<EvaluationModel>> _evaluacionesFuture;
  final _evaluationService = EvaluationService();

  @override
  void initState() {
    super.initState();
    _loadEvaluaciones();
  }

  Future<void> _loadEvaluaciones() async {
    setState(() {
      _evaluacionesFuture = _evaluationService.getAllEvaluaciones();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEvaluaciones,
          ),
        ],
      ),
      body: FutureBuilder<List<EvaluationModel>>(
        future: _evaluacionesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _loadEvaluaciones,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final evaluaciones = snapshot.data!;
          if (evaluaciones.isEmpty) {
            return const Center(
              child: Text('No hay evaluaciones disponibles'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: evaluaciones.length,
            itemBuilder: (context, index) {
              final eval = evaluaciones[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.star, color: colorScheme.primary),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Puntualidad: ${eval.puntualidad}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                  'Comodidad: ${eval.comodidad}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text(
                        eval.descripcion,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Fecha: ${eval.fecha}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class AlertsPage extends StatefulWidget {
  final String idChofer;
  const AlertsPage({Key? key, required this.idChofer}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  late Future<List<AlertModel>> _alertasFuture;
  final _alertService = AlertService();
  final _descController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAlertas();
  }

  Future<void> _loadAlertas() async {
    setState(() {
      _alertasFuture = _alertService.getAlertasByChofer(widget.idChofer);
    });
  }

  Future<void> _createAlerta() async {
    if (_descController.text.trim().isEmpty) return;

    final nuevaAlerta = {
      'descripcion': _descController.text.trim(),
      'hora': DateTime.now().toIso8601String(),
    };

    try {
      await _alertService.createAlerta(nuevaAlerta, widget.idChofer);
      _descController.clear();
      _loadAlertas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta creada con éxito')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la alerta: $e')),
        );
      }
    }
  }

  Future<void> _deleteAlerta(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta alerta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _alertService.deleteAlerta(id);
      _loadAlertas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta eliminada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la alerta: $e')),
        );
      }
    }
  }

  Future<void> _editAlerta(AlertModel alerta) async {
    _descController.text = alerta.descripcion;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Alerta'),
        content: TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _descController.text),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );

    if (result == null || result.trim().isEmpty) return;

    try {
      await _alertService.updateAlerta(
        alerta.idAlerta,
        {
          ...alerta.toJson(),
          'descripcion': result.trim(),
        },
      );
      _loadAlertas();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alerta actualizada')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar la alerta: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAlertas,
          ),
        ],
      ),
      body: FutureBuilder<List<AlertModel>>(
        future: _alertasFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _loadAlertas,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final alertas = snapshot.data!;
          if (alertas.isEmpty) {
            return const Center(
              child: Text('No hay alertas disponibles'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alertas.length,
            itemBuilder: (context, index) {
              final alerta = alertas[index];
              return Dismissible(
                key: Key(alerta.idAlerta),
                direction: DismissDirection.endToStart,
                onDismissed: (_) => _deleteAlerta(alerta.idAlerta),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.errorContainer,
                      child: Icon(
                        Icons.warning_amber_rounded,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    title: Text(alerta.descripcion),
                    subtitle: Text(
                      'Enviada: ${alerta.hora.toLocal().toString().split('.')[0]}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _editAlerta(alerta),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAlertDialog(),
        icon: const Icon(Icons.add_alert),
        label: const Text('Nueva Alerta'),
      ),
    );
  }

  Future<void> _showCreateAlertDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nueva Alerta'),
        content: TextField(
          controller: _descController,
          decoration: const InputDecoration(
            labelText: 'Descripción',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _createAlerta();
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }
}
