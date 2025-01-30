import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:app_ruta/data/models/usuario.dart';
import 'package:app_ruta/chofer/data/providers/service_ruta.dart';

class EditRoutePage extends StatefulWidget {
  final Usuario usuario;

  EditRoutePage({required this.usuario});

  @override
  _EditRoutePageState createState() => _EditRoutePageState();
}

class _EditRoutePageState extends State<EditRoutePage> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  List<Map<String, dynamic>> _routePoints = [];
  final ServiceRuta _serviceRuta = ServiceRuta();
  bool _isLoading = true;
  String? _movingMarkerId;

  @override
  void initState() {
    super.initState();
    _loadRouteFromAPI();
  }

  /// **Obtener la ruta desde la API**
  Future<void> _loadRouteFromAPI() async {
    try {
      final data = await _serviceRuta.getRutaById(widget.usuario.idCombi);
      setState(() {
        _routePoints = data.map((point) {
          return {
            "idRuta": point["idRuta"].toString(),
            "ejeX": double.tryParse(point["ejeX"].toString()) ?? 0.0,
            "ejeY": double.tryParse(point["ejeY"].toString()) ?? 0.0,
            "nombreLugar": point["nombreLugar"] ?? "",
            "paradero": point["paradero"] ?? "",
          };
        }).toList();
        _updateMarkers();
        _isLoading = false;
      });
    } catch (e) {
      print("Error al obtener la ruta: $e");
      setState(() => _isLoading = false);
    }
  }

  /// **Actualizar los marcadores en el mapa**
  void _updateMarkers() {
    _markers.clear();
    for (var point in _routePoints) {
      _markers.add(
        Marker(
          markerId: MarkerId(point["idRuta"].toString()),
          position: LatLng(point["ejeX"], point["ejeY"]),
          draggable: _movingMarkerId == point["idRuta"], // Permitir mover si está en modo "Mover"
          icon: BitmapDescriptor.defaultMarkerWithHue(
            point == _routePoints.first
                ? BitmapDescriptor.hueGreen
                : point == _routePoints.last
                    ? BitmapDescriptor.hueRed
                    : BitmapDescriptor.hueBlue,
          ),
          onDragEnd: (newPosition) async {
            if (_movingMarkerId == point["idRuta"]) {
              await _updatePoint(point["idRuta"], newPosition);
              setState(() => _movingMarkerId = null); // Desactivar modo mover
            }
          },
          onTap: () => _confirmRemoveOrMoveMarker(point["idRuta"]),
        ),
      );
    }
    setState(() {}); // Refrescar la UI
  }

  /// **Añadir un nuevo punto con Modal**
  Future<void> _addMarker(LatLng position) async {
    String nombreLugar = "";
    bool esParadero = false;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text("Agregar nuevo punto"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Nombre del lugar"),
                    onChanged: (value) {
                      nombreLugar = value;
                    },
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: esParadero,
                        onChanged: (value) {
                          setModalState(() {
                            esParadero = value ?? false;
                          });
                        },
                      ),
                      Text("Es paradero"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Cancelar"),
                  onPressed: () => Navigator.pop(context),
                ),
                TextButton(
                  child: Text("Guardar"),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _saveNewPoint(position, nombreLugar, esParadero);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// **Guardar el nuevo punto en la API**
  Future<void> _saveNewPoint(LatLng position, String nombreLugar, bool esParadero) async {
    try {
      final newPoint = await _serviceRuta.createRuta(
        ejeX: position.latitude,
        ejeY: position.longitude,
        nombreLugar: nombreLugar,
        paradero: esParadero ? "paradero" : "",
        idCombi: widget.usuario.idCombi,
      );

      setState(() {
        _routePoints.add({
          "idRuta": newPoint["idRuta"].toString(),
          "ejeX": position.latitude,
          "ejeY": position.longitude,
          "nombreLugar": nombreLugar,
          "paradero": esParadero ? "paradero" : "",
        });
        _updateMarkers();
      });
    } catch (e) {
      print("Error al agregar punto: $e");
    }
  }

  /// **Actualizar un punto existente en la API**
  Future<void> _updatePoint(String idRuta, LatLng newPosition) async {
    try {
      await _serviceRuta.updateRuta(
        idRuta: idRuta,
        ejeX: newPosition.latitude,
        ejeY: newPosition.longitude,
        nombreLugar: "Paradero Modificado",
        paradero: "",
      );

      setState(() {
        var point = _routePoints.firstWhere((p) => p["idRuta"] == idRuta);
        point["ejeX"] = newPosition.latitude;
        point["ejeY"] = newPosition.longitude;
        _updateMarkers();
      });
    } catch (e) {
      print("Error al actualizar punto: $e");
    }
  }

  /// **Confirmar antes de eliminar o mover un punto**
  Future<void> _confirmRemoveOrMoveMarker(String idRuta) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Gestionar punto"),
          content: Text("¿Desea eliminar este punto o moverlo?"),
          actions: [
            TextButton(
              child: Text("Mover"),
              onPressed: () {
                setState(() {
                  _movingMarkerId = idRuta; // Activar modo "Mover"
                });
                Navigator.pop(context);
                _updateMarkers();
              },
            ),
            TextButton(
              child: Text("Eliminar"),
              onPressed: () async {
                Navigator.pop(context);
                await _removeMarker(idRuta);
              },
            ),
          ],
        );
      },
    );
  }

  /// **Eliminar un punto de la ruta en la API**
  Future<void> _removeMarker(String idRuta) async {
    try {
      await _serviceRuta.deleteRuta(idRuta);

      setState(() {
        _routePoints.removeWhere((p) => p["idRuta"] == idRuta);
        _updateMarkers();
      });
    } catch (e) {
      print("Error al eliminar punto: $e");
    }
  }

  /// **Guardar y regresar a `MapPageConductor`**
  void _saveAndExit() {
    Navigator.pop(context, _routePoints.map((p) => LatLng(p["ejeX"], p["ejeY"])).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Editar Ruta"),
        actions: [
          IconButton(icon: Icon(Icons.save), onPressed: _saveAndExit),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: (controller) => _mapController = controller,
              initialCameraPosition: CameraPosition(
                target: _routePoints.isNotEmpty
                    ? LatLng(_routePoints.first["ejeX"], _routePoints.first["ejeY"])
                    : LatLng(-13.627756, -72.875474),
                zoom: 16.0,
              ),
              markers: _markers,
              onTap: (position) => _addMarker(position),
              polylines: {
                Polyline(
                  polylineId: PolylineId('editedRoute'),
                  points: _routePoints.map((p) => LatLng(p["ejeX"], p["ejeY"])).toList(),
                  color: Colors.red,
                  width: 5,
                ),
              },
            ),
    );
  }
}
