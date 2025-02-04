import 'dart:async';
import 'package:app_ruta/data/providers/service_client.dart';
import 'package:app_ruta/services/ajust_camera_map.dart';
import 'package:app_ruta/services/icon_service.dart';
import 'package:app_ruta/services/preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Página principal que administra las pestañas.
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

  // Trayecto (recorrido) del combi.
  List<LatLng> combiPath = [];

  // Icono personalizado para la combi.
  BitmapDescriptor? _combiIcon;

  // Valor seleccionado en el Dropdown (ej: "Línea 3").
  String _selectedRoute = "";
  int _currentIndex = 0;

  // Temporizador para actualizar la ubicación del combi.
  Timer? _timer;

  // Variable para el tipo de mapa: normal o híbrido.
  MapType _currentMapType = MapType.normal;

  // Ubicación inicial centrada en Abancay, Apurímac.
  final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(-13.6368, -72.8822),
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    combisFuture = ServiceClient().combis();
    _loadRoutes();
    _loadCombiIcon();
    // Actualiza la ubicación del combi cada 1 segundo.
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateCombiLocation());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Carga el icono personalizado para la combi (usando el servicio de iconos).
  Future<void> _loadCombiIcon() async {
    _combiIcon = await IconService().createCustomIconCanva(
      const Color.fromARGB(255, 9, 61, 233),
      Icons.directions_bus,
      120.0,
    );
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
          loadedRoutes[linea]!.add(LatLng(lat, lng));
        } else {
          print("Error en coordenadas: ${ruta['ejeX']} , ${ruta['ejeY']}");
        }
      }
    }

    setState(() {
      routePaths = loadedRoutes;
      combisData = combis; // Se guardan los datos para la pestaña "Movil"
    });
  }

  /// Callback que se ejecuta cuando se crea el mapa.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    setState(() {});
  }

  /// Calcula los límites (bounds) de una lista de puntos para centrar la cámara.
  LatLngBounds _calculateLatLngBounds(List<LatLng> points) {
    return AjustCameraMap.calculateBounds(points);
  }

  /// Actualiza la ubicación del combi usando los datos del array "ubicaciones".
  /// Se obtiene el trayecto completo y se actualiza el marcador y polyline.
  /// Si se ha seleccionado una línea, se filtra para que coincida.
  Future<void> _updateCombiLocation() async {
    try {
      final combis = await ServiceClient().combis();
      if (combis.isNotEmpty) {
        String? selectedLine;
        if (_selectedRoute.isNotEmpty) {
          // De "Línea 3" se extrae "3"
          selectedLine = _selectedRoute.split(" ").last;
        }
        // Filtramos el combi por línea si se seleccionó una; de lo contrario, tomamos el primer combi con ubicaciones.
        var combi = (selectedLine != null)
            ? combis.firstWhere(
                (c) => c['linea'].toString() == selectedLine && c['ubicaciones'] != null && c['ubicaciones'].isNotEmpty,
                orElse: () => null,
              )
            : combis.firstWhere(
                (c) => c['ubicaciones'] != null && c['ubicaciones'].isNotEmpty,
                orElse: () => null,
              );

        if (combi != null) {
          List<dynamic> ubicaciones = combi['ubicaciones'];
          if (ubicaciones.isNotEmpty) {
            //para mapear
            List<LatLng> newCombiPath = [];
            for (var ubicacion in ubicaciones) {
              final double? lat = double.tryParse(ubicacion['ejeX'].replaceAll(',', '.'));
              final double? lng = double.tryParse(ubicacion['ejeY'].replaceAll(',', '.'));
              if (lat != null && lng != null) {
                newCombiPath.add(LatLng(lat, lng));
              }
            }
            if (newCombiPath.isNotEmpty) {
              final newPosition = newCombiPath.last;
              setState(() {
                // Actualizamos el marcador del combi con el icono personalizado.
                _markers.removeWhere((m) => m.markerId.value == 'combi');
                _markers.add(
                  Marker(
                    markerId: MarkerId('combi'),
                    position: newPosition,
                    icon: _combiIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
                    infoWindow: InfoWindow(title: "Combi", snippet: "Ubicación actual"),
                  ),
                );
                // Actualizamos la trayectoria completa.
                combiPath = newCombiPath;
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
          } else {
            // Si el combi seleccionado (por línea) no tiene ubicaciones, se limpian los datos.
            setState(() {
              _markers.removeWhere((m) => m.markerId.value == 'combi');
              _polylines.removeWhere((p) => p.polylineId.value == 'combi_path');
              combiPath = [];
            });
          }
        } else {
          // No se encontró ningún combi para la línea seleccionada.
          setState(() {
            _markers.removeWhere((m) => m.markerId.value == 'combi');
            _polylines.removeWhere((p) => p.polylineId.value == 'combi_path');
            combiPath = [];
          });
        }
      }
    } catch (e) {
      print("Error actualizando ubicación: $e");
    }
  }

  /// Cambia la pestaña seleccionada.
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

  /// Dibuja la ruta seleccionada a partir de los puntos de la línea.
  /// Se elimina cualquier polyline previa de rutas (cuyos ids empiecen con "Línea")
  /// para mostrar únicamente la ruta correspondiente a la línea seleccionada.
  void _selectRoute(String route) {
    if (!routePaths.containsKey(route)) return;
    final List<LatLng> routePoints = routePaths[route] ?? [];
    if (routePoints.isNotEmpty) {
      setState(() {
        // Eliminamos todas las polylines de rutas (identificadas por un id que comienza con "Línea").
        _polylines.removeWhere((p) => p.polylineId.value.startsWith("Línea"));
        // Agregamos la polyline de la ruta seleccionada.
        _polylines.add(Polyline(
          polylineId: PolylineId(route),
          points: routePoints,
          color: Colors.blue,
          width: 5,
        ));
        // Actualizamos los marcadores de inicio, intermedio y fin.
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
      // Centra la cámara en la ruta.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_calculateLatLngBounds(routePoints), 50),
          );
        }
      });
    }
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

        // Creamos una lista de pestañas (cada una simulando su propio Scaffold).
        final List<Widget> tabs = [
          MapTabWidget(
            title: "Mapa Cliente",
            mapType: _currentMapType,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            onMapCreated: _onMapCreated,
            onMapTypeChanged: _onMapTypeChanged,
            onChangeRole: () => Preferences.changeRole(context, 'conductor'),
          ),
          RouteTabWidget(
            title: "Ruta",
            mapType: _currentMapType,
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            polylines: _polylines,
            routePaths: routePaths,
            selectedRoute: _selectedRoute,
            onRouteSelected: (value) {
              setState(() {
                _selectedRoute = value;
              });
              _selectRoute(value);
            },
            onMapCreated: _onMapCreated,
            onMapTypeChanged: _onMapTypeChanged,
            onChangeRole: () => Preferences.changeRole(context, 'conductor'),
          ),
          MobileTabWidget(
            title: "Datos del Móvil",
            combisData: combisData,
            selectedRoute: _selectedRoute,
          ),
        ];

        return Scaffold(
          body: tabs[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: _onTabTapped,
            selectedItemColor: Colors.indigo,
            unselectedItemColor: Colors.grey,
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

/// Pestaña "Mapa" (simula un Scaffold propio).
class MapTabWidget extends StatelessWidget {
  final String title;
  final MapType mapType;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(GoogleMapController) onMapCreated;
  final Function(MapType) onMapTypeChanged;
  final VoidCallback onChangeRole;

  const MapTabWidget({
    Key? key,
    required this.title,
    required this.mapType,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    required this.onMapTypeChanged,
    required this.onChangeRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle),
            tooltip: 'Cambiar rol',
            onPressed: onChangeRole,
          ),
          PopupMenuButton<MapType>(
            onSelected: onMapTypeChanged,
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
      body: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: initialCameraPosition,
        markers: markers,
        polylines: polylines,
        mapType: mapType,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}

/// Pestaña "Ruta" con Dropdown y mapa.
class RouteTabWidget extends StatelessWidget {
  final String title;
  final MapType mapType;
  final CameraPosition initialCameraPosition;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Map<String, List<LatLng>> routePaths;
  final String selectedRoute;
  final Function(String) onRouteSelected;
  final Function(GoogleMapController) onMapCreated;
  final Function(MapType) onMapTypeChanged;
  final VoidCallback onChangeRole;

  const RouteTabWidget({
    Key? key,
    required this.title,
    required this.mapType,
    required this.initialCameraPosition,
    required this.markers,
    required this.polylines,
    required this.routePaths,
    required this.selectedRoute,
    required this.onRouteSelected,
    required this.onMapCreated,
    required this.onMapTypeChanged,
    required this.onChangeRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.change_circle),
            tooltip: 'Cambiar rol',
            onPressed: onChangeRole,
          ),
          PopupMenuButton<MapType>(
            onSelected: onMapTypeChanged,
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
      body: Column(
        children: [
          // Dropdown estilizado.
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade300,
                    blurRadius: 6.0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: DropdownButton<String>(
                isExpanded: true,
                underline: Container(),
                hint: Text("Selecciona una línea", style: TextStyle(fontSize: 16)),
                value: selectedRoute.isEmpty ? null : selectedRoute,
                items: routePaths.keys
                    .map((line) => DropdownMenuItem<String>(
                          value: line,
                          child: Text(line, style: TextStyle(fontSize: 16)),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    onRouteSelected(value);
                  }
                },
              ),
            ),
          ),
          // Mapa.
          Expanded(
            child: GoogleMap(
              onMapCreated: onMapCreated,
              initialCameraPosition: initialCameraPosition,
              markers: markers,
              polylines: polylines,
              mapType: mapType,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pestaña "Movil" que muestra los datos filtrados.
class MobileTabWidget extends StatelessWidget {
  final String title;
  final List<dynamic> combisData;
  final String selectedRoute;

  const MobileTabWidget({
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
    );
  }
}
