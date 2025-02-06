import 'package:app_ruta/data/providers/combi_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:app_ruta/data/models/combi_model.dart';

class CombisScreens extends StatefulWidget {
  @override
  _CombisScreensState createState() => _CombisScreensState();
}

class _CombisScreensState extends State<CombisScreens> {
  // Lista de combis
  List<CombiModel> combis = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCombis();
  }

  // Método para cargar las combis desde la API
  Future<void> fetchCombis() async {
    setState(() {
      isLoading = true;
    });
    try {
      combis = await CombiService().getAllCombis();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las combis: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Abre el formulario para crear o editar una combi
  void _openCombiForm([CombiModel? combi]) {
    final bool isEditing = combi != null;
    final formKey = GlobalKey<FormState>();

    // Controladores para los campos
    final TextEditingController placaController = TextEditingController(text: isEditing ? combi.placa : '');
    final TextEditingController modeloController = TextEditingController(text: isEditing ? combi.modelo : '');
    final TextEditingController lineaController = TextEditingController(text: isEditing ? combi.linea : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Combi' : 'Nueva Combi'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: placaController,
                  decoration: InputDecoration(
                    labelText: 'Placa',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la placa' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: modeloController,
                  decoration: InputDecoration(
                    labelText: 'Modelo',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese el modelo' : null,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: lineaController,
                  decoration: InputDecoration(
                    labelText: 'Línea',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la línea' : null,
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
                  'placa': placaController.text,
                  'modelo': modeloController.text,
                  'linea': lineaController.text,
                };

                try {
                  if (isEditing) {
                    await CombiService().updateCombi(combi!.idCombi, data);
                  } else {
                    await CombiService().createCombi(data);
                  }
                  Navigator.of(context).pop();
                  fetchCombis();
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

  // Método para eliminar una combi con confirmación
  void _deleteCombi(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Combi'),
        content: Text('¿Está seguro de eliminar esta combi?'),
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
        await CombiService().deleteCombi(id);
        fetchCombis();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la combi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Combis'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : combis.isEmpty
              ? Center(child: Text('No hay combis registradas.'))
              : ListView.builder(
                  itemCount: combis.length,
                  itemBuilder: (context, index) {
                    final combi = combis[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.directions_bus),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        title: Text('${combi.placa}'),
                        subtitle: Text('Modelo: ${combi.modelo}\nLínea: ${combi.linea}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openCombiForm(combi),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteCombi(combi.idCombi),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Crear Nueva Combi',
        onPressed: () => _openCombiForm(),
        child: Icon(Icons.directions_bus),
      ),
    );
  }
}
