import 'dart:async';
import 'package:app_ruta/data/providers/service_client.dart';
import 'package:app_ruta/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPageCliente extends StatefulWidget {
  @override
  _MapPageClienteState createState() => _MapPageClienteState();
}

class _MapPageClienteState extends State<MapPageCliente> {
  late Future<List<dynamic>> combisFuture;
  List<dynamic> combisData = [];
  Map<String, List<LatLng>> routePaths = {};

  GoogleMapController? _mapController;
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  // Variable para almacenar el trayecto (recorrido) del combi
  List<LatLng> combiPath = [];

  // Valor seleccionado en el Dropdown (ej: "Línea 3")
  String _selectedRoute = "";
  bool _mapReady = false;
  int _currentIndex = 0;

  // Temporizador para actualizar la ubicación del combi
  Timer? _timer;

  // Variable para el tipo de mapa: normal o híbrido
  MapType _currentMapType = MapType.normal;

  // Ubicación inicial centrada en Abancay, Apurímac
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-13.6368, -72.8822),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    combisFuture = ServiceClient().combis();
    _loadRoutes();

    // Actualiza la ubicación del combi cada 1 segundo.
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateCombiLocation());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Carga las rutas desde la API y almacena los puntos de cada línea.
  /// Se asume que en los datos, 'ejeX' es la latitud y 'ejeY' la longitud.
  Future<void> _loadRoutes() async {
    final combis = await combisFuture;
    final Map<String, List<LatLng>> loadedRoutes = {};

    for (var combi in combis) {
      final String linea = "Línea ${combi['linea']}";
      final List<dynamic> rutas = combi['rutas'];

      if (!loadedRoutes.containsKey(linea)) {
        loadedRoutes[linea] = [];
      }

      for (var ruta in rutas) {
        final double? lat = double.tryParse(ruta['ejeX'].replaceAll(',', '.'));
        final double? lng = double.tryParse(ruta['ejeY'].replaceAll(',', '.'));

        if (lat != null && lng != null) {
          loadedRoutes[linea]!.add(LatLng(lat, lng)); // (lat, lng)
        } else {
          print("Error en coordenadas: ${ruta['ejeX']} , ${ruta['ejeY']}");
        }
      }
    }

    setState(() {
      routePaths = loadedRoutes;
      combisData = combis; // Se guardan los datos para usarlos en la pestaña "Movil"
    });
  }

  /// Callback que se ejecuta cuando se crea el mapa.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapReady = true;
    });
  }

  /// Calcula los límites (bounds) de una lista de puntos para centrar la cámara.
  LatLngBounds _calculateLatLngBounds(List<LatLng> points) {
    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  /// Dibuja la ruta seleccionada, coloca marcadores de inicio, intermedio y fin,
  /// y centra la cámara para mostrarla completa.
  void _selectRoute(String route) {
    if (!routePaths.containsKey(route)) return;

    final List<LatLng> routePoints = routePaths[route] ?? [];

    if (routePoints.isNotEmpty) {
      setState(() {
        _selectedRoute = route;
        _polylines.clear();
        _polylines.add(
          Polyline(
            polylineId: PolylineId(route),
            points: routePoints,
            color: Colors.blue,
            width: 5,
          ),
        );

        // Se eliminan marcadores anteriores de ruta
        _markers
            .removeWhere((m) => m.markerId.value == 'start' || m.markerId.value == 'mid' || m.markerId.value == 'end');

        final start = routePoints.first;
        final end = routePoints.last;
        final mid = routePoints[(routePoints.length / 2).floor()];

        _markers.add(Marker(
          markerId: MarkerId('start'),
          position: start,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: "Inicio"),
        ));

        _markers.add(Marker(
          markerId: MarkerId('mid'),
          position: mid,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "Intermedio"),
        ));

        _markers.add(Marker(
          markerId: MarkerId('end'),
          position: end,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: "Fin"),
        ));
      });

      // Centra la cámara en la ruta
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(
              _calculateLatLngBounds(routePoints),
              50,
            ),
          );
        }
      });
    }
  }

  /// Actualiza la ubicación del combi usando los datos del array "ubicaciones".
  /// Se toma la última ubicación disponible y se añade a la trayectoria.
  Future<void> _updateCombiLocation() async {
    try {
      final combis = await ServiceClient().combis();
      if (combis.isNotEmpty) {
        // Buscamos el primer combi que tenga datos en "ubicaciones"
        var combi = combis.firstWhere(
          (c) => c['ubicaciones'] != null && c['ubicaciones'].isNotEmpty,
          orElse: () => null,
        );

        if (combi != null) {
          List<dynamic> ubicaciones = combi['ubicaciones'];
          final lastUbicacion = ubicaciones.last;
          final double? lat = double.tryParse(lastUbicacion['ejeX'].replaceAll(',', '.'));
          final double? lng = double.tryParse(lastUbicacion['ejeY'].replaceAll(',', '.'));

          if (lat != null && lng != null) {
            final newPosition = LatLng(lat, lng);
            setState(() {
              // Removemos la ubicación anterior de la combi (si existe)
              _markers.removeWhere((m) => m.markerId.value == 'combi');

              // Agregamos (o actualizamos) el marcador de la combi
              _markers.add(Marker(
                markerId: MarkerId('combi'),
                position: newPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                infoWindow: InfoWindow(title: "Combi", snippet: "Ubicación actual"),
              ));

              // Agregamos el nuevo punto a la trayectoria y actualizamos el polyline
              combiPath.add(newPosition);
              _polylines.removeWhere((polyline) => polyline.polylineId.value == 'combi_path');
              _polylines.add(
                Polyline(
                  polylineId: PolylineId('combi_path'),
                  points: combiPath,
                  color: Colors.green.withOpacity(0.5),
                  width: 4,
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      print("Error actualizando ubicación: $e");
    }
  }

  /// Cambia entre las pestañas inferiores.
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  /// Cambia el tipo de mapa (normal o híbrido).
  void _onMapTypeChanged(MapType selectedType) {
    setState(() {
      _currentMapType = selectedType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: combisFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error al cargar datos: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Sin datos')),
            body: Center(child: Text('No se encontraron datos disponibles.')),
          );
        }

        // Se utiliza una única instancia del widget GoogleMap.
        Widget mapWidget = GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: _initialCameraPosition,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          polylines: _polylines,
          markers: _markers,
          mapType: _currentMapType,
        );

        Widget bodyContent;
        if (_currentIndex == 0) {
          // Pestaña "Mapa": muestra el mapa
          bodyContent = mapWidget;
        } else if (_currentIndex == 1) {
          // Pestaña "Ruta": muestra un Dropdown para seleccionar la ruta y el mapa debajo.
          bodyContent = Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  hint: Text("Selecciona una línea"),
                  value: _selectedRoute.isEmpty ? null : _selectedRoute,
                  items: routePaths.keys
                      .map((line) => DropdownMenuItem<String>(
                            value: line,
                            child: Text(line),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectRoute(value);
                    }
                  },
                ),
              ),
              Expanded(child: mapWidget),
            ],
          );
        } else {
          // Pestaña "Movil": muestra los datos del combi según la línea seleccionada.
          List<dynamic> filteredCombis = [];
          if (_selectedRoute.isNotEmpty) {
            // Se asume que _selectedRoute tiene el formato "Línea X"
            final String selectedLine = _selectedRoute.split(" ").last;
            filteredCombis = combisData.where((combi) => combi['linea'] == selectedLine).toList();
          }

          if (filteredCombis.isEmpty) {
            bodyContent = Center(child: Text("Seleccione una línea para ver los datos del móvil."));
          } else {
            bodyContent = ListView.builder(
              itemCount: filteredCombis.length,
              itemBuilder: (context, index) {
                final combi = filteredCombis[index];
                final chofer = combi['chofer'];
                final horario = combi['horario'];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text("Línea: ${combi['linea']} - Placa: ${combi['placa']}"),
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
            );
          }
        }

        return Scaffold(
          appBar: AppBar(
            title: Text("Mapa Cliente"),
            actions: [
              IconButton(
                icon: const Icon(Icons.change_circle),
                tooltip: 'Cambiar rol',
                onPressed: () => Preferences.changeRole(context, 'conductor'),
              ),
              PopupMenuButton<MapType>(
                onSelected: _onMapTypeChanged,
                icon: Icon(Icons.layers),
                itemBuilder: (BuildContext context) => <PopupMenuEntry<MapType>>[
                  PopupMenuItem<MapType>(
                    value: MapType.normal,
                    child: Text("Normal"),
                  ),
                  PopupMenuItem<MapType>(
                    value: MapType.hybrid,
                    child: Text("Híbrido"),
                  ),
                ],
              ),
            ],
          ),
          body: bodyContent,
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Mapa'),
              BottomNavigationBarItem(icon: Icon(Icons.directions), label: 'Ruta'),
              BottomNavigationBarItem(icon: Icon(Icons.directions_bus), label: 'Movil'),
            ],
          ),
        );
      },
    );
  }
}
