import 'package:app_ruta/chofer/data/providers/service_ubicacion.dart';
import 'package:app_ruta/chofer/screens/add_route.dart';
import 'package:app_ruta/services/icon_service.dart';
import 'package:app_ruta/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/chofer/data/providers/service_ruta.dart';

class MapPageConductor extends StatefulWidget {
  final Usuario usuario;

  MapPageConductor({required this.usuario});

  @override
  _MapPageConductorState createState() => _MapPageConductorState();
}

class _MapPageConductorState extends State<MapPageConductor> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<LatLng> _routePoints = [];
  LatLng _initialPosition = LatLng(0, 0);
  bool _hasRoute = false;
  BitmapDescriptor? _iconNameRoute;
  BitmapDescriptor? _iconWhereaboutsRoute;
  BitmapDescriptor? _iconBusRealTime;
  Marker? _locationMarker;
  LatLng? _lastSavedPosition; // Última posición guardada
  final double minDistance = 5.0; // Distancia mínima en metros
  final double minSpeed = 0.5; // Velocidad mínima en m/s para considerar movimiento
  DateTime? _lastSavedTime; // Última vez que se guardó una ubicación
  final Duration minTimeBetweenSaves = Duration(seconds: 10); // Tiempo mínimo entre registros

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  /// **Carga los iconos personalizados y obtiene la ruta antes de activar la ubicación en tiempo real**
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

    await _fetchRoutePoints(); //Primero muestra la ruta en el mapa

    await Future.delayed(Duration(seconds: 5)); //Espera 5 segundos antes de activar la ubicación en tiempo real

    _listenToLocation(); // Luego activa la ubicación en tiempo real
  }

  /// **Escucha la ubicación en tiempo real y actualiza el marcador en el mapa**
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

        //Mover la cámara más cerca y con rotación
        _mapController?.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
            target: newPosition,
            zoom: 18.5, //Zoom más cercano
            tilt: 30, //Inclinación de la cámara para vista 3D
            bearing: heading, //Gira la cámara en la dirección del movimiento
          ),
        ));
      });
    });
  }

  Future<void> _saveNewLocation(
      LatLng position, double speed, String nombreLugar, bool esParadero, String tiempoTranscurrido) async {
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

    //Verificar si la distancia es suficiente para considerar un nuevo punto
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

  /// **Obtiene los puntos de la ruta desde la API**
  Future<void> _fetchRoutePoints() async {
    try {
      final rutas = await ServiceRuta().getRutaById(widget.usuario.idCombi);

      if (rutas.isNotEmpty) {
        rutas.sort((a, b) => (a["idRuta"] as int).compareTo(b["idRuta"] as int));

        List<LatLng> points = [];
        Set<Marker> newMarkers = {};

        //recorre cada objeto de punto con sus respectivos atributos
        for (int i = 0; i < rutas.length; i++) {
          //convierte a double los datos obtenidos de x y y
          double? lat = double.tryParse(rutas[i]["ejeX"] ?? '');
          double? lng = double.tryParse(rutas[i]["ejeY"] ?? '');

          if (lat == null || lng == null) {
            print('Error en coordenadas: ${rutas[i]}');
            continue;
          }

          //obtines la posicion y lo agrega al points
          LatLng position = LatLng(lat, lng);
          points.add(position);

          //crea un icono para un punto
          BitmapDescriptor icon = (i == 0)
              ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen)
              : (i == rutas.length - 1)
                  ? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)
                  : (rutas[i]["paradero"] == "paradero"
                      ? _iconWhereaboutsRoute ?? BitmapDescriptor.defaultMarker
                      : _iconNameRoute ?? BitmapDescriptor.defaultMarker);

          //agrega un markador(punto de ubicacion) a newMarkers
          newMarkers.add(
            Marker(
              markerId: MarkerId(rutas[i]["idRuta"].toString()),
              position: position,
              infoWindow: InfoWindow(
                title: "${rutas[i]["nombreLugar"]}",
              ),
              icon: icon,
              onTap: () {
                //cuando se toca el punto realiza una accion
              },
            ),
          );
        }

        //actualiza los estados
        setState(() {
          _routePoints = points;
          _markers.clear();
          _markers.addAll(newMarkers);
          _hasRoute = _routePoints.isNotEmpty;
          if (_routePoints.isNotEmpty) _initialPosition = _routePoints.first;
        });

        //animacion de la camara de enfoque
        if (_mapController != null && _routePoints.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: 500));

          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 50),
          );
        }
      }
    } catch (e) {
      print('Error al obtener los puntos de ruta: $e');
    }
  }

  /// **Configura el mapa cuando se crea**
  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_routePoints.isNotEmpty) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 80),
      );
    }
  }

  /// **Calcula los límites de la ruta para ajustar la cámara**
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double south = points.first.latitude, north = points.first.latitude;
    double west = points.first.longitude, east = points.first.longitude;

    for (LatLng point in points) {
      if (point.latitude < south) south = point.latitude;
      if (point.latitude > north) north = point.latitude;
      if (point.longitude < west) west = point.longitude;
      if (point.longitude > east) east = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.usuario.nombre} ${widget.usuario.apellidos}'),
        actions: [
          IconButton(
            icon: Icon(_hasRoute ? Icons.edit_location_alt : Icons.add_location_alt_outlined),
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
              mapType: MapType.hybrid,
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: PolylineId('mainRoute'),
                  points: _routePoints,
                  color: Colors.blue.withOpacity(0.80),
                  width: 10,
                  startCap: Cap.roundCap, // Puntas redondeadas
                  endCap: Cap.roundCap, // Puntas redondeadas
                ),
              },
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5.0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información de la Combi',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Placa: ${widget.usuario.placa}'),
                      Text('Modelo: ${widget.usuario.modelo}'),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Horario de Ruta',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Partida: ${widget.usuario.horaPartida}'),
                      Text('Llegada: ${widget.usuario.horaLlegada}'),
                      Text('Duración: ${widget.usuario.tiempoLlegada}'),
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
