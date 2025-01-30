import 'package:app_ruta/chofer/screens/add_route.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
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
  BitmapDescriptor? _intermediateMarker;

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
  }

  /// **Crea un ícono personalizado con un círculo y un ícono de Flutter**
  Future<BitmapDescriptor> _createCustomIcon(Color color, IconData icon) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 64.0; // Tamaño del ícono personalizado

    // Dibuja un círculo con el color deseado
    final Paint paint = Paint()..color = color;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2.5, paint);

    // Agrega el ícono en el centro del círculo
    final textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size / 2.5,
          fontFamily: icon.fontFamily,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size / 3.5, size / 3.5));

    // Convierte el Canvas a BitmapDescriptor
    final ui.Image image = await pictureRecorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  /// **Carga los iconos personalizados**
  void _loadCustomMarkers() async {
    _intermediateMarker = await _createCustomIcon(
      const Color.fromARGB(255, 8, 33, 106), // Azul oscuro
      Icons.place, // Ícono de lugar
    );

    // Una vez cargado, busca y dibuja los puntos de la ruta
    await _fetchRoutePoints();
  }

  /// **Obtiene los puntos de la ruta desde la API**
  Future<void> _fetchRoutePoints() async {
    try {
      final rutas = await ServiceRuta().getRutaById(widget.usuario.idCombi);

      if (rutas.isNotEmpty) {
        // Ordena la lista de rutas por idRuta
        rutas.sort((a, b) => (a["idRuta"] as int).compareTo(b["idRuta"] as int));

        List<LatLng> points = [];
        Set<Marker> newMarkers = {};

        for (int i = 0; i < rutas.length; i++) {
          double? lat = double.tryParse(rutas[i]["ejeX"] ?? '');
          double? lng = double.tryParse(rutas[i]["ejeY"] ?? '');

          if (lat == null || lng == null) {
            print('Error en coordenadas: ${rutas[i]}');
            continue;
          }

          LatLng position = LatLng(lat, lng);
          points.add(position);

          BitmapDescriptor icon;
          if (i == 0) {
            icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen); // Punto inicial
          } else if (i == rutas.length - 1) {
            icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed); // Punto final
          } else {
            icon = _intermediateMarker ?? BitmapDescriptor.defaultMarker; // Puntos intermedios
          }

          newMarkers.add(
            Marker(
              markerId: MarkerId(rutas[i]["idRuta"].toString()),
              position: position,
              infoWindow: InfoWindow(
                title: i == 0
                    ? "Inicio: ${rutas[i]["nombreLugar"]}"
                    : i == rutas.length - 1
                        ? "Fin: ${rutas[i]["nombreLugar"]}"
                        : "Intermedio: ${rutas[i]["nombreLugar"]}",
              ),
              icon: icon,
            ),
          );
        }

        setState(() {
          _routePoints = points;
          _markers.clear();
          _markers.addAll(newMarkers);
          _hasRoute = _routePoints.isNotEmpty;

          if (_routePoints.isNotEmpty) {
            _initialPosition = _routePoints.first; // Usa el primer punto como posición inicial
          }
        });

        // Asegurar que el mapa ya está creado antes de cambiar la cámara
        if (_mapController != null && _routePoints.isNotEmpty) {
          await Future.delayed(Duration(milliseconds: 500)); // Pequeña pausa antes de animar la cámara
          _mapController!.animateCamera(
            CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 50),
          );
        }
      } else {
        print('La API no devolvió puntos de ruta.');
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
        CameraUpdate.newLatLngBounds(_calculateBounds(_routePoints), 50),
      );
    }
  }

  /// **Calcula los límites de la ruta para ajustar la cámara**
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double south = points.first.latitude;
    double north = points.first.latitude;
    double west = points.first.longitude;
    double east = points.first.longitude;

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
              markers: _markers,
              polylines: {
                Polyline(
                  polylineId: PolylineId('mainRoute'),
                  points: _routePoints,
                  color: Colors.blue,
                  width: 5,
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
