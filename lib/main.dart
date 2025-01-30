import 'package:app_ruta/chofer/screens/login_chofer.dart';
import 'package:app_ruta/pasajeros/screens/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GeoBusApp());
}

class GeoBusApp extends StatelessWidget {
  const GeoBusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: GeoBusHomePage(),
    );
  }
}

class GeoBusHomePage extends StatelessWidget {
  const GeoBusHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFFE0F7FA),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo and Title Section
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.0),
                    child: Icon(
                      Icons.directions_bus,
                      size: 100,
                      color: Colors.blue,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'GeoBus',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'APP UBICACION',
                    style: TextStyle(
                      fontSize: 16,
                      letterSpacing: 1.5,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 60),

              // Buttons Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Center(
                        child: Text(
                          'CONDUCTOR',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPageCliente(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5,
                        backgroundColor: Colors.blueAccent,
                      ),
                      child: Center(
                        child: Text(
                          'USUARIO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),

              // Footer Section
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  '© 2025 GeoBus. Todos los derechos reservados.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
