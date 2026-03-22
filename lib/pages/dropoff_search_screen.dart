import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ============================================================================
// FIRST SCREEN: MAIN CATEGORY SELECTION
// ============================================================================

class DropoffSearchScreen extends StatefulWidget {
  const DropoffSearchScreen({Key? key}) : super(key: key);

  @override
  _DropoffSearchScreenState createState() => _DropoffSearchScreenState();
}

class _DropoffSearchScreenState extends State<DropoffSearchScreen> {
  final Color bgColor = const Color(0xFFF4FAF5); // Soft background
  final Color primaryGreen = const Color(0xFF4C7B4D);
  final Color darkGreen = const Color(0xFF1B4332);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8F5E9),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: darkGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Find Center',
          style: TextStyle(
            color: darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // --- HEADER SECTION ---
            Stack(
              clipBehavior: Clip.none, 
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 240,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://images.unsplash.com/photo-1604187351574-c75ca79f5807?auto=format&fit=crop&q=80&w=1000'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                      ),
                    ),
                  ),
                ),
                
                Positioned(
                  bottom: -30, 
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white, 
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Text(
                      'Choose a Waste Category and Enter your location to find the nearest Drop-Off Location!',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: darkGreen,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 50),
            
            // --- CATEGORIES LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                   _wasteCategoryCard(
                    title: 'Organic',
                    status: 'Compostable materials',
                    statusColor: primaryGreen,
                    distance: 'Food scraps, yard trimmings, degradables',
                    icon: Icons.eco_outlined,
                  ),
                   _wasteCategoryCard(
                    title: 'E-Waste',
                    status: 'Electronics collection',
                    statusColor: primaryGreen,
                    distance: 'Computers, phones, batteries, appliances',
                    icon: Icons.devices_other_outlined,
                  ),
                   _wasteCategoryCard(
                    title: 'Paper',
                    status: 'Recyclable paper goods',
                    statusColor: primaryGreen,
                    distance: 'Newspapers, cardboard, white paper, books',
                    icon: Icons.article_outlined,
                  ),
                  _wasteCategoryCard(
                    title: 'Plastic',
                    status: 'Plastic bottles and containers',
                    statusColor: primaryGreen,
                    distance: 'PET bottles, containers, packing material',
                    icon: Icons.layers_outlined,
                  ),
                  _wasteCategoryCard(
                    title: 'Glass',
                    status: 'Glass bottles and jars',
                    statusColor: primaryGreen,
                    distance: 'Beverage bottles, jars, broken glass',
                    icon: Icons.wine_bar_outlined,
                  ),
                   _wasteCategoryCard(
                    title: 'Recyclable',
                    status: 'General recyclables',
                    statusColor: primaryGreen,
                    distance: 'Scrap metal, iron, aluminium, copper, brass',
                    icon: Icons.recycling,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _wasteCategoryCard({
    required String title,
    required String status,
    required Color statusColor,
    required String distance,
    required IconData icon,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200.withOpacity(0.5), width: 1),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationEntryScreen(categoryName: title),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 26, color: primaryGreen),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          status.contains('Open') ? Icons.access_time : Icons.info_outline,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            status,
                            style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      distance,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13, height: 1.3),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.grey.shade300, size: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SECOND SCREEN: LOCATION ENTRY & DATABASE FETCH WITH GOOGLE MAPS
// ============================================================================

class LocationEntryScreen extends StatefulWidget {
  final String categoryName;

