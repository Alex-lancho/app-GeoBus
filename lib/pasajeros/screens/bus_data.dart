import 'package:flutter/material.dart';

class BusData extends StatelessWidget {
  final String title;
  final List<dynamic> combisData;
  final String selectedRoute;

  const BusData({
    Key? key,
    required this.title,
    required this.combisData,
    required this.selectedRoute,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Filtramos los combis según la línea seleccionada (se espera "Línea X").
    List<dynamic> filteredCombis = [];
    if (selectedRoute.isNotEmpty) {
      final String selectedLine = selectedRoute.split(" ").last;
      filteredCombis = combisData.where((combi) => combi['linea'].toString() == selectedLine).toList();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
      ),
      body: (filteredCombis.isEmpty)
          ? Center(child: Text("Seleccione una línea para ver los datos del móvil."))
          : ListView.builder(
              itemCount: filteredCombis.length,
              itemBuilder: (context, index) {
                final combi = filteredCombis[index];
                final chofer = combi['chofer'];
                final horario = combi['horario'];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  elevation: 3.0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    title: Text("Línea: ${combi['linea']} - Placa: ${combi['placa']}",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Chofer: ${chofer['nombre']} ${chofer['apellidos']}"),
                        Text("Modelo: ${combi['modelo']}"),
                        Text("Horario: ${horario['horaPartida']} - ${horario['horaLlegada']}"),
                        Text("Tiempo de llegada: ${horario['tiempoLlegada']}"),
                        if (combi['ubicaciones'] != null && combi['ubicaciones'].isNotEmpty)
                          Text("Última ubicación: ${combi['ubicaciones'].last['nombreLugar']}"),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => (),
        child: Icon(Icons.add),
      ),
    );
  }
}
