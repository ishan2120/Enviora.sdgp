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

class ScheduleApiService {
  final _client = http.Client();

  Future<List<ScheduleItem>> getMySchedule(int userId) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/schedules/my-schedule?userId=$userId'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => ScheduleItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load schedule');
    }
  }

  Future<List<ScheduleNotification>> getNotifications(int userId) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/schedules/notifications?userId=$userId'),
    );
    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((item) => ScheduleNotification.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }
}
