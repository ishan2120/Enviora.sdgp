import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';

class SupervisorProfile {
  final String uid;
  final String name;
  final String email;
  final String role; // should be 'supervisor'
  final String? zone;
  final String? badgeNumber;

  SupervisorProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.zone,
    this.badgeNumber,
  });

  factory SupervisorProfile.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupervisorProfile(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      zone: data['zone'],
      badgeNumber: data['badgeNumber'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'zone': zone,
      'badgeNumber': badgeNumber,
    };
  }
}

class SupervisorVehicle {
  final String vehicleId;
  final String driverName;
  final String driverPhone;
  final String licensePlate;
  final TrackingStatus status;
  final String lastUpdated;
  final double latitude;
  final double longitude;

  SupervisorVehicle({
    required this.vehicleId,
    required this.driverName,
    required this.driverPhone,
    required this.licensePlate,
    required this.status,
    required this.lastUpdated,
    required this.latitude,
    required this.longitude,
  });

  factory SupervisorVehicle.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupervisorVehicle(
      vehicleId: doc.id,
      driverName: data['driverName'] ?? '',
      driverPhone: data['driverPhone'] ?? '',
      licensePlate: data['licensePlate'] ?? '',
      status: _parseStatus(data['status']),
      lastUpdated: data['lastUpdated'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
    );
  }

  static TrackingStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'enroute':
      case 'en route':
        return TrackingStatus.enRoute;
      case 'arrived':
        return TrackingStatus.arrived;
      case 'delayed':
        return TrackingStatus.delayed;
      default:
        return TrackingStatus.enRoute;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driverName': driverName,
      'driverPhone': driverPhone,
      'licensePlate': licensePlate,
      'status': status.toString().split('.').last,
      'lastUpdated': lastUpdated,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class SupervisorNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? type; // 'report', 'vehicle', 'alert'

  SupervisorNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.type,
  });

  factory SupervisorNotification.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SupervisorNotification(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      type: data['type'],
    );
  }
}
