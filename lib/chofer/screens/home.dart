import 'package:app_ruta/chofer/data/providers/service_ubicacion.dart';
import 'package:app_ruta/chofer/screens/add_route.dart';
import 'package:app_ruta/chofer/screens/notificacions_page.dart';
import 'package:app_ruta/services/ajust_camera_map.dart';
import 'package:app_ruta/services/icon_service.dart';
import 'package:app_ruta/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/chofer/data/providers/service_ruta.dart';

class MapPageConductor extends StatefulWidget {
  final Usuario usuario;

  const MapPageConductor({super.key, required this.usuario});

  @override
  _MapPageConductorState createState() => _MapPageConductorState();
}

class _MapPageConductorState extends State<MapPageConductor> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];
  LatLng _initialPosition = const LatLng(0, 0);
  bool _hasRoute = false;
  BitmapDescriptor? _iconNameRoute;
  BitmapDescriptor? _iconWhereaboutsRoute;
  BitmapDescriptor? _iconBusRealTime;
  Marker? _locationMarker;
  LatLng? _lastSavedPosition; // Última posición guardada
  final double minDistance = 0.1; // Distancia mínima en metros
  final double minSpeed = 0.1; // Velocidad mínima en m/s para considerar movimiento
  DateTime? _lastSavedTime; // Última vez que se guardó una ubicación
  final Duration minTimeBetweenSaves = const Duration(seconds: 10);

  // Variable para el tipo de mapa, inicializado en híbrido
  MapType _currentMapType = MapType.hybrid;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  /// Carga los iconos personalizados y obtiene la ruta antes de activar la ubicación en tiempo real.
  void _loadCustomMarkers() async {
    _iconNameRoute = await IconService().createCustomIcon(
      const Color.fromARGB(255, 8, 33, 106),
      Icons.circle,
      20.0,
    );
    _iconWhereaboutsRoute = await IconService().createCustomIcon(
      const Color.fromARGB(255, 2, 67, 9),
      Icons.directions_transit,
      30.0,
    );
    _iconBusRealTime = await IconService().createCustomIconCanva(
      const Color.fromARGB(255, 9, 61, 233),
      Icons.directions_bus,
      120.0,
    );

    await _fetchRoutePoints(); // Primero muestra la ruta en el mapa
    await Future.delayed(const Duration(seconds: 5)); // Espera 5 segundos antes de activar la ubicación en tiempo real
    _listenToLocation(); // Activa la ubicación en tiempo real
  }

  /// Escucha la ubicación en tiempo real y actualiza el marcador en el mapa.
  void _listenToLocation() async {
    bool hasPermission = await LocationService().checkPermissions();
    if (!hasPermission) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Permisos de ubicación denegados"),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    LocationService().getLocationStream().listen((Position position) {
      LatLng newPosition = LatLng(position.latitude, position.longitude);
      double heading = position.heading;
      double speed = position.speed; // Velocidad en m/s

      print("Ubicación actual: Latitud ${position.latitude}, Longitud ${position.longitude}");
      // Llamar a la función de guardado, pero solo si hay movimiento
      _saveNewLocation(newPosition, speed, "Ubicación en movimiento", false, DateTime.now().toIso8601String());

      setState(() {
        _locationMarker = Marker(
          markerId: MarkerId("busLocation"),
          position: newPosition,
          icon: _iconBusRealTime ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(title: "Ubicación del Bus"),
        );

        _markers.removeWhere((marker) => marker.markerId.value == "busLocation");
        _markers.add(_locationMarker!);

        // Mover la cámara más cerca y con rotación
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 18.5, // Zoom más cercano
            tilt: 30, // Inclinación de la cámara para vista 3D
            bearing: heading, // Gira la cámara en la dirección del movimiento
          ),
        ));
      });
    });
  }

  Future<void> _saveNewLocation(
    LatLng position,
    double speed,
    String nombreLugar,
    bool esParadero,
    String tiempoTranscurrido,
  ) async {
    DateTime now = DateTime.now();

    // Verificar si ha pasado suficiente tiempo desde la última vez que se guardó una ubicación
    if (_lastSavedTime != null && now.difference(_lastSavedTime!) < minTimeBetweenSaves) {
      print("No se guarda ubicación: tiempo mínimo no cumplido.");
      return;
    }

    // Verificar si la velocidad es suficiente para considerar movimiento
    if (speed < minSpeed) {
      print("No se guarda ubicación: velocidad muy baja (${speed} m/s).");
      return;
    }

    // Verificar si la distancia es suficiente para considerar un nuevo punto
    if (_lastSavedPosition != null) {
      double distance = Geolocator.distanceBetween(
        _lastSavedPosition!.latitude,
        _lastSavedPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      if (distance < minDistance) {
        print("No se guarda ubicación: distancia mínima (${distance} m) no cumplida.");
        return;
      }
    }

    try {
      await ServiceUbicacion().createLocation(
        ejeX: position.latitude,
        ejeY: position.longitude,
        nombreLugar: nombreLugar,
        tiempoTranscurrido: tiempoTranscurrido,
        idCombi: widget.usuario.idCombi,
      );

      // Actualizar valores
      _lastSavedPosition = position;
      _lastSavedTime = now;

      print("Ubicación guardada: Lat ${position.latitude}, Lon ${position.longitude}, Velocidad: ${speed} m/s.");
    } catch (e) {
      print("Error al agregar punto: $e");
    }
  }

  /// Obtiene los puntos de la ruta desde la API.
  Future<void> _fetchRoutePoints() async {
    try {
      final rutas = await ServiceRuta().getRutaById(widget.usuario.idCombi);

      if (rutas.isNotEmpty) {
        rutas.sort((a, b) => (a["idRuta"] as int).compareTo(b["idRuta"] as int));

        final points = <LatLng>[];
        final newMarkers = <Marker>{};

        for (int i = 0; i < rutas.length; i++) {
          final lat = double.tryParse(rutas[i]["ejeX"] ?? '');
          final lng = double.tryParse(rutas[i]["ejeY"] ?? '');

          if (lat == null || lng == null) {
            print('Error en coordenadas: ${rutas[i]}');
            continue;
          }

          final position = LatLng(lat, lng);
          points.add(position);

          // Selección de icono según la posición y si es paradero.
          final icon = (i == 0)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : (i == rutas.length - 1)
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                  : (rutas[i]["paradero"] == "paradero"
                      ? _iconWhereaboutsRoute ?? BitmapDescriptor.defaultMarker
                      : _iconNameRoute ?? BitmapDescriptor.defaultMarker);

          newMarkers.add(
            Marker(
              markerId: MarkerId(rutas[i]["idRuta"].toString()),
              position: position,
              infoWindow: InfoWindow(
                title: "${rutas[i]["nombreLugar"]}",
              ),
              icon: icon,
              onTap: () {
                // Acción al tocar el punto (puedes agregar funcionalidad adicional aquí)
              },
            ),
          );
        }

        setState(() {
          _routePoints = points;
          _markers.clear();
          _markers.addAll(newMarkers);
          _hasRoute = _routePoints.isNotEmpty;
          if (_routePoints.isNotEmpty) {
            _initialPosition = _routePoints.first;
          }
        });

        // Anima la cámara para ajustar la vista a la ruta.
        if (_mapController != null && _routePoints.isNotEmpty) {
          await Future.delayed(const Duration(milliseconds: 500));
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 50),
          );
        }
      }
    } catch (e) {
      print('Error al obtener los puntos de ruta: $e');
    }
  }

  /// Configura el mapa cuando se crea.
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routePoints.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 80),
      );
    }
  }

  /// Calcula los límites de la ruta para ajustar la cámara.
  LatLngBounds _calculateBounds(List<LatLng> points) {
    return AjustCameraMap.calculateBounds(points);
  }

  /// Cambia el tipo de mapa entre normal e híbrido.
  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.hybrid ? MapType.normal : MapType.hybrid;
    });
  }

  /// Navega a la página de notificaciones.
  void _onNotificationsPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NotificationsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.usuario.nombre} ${widget.usuario.apellidos}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        //backgroundColor: Colors.indigo,
        elevation: 4.0,
        actions: [
          IconButton(
            icon: Icon(
              _currentMapType == MapType.hybrid ? Icons.map : Icons.satellite,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: _toggleMapType,
            tooltip: 'Cambiar tipo de mapa',
          ),
          IconButton(
            icon: const Icon(Icons.notifications, color: Color.fromARGB(255, 0, 0, 0)),
            onPressed: _onNotificationsPressed,
            tooltip: 'Notificaciones',
          ),
          IconButton(
            icon: Icon(
              _hasRoute ? Icons.edit_location_alt : Icons.add_location_alt_outlined,
              color: const Color.fromARGB(255, 0, 0, 0),
            ),
            onPressed: () async {
              final updatedRoute = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditRoutePage(usuario: widget.usuario),
                ),
              );
              if (updatedRoute != null && updatedRoute is List<LatLng>) {
                await _fetchRoutePoints();
              }
            },
            tooltip: _hasRoute ? 'Editar ruta' : 'Agregar ruta',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 16.0,
              ),
              myLocationEnabled: true,
              mapType: _currentMapType,
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('mainRoute'),
                  points: _routePoints,
                  color: Colors.blue.withOpacity(0.80),
                  width: 10,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                ),
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              margin: const EdgeInsets.only(top: 8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la Combi',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Placa: ${widget.usuario.placa}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        'Modelo: ${widget.usuario.modelo}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                  const Divider(height: 24.0, thickness: 1.2),
                  Text(
                    'Horario de Ruta',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Partida: ${widget.usuario.horaPartida}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        'Llegada: ${widget.usuario.horaLlegada}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      Text(
                        'Duración: ${widget.usuario.tiempoLlegada}',
                        style: const TextStyle(fontSize: 16.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
