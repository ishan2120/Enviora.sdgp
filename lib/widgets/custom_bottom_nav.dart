import 'package:flutter/material.dart';
import '../pages/dashboard.dart';
import '../pages/segregation_guide.dart';
import '../pages/track_vehicle_page.dart';
import '../pages/profile_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'HOME', currentIndex == 0, 0),
            _buildNavItem(
                context, Icons.menu_book, 'GUIDE', currentIndex == 1, 1),
            _buildNavItem(context, Icons.map, 'MAP', currentIndex == 2, 2),
            _buildNavItem(
                context, Icons.person, 'PROFILE', currentIndex == 3, 3),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label,
      bool isActive, int targetIndex) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Widget page;
          if (targetIndex == 0) {
            page = const HomeScreen(); // This is the Dashboard
          } else if (targetIndex == 1) {
            page = const SegregationGuideScreen();
          } else if (targetIndex == 2) {
            page = const TrackVehiclePage();
          } else {
            page = const ProfileScreen();
          }
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation1, animation2) => page,
              transitionDuration: Duration.zero,
              reverseTransitionDuration: Duration.zero,
            ),
          );
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF4CAF50) : Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
