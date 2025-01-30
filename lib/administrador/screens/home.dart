import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/main.dart';
import 'package:flutter/material.dart';

class AdminDashboardPage extends StatelessWidget {
  final Usuario usuario;
  AdminDashboardPage({required this.usuario});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GeoBusHomePage(),
              ),
            );
          },
        ),
        title: Text(usuario.usuario),
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Datos del Usuario'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Usuario: ${usuario.usuario}'),
                        Text('ID: ${usuario.idChofer}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text('Cerrar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Bienvenido al panel de administración.'),
      ),
    );
  }
}
