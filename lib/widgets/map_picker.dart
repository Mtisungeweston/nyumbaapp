import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class MapPicker extends StatefulWidget {
  final Function(LatLng) onLocationSelected;
  final LatLng? initialLocation;

  const MapPicker({
    Key? key,
    required this.onLocationSelected,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<MapPicker> createState() => _MapPickerState();
}

class _MapPickerState extends State<MapPicker> {
  late GoogleMapController mapController;
  final LocationService _locationService = LocationService();
  late LatLng _selectedLocation;
  final Set<Marker> _markers = {};

  // Malawi center coordinates
  static const LatLng _malawiCenter = LatLng(-13.2543, 34.3015);

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation ?? _malawiCenter;
    _addMarker(_selectedLocation);
    _getCurrentLocation();
  }

  void _addMarker(LatLng location) {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('selected_location'),
        position: location,
        infoWindow: const InfoWindow(
          title: 'Property Location',
          snippet: 'Tap on map to change',
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    final permission = await _locationService.requestLocationPermission();
    if (permission) {
      final position = await _locationService.getCurrentPosition();
      if (position != null) {
        final newLocation = LatLng(position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _selectedLocation = newLocation;
            _addMarker(_selectedLocation);
          });
          mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: newLocation,
                zoom: 13,
              ),
            ),
          );
        }
      }
    }
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
      _addMarker(_selectedLocation);
    });
  }

  void _confirmSelection() {
    widget.onLocationSelected(_selectedLocation);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Property Location'),
        elevation: 0,
        backgroundColor: Colors.blue[600],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) {
              mapController = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 13,
            ),
            markers: _markers,
            onTap: _onMapTapped,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lat: ${_selectedLocation.latitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  Text(
                    'Lng: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmSelection,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Confirm Location'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }
}
