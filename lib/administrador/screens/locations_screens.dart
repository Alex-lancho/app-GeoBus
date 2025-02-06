import 'package:flutter/material.dart';

class LocationsScreens extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CRUD de Combis'),
      ),
      body: Center(
        child: Text('Aquí manejarás las combis (listar, crear, editar, eliminar).'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Lógica para agregar un nuevo chofer
        },
      ),
    );
  }
}
