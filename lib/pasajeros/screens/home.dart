import 'dart:async';
import 'package:app_ruta/data/providers/service_client.dart';
import 'package:app_ruta/pasajeros/screens/bus_data.dart';
import 'package:app_ruta/pasajeros/screens/map_client.dart';
import 'package:app_ruta/pasajeros/screens/map_route.dart';
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
  int _currentIndex = 1;

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
          MapRute(
            title: "Mapa Cliente",
            mapType: _currentMapType,
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: _onMapCreated,
            onMapTypeChanged: _onMapTypeChanged,
            onChangeRole: () => Preferences.changeRole(context, 'conductor'),
          ),
          MapClient(
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
          BusData(
            title: "Datos del Móvil",
            combisData: combisData,
            selectedRoute: _selectedRoute,
          ),
        ];

        return Scaffold(
          body: tabs[_currentIndex],
          bottomNavigationBar: NavigationBar(
            onDestinationSelected: _onTabTapped,
            selectedIndex: _currentIndex,
            indicatorColor: const Color.fromARGB(227, 29, 146, 144),
            backgroundColor: const Color.fromARGB(226, 255, 255, 255),
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.map, color: Color.fromARGB(255, 255, 255, 255)),
                icon: Icon(Icons.map_outlined),
                label: 'Mapa',
              ),
              NavigationDestination(
                  selectedIcon: Icon(Icons.directions, color: Color.fromARGB(255, 255, 255, 255)),
                  icon: Icon(
                    Icons.directions_outlined,
                  ),
                  label: 'Ruta'),
              NavigationDestination(
                selectedIcon: Badge(
                  label: Text("2"),
                  child: Icon(Icons.directions_bus, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                icon: Badge(
                  label: Text("2"),
                  child: Icon(Icons.directions_bus_outlined),
                ),
                label: 'Combi',
              ),
            ],
          ),
        );
      },
    );
  }
}
