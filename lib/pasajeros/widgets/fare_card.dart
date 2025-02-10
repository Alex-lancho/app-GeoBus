import 'package:flutter/material.dart';

class FareCard extends StatelessWidget {
  final String ruta;
  const FareCard({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ruta,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(227, 29, 146, 144),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Nota: Se cobra pasaje escolar Y/O universitario en días laborables',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildFareRow('Adulto', '1.00'),
            const Divider(height: 12),
            _buildFareRow('Universitario', '0.70'),
            const Divider(height: 12),
            _buildFareRow('Escolar', '0.50'),
          ],
        ),
      ),
    );
  }

  Widget _buildFareRow(String type, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          type,
          style: const TextStyle(
            fontSize: 12,
            fontStyle: FontStyle.italic,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromARGB(227, 29, 146, 144),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '\$$price',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
