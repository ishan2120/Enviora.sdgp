import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupervisorProfilePage extends StatefulWidget {
  const SupervisorProfilePage({Key? key}) : super(key: key);

  @override
  State<SupervisorProfilePage> createState() => _SupervisorProfilePageState();
}

class _SupervisorProfilePageState extends State<SupervisorProfilePage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: const Text('Supervisor Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Color(0xFF48702E)),
            onPressed: () {
              // Edit profile logic
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileHeader(),
            const SizedBox(height: 32),
            _buildInfoSection(),
            const SizedBox(height: 32),
            _buildAppPreferences(),
            const SizedBox(height: 48),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 56,
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            backgroundColor: const Color(0xFF48702E).withOpacity(0.1),
            child: user?.photoURL == null 
              ? const Icon(Icons.person, size: 60, color: Color(0xFF48702E)) 
              : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user?.displayName ?? 'Supervisor Name',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32)),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF48702E).withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Official Supervisor',
            style: TextStyle(color: Color(0xFF48702E), fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.email_outlined, 'Email', user?.email ?? 'N/A'),
          const Divider(height: 32),
          _buildInfoRow(Icons.badge_outlined, 'Employee ID', 'EMP-7729'),
          const Divider(height: 32),
          _buildInfoRow(Icons.location_on_outlined, 'Assigned Zone', 'Sector 4 - Urban West'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF48702E), size: 24),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32))),
          ],
        ),
      ],
    );
  }

  Widget _buildAppPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4.0, bottom: 12.0),
          child: Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildPreferenceTile(Icons.notifications_active_outlined, 'Push Notifications', true),
              const Divider(height: 0),
              _buildPreferenceTile(Icons.dark_mode_outlined, 'Dark Mode', false),
              const Divider(height: 0),
              _buildPreferenceTile(Icons.language_outlined, 'Language', null, subtitle: 'English'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceTile(IconData icon, String title, bool? value, {String? subtitle}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2E3E32), size: 22),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: value != null 
        ? Switch(value: value, onChanged: (v) {}, activeColor: const Color(0xFF48702E))
        : const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Sign Out', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.red,
          elevation: 0,
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
