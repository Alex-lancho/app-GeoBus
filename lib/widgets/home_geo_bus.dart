import 'package:app_ruta/chofer/screens/login_chofer.dart';
import 'package:app_ruta/pasajeros/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GeoBusHome extends StatelessWidget {
  const GeoBusHome({super.key});

  /// Método para guardar el rol y navegar a la pantalla correspondiente.
  Future<void> _selectRole(BuildContext context, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);

    if (role == 'conductor') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } else if (role == 'pasajero') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapPageCliente()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores de referencia// Parte inferior
    const Color buttonColor = Color.fromARGB(255, 30, 125, 242); // Azul botones

    return Scaffold(
      body: Stack(
        children: [
          // FONDO CON DOS COLORES (Sección superior y inferior)
          Column(
            children: [
              Expanded(
                flex: 6, // Ajusta el tamaño de la parte superior
                child: Container(color: const Color.fromARGB(162, 158, 255, 247)),
              ),
              Expanded(
                flex: 4, // Ajusta el tamaño de la parte inferior
                child: Container(color: const Color.fromARGB(208, 35, 162, 151)),
              ),
            ],
          ),

          // CONTENIDO (Logo, texto y botones)
          Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  // LOGO
                  SizedBox(
                    width: 150,
                    height: 120,
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'GeoBus',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    'APP UBICACION',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.5,
                      color: Color.fromARGB(226, 0, 0, 0),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // CONTENEDOR CENTRAL BLANCO
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 40,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(234, 255, 255, 255),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Botón Conductor
                        ElevatedButton(
                          onPressed: () => _selectRole(context, 'conductor'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            'Conductor',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Botón Usuario (lógica = 'pasajero')
                        ElevatedButton(
                          onPressed: () => _selectRole(context, 'pasajero'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            elevation: 5,
                            minimumSize: const Size.fromHeight(50),
                          ),
                          child: const Text(
                            'Pasajero',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  // PIE DE PÁGINA
                  const Text(
                    '© 2025 GeoBus. Todos los derechos reservados.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(209, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
