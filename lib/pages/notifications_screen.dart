import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_bottom_nav.dart';
import '../utils/schedule_api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class NotificationItem {
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color iconColor;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.iconColor,
  });
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _apiService = ScheduleApiService();
  bool _isLoading = true;
  String? _error;

  // Toggle States
  bool pickupRemindersEnabled = true;
  bool truckTrackingEnabled = true;
  bool specialPickupsEnabled = false;
  bool systemUpdatesEnabled = true;

  // Notification History
  List<NotificationItem> notifications = [];

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      final results = await _apiService.getNotifications(email: email);
      setState(() {
        notifications = results.map((n) => NotificationItem(
          title: n.day == 'Today' ? "Collection Today" : "Collection Tomorrow",
          message: "${n.title} at ${n.time}",
          time: n.date,
          isRead: false,
          icon: Icons.local_shipping,
          iconColor: const Color(0xFF4CAF50),
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load notifications. Please check your connection.";
        _isLoading = false;
      });
    }
  }

  void _clearAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear All Notifications?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                notifications.clear();
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light gray background
      body: SafeArea(
        child: Column(
          children: [
            // Status Bar & Header
            _buildHeader(context),

            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : _error != null 
                  ? Center(child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_error!, style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _fetchNotifications, child: const Text("Retry"))
                      ],
                    ))
                  : RefreshIndicator(
                      onRefresh: _fetchNotifications,
                      child: ListView(
                        padding: const EdgeInsets.all(16.0),
                        children: [
                          // Notification History Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionHeader("Upcoming Collections"),
                              if (notifications.isNotEmpty)
                                TextButton(
                                  onPressed: _clearAllNotifications,
                                  child: const Text(
                                    "Clear All",
                                    style: TextStyle(
                                      color: Color(0xFFF44336),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (notifications.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Center(
                                child: Text(
                                  "No upcoming collections found",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          else
                            ...notifications.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _buildNotificationCard(item),
                                )),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // AppBar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    'Notifications',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212121),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48), // Balance for back button
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Show details or navigate
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: item.iconColor,
                radius: 20,
                child: Icon(item.icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF212121),
                          ),
                        ),
                        Text(
                          item.time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.message,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF757575),
                      ),
                    ),
                  ],
                ),
              ),
              if (!item.isRead)
                Container(
                  margin: const EdgeInsets.only(left: 8, top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4CAF50),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
