import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  missedCollection,
  illegalDumping,
}

enum ReportStatus {
  pending,
  inProgress,
  resolved,
}

class Report {
  final String id;
  final ReportType type;
  final String issueType;
  final String description;
  final String? imageUrl;
  final ReportStatus status;
  final DateTime reportedDate;

  factory Report.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Report(
      id: doc.id,
      type: _parseType(data['reportType']),
      issueType: data['issueType'] ?? 'Unknown',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      status: _parseStatus(data['status']),
      reportedDate: (data['reportedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static ReportType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'missedcollection':
      case 'missed collection':
        return ReportType.missedCollection;
      case 'illegaldumping':
      case 'illegal dumping':
        return ReportType.illegalDumping;
      default:
        return ReportType.missedCollection;
    }
  }

  static ReportStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'inprogress':
      case 'in progress':
      case 'accepted': // Maps accepted to inProgress for this UI for now
        return ReportStatus.inProgress;
      case 'resolved':
        return ReportStatus.resolved;
      default:
        return ReportStatus.pending;
    }
  }

  Report({
    required this.id,
    required this.type,
    required this.issueType,
    required this.description,
    this.imageUrl,
    required this.status,
    required this.reportedDate,
  });

  String get typeString {
    switch (type) {
      case ReportType.missedCollection:
        return 'Missed Collection';
      case ReportType.illegalDumping:
        return 'Illegal Dumping';
    }
  }

  String get statusString {
    switch (status) {
      case ReportStatus.pending:
        return 'PENDING';
      case ReportStatus.inProgress:
        return 'IN PROGRESS';
      case ReportStatus.resolved:
        return 'RESOLVED';
    }
  }
}

class SupervisorUpdate {
  final String supervisorName;
  final String message;
  final DateTime timestamp;

  SupervisorUpdate({
    required this.supervisorName,
    required this.message,
    required this.timestamp,
  });
}

enum TrackingStatus {
  enRoute,
  arrived,
  delayed,
}

class VehicleLocation {
  final String vehicleId;
  final double latitude;
  final double longitude;
  final TrackingStatus status;
  final int estimatedMinutes;
  final String currentLocation;
  final List<LocationPoint> routePath;

  VehicleLocation({
    required this.vehicleId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.estimatedMinutes,
    required this.currentLocation,
    this.routePath = const [],
  });

  String get statusString {
    switch (status) {
      case TrackingStatus.enRoute:
        return 'EN ROUTE';
      case TrackingStatus.arrived:
        return 'ARRIVED';
      case TrackingStatus.delayed:
        return 'DELAYED';
    }
  }
}

class LocationPoint {
  final double latitude;
  final double longitude;

  LocationPoint({
    required this.latitude,
    required this.longitude,
  });
}
