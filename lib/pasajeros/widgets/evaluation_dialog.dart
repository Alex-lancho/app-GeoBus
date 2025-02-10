import 'package:app_ruta/data/providers/evaluation_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EvaluationDialog extends StatefulWidget {
  final String idChofer;

  const EvaluationDialog({Key? key, required this.idChofer}) : super(key: key);

  @override
  State<EvaluationDialog> createState() => _EvaluationDialogState();
}

class _EvaluationDialogState extends State<EvaluationDialog> {
  final _formKey = GlobalKey<FormState>();
  String? puntualidad;
  double comodidad = 3;
  DateTime? fecha;
  final TextEditingController descripcionController = TextEditingController();

  @override
  void dispose() {
    descripcionController.dispose();
    super.dispose();
  }

  Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitEvaluation() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final data = {
        'puntualidad': puntualidad,
        'comodidad': comodidad.toStringAsFixed(0),
        'fecha': fecha != null ? DateFormat('yyyy-MM-dd').format(fecha!) : '',
        'descripcion': descripcionController.text,
      };

      try {
        await EvaluationService().createEvaluacion(data, widget.idChofer);
        if (!mounted) return;

        showDialog(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Evaluación Enviada',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSummaryItem(
                    'Puntualidad',
                    puntualidad ?? '',
                    Icons.timer,
                  ),
                  _buildSummaryItem(
                    'Comodidad',
                    '${comodidad.toStringAsFixed(0)} estrellas',
                    Icons.star,
                  ),
                  _buildSummaryItem(
                    'Fecha',
                    fecha != null ? DateFormat('dd/MM/yyyy').format(fecha!) : '',
                    Icons.calendar_today,
                  ),
                  _buildSummaryItem(
                    'Descripción',
                    descripcionController.text,
                    Icons.description,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Aceptar'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al enviar evaluación: $e')),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: screenSize.width * 0.85,
        constraints: BoxConstraints(
          maxHeight: screenSize.height * 0.75,
          minHeight: screenSize.height * 0.4,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.rate_review_outlined,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Nueva Evaluación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Puntualidad
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Puntualidad',
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                          ),
                          value: puntualidad,
                          items: ['Sí', 'No'].map((option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              puntualidad = value;
                            });
                          },
                          validator: (value) => value == null ? 'Seleccione una opción' : null,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Comodidad
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comodidad',
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              children: [
                                Text(
                                  comodidad.toStringAsFixed(0),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.star, color: Colors.amber, size: 20),
                              ],
                            ),
                            Slider(
                              value: comodidad,
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: comodidad.toStringAsFixed(0),
                              onChanged: (value) {
                                setState(() {
                                  comodidad = value;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fecha
                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Fecha',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.calendar_today),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        controller: TextEditingController(
                          text: fecha != null ? DateFormat('dd/MM/yyyy').format(fecha!) : '',
                        ),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: fecha ?? DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: Colors.blue.shade700,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            setState(() {
                              fecha = picked;
                            });
                          }
                        },
                        validator: (value) => fecha == null ? 'Seleccione la fecha' : null,
                      ),
                      const SizedBox(height: 16),

                      // Descripción
                      TextFormField(
                        controller: descripcionController,
                        decoration: InputDecoration(
                          labelText: 'Descripción',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        maxLines: 2,
                        validator: (value) => value?.isEmpty ?? true ? 'Ingrese la descripción' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),

            // Botones
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitEvaluation,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Enviar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
