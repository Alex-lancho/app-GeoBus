import 'package:app_ruta/administrador/screens/home.dart';
import 'package:app_ruta/chofer/screens/home.dart';
import 'package:app_ruta/chofer/screens/registro.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/data/providers/service_login.dart';
import 'package:app_ruta/services/preferences.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final ServiceLogin serviceLogin = ServiceLogin();

  LoginPage({super.key});

  /*void handleLogin(BuildContext context) async {
    final usuario = userController.text;
    final contrasena = passwordController.text;

    try {
      // Llamar al servicio de login
      Usuario? user = await serviceLogin.login(usuario, contrasena);

      if (user != null) {
        // Redirigir según el tipo de usuario
        if (user.tipo == "Administrador") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AdminDashboardPage(usuario: user)),
          );
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
          SnackBar(content: Text('Usuario o contraseña incorrecto')),
        );
      }
    } catch (e) {
      // Error de conexión o servidor
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }*/
  void handleLogin(BuildContext context) async {
    final usuario = userController.text;
    final contrasena = passwordController.text;

    try {
      // Llamar al servicio de login
      Map<String, dynamic>? data = await serviceLogin.login(usuario, contrasena);

      if (data != null) {
        // Redirigir según el tipo de usuario
        if (data["tipo"] == "Administrador") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AdminDashboardPage(usuario: data),
            ),
          );
        } else if (data["tipo"] == "Conductor") {
          Usuario usuario = Usuario.fromJson(data);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MapPageConductor(usuario: usuario),
            ),
          );
        } else {
          // Manejo de otros tipos de usuarios si aplica
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tipo de usuario desconocido: ${data["tipo"]}')),
          );
        }
      } else {
        // Usuario o contraseña incorrectos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario o contraseña incorrecto')),
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
      // Color de fondo similar al de la imagen
      backgroundColor: const Color(0xFFE0F7FA),
      appBar: AppBar(
        // Hacemos el AppBar translúcido/ligero para que no choque con el diseño
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          ' ', // Se deja en blanco para no sobreponer el título grande del body
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle),
            tooltip: 'Cambiar rol',
            onPressed: () => Preferences.changeRole(context, 'conductor'),
          )
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícono circular grande para el "avatar" de la pantalla de login
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.black12,
                  child: Icon(
                    Icons.lock_person,
                    size: 60,
                    color: const Color.fromARGB(218, 0, 0, 0),
                  ),
                ),
                const SizedBox(height: 16),
                // Título de la pantalla de login
                const Text(
                  'INICIO DE SESIÓN',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                // Campo de texto para el usuario (lo llamamos "Email" para seguir la imagen)
                TextField(
                  controller: userController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Color.fromARGB(154, 0, 0, 0)),
                    labelText: 'Usuaro/Correo',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(154, 0, 0, 0),
                    ), // Color del texto cuando no está enfocado
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(255, 60, 60, 60), width: 1.5), // Borde cuando no está en foco
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                          color: Color.fromARGB(154, 18, 101, 184), width: 2.0), // Borde cuando tiene foco
                    ), // Color del texto cuando está enfocado
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                // Campo de texto para la contraseña passwordController
                TextField(
                  controller: passwordController,
                  obscureText: true, // Ocultar texto de la contraseña
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    labelStyle: const TextStyle(
                      color: Color.fromARGB(154, 0, 0, 0),
                      fontWeight: FontWeight.normal, // Negrita para mejor visibilidad
                    ), // Color del texto cuando no está enfocado
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0), // Bordes más redondeados
                      borderSide: const BorderSide(
                        color: Color.fromARGB(255, 60, 60, 60),
                        width: 1.5, // Borde cuando no está en foco
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: const BorderSide(
                        color: Color.fromARGB(154, 18, 101, 184),
                        width: 2.0, // Borde cuando tiene foco
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.lock, color: Color.fromARGB(154, 0, 0, 0)), // Icono de candado
                  ),
                ),

                const SizedBox(height: 24),
                // Botón para iniciar sesión
                ElevatedButton(
                  onPressed: () => handleLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'INICIAR SESIÓN',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
                const SizedBox(height: 16),
                // Texto para ir al registro
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistrationPage(),
                      ),
                    );
                  },
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes cuenta?  ',
                      style: const TextStyle(
                        color: Color.fromARGB(255, 36, 151, 245),
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                      ),
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Registrate',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
