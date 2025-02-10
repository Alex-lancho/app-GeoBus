import 'package:app_ruta/data/models/alert_model.dart';
import 'package:app_ruta/data/providers/alert_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AlertsDialog extends StatelessWidget {
  final String idChofer;

  const AlertsDialog({Key? key, required this.idChofer}) : super(key: key);

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.blue.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Alertas',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  splashRadius: 24,
                ),
              ],
            ),
            const Divider(height: 24),
            // Content
            FutureBuilder<List<AlertModel>>(
              future: AlertService().getAlertasByChofer(idChofer),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    height: 100,
                    alignment: Alignment.center,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.blue.shade300,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade100),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Error al cargar las alertas',
                            style: TextStyle(color: Colors.red.shade700),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final alertas = snapshot.data ?? [];
                if (alertas.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 12),
                        const Text('No hay alertas disponibles'),
                      ],
                    ),
                  );
                }

                return ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                    minHeight: 100,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: alertas.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alerta = alertas[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              alerta.descripcion,
                              style: const TextStyle(
                                fontSize: 15,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDateTime(alerta.hora),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
