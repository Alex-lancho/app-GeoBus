class Persona {
  String? nombre;
  String? apellido;

  Persona({this.nombre, this.apellido});

  void nombreCompleto() {
    print('$nombre $apellido');
  }
}

/*void main(List<String> args) {
  Persona persona = Persona(apellido: 'lancho', nombre: 'alex');

  print(persona.nombre);
}

{
nombre:alex
apellido: lancho
}
*/
