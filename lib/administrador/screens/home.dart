import 'package:app_ruta/administrador/data/services/alert_service.dart';
import 'package:app_ruta/administrador/data/services/combi_service.dart';
import 'package:app_ruta/administrador/data/services/driver_service.dart';
import 'package:app_ruta/administrador/data/services/evaluation_service.dart';
import 'package:app_ruta/administrador/data/services/location_service.dart';
import 'package:app_ruta/administrador/data/services/notification_service.dart';
import 'package:app_ruta/administrador/data/services/route_service.dart';
import 'package:app_ruta/administrador/data/services/shedul_service.dart';
import 'package:app_ruta/administrador/screens/alerts_screens.dart';
import 'package:app_ruta/administrador/screens/combis_screens.dart';
import 'package:app_ruta/administrador/screens/drivers_screen.dart';
import 'package:app_ruta/administrador/screens/evaluations_screens.dart';
import 'package:app_ruta/administrador/screens/locations_screens.dart';
import 'package:app_ruta/administrador/screens/notifications_screens.dart';
import 'package:app_ruta/administrador/screens/routes_screens.dart';
import 'package:app_ruta/administrador/screens/shedules_screens.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatefulWidget {
  final Map<String, dynamic> usuario;

  const AdminDashboardPage({Key? key, required this.usuario}) : super(key: key);

  @override
  _AdminDashboardPageState createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  // Inicializamos los contadores en cero
  int choferesCount = 0;
  int combisCount = 0;
  int rutasCount = 0;
  int alertasCount = 0;
  int notificacionesCount = 0;
  int evaluacionesCount = 0;
  int horariosCount = 0;
  int ubicacionesCount = 0;

  @override
  void initState() {
    super.initState();
    // Llamamos a la función para cargar los conteos desde la API
    loadCounts();
  }

  Future<void> loadCounts() async {
    try {
      final int choferCount = await DriverService().getDriverCount();
      final int combiCount = await CombiService().getCombiCount();
      final int rutaCount = await RouteService().getRouteCount();
      final int alertaCount = await AlertService().getAlertaCount();
      final int notificacionCount = await NotificationService().getNotificationCount();
      final int evaluacionCount = await EvaluationService().getEvaluationCount();
      final int horarioCount = await ShedulService().getShedulesCount();
      final int ubicacionCount = await LocationService().getLocationCount();

      // Actualizamos el estado con los valores obtenidos
      setState(() {
        choferesCount = choferCount;
        combisCount = combiCount;
        rutasCount = rutaCount;
        alertasCount = alertaCount;
        notificacionesCount = notificacionCount;
        evaluacionesCount = evaluacionCount;
        horariosCount = horarioCount;
        ubicacionesCount = ubicacionCount;
      });
    } catch (e) {
      // Puedes manejar el error mostrando un mensaje en consola o en la UI
      print("Error al cargar los conteos: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final adminInfo = widget.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text('Administrador'),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () => _mostrarInfoUsuario(context, adminInfo),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _headerSection(adminInfo),
            SizedBox(height: 10),
            _statsGrid(context),
            SizedBox(height: 20),
            _seccionTablas(context),
          ],
        ),
      ),
    );
  }

  /// Sección de encabezado con info del Admin
  Widget _headerSection(Map<String, dynamic> adminInfo) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 15, 146, 211),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de perfil (opcional)
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.admin_panel_settings,
                  color: Colors.indigo,
                  size: 35,
                ),
              ),
              SizedBox(width: 16),
              Text(
                '${adminInfo["nombre"] ?? "Admin"} ${adminInfo["apellidos"] ?? ""}',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tipo: ${adminInfo["tipo"] ?? ""}',
            style: TextStyle(color: Colors.white70),
          ),
          Text(
            'DNI: ${adminInfo["dni"] ?? ""}',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            'Panel de Super Administrador',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  /// Sección de cards con estadísticas
  Widget _statsGrid(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          _statCard('Choferes', choferesCount, Icons.person_outline, Colors.blue),
          _statCard('Combis', combisCount, Icons.bus_alert, Colors.orange),
          _statCard('Rutas', rutasCount, Icons.map, Colors.teal),
          _statCard('Alertas', alertasCount, Icons.warning, Colors.red),
          _statCard('Notificaciones', notificacionesCount, Icons.notifications, Colors.purple),
          _statCard('Evaluaciones', evaluacionesCount, Icons.star_rate_outlined, Colors.green),
          _statCard('Horarios', horariosCount, Icons.av_timer, Colors.brown),
          _statCard('Ubicaciones', ubicacionesCount, Icons.location_on_outlined, Colors.blueGrey),
        ],
      ),
    );
  }

  /// Widget para cada tarjeta de estadísticas
  Widget _statCard(String titulo, int count, IconData icon, Color colorFondo) {
    return Container(
      width: 170,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: colorFondo,
            child: Icon(icon, color: Colors.white),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  titulo,
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Sección con botones o accesos directos a cada CRUD
  Widget _seccionTablas(BuildContext context) {
    return Column(
      children: [
        Text(
          'Tablas Disponibles',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Divider(),
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: [
            _crudButton(context, "Choferes", Icons.person, _navegateADrivers),
            _crudButton(context, "Combis", Icons.directions_bus_filled, _navegateACombis),
            _crudButton(context, "Evaluaciones", Icons.star_border, _navegateAEvaluations),
            _crudButton(context, "Alertas", Icons.warning_amber, _navegateAAlerts),
            _crudButton(context, "Notificaciones", Icons.notifications_active, _navegateNotifications),
            _crudButton(context, "Rutas", Icons.map_outlined, _navegateARoutes),
            _crudButton(context, "Horarios", Icons.schedule, _navegateAShedules),
            _crudButton(context, "Ubicaciones", Icons.location_on, _navegateALocation),
          ],
        ),
      ],
    );
  }

  /// Botón genérico para cada tabla
  Widget _crudButton(BuildContext context, String nombre, IconData icono, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.indigo.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icono, color: Colors.indigo.shade700, size: 30),
          ),
          SizedBox(height: 5),
          Text(nombre),
        ],
      ),
    );
  }

  // Funciones de navegación a páginas "placeholder" de cada CRUD
  void _navegateADrivers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DriversScreen()),
    );
  }

  void _navegateACombis() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CombisScreens()),
    );
  }

  void _navegateARoutes() {
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoutesScreens()),
    );*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aun esta en desarrollo'), duration: const Duration(milliseconds: 1500),
        width: 300.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _navegateAShedules() {
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShedulesScreens()),
    );*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aun esta en desarrollo'), duration: const Duration(milliseconds: 1500),
        width: 300.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _navegateALocation() {
    /*Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LocationsScreens()),
    );*/
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Aun esta en desarrollo'), duration: const Duration(milliseconds: 1500),
        width: 300.0, // Width of the SnackBar.
        padding: const EdgeInsets.symmetric(
          horizontal: 10.0,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _navegateAEvaluations() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EvaluationsScreens()),
    );
  }

  void _navegateAAlerts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AlertsScreens()),
    );
  }

  void _navegateNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NotificationsScreens()),
    );
  }

  /// Modal con datos del usuario
  void _mostrarInfoUsuario(BuildContext context, Map<String, dynamic> usuario) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Datos del Usuario',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.indigo,
            ),
          ),
          content: Container(
            // Ajusta el ancho máximo si lo deseas
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Usuario', usuario['usuario']),
                SizedBox(height: 8),
                SizedBox(height: 8),
                _buildInfoRow('Tipo', usuario['tipo']),
                SizedBox(height: 8),
                _buildInfoRow('Nombre', usuario['nombre']),
                SizedBox(height: 8),
                _buildInfoRow('Apellidos', usuario['apellidos']),
                SizedBox(height: 8),
                _buildInfoRow('DNI', usuario['dni']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cerrar',
                style: TextStyle(
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ),
      ],
    );
  }
}
