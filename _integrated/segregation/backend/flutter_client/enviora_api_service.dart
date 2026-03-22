// lib/services/enviora_api_service.dart
// Drop this file into your Flutter project under lib/services/
// Requires: http package in pubspec.yaml → http: ^1.2.0

import 'dart:convert';
import 'package:http/http.dart' as http;

// ─── Models ────────────────────────────────────────────────────────────────

class WasteCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String colorHex;
  final int itemCount;

  WasteCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.colorHex,
    required this.itemCount,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> json) => WasteCategory(
        id: json['id'],
        name: json['name'],
        slug: json['slug'],
        description: json['description'] ?? '',
        imageUrl: json['image_url'] ?? '',
        colorHex: json['color_hex'] ?? '#4CAF50',
        itemCount: json['item_count'] ?? 0,
      );
}

class WasteItem {
  final int id;
  final String name;
  final String imageUrl;
  final String shortDescription;
  final int categoryId;
  final String categoryName;
  final String categorySlug;
  final String colorHex;

  WasteItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shortDescription,
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
    required this.colorHex,
  });

  factory WasteItem.fromJson(Map<String, dynamic> json) => WasteItem(
        id: json['id'],
        name: json['name'],
        imageUrl: json['image_url'] ?? '',
        shortDescription: json['short_description'] ?? '',
        categoryId: json['category_id'],
        categoryName: json['category_name'] ?? '',
        categorySlug: json['category_slug'] ?? '',
        colorHex: json['color_hex'] ?? '#4CAF50',
      );
}

class WasteItemDetail extends WasteItem {
  final List<String> disposalInstructions;
  final String youtubeVideoUrl;
  final List<String> tags;
  final String categoryDescription;

  WasteItemDetail({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.shortDescription,
    required super.categoryId,
    required super.categoryName,
    required super.categorySlug,
    required super.colorHex,
    required this.disposalInstructions,
    required this.youtubeVideoUrl,
    required this.tags,
    required this.categoryDescription,
  });

  factory WasteItemDetail.fromJson(Map<String, dynamic> json) {
    List<String> instructions = [];
    if (json['disposal_instructions'] is List) {
      instructions = List<String>.from(json['disposal_instructions']);
    }

    List<String> tags = [];
    if (json['tags'] is List) {
      tags = List<String>.from(json['tags']);
    }

    return WasteItemDetail(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? '',
      shortDescription: json['short_description'] ?? '',
      categoryId: json['category_id'],
      categoryName: json['category_name'] ?? '',
      categorySlug: json['category_slug'] ?? '',
      colorHex: json['color_hex'] ?? '#4CAF50',
      disposalInstructions: instructions,
      youtubeVideoUrl: json['youtube_video_url'] ?? '',
      tags: tags,
      categoryDescription: json['category_description'] ?? '',
    );
  }
}

class PaginatedItems {
  final List<WasteItem> items;
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  PaginatedItems({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });
}

class RecyclingTip {
  final int id;
  final String tip;
  final String source;

  RecyclingTip({required this.id, required this.tip, required this.source});

  factory RecyclingTip.fromJson(Map<String, dynamic> json) => RecyclingTip(
        id: json['id'],
        tip: json['tip'],
        source: json['source'] ?? '',
      );
}

// ─── API Service ────────────────────────────────────────────────────────────

class EnvioraApiService {
  // TODO: Change this to your server IP/domain in production
  static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  // Use 10.0.2.2 for Android emulator → maps to localhost on host machine
  // Use localhost for iOS simulator
  // Use your server's IP for physical devices

  final http.Client _client;

  EnvioraApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      final body = json.decode(response.body);
      throw Exception(body['message'] ?? 'Request failed: ${response.statusCode}');
    }
  }

  /// Fetch all waste categories
  Future<List<WasteCategory>> getCategories() async {
    final data = await _get('/categories');
    final List list = data['data'];
    return list.map((e) => WasteCategory.fromJson(e)).toList();
  }

  /// Fetch a single category by slug
  Future<WasteCategory> getCategoryBySlug(String slug) async {
    final data = await _get('/categories/$slug');
    return WasteCategory.fromJson(data['data']);
  }

  /// Fetch paginated waste items, optionally filtered by category
  Future<PaginatedItems> getItems({
    int? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (categoryId != null) params['category_id'] = categoryId.toString();

    final query = Uri(queryParameters: params).query;
    final data = await _get('/items?$query');

    final List list = data['data'];
    final pagination = data['pagination'];

    return PaginatedItems(
      items: list.map((e) => WasteItem.fromJson(e)).toList(),
      page: pagination['page'],
      limit: pagination['limit'],
      total: pagination['total'],
      totalPages: pagination['total_pages'],
      hasNext: pagination['has_next'],
      hasPrev: pagination['has_prev'],
    );
  }

  /// Fetch full details of a waste item by ID
  Future<WasteItemDetail> getItemById(int id) async {
    final data = await _get('/items/$id');
    return WasteItemDetail.fromJson(data['data']);
  }

  /// Search waste items by name or tag (partial match, paginated)
  Future<PaginatedItems> searchItems(String query, {int page = 1, int limit = 10}) async {
    final params = Uri(queryParameters: {
      'q': query,
      'page': page.toString(),
      'limit': limit.toString(),
    }).query;
    final data = await _get('/items/search?$params');

    final List list = data['data'];
    final pagination = data['pagination'];

    return PaginatedItems(
      items: list.map((e) => WasteItem.fromJson(e)).toList(),
      page: pagination['page'],
      limit: pagination['limit'],
      total: pagination['total'],
      totalPages: pagination['total_pages'],
      hasNext: pagination['has_next'],
      hasPrev: pagination['has_prev'],
    );
  }

  /// Fetch a random "Did You Know?" recycling tip
  Future<RecyclingTip> getRandomTip() async {
    final data = await _get('/tips/random');
    return RecyclingTip.fromJson(data['data']);
  }

  /// Fetch all recycling tips
  Future<List<RecyclingTip>> getAllTips() async {
    final data = await _get('/tips');
    final List list = data['data'];
    return list.map((e) => RecyclingTip.fromJson(e)).toList();
  }

  void dispose() => _client.close();
}
