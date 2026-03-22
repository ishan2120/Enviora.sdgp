import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supervisor_models.dart';
import 'supervisor_vehicle_detail_page.dart';

class SupervisorVehicleTrackingPage extends StatefulWidget {
  const SupervisorVehicleTrackingPage({Key? key}) : super(key: key);

  @override
  State<SupervisorVehicleTrackingPage> createState() => _SupervisorVehicleTrackingPageState();
}

class _SupervisorVehicleTrackingPageState extends State<SupervisorVehicleTrackingPage> {
  final MapController _mapController = MapController();
  
  // Default center (can be updated based on fleet distribution)
  final LatLng _defaultCenter = const LatLng(6.9271, 79.8612); // Colombo, Sri Lanka example

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fleet Tracking', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location, color: Color(0xFF48702E)),
            onPressed: () {
              _mapController.move(_defaultCenter, 13.0);
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('vehicles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final vehicles = snapshot.data!.docs
              .map((doc) => SupervisorVehicle.fromFirestore(doc))
              .toList();

          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.enviora.app',
              ),
              MarkerLayer(
                markers: vehicles.map((vehicle) => _buildVehicleMarker(vehicle)).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Marker _buildVehicleMarker(SupervisorVehicle vehicle) {
    return Marker(
      point: LatLng(vehicle.latitude, vehicle.longitude),
      width: 80,
      height: 80,
      child: GestureDetector(
        onTap: () => _showVehicleQuickView(vehicle),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _getStatusColor(vehicle.status),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: Colors.black26, blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Icons.local_shipping, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                vehicle.vehicleId.toUpperCase(),
                style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showVehicleQuickView(SupervisorVehicle vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vehicle ${vehicle.vehicleId}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Driver: ${vehicle.driverName}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  _buildStatusBadge(vehicle.status),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickInfo(Icons.speed, 'Status', vehicle.status.toString().split('.').last),
                  _buildQuickInfo(Icons.phone, 'Contact', 'Call Driver'),
                  _buildQuickInfo(Icons.info_outline, 'Details', 'View More'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SupervisorVehicleDetailPage(vehicle: vehicle),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48702E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('View Full Details'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickInfo(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF48702E), size: 24),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusBadge(dynamic status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toString().split('.').last.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getStatusColor(dynamic status) {
    final statusStr = status.toString().toLowerCase();
    if (statusStr.contains('enroute')) return Colors.blue;
    if (statusStr.contains('arrived')) return Colors.green;
    if (statusStr.contains('delayed')) return Colors.red;
    return Colors.grey;
  }
}
