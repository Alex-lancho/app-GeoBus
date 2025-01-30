import 'package:app_ruta/administrador/screens/home.dart';
import 'package:app_ruta/chofer/screens/home.dart';
import 'package:app_ruta/chofer/screens/registro.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/data/providers/service_login.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ServiceLogin serviceLogin = ServiceLogin();

  LoginPage({super.key});

  void handleLogin(BuildContext context) async {
    final usuario = userController.text;
    final contrasena = passwordController.text;

    try {
      // Llamar al servicio de login
      Usuario? user = await serviceLogin.login(usuario, contrasena);

      if (user != null) {
        // Redirigir según el tipo de usuario
        if (user.tipo == "Administrador") {
          Navigator.push(context, MaterialPageRoute(builder: (context) => AdminDashboardPage(usuario: user)));
        } else if (user.tipo == "Conductor") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MapPageConductor(usuario: user)),
          );
        } else {
          // Manejo de otros tipos de usuarios si aplica
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tipo de usuario desconocido: ${user.tipo}')),
          );
        }
      } else {
        // Usuario o contraseña incorrectos
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario o contraseña incorrectos $user')),
        );
      }
    } catch (e) {
      // Error de conexión o servidor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: userController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => handleLogin(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              child: const Text('INICIAR SESIÓN'),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistrationPage(),
                  ),
                );
              },
              child: const Text(
                '¿No tienes cuenta? Regístrate',
                style: TextStyle(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
