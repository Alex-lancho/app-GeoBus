import 'package:app_ruta/data/providers/service_client.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:async';

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
  Location _location = Location();
  String _selectedRoute = "";
  bool _mapReady = false;

  int _currentIndex = 0;

  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-13.6368, -72.8822), // Ubicación centrada en Abancay, Apurímac
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    combisFuture = ServiceClient().combi();
    _loadRoutes();
  }

  /// Carga las rutas desde la API y almacena los puntos de cada línea
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
        // Conversión segura de coordenadas con manejo de errores
        final double? ejeX = double.tryParse(ruta['ejeX'].replaceAll(',', '.')); // Longitud
        final double? ejeY = double.tryParse(ruta['ejeY'].replaceAll(',', '.')); // Latitud

        if (ejeX != null && ejeY != null) {
          loadedRoutes[linea]!.add(LatLng(ejeY, ejeX)); // Formato correcto LAT, LNG
        } else {
          print("Error en coordenadas: ${ruta['ejeX']} , ${ruta['ejeY']}");
        }
      }
    }

    setState(() {
      routePaths = loadedRoutes;
      combisData = combis; // Guardar datos en memoria para evitar recargas
    });
  }

  /// Inicializa el mapa cuando se crea
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {
      _mapReady = true;
    });
  }

  /// Selecciona una ruta y la muestra en el mapa
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
      });

      if (_mapController != null) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            _calculateLatLngBounds(routePoints),
            100,
          ),
        );
      }
    }
  }

  /// Calcula los límites de la ruta seleccionada para centrar la cámara en ella
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

  /// Controla el cambio entre las pestañas inferiores
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: combisFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Error al cargar datos: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: Text('Sin datos')),
            body: Center(child: Text('No se encontraron rutas disponibles.')),
          );
        }

        List<Widget> _screens = [
          Scaffold(
            appBar: AppBar(title: Text('Mapa')),
            body: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: _initialCameraPosition,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              polylines: _polylines,
              markers: _markers,
            ),
          ),
          Scaffold(
            appBar: AppBar(title: Text('Ruta')),
            body: Column(
              children: [
                DropdownButton<String>(
                  hint: Text("Selecciona una línea"),
                  value: _selectedRoute.isEmpty ? null : _selectedRoute,
                  items: routePaths.keys
                      .map((line) => DropdownMenuItem(
                            child: Text(line),
                            value: line,
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      _selectRoute(value);
                    }
                  },
                ),
                Expanded(
                  child: _mapReady
                      ? GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: _initialCameraPosition,
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          polylines: _polylines,
                          markers: _markers,
                        )
                      : Center(child: CircularProgressIndicator()),
                ),
              ],
            ),
          ),
          Scaffold(
            appBar: AppBar(title: Text('Movil')),
            body: Column(
              children: [
                Card(
                  child: ListTile(
                    leading: Icon(Icons.person),
                    title: Text("Chofer: Carlos González"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.directions_car),
                    title: Text("Placa: XYZ-789"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.access_time),
                    title: Text("Horario: 09:00 AM - 09:45 AM"),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(Icons.timer),
                    title: Text("Tiempo de llegada: 45 minutos"),
                  ),
                ),
              ],
            ),
          ),
        ];

        return Scaffold(
          body: _screens[_currentIndex],
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
