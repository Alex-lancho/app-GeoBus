import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.indigo,
      ),
      body: Center(
        child: Text(
          'Aquí podrás ver y enviar tus notificaciones.',
          style: TextStyle(fontSize: 18.0, color: Colors.grey.shade700),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
