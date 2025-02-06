import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapRute extends StatelessWidget {
  final String title;
  final MapType mapType;
  final CameraPosition initialCameraPosition;
  final Function(GoogleMapController) onMapCreated;
  final Function(MapType) onMapTypeChanged;
  final VoidCallback onChangeRole;

  const MapRute({
    Key? key,
    required this.title,
    required this.mapType,
    required this.initialCameraPosition,
    required this.onMapCreated,
    required this.onMapTypeChanged,
    required this.onChangeRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        //backgroundColor: Colors.indigo,
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
        mapType: mapType,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
