import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationService {
  // Verifica permisos antes de obtener la ubicación en tiempo real
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el servicio de ubicación está activado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print("El servicio de ubicación está deshabilitado.");
      return false;
    }

    // Verifica y solicita permisos de ubicación
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Los permisos de ubicación fueron denegados.");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Los permisos de ubicación están permanentemente denegados.");
      return false;
    }

    return true; // Permisos concedidos
  }

  // Escucha cambios de ubicación en tiempo real
  Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high, // Alta precisión
        distanceFilter: 10, // Se actualiza cada 10 metros
      ),
    );
  }

  // Realizando mapeo de puntos y marcadores
  /*(List<LatLng>, Set<Marker>) procesarRutas(List<Map<String, dynamic>> rutas, BitmapDescriptor iconoStart,BitmapDescriptor iconWhereaboutsRoute, BitmapDescriptor ) {
    final List<LatLng> points = [];
    final Set<Marker> newMarkers = {};

    for (int i = 0; i < rutas.length; i++) {
      final lat = double.tryParse(rutas[i]["ejeX"] ?? '');
      final lng = double.tryParse(rutas[i]["ejeY"] ?? '');

      if (lat == null || lng == null) {
        print('Error en coordenadas: ${rutas[i]}');
        continue;
      }

      final position = LatLng(lat, lng);
      points.add(position);

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
          infoWindow: InfoWindow(title: rutas[i]["nombreLugar"] ?? "Sin nombre"),
          icon: icon,
        ),
      );
    }

    return (points, newMarkers);
  }*/
}
