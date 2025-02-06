import 'package:app_ruta/data/providers/driver_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ruta/data/models/driver_model.dart';

class DriversScreen extends StatefulWidget {
  @override
  _DriversScreenState createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  // Lista de choferes
  List<DriverModel> drivers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDrivers();
  }

  // Método para cargar los choferes desde la API
  Future<void> fetchDrivers() async {
    setState(() {
      isLoading = true;
    });
    try {
      drivers = await DriverService().getChoferes();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar los choferes: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Abre el formulario para crear o editar un chofer
  void _openDriverForm([DriverModel? driver]) {
    final bool isEditing = driver != null;
    final formKey = GlobalKey<FormState>();

    // Controladores para los campos
    final TextEditingController nombreController = TextEditingController(text: isEditing ? driver!.nombre : '');
    final TextEditingController apellidosController = TextEditingController(text: isEditing ? driver.apellidos : '');
    final TextEditingController dniController = TextEditingController(text: isEditing ? driver.dni : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Chofer' : 'Nuevo Chofer'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nombreController,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el nombre' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: apellidosController,
                  decoration: InputDecoration(
                    labelText: 'Apellidos',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese los apellidos' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: dniController,
                  decoration: InputDecoration(
                    labelText: 'DNI',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese DNI' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Preparamos los datos
                final Map<String, dynamic> data = {
                  'nombre': nombreController.text,
                  'apellidos': apellidosController.text,
                  'dni': dniController.text,
                };

                try {
                  if (isEditing) {
                    await DriverService().updateChofer(driver!.idChofer, data);
                  } else {
                    await DriverService().createChofer(data);
                  }
                  Navigator.of(context).pop();
                  fetchDrivers();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Guardar' : 'Crear'),
          ),
        ],
      ),
    );
  }

  // Método para eliminar un chofer con confirmación
  void _deleteDriver(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Chofer'),
        content: Text('¿Está seguro de eliminar este chofer?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DriverService().deleteChofer(id);
        fetchDrivers();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar el chofer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Choferes'),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : drivers.isEmpty
                ? Center(child: Text('No hay choferes registrados.'))
                : ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      final driver = drivers[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.person),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                          title: Text('${driver.nombre} ${driver.apellidos}'),
                          subtitle: Text('DNI: ${driver.dni}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _openDriverForm(driver),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteDriver(driver.idChofer),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
        //
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          tooltip: 'Crear Nuevo Usuario',
          onPressed: () => _openDriverForm(),
          child: Icon(Icons.person_add),
        ));
  }
}
