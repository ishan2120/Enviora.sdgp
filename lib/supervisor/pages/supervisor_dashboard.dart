import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/supervisor_bottom_nav.dart';
import 'supervisor_reports_page.dart';
import 'supervisor_vehicle_tracking_page.dart';
import 'supervisor_notifications_page.dart';
import 'supervisor_profile_page.dart';
import 'supervisor_announcement_page.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({Key? key}) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _DashboardOverview(),
    const SupervisorReportsPage(),
    const SupervisorVehicleTrackingPage(),
    const SupervisorNotificationsPage(),
    const SupervisorProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SupervisorBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _DashboardOverview extends StatelessWidget {
  const _DashboardOverview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: const Text(
          'Supervisor Portal',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2E3E32)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFF48702E)),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushReplacementNamed(context, '/supervisor-login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 24),
            _buildStatGrid(),
            const SizedBox(height: 32),
            _buildSectionTitle('Quick Actions'),
            const SizedBox(height: 16),
            _buildQuickActionGrid(context),
            const SizedBox(height: 32),
            _buildSectionTitle('Recent Activity'),
            const SizedBox(height: 16),
            _buildRecentActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    final user = FirebaseAuth.instance.currentUser;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome back,',
          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
        ),
        Text(
          user?.displayName ?? 'Supervisor',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E3E32),
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Total Reports', '124', Icons.assignment, Colors.blue),
        _buildStatCard('Pending', '12', Icons.pending_actions, Colors.orange),
        _buildStatCard('Active Fleet', '8', Icons.local_shipping, Colors.green),
        _buildStatCard('Alerts', '4', Icons.notifications_active, Colors.red),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32)),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E3E32),
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildQuickActionButton('Assign Fleet', Icons.map_outlined, () {}),
        _buildQuickActionButton('Issue Alert', Icons.campaign_outlined, () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SupervisorAnnouncementPage()),
          );
        }),
        _buildQuickActionButton('Generate Report', Icons.summarize_outlined, () {}),
      ],
    );
  }

  Widget _buildQuickActionButton(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF48702E).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF48702E)),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFF2F8F2),
                child: Icon(Icons.info_outline, color: Color(0xFF48702E)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Garbage Truck #402 Arrived',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Location: Sector 4',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              Text(
                '2m ago',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        );
      },
    );
  }
}
