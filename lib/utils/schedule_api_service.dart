import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class ScheduleItem {
  final String date;
  final String time;
  final String type;
  final String ward;
  final String roads;

  ScheduleItem({
    required this.date,
    required this.time,
    required this.type,
    required this.ward,
    required this.roads,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      type: json['type'] ?? '',
      ward: json['ward'] ?? '',
      roads: json['roads'] ?? '',
    );
  }
}

class ScheduleNotification {
  final String title;
  final String time;
  final String day;
  final String date;

  ScheduleNotification({
    required this.title,
    required this.time,
    required this.day,
    required this.date,
  });

  factory ScheduleNotification.fromJson(Map<String, dynamic> json) {
    return ScheduleNotification(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      day: json['day'] ?? '',
      date: json['date'] ?? '',
    );
  }
}

class Announcement {
  final int id;
  final String targetAddress;
  final String message;
  final String type;
  final String createdAt;

  Announcement({
    required this.id,
    required this.targetAddress,
    required this.message,
    required this.type,
    required this.createdAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    return Announcement(
      id: json['id'] ?? 0,
      targetAddress: json['target_address'] ?? 'all',
      message: json['message'] ?? '',
      type: json['type'] ?? 'general',
      createdAt: json['created_at'] ?? '',
    );
  }
}

class ScheduleApiService {
  final _client = http.Client();

  Future<List<ScheduleItem>> getMySchedule({int? userId, String? email}) async {
    final queryParam = email != null ? 'email=$email' : 'userId=${userId ?? 1}';
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/schedules/my-schedule?$queryParam'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => ScheduleItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load schedule');
    }
  }

  Future<List<ScheduleNotification>> getNotifications({int? userId, String? email}) async {
    final queryParam = email != null ? 'email=$email' : 'userId=${userId ?? 1}';
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/schedules/notifications?$queryParam'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => ScheduleNotification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<List<Announcement>> getAnnouncements(String address) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/dashboard/announcements?address=$address'),
    );
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['success'] == true) {
        List data = jsonResponse['announcements'] ?? [];
        return data.map((item) => Announcement.fromJson(item)).toList();
      }
    }
    return [];
  }
}
