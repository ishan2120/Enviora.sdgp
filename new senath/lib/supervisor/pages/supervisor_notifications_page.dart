import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supervisor_models.dart';

class SupervisorNotificationsPage extends StatefulWidget {
  const SupervisorNotificationsPage({Key? key}) : super(key: key);

  @override
  State<SupervisorNotificationsPage> createState() => _SupervisorNotificationsPageState();
}

class _SupervisorNotificationsPageState extends State<SupervisorNotificationsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: const Text('Alerts & Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: const Text('Mark all as read', style: TextStyle(color: Color(0xFF48702E))),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('supervisor_notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data!.docs
              .map((doc) => SupervisorNotification.fromFirestore(doc))
              .toList();

          if (notifications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return _buildNotificationCard(notification);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'All caught up!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
          ),
          Text(
            'No new alerts at the moment.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(SupervisorNotification notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: notification.isRead 
          ? BorderSide.none 
          : const BorderSide(color: Color(0xFF48702E), width: 1),
      ),
      elevation: 0,
      color: notification.isRead ? Colors.white : const Color(0xFFF2F8F2),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(notification.type).withOpacity(0.1),
          child: Icon(_getCategoryIcon(notification.type), color: _getCategoryColor(notification.type)),
        ),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(notification.body),
            const SizedBox(height: 8),
            Text(
              _formatTimestamp(notification.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        onTap: () => _markAsRead(notification.id),
      ),
    );
  }

  IconData _getCategoryIcon(String? type) {
    switch (type?.toLowerCase()) {
      case 'report': return Icons.assignment_late_outlined;
      case 'vehicle': return Icons.local_shipping_outlined;
      case 'alert': return Icons.warning_amber_rounded;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getCategoryColor(String? type) {
    switch (type?.toLowerCase()) {
      case 'report': return Colors.orange;
      case 'vehicle': return Colors.blue;
      case 'alert': return Colors.red;
      default: return const Color(0xFF48702E);
    }
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _markAsRead(String id) async {
    await FirebaseFirestore.instance
        .collection('supervisor_notifications')
        .doc(id)
        .update({'isRead': true});
  }

  Future<void> _markAllAsRead() async {
    final batch = FirebaseFirestore.instance.batch();
    final query = await FirebaseFirestore.instance
        .collection('supervisor_notifications')
        .where('isRead', isEqualTo: false)
        .get();
    
    for (var doc in query.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }
}
