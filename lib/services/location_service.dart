import 'package:geolocator/geolocator.dart';

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
}
