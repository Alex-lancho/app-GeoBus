import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapClient extends StatelessWidget {
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

  const MapClient({
    super.key,
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
  });

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
