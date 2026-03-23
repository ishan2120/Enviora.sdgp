import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/custom_bottom_nav.dart';
import 'edit_profile_screen.dart';
import 'notifications_screen.dart';
import 'activity_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _fullName = 'Loading...';
  String _email = '';
  String? _photoPath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // First use email from auth as a quick fallback
        setState(() {
          _email = user.email ?? '';
          _fullName = user.displayName ?? user.email?.split('@').first ?? 'User';
        });

        // Then try to get full name and photo path from Firestore
        final doc = await FirebaseFirestore.instance
            .collection('user')
            .doc(user.uid)
            .get();
        if (doc.exists && mounted) {
          final data = doc.data();
          setState(() {
            _fullName = data?['name'] ?? _fullName;
            _email = data?['email'] ?? _email;
            _photoPath = data?['photoPath'];
          });
        }
      }
    } catch (e) {
      // silently handle
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFE8F5E9), // Very light green tint for background as per image
      body: SafeArea(
        child: Column(
          children: [
            // App Bar Title
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Profile',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50), // Dark blue-gray text
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Avatar & Info
                      _buildProfileHeader(),
                      const SizedBox(height: 24),

                      // Points Card
                      _buildPointsCard(),
                      const SizedBox(height: 24),

                      // Account Settings
                      _buildSectionHeader('Account Settings'),
                      _buildSettingsItem(
                          context, 'Edit Profile', Icons.person_rounded),
                      const SizedBox(height: 12),
                      _buildSettingsItem(
                          context, 'Notifications', Icons.notifications),
                      const SizedBox(height: 24),

                      // Activity History
                      _buildSectionHeader(
                          'Activity History'), // Or custom implementation for this one with subtitle
                      _buildActivityHistoryItem(context),
                      const SizedBox(height: 27),

                      // Preferences
                      _buildSectionHeader('Preferences'),
                      _buildSettingsItem(
                          context, 'Region Settings', Icons.location_on),
                      const SizedBox(height: 12),
                      _buildSettingsItem(
                          context,
                          'Appearance',
                          Icons
                              .dark_mode), // Using dark_mode as palette icon approximation
                      const SizedBox(height: 32),

                      // Logout Button
                      _buildLogoutButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildProfileHeader() {
    Widget photoWidget;
    if (_photoPath != null && _photoPath!.isNotEmpty && File(_photoPath!).existsSync()) {
      photoWidget = ClipOval(
        child: Image.file(
          File(_photoPath!),
          fit: BoxFit.cover,
          width: 80,
          height: 80,
        ),
      );
    } else {
      photoWidget = Center(
        child: Text(
          _fullName.isNotEmpty ? _fullName[0].toUpperCase() : 'U',
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: photoWidget,
        ),
        const SizedBox(height: 12),
        Text(
          _fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              Text(
                'View all',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF66BB6A), // Lighter green for card
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total points',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Text(
                      '1000',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem(BuildContext context, String title, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE0E0E0), // Light gray background for icon
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2C3E50),
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () async {
          if (title == 'Edit Profile') {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditProfileScreen(
                  initialFullName: _fullName,
                  initialEmail: _email,
                ),
              ),
            );

            if (result != null) {
              // Reload user data whenever returning from edit screen
              _loadUserData();
            }
          } else if (title == 'Notifications') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildActivityHistoryItem(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8), // slightly more padding
        title: const Text(
          'Activity History',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF2C3E50),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'View reported issues & pickups',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.push(
            context, // This 'context' might not be available here, checking caller
            MaterialPageRoute(
                builder: (context) => const ActivityHistoryScreen()),
          );
        },
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/language', (route) => false);
          }
        },
        icon: const Icon(Icons.logout, color: Colors.red),
        label: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
