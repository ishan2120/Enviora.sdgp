import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

// ─────────────────────────────────────────────
// The base URL is now centralized in api_config.dart
// ─────────────────────────────────────────────
final String kBaseUrl = '${ApiConfig.baseUrl}/segregation';

// ══════════════════════════════════════════════
// MODELS
// ══════════════════════════════════════════════

class WasteCategory {
  final int id;
  final String name;
  final String slug;
  final String description;
  final String imageUrl;
  final String colorHex;
  final int itemCount;

  const WasteCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.imageUrl,
    required this.colorHex,
    required this.itemCount,
  });

  factory WasteCategory.fromJson(Map<String, dynamic> j) => WasteCategory(
    id: j['id'],
    name: j['name'] ?? '',
    slug: j['slug'] ?? '',
    description: j['description'] ?? '',
    imageUrl: j['image_url'] ?? '',
    colorHex: j['color_hex'] ?? '#4CAF50',
    itemCount: j['item_count'] ?? 0,
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

  const WasteItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shortDescription,
    required this.categoryId,
    required this.categoryName,
    required this.categorySlug,
    required this.colorHex,
  });

  factory WasteItem.fromJson(Map<String, dynamic> j) => WasteItem(
    id: j['id'],
    name: j['name'] ?? '',
    imageUrl: j['image_url'] ?? '',
    shortDescription: j['short_description'] ?? '',
    categoryId: j['category_id'] ?? 0,
    categoryName: j['category_name'] ?? '',
    categorySlug: j['category_slug'] ?? '',
    colorHex: j['color_hex'] ?? '#4CAF50',
  );
}

class WasteItemDetail {
  final int id;
  final String name;
  final String imageUrl;
  final String shortDescription;
  final List<String> disposalInstructions;
  final String youtubeVideoUrl;
  final List<String> tags;
  final int categoryId;
  final String categoryName;
  final String colorHex;

  const WasteItemDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.shortDescription,
    required this.disposalInstructions,
    required this.youtubeVideoUrl,
    required this.tags,
    required this.categoryId,
    required this.categoryName,
    required this.colorHex,
  });

  factory WasteItemDetail.fromJson(Map<String, dynamic> j) => WasteItemDetail(
    id: j['id'],
    name: j['name'] ?? '',
    imageUrl: j['image_url'] ?? '',
    shortDescription: j['short_description'] ?? '',
    disposalInstructions: j['disposal_instructions'] is List
        ? List<String>.from(j['disposal_instructions'])
        : [],
    youtubeVideoUrl: j['youtube_video_url'] ?? '',
    tags: j['tags'] is List ? List<String>.from(j['tags']) : [],
    categoryId: j['category_id'] ?? 0,
    categoryName: j['category_name'] ?? '',
    colorHex: j['color_hex'] ?? '#4CAF50',
  );
}

class PaginatedItems {
  final List<WasteItem> items;
  final int page;
  final int total;
  final int totalPages;
  final bool hasNext;

  const PaginatedItems({
    required this.items,
    required this.page,
    required this.total,
    required this.totalPages,
    required this.hasNext,
  });
}

class RecyclingTip {
  final int id;
  final String tip;
  final String source;

  const RecyclingTip({
    required this.id,
    required this.tip,
    required this.source,
  });

  factory RecyclingTip.fromJson(Map<String, dynamic> j) =>
      RecyclingTip(id: j['id'], tip: j['tip'] ?? '', source: j['source'] ?? '');
}

// ══════════════════════════════════════════════
// API SERVICE
// ══════════════════════════════════════════════

class EnvioraApiService {
  static final EnvioraApiService _instance = EnvioraApiService._internal();
  factory EnvioraApiService() => _instance;
  EnvioraApiService._internal();

  final _client = http.Client();

  Future<Map<String, dynamic>> _get(String path) async {
    final uri = Uri.parse('$kBaseUrl$path');
    print('📡 CALLING API: $uri'); // Add this for debugging
    final res = await _client.get(uri).timeout(const Duration(seconds: 10));
    print('📡 RESPONSE STATUS: ${res.statusCode}');
    if (res.body.startsWith('<!DOCTYPE html>')) {
      print('📡 WARNING: Received HTML instead of JSON!');
      print('📡 HTML PREVIEW: ${res.body.substring(0, (res.body.length > 500 ? 500 : res.body.length))}');
    }
    final body = json.decode(res.body);
    if (res.statusCode == 200) return body;
    throw Exception(body['message'] ?? 'Request failed (${res.statusCode})');
  }

  Future<List<WasteCategory>> getCategories() async {
    final data = await _get('/categories');
    return (data['data'] as List)
        .map((e) => WasteCategory.fromJson(e))
        .toList();
  }

  Future<PaginatedItems> getItems({
    int? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    final q = {
      'page': '$page',
      'limit': '$limit',
      if (categoryId != null) 'category_id': '$categoryId',
    };
    final data = await _get('/items?${Uri(queryParameters: q).query}');
    final pg = data['pagination'];
    return PaginatedItems(
      items: (data['data'] as List).map((e) => WasteItem.fromJson(e)).toList(),
      page: pg['page'],
      total: pg['total'],
      totalPages: pg['total_pages'],
      hasNext: pg['has_next'],
    );
  }

  Future<PaginatedItems> searchItems(
    String query, {
    int page = 1,
    int limit = 10,
  }) async {
    final q = {'q': query, 'page': '$page', 'limit': '$limit'};
    final data = await _get('/items/search?${Uri(queryParameters: q).query}');
    final pg = data['pagination'];
    return PaginatedItems(
      items: (data['data'] as List).map((e) => WasteItem.fromJson(e)).toList(),
      page: pg['page'],
      total: pg['total'],
      totalPages: pg['total_pages'],
      hasNext: pg['has_next'],
    );
  }

  Future<WasteItemDetail> getItemDetail(int id) async {
    final data = await _get('/items/$id');
    return WasteItemDetail.fromJson(data['data']);
  }

  Future<RecyclingTip> getRandomTip() async {
    final data = await _get('/tips/random');
    return RecyclingTip.fromJson(data['data']);
  }
}