  const LocationEntryScreen({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<LocationEntryScreen> createState() => _LocationEntryScreenState();
}

class _LocationEntryScreenState extends State<LocationEntryScreen> {
  final TextEditingController _searchController = TextEditingController(); 
  GoogleMapController? _mapController;
  
  List<dynamic> _locations = [];
  List<dynamic> _filteredLocations = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _showMap = true;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _fetchLocations() async {
    final String apiUrl = 'http://10.0.2.2:5000/api/dropoffs/${widget.categoryName}';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> fetched = json.decode(response.body);
        setState(() {
          _locations = fetched;
          _filteredLocations = List.from(_locations);
          _isLoading = false;
          _updateMarkers();
        });
      } else {
        setState(() {
          _errorMessage = 'Server error: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the server.';
        _isLoading = false;
      });
    }
  }

  void _updateMarkers() {
    _markers = _filteredLocations
      .where((loc) => loc['latitude'] != null && loc['longitude'] != null)
      .map((loc) => Marker(
        markerId: MarkerId(loc['Facility Name'] ?? 'loc'),
        position: LatLng(
          (loc['latitude'] as num).toDouble(), 
          (loc['longitude'] as num).toDouble()
        ),
        onTap: () => _showLocationDetails(loc),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ))
      .toSet();
  }

  void _showLocationDetails(dynamic location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on, color: Color(0xFF4C7B4D)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location['Facility Name'] ?? 'Unknown Facility',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B4332),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        location['Category'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'ADDRESS',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              location['Address'] ?? 'No address provided',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            if (location['Telephone'] != null && location['Telephone'] != '-') ...[
              const SizedBox(height: 20),
              Text(
                'CONTACT',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(location['Telephone'], style: const TextStyle(fontSize: 15)),
            ],
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openGoogleMaps(location['Address']),
                    icon: const Icon(Icons.directions, size: 20),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4C7B4D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                if (location['Telephone'] != null && location['Telephone'] != '-') ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => _makePhoneCall(location['Telephone']),
                    icon: const Icon(Icons.phone),
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F5E9),
                      foregroundColor: const Color(0xFF4C7B4D),
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _filterLocations(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredLocations = List.from(_locations);
        _updateMarkers();
      });
    } else {
      setState(() {
        _filteredLocations = _locations.where((center) {
          final name = (center['Facility Name'] ?? '').toLowerCase();
          final address = (center['Address'] ?? '').toLowerCase();
          final searchLower = query.toLowerCase();

          return name.contains(searchLower) || address.contains(searchLower);
        }).toList();
        _updateMarkers();
      });
    }
  }

  Future<void> _openGoogleMaps(String address) async {
    if (address == 'No address provided') return;

    final encodedAddress = Uri.encodeComponent(address);
    // Use directions API instead of search to show directions from "My Location"
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$encodedAddress');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps.')),
        );
      }
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the phone dialer.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: , 
      appBar: AppBar(
        title: Text(
          '${widget.categoryName} Drop-off',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1B4332), 
          ),
        ),
        backgroundColor: const Color(0xFFE8F5E9),
        foregroundColor: const Color(0xFF1B4332),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () => setState(() => _showMap = !_showMap),
          )
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(color: Colors.green.shade100, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _filterLocations,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                decoration: InputDecoration(
                  hintText: 'e.g., Colombo, Kandy...',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade400,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4C7B4D)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.cancel, color: Colors.grey.shade300),
                          onPressed: () {
                            _searchController.clear();
                            _filterLocations('');
                            FocusScope.of(context).unfocus(); 
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF4C7B4D)))
              : _showMap 
                ? _buildMapView() 
                : _buildListView(),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    LatLng initialPos = const LatLng(6.9271, 79.8612); // Colombo
    if (_filteredLocations.isNotEmpty && _filteredLocations.first['latitude'] != null) {
      initialPos = LatLng(
        (_filteredLocations.first['latitude'] as num).toDouble(),
        (_filteredLocations.first['longitude'] as num).toDouble()
      );
    }

    return GoogleMap(
      onMapCreated: (controller) => _mapController = controller,
      initialCameraPosition: CameraPosition(
        target: initialPos,
        zoom: 12.0,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapType: MapType.normal,
    );
  }

  Widget _buildListView() {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_filteredLocations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No drop-off centers found.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _filteredLocations.length,
      itemBuilder: (context, index) {
        final center = _filteredLocations[index];
        
        return Card(
          elevation: 0, 
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.green.shade200.withOpacity(0.5), width: 1), 
          ),
          color: Colors.white, 
          child: InkWell( 
            onTap: () {
              if (center['latitude'] != null) {
                // First switch to map and animate
                setState(() => _showMap = true);
                
                // Use a short delay to ensure map is visible before animating
                Future.delayed(const Duration(milliseconds: 100), () {
                  _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
                    LatLng((center['latitude'] as num).toDouble(), (center['longitude'] as num).toDouble()),
                    15.0 // Zoom in closer
                  ));
                });
                
                // Show details sheet
                Future.delayed(const Duration(milliseconds: 400), () {
                  _showLocationDetails(center);
                });
              } else {
                // If no lat/lng, directly open Google Maps search
                _openGoogleMaps(center['Address'] ?? '');
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          center['Facility Name'] ?? 'Unknown Facility',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1B4332), 
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_outward_rounded, color: Colors.grey.shade400, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Color(0xFF4C7B4D)), 
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          center['Address'] ?? 'No address provided',
                          style: TextStyle(color: Colors.grey.shade700, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  Divider(color: Colors.grey.shade100, height: 1),
                  const SizedBox(height: 8),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton.icon(
                        onPressed: () => _openGoogleMaps(center['Address'] ?? 'No address provided'),
                        icon: const Icon(Icons.directions, size: 18, color: Color(0xFF4C7B4D)),
                        label: const Text('Directions', style: TextStyle(color: Color(0xFF4C7B4D), fontWeight: FontWeight.w600)),
                      ),
                      
                      if (center['Telephone'] != null && center['Telephone'].toString().trim() != '-' && center['Telephone'].toString().trim().isNotEmpty)
                        TextButton.icon(
                          onPressed: () => _makePhoneCall(center['Telephone']),
                          icon: const Icon(Icons.phone, size: 18, color: Color(0xFF4C7B4D)),
                          label: Text(center['Telephone'], style: const TextStyle(color: Color(0xFF4C7B4D), fontWeight: FontWeight.w600)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}