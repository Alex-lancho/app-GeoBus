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
    // Creamos las dos pantallas: Evaluaciones y Alertas
    _screens = [
      EvaluationsPage(idChofer: widget.idChofer),
      AlertsPage(idChofer: widget.idChofer),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          labelTextStyle: MaterialStateProperty.all(
            const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
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
      ),
    );
  }
}

///
/// Pantalla para mostrar las Evaluaciones recibidas
///
class EvaluationsPage extends StatelessWidget {
  final String idChofer;
  const EvaluationsPage({Key? key, required this.idChofer}) : super(key: key);

  // Ejemplo de evaluaciones de prueba
  final List<Map<String, dynamic>> _evaluaciones = const [
    {
      "puntualidad": "Excelente",
      "comodidad": "Muy buena",
      "fecha": "2025-02-05",
      "descripcion": "Llegó antes de la hora acordada y fue muy amable.",
    },
    {
      "puntualidad": "Regular",
      "comodidad": "Aceptable",
      "fecha": "2025-02-03",
      "descripcion": "El viaje estuvo bien, aunque se demoró un poco en llegar.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluaciones Recibidas'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _evaluaciones.isEmpty
          ? const Center(child: Text("No tienes evaluaciones aún"))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _evaluaciones.length,
              itemBuilder: (context, index) {
                final eval = _evaluaciones[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.secondaryContainer,
                        child: Icon(
                          Icons.thumb_up_alt_rounded,
                          color: colorScheme.secondary,
                        ),
                      ),
                      title: Text(
                        "Puntualidad: ${eval['puntualidad']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Comodidad: ${eval['comodidad']}"),
                            Text("Fecha: ${eval['fecha']}"),
                            const SizedBox(height: 6),
                            Text(
                              eval['descripcion'],
                              style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

///
/// Pantalla para ver y enviar Alertas
///
class AlertsPage extends StatefulWidget {
  final String idChofer;
  const AlertsPage({Key? key, required this.idChofer}) : super(key: key);

  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  // Ejemplo de alertas existentes
  final List<Map<String, dynamic>> _alertas = [
    {
      "descripcion": "Tráfico pesado en ruta",
      "hora": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "descripcion": "Retraso por desperfecto mecánico",
      "hora": DateTime.now().subtract(const Duration(days: 1)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Alertas'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _alertas.isEmpty
          ? const Center(child: Text("No has enviado alertas todavía"))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _alertas.length,
              itemBuilder: (context, index) {
                final alerta = _alertas[index];
                final hora = alerta['hora'] as DateTime;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.errorContainer,
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: colorScheme.error,
                        ),
                      ),
                      title: Text(
                        alerta['descripcion'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Hora: ${hora.toLocal().toString().split('.')[0]}",
                          style: TextStyle(fontSize: 13, color: colorScheme.onSurface.withOpacity(0.6)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostrarDialogNuevaAlerta,
        icon: const Icon(Icons.add_alert),
        label: const Text('Nueva Alerta'),
      ),
    );
  }

  ///
  /// Diálogo para crear y enviar una nueva alerta
  ///
  void _mostrarDialogNuevaAlerta() {
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Enviar Nueva Alerta'),
          content: TextField(
            controller: descController,
            decoration: InputDecoration(
              hintText: 'Descripción de la alerta',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (descController.text.trim().isNotEmpty) {
                  setState(() {
                    _alertas.insert(0, {
                      "descripcion": descController.text.trim(),
                      "hora": DateTime.now(),
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Enviar'),
            ),
          ],
        );
      },
    );
  }
}
