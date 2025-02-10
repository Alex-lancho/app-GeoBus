import 'package:app_ruta/pasajeros/widgets/alerts_dialog.dart';
import 'package:app_ruta/pasajeros/widgets/action_button.dart';
import 'package:app_ruta/pasajeros/widgets/evaluation_dialog.dart';
import 'package:app_ruta/pasajeros/widgets/notification_dialog.dart';
import 'package:flutter/material.dart';

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
    List<dynamic> filteredCombis = [];
    if (selectedRoute.isNotEmpty) {
      final String selectedLine = selectedRoute.split(" ").last;
      filteredCombis = combisData.where((combi) => combi['linea'].toString() == selectedLine).toList();
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: filteredCombis.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.directions_bus_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Seleccione una línea\npara ver los datos del móvil",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          : _buildSingleView(context, filteredCombis.first),
    );
  }

  Widget _buildSingleView(BuildContext context, dynamic combi) {
    final chofer = combi['chofer'];
    final horario = combi['horario'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.account_circle_outlined,
                    size: 50,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Datos Del Conductor",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Driver Info Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1D9290),
                  const Color(0xFF1D9290).withOpacity(0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1D9290).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -20,
                  top: -20,
                  child: Icon(
                    Icons.directions_bus,
                    size: 100,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        "Conductor",
                        "${chofer['nombre']} ${chofer['apellidos']}",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.directions_bus_filled,
                        "Modelo",
                        combi['modelo'],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.access_time,
                        "Horario",
                        "${horario['horaPartida']} - ${horario['horaLlegada']}",
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.timer,
                        "Tiempo de llegada",
                        horario['tiempoLlegada'],
                      ),
                      if (combi['ubicaciones'] != null && combi['ubicaciones'].isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          Icons.location_on,
                          "Última ubicación",
                          combi['ubicaciones'].last['nombreLugar'],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Acciones a Realizar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      context,
                      Icons.warning_amber_rounded,
                      'Alertas',
                      Colors.orange,
                      () => showDialog(
                        context: context,
                        builder: (context) => AlertsDialog(idChofer: chofer['idChofer']),
                      ),
                    ),
                    _buildActionButton(
                      context,
                      Icons.star_border,
                      'Evaluar',
                      Colors.blue,
                      () => showDialog(
                        context: context,
                        builder: (context) => EvaluationDialog(idChofer: chofer['idChofer']),
                      ),
                    ),
                    _buildActionButton(
                      context,
                      Icons.notifications,
                      'Notificación',
                      Colors.green,
                      () => showDialog(
                        context: context,
                        builder: (context) => const NotificationDialog(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
