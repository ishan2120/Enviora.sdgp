import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/models.dart';
import '../widgets/custom_bottom_nav.dart';
import 'file_complaint_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ─────────────────────────────────────────────────────────────
// CHANGE THIS to your computer's IP address (from ipconfig)
// ─────────────────────────────────────────────────────────────
const String _baseUrl   = 'http://192.168.1.23:3000/api';
const String _vehicleId = 'truck-402';
const String _userId    = 'user-123';

class TrackVehiclePage extends StatefulWidget {
  const TrackVehiclePage({super.key});

  @override
  State<TrackVehiclePage> createState() => _TrackVehiclePageState();
}

class _TrackVehiclePageState extends State<TrackVehiclePage> {
  bool _notifyWhenNear = true;
  bool _isLoading      = true;
  bool _hasError       = false;
  String _errorMessage = '';
  bool _mapAvailable   = false;
  String _driverName   = 'Senath';

  VehicleLocation? _vehicleData;
  final MapController _mapController = MapController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _fetchVehicleData();
    _loadNotifyPreference();
    _pollingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _fetchVehicleData(),
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchVehicleData() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/vehicles/$_vehicleId'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final v    = data['vehicle'];

        final List<LocationPoint> routePath = (v['routePath'] as List)
            .map((p) => LocationPoint(
                  latitude:  (p['latitude']  as num).toDouble(),
                  longitude: (p['longitude'] as num).toDouble(),
                ))
            .toList();

        final TrackingStatus status;
        switch (v['status']) {
          case 'arrived': status = TrackingStatus.arrived; break;
          default:        status = TrackingStatus.enRoute;
        }

        if (mounted) {
          setState(() {
            _vehicleData = VehicleLocation(
              vehicleId:        v['vehicleId'],
              latitude:         (v['latitude']  as num).toDouble(),
              longitude:        (v['longitude'] as num).toDouble(),
              status:           status,
              estimatedMinutes: (v['estimatedMinutes'] as num).toInt(),
              currentLocation:  v['currentLocation'],
              routePath:        routePath,
            );
            _mapAvailable = v['mapAvailable'] ?? false;
            _driverName   = v['driver']       ?? 'James Okafor';
            _isLoading    = false;
            _hasError     = false;
          });
        }
      } else {
        _setError('Server error (${response.statusCode}).');
      }
    } on TimeoutException {
      _setError('Request timed out.\nIs the server still running?');
    } catch (e) {
      _setError('Cannot connect to the server.\nMake sure the backend is running and your IP is correct.');
    }
  }

  Future<void> _loadNotifyPreference() async {
    try {
      final response = await http.get(Uri.parse(
        '$_baseUrl/notifications/preference?userId=$_userId&vehicleId=$_vehicleId',
      ));
      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _notifyWhenNear = data['notifyWhenNear'] ?? true;
        });
      }
    } catch (_) {}
  }

  Future<void> _saveNotifyPreference(bool value) async {
    try {
      await http.post(
        Uri.parse('$_baseUrl/notifications/preference'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId':         _userId,
          'vehicleId':      _vehicleId,
          'notifyWhenNear': value,
        }),
      );
    } catch (_) {}
  }

  void _setError(String message) {
    if (mounted) {
      setState(() {
        _hasError      = true;
        _errorMessage  = message;
        _isLoading     = false;
      });
    }
  }

  // ── Truck details popup ──────────────────────────────────────
  void _showTruckDetails(VehicleLocation vehicle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_shipping,
                  size: 40, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Truck Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _detailRow(
              icon: Icons.local_shipping,
              label: 'VEHICLE ID',
              value: 'Truck ${vehicle.vehicleId}',
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.person,
              label: 'DRIVER',
              value: _driverName,
            ),
            const SizedBox(height: 10),
            _detailRow(
              icon: Icons.route,
              label: 'CURRENT ROUTE',
              value: vehicle.currentLocation,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF4CAF50), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Track Your Collection',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.language, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'EN/ق/தி',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            )
          : _hasError
              ? _buildErrorScreen()
              : _buildMainContent(),
    );
  }

  Widget _buildErrorScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() { _isLoading = true; _hasError = false; });
                _fetchVehicleData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    final vehicle = _vehicleData!;

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Stack(
            children: [
              _mapAvailable
                  ? FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: LatLng(vehicle.latitude, vehicle.longitude),
                        initialZoom: 15.0,
                        minZoom: 10.0,
                        maxZoom: 18.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.envioraa',
                        ),
                        PolylineLayer(
                          polylines: [
                            Polyline(
                              points: vehicle.routePath
                                  .map((p) => LatLng(p.latitude, p.longitude))
                                  .toList(),
                              strokeWidth: 4.0,
                              color: const Color(0xFF4CAF50),
                            ),
                          ],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(vehicle.latitude, vehicle.longitude),
                              width: 80,
                              height: 80,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black87,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      vehicle.vehicleId,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF2E7D32),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.local_shipping,
                                        color: Colors.white, size: 24),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      color: const Color(0xFFE8F0E0),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.2),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.map_outlined,
                                  size: 48, color: Color(0xFF4CAF50)),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Live map is currently unavailable',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Location updates are still active below',
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                    ),

              Positioned(
                right: 16,
                top: 16,
                child: Column(
                  children: [
                    _MapControlButton(
                      icon: Icons.add,
                      onPressed: _mapAvailable
                          ? () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom + 1,
                              )
                          : null,
                    ),
                    const SizedBox(height: 8),
                    _MapControlButton(
                      icon: Icons.remove,
                      onPressed: _mapAvailable
                          ? () => _mapController.move(
                                _mapController.camera.center,
                                _mapController.camera.zoom - 1,
                              )
                          : null,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: 16,
                bottom: 16,
                child: _MapControlButton(
                  icon: Icons.my_location,
                  onPressed: _mapAvailable
                      ? () => _mapController.move(
                            LatLng(vehicle.latitude, vehicle.longitude),
                            15.0,
                          )
                      : null,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          flex: 2,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 8, height: 8,
                                    decoration: BoxDecoration(
                                      color: vehicle.status == TrackingStatus.arrived
                                          ? Colors.blue
                                          : const Color(0xFF4CAF50),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    vehicle.statusString,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              vehicle.status == TrackingStatus.arrived
                                  ? const Text(
                                      'Arrived! 🎉',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    )
                                  : Text(
                                      '${vehicle.estimatedMinutes} mins',
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                              const SizedBox(height: 4),
                              Text(
                                vehicle.status == TrackingStatus.arrived
                                    ? 'The truck is at your location'
                                    : 'Estimated arrival at your location',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        // Truck badge — tap opens popup
                        GestureDetector(
                          onTap: () => _showTruckDetails(vehicle),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                const Icon(Icons.local_shipping,
                                    size: 32, color: Color(0xFF4CAF50)),
                                const SizedBox(height: 4),
                                Text(
                                  'Truck ${vehicle.vehicleId}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.location_on,
                                color: Color(0xFF4CAF50), size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'CURRENT LOCATION',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  vehicle.currentLocation,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.notifications,
                                color: Color(0xFF4CAF50), size: 24),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Notify when near',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Switch(
                            value: _notifyWhenNear,
                            onChanged: (value) {
                              setState(() { _notifyWhenNear = value; });
                              _saveNotifyPreference(value);
                            },
                            activeColor: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FileComplaintPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Report an Issue',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _MapControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: onPressed != null ? Colors.white : Colors.white60,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: onPressed != null ? Colors.black87 : Colors.grey[400],
        ),
        onPressed: onPressed,
      ),
    );
  }
}
