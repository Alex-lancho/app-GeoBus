import 'package:app_ruta/widgets/home_geo_bus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa tus pantallas existentes
import 'package:app_ruta/chofer/screens/login_chofer.dart';
import 'package:app_ruta/pasajeros/screens/home.dart';

void main() async {
  // Asegura que Flutter esté inicializado y las preferencias estén disponibles
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final String? savedRole = prefs.getString('user_role');

  runApp(GeoBusApp(initialRole: savedRole));
}

class GeoBusApp extends StatelessWidget {
  final String? initialRole;

  const GeoBusApp({Key? key, this.initialRole}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget homeWidget;

    // Si ya se seleccionó un rol, asigna la pantalla correspondiente.
    if (initialRole == 'conductor') {
      homeWidget = LoginPage();
    } else if (initialRole == 'pasajero') {
      homeWidget = MapPageCliente();
    } else {
      homeWidget = const GeoBusHome();
    }

    return MaterialApp(
      title: 'GeoBus',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFE0F7FA),
      ),
      home: homeWidget,
    );
  }
}
