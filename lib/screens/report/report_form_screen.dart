import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Import for userId

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _descController = TextEditingController();
  LatLng? _selectedPoint;
  late final MapController _mapController;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  Future<void> _submitReport() async {
    final desc = _descController.text.trim();

    if (desc.isEmpty || _selectedPoint == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a location and add a description")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser; // ✅ Get current user

    await FirebaseFirestore.instance.collection('reports').add({
      'description': desc,
      'timestamp': Timestamp.now(),
      'location': {
        'lat': _selectedPoint!.latitude,
        'lng': _selectedPoint!.longitude,
      },
      'userId': user?.uid ?? 'anonymous', // ✅ Save userId
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Report submitted successfully")),
    );

    _descController.clear();
    setState(() => _selectedPoint = null);
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location permission denied")),
      );
      return;
    }

    Position pos = await Geolocator.getCurrentPosition();
    LatLng userLatLng = LatLng(pos.latitude, pos.longitude);

    _mapController.move(userLatLng, 15);
    setState(() => _selectedPoint = userLatLng);
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(30.033333, 31.233334); // Default: Cairo

    return Scaffold(
      appBar: AppBar(title: const Text("Report an Issue")),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: center,
                initialZoom: 13,
                onTap: (tapPosition, point) {
                  setState(() => _selectedPoint = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.hayygov',
                ),
                if (_selectedPoint != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: _selectedPoint!,
                        child: const Icon(Icons.location_pin, size: 40, color: Colors.red),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text("Use My Location"),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Describe the problem",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _submitReport,
                    icon: const Icon(Icons.send),
                    label: const Text("Submit Report"),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
