import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_bottom_nav.dart';
import 'profile_screen.dart';
import 'notifications_screen.dart';
import 'dropoff_search_screen.dart';
import 'file_complaint_page.dart';
import 'collection_schedule_page.dart';
import 'track_vehicle_page.dart';
import 'my_reports_page.dart';
import '../utils/schedule_api_service.dart';
import 'package:intl/intl.dart';

bool _globalHasShownPopup = false;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = 'User';
  String? _photoPath;
  ScheduleItem? _nextPickup;
  Announcement? _latestAnnouncement;
  bool _isLoadingSchedule = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final apiService = ScheduleApiService();
        final schedules = await apiService.getMySchedule(email: user.email);
        
        if (schedules.isNotEmpty) {
          // Sort logically if backend hasn't (assuming format is YYYY-MM-DD)
          schedules.sort((a, b) => a.date.compareTo(b.date));
          
          final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
          final upcomingSchedules = schedules.where((s) => s.date.compareTo(todayStr) >= 0).toList();
          
          if (upcomingSchedules.isNotEmpty) {
            setState(() {
               _nextPickup = upcomingSchedules.first;
               _isLoadingSchedule = false;
            });
            
            // Show popup if the pickup is today and we haven't shown it yet
            if (_nextPickup!.date == todayStr && !_globalHasShownPopup) {
               _globalHasShownPopup = true;
               WidgetsBinding.instance.addPostFrameCallback((_) {
                 _showTodayPickupPopup(_nextPickup!);
               });
            }
            return;
          }
        }
      }
    } catch (e) {
      print('Failed to load schedule: $e');
    }
    setState(() {
      _isLoadingSchedule = false;
    });
  }

  void _showTodayPickupPopup(ScheduleItem pickup) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.directions_car, color: Colors.green),
            SizedBox(width: 8),
            Text('Collection Today!'),
          ],
        ),
        content: Text(
          'A truck is scheduled to collect ${pickup.type} today around ${pickup.time}. Please have your waste ready.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        setState(() {
          _userName = user.displayName ?? (user.email?.split('@').first ?? 'User');
        });

        // Try to get photo path, name, and address from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
            
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _userName = data?['name'] ?? _userName;
            _photoPath = data?['photoPath'];
          });
          
          final address = data?['address'];
          if (address != null && address.toString().isNotEmpty) {
             final announcements = await ScheduleApiService().getAnnouncements(address);
             if (announcements.isNotEmpty && mounted) {
                setState(() {
                   _latestAnnouncement = announcements.first;
                });
             }
          }
        }
      }
    } catch (e) {
      // silently handle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.white,
              child: Row(
                children: [
                  // Profile Picture
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()),
                      );
                      // Refresh data
                      _loadUserData();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: Colors.grey.shade300, width: 1),
                      ),
                      child: ClipOval(
                        child: (_photoPath != null && _photoPath!.isNotEmpty && File(_photoPath!).existsSync())
                            ? Image.file(
                                File(_photoPath!),
                                fit: BoxFit.cover,
                              )
                            : Center(
                                child: Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4CAF50),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GOOD MORNING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF666666),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification Icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const NotificationsScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined, size: 24),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B6B),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Next Pickup Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E7D4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _isLoadingSchedule
                                        ? 'Loading...'
                                        : (_nextPickup != null 
                                          ? '${_formatDate(_nextPickup!.date)}, ${_nextPickup!.time}' 
                                          : 'No upcoming pickup'),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _nextPickup?.type ?? '---',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF2D5F2E),
                                    ),
                                  ),
                                ],
                              ),
                              // Bin Icon
                              const SizedBox(
                                width: 50,
                                height: 50,
                                child: Text(
                                  '🗑️',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Pickup Info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _nextPickup != null ? 'Upcoming Collection' : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2D5F2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _nextPickup != null ? 'Serving: ${_nextPickup!.roads}' : '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Truck Status Card
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const TrackVehiclePage()),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.local_shipping,
                                    color: Color(0xFF2D5F2E),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'TRUCK IS NEARBY',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2D5F2E),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Text(
                                    '~15 min away',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w400,
                                      color: Color(0xFF999999),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.warning_amber_rounded,
                              label: 'REPORT ISSUE',
                              color: const Color(0xFFFF6B6B),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const MyReportsPage()),
                                );
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.calendar_today,
                              label: 'VIEW SCHEDULE',
                              color: const Color(0xFF000000),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const CollectionSchedulePage()),
                                );
                              },
                            ),
                            _buildQuickActionButton(
                              icon: Icons.location_on,
                              label: 'TRACK TRUCK',
                              color: const Color(0xFF4CAF50),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const TrackVehiclePage()),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildQuickActionButton(
                              icon: Icons.eco_outlined,
                              label: 'DROP-OFF LOCATIONS',
                              color: const Color(0xFF4CAF50),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const DropoffSearchScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    if (_latestAnnouncement != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Supervisor Alert',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF000000),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _latestAnnouncement!.type == 'breakdown' || _latestAnnouncement!.type == 'postponement' 
                              ? const Color(0xFFFFEBEB) 
                              : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: _latestAnnouncement!.type == 'breakdown' || _latestAnnouncement!.type == 'postponement' 
                                  ? Colors.red.shade200 
                                  : Colors.blue.shade200),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _latestAnnouncement!.type == 'breakdown' ? Icons.warning_amber_rounded 
                              : _latestAnnouncement!.type == 'postponement' ? Icons.schedule 
                              : Icons.info_outline,
                              color: _latestAnnouncement!.type == 'breakdown' || _latestAnnouncement!.type == 'postponement' 
                                  ? Colors.red 
                                  : Colors.blue,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _latestAnnouncement!.type.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: _latestAnnouncement!.type == 'breakdown' || _latestAnnouncement!.type == 'postponement' 
                                          ? Colors.red 
                                          : Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _latestAnnouncement!.message,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Daily Eco Tip in dashboard
                    const Text(
                      'Daily Eco Tip',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Light bulb icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.lightbulb_outline,
                              color: Color(0xFFFFB800),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'DID YOU KNOW ?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF666666),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  'Always give your recyclable containers (like plastic bottles, glass jars) a quick rinse before throwing them in the recycling bin.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF333333),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recent Activity
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          // Checkmark icon
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Color(0xFF4CAF50),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Glass Collection Completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Yesterday 9:15 AM',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                        height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF000000),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final today = DateTime.now();
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      
      if (date.year == today.year && date.month == today.month && date.day == today.day) {
        return 'Today';
      } else if (date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day) {
        return 'Tomorrow';
      } else {
        return DateFormat('EEEE, MMM d').format(date);
      }
    } catch (e) {
      return dateStr;
    }
  }
}
