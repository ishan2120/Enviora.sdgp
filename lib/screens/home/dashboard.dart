import 'package:flutter/material.dart';
import 'segregation_guide.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: ClipOval(
                      child: Image.network(
                        'https://i.pravatar.cc/150?img=1',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, size: 24);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Good Morning & Name
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
                        const Text(
                          'Kisanda',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Language Selector
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4E7D4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          'EN',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D5F2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          '/ සි',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF2D5F2E),
                          ),
                        ),
                        const Text(
                          '/ த',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D5F2E),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Notification Icon
                  Stack(
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
                                  const Text(
                                    'Tomorrow, 8.00 AM',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF000000),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Recyclables & Paper',
                                    style: TextStyle(
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
                              const Text(
                                'Pickup in 5 days',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF2D5F2E),
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Friday, November 29',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Truck Status Card
                          Container(
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickActionButton(
                          icon: Icons.warning_amber_rounded,
                          label: 'REPORT ISSUE',
                          color: const Color(0xFFFF6B6B),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.calendar_today,
                          label: 'VIEW SCHEDULE',
                          color: const Color(0xFF000000),
                        ),
                        _buildQuickActionButton(
                          icon: Icons.location_on,
                          label: 'TRACK TRUCK',
                          color: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Daily Eco Tip
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DID YOU KNOW ?',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF666666),
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Glass Collection Completed',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF000000),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
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
                    
                    const SizedBox(height: 80), // Extra space for bottom navigation
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: const Color(0xFF999999),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          currentIndex: 0,
          elevation: 0,
          onTap: (index) {
            if (index == 1) {
              // Navigate to Segregation Guide
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SegregationGuideScreen(),
                ),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book),
              label: 'GUIDE',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'MAP',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'PROFILE',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return SizedBox(
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
                  color: Colors.black.withOpacity(0.05),
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
    );
  }
}