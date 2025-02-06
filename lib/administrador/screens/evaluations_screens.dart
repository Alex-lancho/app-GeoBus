import 'package:app_ruta/administrador/data/models/evaluation_model.dart';
import 'package:app_ruta/administrador/data/models/combi_model.dart';
import 'package:app_ruta/administrador/data/services/combi_service.dart';
import 'package:app_ruta/administrador/data/services/evaluation_service.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';

class EvaluationsScreens extends StatefulWidget {
  @override
  _EvaluationsScreensState createState() => _EvaluationsScreensState();
}

class _EvaluationsScreensState extends State<EvaluationsScreens> {
  // Lista de evaluaciones
  List<EvaluationModel> evaluations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEvaluations();
  }

  // Método para cargar las evaluaciones desde la API
  Future<void> fetchEvaluations() async {
    setState(() {
      isLoading = true;
    });
    try {
      evaluations = await EvaluationService().getAllEvaluaciones();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar las evaluaciones: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Abre el formulario para crear o editar una evaluación, incluyendo la selección de combi
  void _openEvaluationForm([EvaluationModel? evaluation]) {
    final bool isEditing = evaluation != null;
    final formKey = GlobalKey<FormState>();

    // Variables locales para los campos personalizados:
    // Puntualidad: Dropdown ("Sí" o "No")
    String? selectedPuntualidad = isEditing ? evaluation.puntualidad : null;
    // Comodidad: Slider (escala de 1 a 5). Se guarda como double.
    double selectedComodidad = isEditing ? double.tryParse(evaluation.comodidad) ?? 3.0 : 3.0;
    // Fecha: Usamos un DateTime. Se intenta parsear si estamos editando.
    DateTime? selectedDate = isEditing ? DateTime.tryParse(evaluation.fecha) : null;
    // Descripción: Campo de texto
    final TextEditingController descripcionController =
        TextEditingController(text: isEditing ? evaluation.descripcion : '');

    // Variable local para almacenar el id de la combi seleccionada (solo en creación)
    String? selectedCombiId;

    showDialog(
      context: context,
      builder: (context) {
        // Usamos StatefulBuilder para actualizar el estado local del diálogo
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Editar Evaluación' : 'Nueva Evaluación'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Si estamos creando, se muestra el dropdown para seleccionar combi
                      if (!isEditing)
                        FutureBuilder<List<CombiModel>>(
                          future: CombiService().getAllCombis(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              List<CombiModel> combis = snapshot.data!;
                              return DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                  labelText: 'Combi',
                                  border: OutlineInputBorder(),
                                ),
                                items: combis.map((combi) {
                                  return DropdownMenuItem<String>(
                                    value: combi.idCombi,
                                    child: Text(combi.placa),
                                  );
                                }).toList(),
                                value: selectedCombiId,
                                onChanged: (value) {
                                  setStateDialog(() {
                                    selectedCombiId = value;
                                  });
                                },
                                validator: (value) => (value == null || value.isEmpty) ? 'Seleccione una combi' : null,
                              );
                            } else if (snapshot.hasError) {
                              return Text('Error al cargar combis');
                            } else {
                              return Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      if (!isEditing) SizedBox(height: 16),
                      // Dropdown para puntualidad ("Sí" o "No")
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Puntualidad',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedPuntualidad,
                        items: ['Sí', 'No']
                            .map((option) => DropdownMenuItem<String>(
                                  value: option,
                                  child: Text(option),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedPuntualidad = value;
                          });
                        },
                        validator: (value) => value == null || value.isEmpty ? 'Seleccione una opción' : null,
                      ),
                      SizedBox(height: 16),
                      // Slider para comodidad (escala de 1 a 5)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Comodidad: ${selectedComodidad.toStringAsFixed(0)}'),
                          Slider(
                            value: selectedComodidad,
                            min: 1,
                            max: 5,
                            divisions: 4,
                            label: selectedComodidad.toStringAsFixed(0),
                            onChanged: (value) {
                              setStateDialog(() {
                                selectedComodidad = value;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      // Campo para fecha (read-only) con selector de fecha
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: TextEditingController(
                          text: selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
                        ),
                        onTap: () async {
                          DateTime now = DateTime.now();
                          DateTime initialDate = selectedDate ?? now;
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(now.year - 5),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() {
                              selectedDate = pickedDate;
                            });
                          }
                        },
                        validator: (value) => (selectedDate == null) ? 'Seleccione la fecha' : null,
                      ),
                      SizedBox(height: 16),
                      // Campo de descripción
                      TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) => (value == null || value.isEmpty) ? 'Ingrese la descripción' : null,
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
                      // Preparamos los datos a enviar
                      final Map<String, dynamic> data = {
                        'puntualidad': selectedPuntualidad,
                        'comodidad': selectedComodidad.toStringAsFixed(0),
                        'fecha': selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : '',
                        'descripcion': descripcionController.text,
                      };

                      try {
                        if (isEditing) {
                          await EvaluationService().updateEvaluacion(evaluation.idEvaluacion, data);
                        } else {
                          // Si estamos creando, es obligatorio haber seleccionado una combi
                          if (selectedCombiId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Seleccione una combi')),
                            );
                            return;
                          }
                          await EvaluationService().createEvaluacion(data, selectedCombiId!);
                        }
                        Navigator.of(context).pop();
                        fetchEvaluations();
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
            );
          },
        );
      },
    );
  }

  // Método para eliminar una evaluación con confirmación
  void _deleteEvaluation(String id) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Evaluación'),
        content: Text('¿Está seguro de eliminar esta evaluación?'),
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
        await EvaluationService().deleteEvaluacion(id);
        fetchEvaluations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar la evaluación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Evaluaciones'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : evaluations.isEmpty
              ? Center(child: Text('No hay evaluaciones registradas.'))
              : ListView.builder(
                  itemCount: evaluations.length,
                  itemBuilder: (context, index) {
                    final evaluation = evaluations[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.star_rate_outlined),
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        ),
                        title: Text(
                          evaluation.fecha,
                        ),
                        subtitle: Text(
                          'Puntualidad: ${evaluation.puntualidad} \nComodidad(1-5): ${evaluation.comodidad} \nDescripción: ${evaluation.descripcion}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _openEvaluationForm(evaluation),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteEvaluation(evaluation.idEvaluacion),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Crear Nueva Evaluación',
        onPressed: () => _openEvaluationForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
