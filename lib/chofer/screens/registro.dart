import 'package:app_ruta/data/models/registro.dart';
import 'package:app_ruta/data/providers/service_login.dart';
import 'package:flutter/material.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  RegistrationPageState createState() => RegistrationPageState();
}

class RegistrationPageState extends State<RegistrationPage> {
  int _currentStep = 0;
  final RegistrationData registrationData = RegistrationData();

  final _formKeys = List.generate(3, (_) => GlobalKey<FormState>());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro'),
        backgroundColor: Color(0xFF0288D1),
      ),
      body: Stepper(
        currentStep: _currentStep,
        steps: [
          Step(
            title: Text('Datos Personales'),
            content: Form(
              key: _formKeys[0],
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.nombre = value,
                    validator: (value) => value!.isEmpty ? 'El nombre es obligatorio' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Apellidos',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.apellidos = value,
                    validator: (value) => value!.isEmpty ? 'Los apellidos son obligatorios' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.dni = value,
                    validator: (value) => value!.isEmpty ? 'El DNI es obligatorio' : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text('Datos Login'),
            content: Form(
              key: _formKeys[1],
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Correo o Usuario',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.usuario = value,
                    validator: (value) => value!.isEmpty ? 'El usuario es obligatorio' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.contrasenia = value,
                    validator: (value) => value!.isEmpty ? 'La contraseña es obligatoria' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Confirme la Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.confirmacionContrasenia = value,
                    validator: (value) => value != registrationData.contrasenia ? 'Las contraseñas no coinciden' : null,
                  ),
                ],
              ),
            ),
          ),
          Step(
            title: Text('Datos Combi'),
            content: Form(
              key: _formKeys[2],
              child: Column(
                children: [
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Placa',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.placa = value,
                    validator: (value) => value!.isEmpty ? 'La placa es obligatoria' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.modelo = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Linea',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.linea = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hora Inicio',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.horaInicio = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Hora Fin',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.horaFin = value,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Tiempo Llegada',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => registrationData.tiempoLlegada = value,
                  ),
                ],
              ),
            ),
          ),
        ],
        onStepContinue: () {
          if (_formKeys[_currentStep].currentState!.validate()) {
            if (_currentStep < 2) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              // Crear el objeto para el backend
              final registro = {
                "usuario": {
                  "tipo": "Conductor",
                  "usuario": registrationData.usuario,
                  "contraseña": registrationData.contrasenia,
                },
                "combi": {
                  "placa": registrationData.placa,
                  "modelo": registrationData.modelo,
                  "linea": registrationData.linea,
                },
                "chofer": {
                  "nombre": registrationData.nombre,
                  "apellidos": registrationData.apellidos,
                  "dni": registrationData.dni,
                },
                "horario": {
                  "horaPartida": registrationData.horaInicio,
                  "horaLlegada": registrationData.horaFin,
                  "tiempoLlegada": registrationData.tiempoLlegada,
                },
              };
              // Enviar los datos al backend
              ServiceLogin().enviarDatos(context, registro);
            }
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
      ),
    );
  }
}
