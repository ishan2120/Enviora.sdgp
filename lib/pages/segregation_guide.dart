import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../utils/segregation_api_service.dart';
import 'category_items_screen.dart';

class SegregationGuideScreen extends StatefulWidget {
  const SegregationGuideScreen({super.key});

  @override
  State<SegregationGuideScreen> createState() => _SegregationGuideScreenState();
}

class _SegregationGuideScreenState extends State<SegregationGuideScreen> {
  final _api = EnvioraApiService();
  final _searchController = TextEditingController();
  final _searchScrollController = ScrollController();

  // ── Categories state ───────────────────────────────────────
  List<WasteCategory> _categories = [];
  bool _categoriesLoading = true;
  String? _categoriesError;

  // ── Tip state ──────────────────────────────────────────────
  RecyclingTip? _tip;

  // ── Search state ───────────────────────────────────────────
  bool _isSearching = false;
  List<WasteItem> _searchResults = [];
  bool _searchLoading = false;
  bool _searchHasMore = false;
  int _searchPage = 1;
  String _lastQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadTip();
    _searchScrollController.addListener(_onSearchScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchScrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Loaders ───────────────────────────────

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesLoading = true;
      _categoriesError = null;
    });
    try {
      final cats = await _api.getCategories();
      if (mounted)
        setState(() {
          _categories = cats;
          _categoriesLoading = false;
        });
    } catch (e) {
      print('ERROR LOADING CATEGORIES: $e');
      if (mounted)
        setState(() {
          _categoriesError = e.toString();
          _categoriesLoading = false;
        });
    }
  }

  Future<void> _loadTip() async {
    try {
      final tip = await _api.getRandomTip();
      if (mounted) setState(() => _tip = tip);
    } catch (_) {}
  }

  // ── Search ───────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() { _isSearching = false; _searchResults = []; });
      return;
    }
    setState(() { _isSearching = true; _searchLoading = true; });
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _runSearch(value.trim(), reset: true),
    );
  }

  Future<void> _runSearch(String query, {bool reset = false}) async {
    if (reset) {
      _searchPage = 1;
      _searchResults = [];
      _lastQuery = query;
    }
    setState(() => _searchLoading = true);
    try {
      final result = await _api.searchItems(query, page: _searchPage, limit: 12);
      if (mounted) {
        setState(() {
          if (reset) {
            _searchResults = result.items;
          } else {
            _searchResults.addAll(result.items);
          }
          _searchHasMore = result.hasNext;
          _searchPage++;
          _searchLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _searchLoading = false);
    }
  }

  void _onSearchScroll() {
    if (_searchScrollController.position.pixels >=
        _searchScrollController.position.maxScrollExtent - 200) {
      if (!_searchLoading && _searchHasMore) {
        _runSearch(_lastQuery);
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() { _isSearching = false; _searchResults = []; });
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF4CAF50);
    }
  }


  // BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isSearching ? _buildSearchView() : _buildMainView(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  // ── App Bar ────────────────────────────────────────────────

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.white,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ENVIORA',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF4CAF50),
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Segregation Guide',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Color(0xFF000000),
            ),
          ),
        ],
      ),
    );
  }

  // ── Main View ──────────────────────────────────────────────

  Widget _buildMainView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, height: 1.3),
              children: [
                TextSpan(text: 'What are you\n', style: TextStyle(color: Color(0xFF000000))),
                TextSpan(text: 'throwing away ', style: TextStyle(color: Color(0xFF4CAF50))),
                TextSpan(text: 'today?', style: TextStyle(color: Color(0xFF000000))),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSearchBar(),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Waste Categories',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              GestureDetector(
                onTap: _loadCategories,
                child: const Text(
                  'Refresh',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoriesGrid(),
          const SizedBox(height: 20),
          _buildTipCard(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Search Bar ────────

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Color(0xFF999999), size: 20),
          hintText: 'Search items (e.g. banana peel, battery...)',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF999999)),
          border: InputBorder.none,
          suffixIcon: _isSearching
              ? GestureDetector(
                  onTap: _clearSearch,
                  child: const Icon(Icons.close, color: Color(0xFF999999), size: 20),
                )
              : null,
        ),
      ),
    );
  }

  // ── Categories Grid ────────────────────────────────────────

  Widget _buildCategoriesGrid() {
    if (_categoriesLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50))),
      );
    }

    if (_categoriesError != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('Failed to load categories',
                style: TextStyle(color: Colors.red.shade700)),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4CAF50)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('No categories available.'));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _categories.length,
      itemBuilder: (_, i) => _buildCategoryCard(_categories[i]),
    );
  }

  Widget _buildCategoryCard(WasteCategory category) {
    final color = _hexColor(category.colorHex);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryItemsScreen(category: category),
        ),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: category.imageUrl.isNotEmpty
                    ? (category.imageUrl.startsWith('http')
                        ? Image.network(
                            category.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: color.withOpacity(0.12),
                              child: Icon(Icons.image, color: color, size: 40),
                            ),
                          )
                        : Image.asset(
                            category.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: color.withOpacity(0.12),
                              child: Icon(Icons.image, color: color, size: 40),
                            ),
                          ))
                    : Container(
                        color: color.withOpacity(0.12),
                        child: Icon(Icons.image, color: color, size: 40),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    category.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF666666),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.itemCount} items',
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search View ────────────────────────────────────────────

  Widget _buildSearchView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: _buildSearchBar(),
        ),
        const SizedBox(height: 12),
        if (_searchLoading && _searchResults.isEmpty)
          const Expanded(
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
            ),
          )
        else if (_searchResults.isEmpty && !_searchLoading)
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'No results for "${_searchController.text}"',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: GridView.builder(
              controller: _searchScrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.82,
              ),
              itemCount: _searchResults.length + (_searchHasMore ? 1 : 0),
              itemBuilder: (_, i) {
                if (i >= _searchResults.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    ),
                  );
                }
                return _buildSearchResultCard(_searchResults[i]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildSearchResultCard(WasteItem item) {
    final color = _hexColor(item.colorHex);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CategoryItemsScreen(
            category: WasteCategory(
              id: item.categoryId,
              name: item.categoryName,
              slug: item.categorySlug,
              description: '',
              imageUrl: '',
              colorHex: item.colorHex,
              itemCount: 0,
            ),
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 100,
                width: double.infinity,
                child: item.imageUrl.isNotEmpty
                    ? (item.imageUrl.startsWith('http')
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: color.withOpacity(0.1),
                              child: Icon(Icons.image, color: color, size: 32),
                            ),
                          )
                        : Image.asset(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: color.withOpacity(0.1),
                              child: Icon(Icons.image, color: color, size: 32),
                            ),
                          ))
                    : Container(
                        color: color.withOpacity(0.1),
                        child: Icon(Icons.image, color: color, size: 32),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.categoryName,
                      style: TextStyle(
                        fontSize: 10,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Did You Know ───────────────────────────────────────────

  Widget _buildTipCard() {
    return GestureDetector(
      onTap: _loadTip,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFD4E7D4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF2D5F2E), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Did you know?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D5F2E),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Tap for new tip',
                        style: TextStyle(fontSize: 10, color: Colors.green.shade700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _tip?.tip ??
                        'Rinsing your plastic containers before recycling increases the quality of the recycled material significantly!',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF2D5F2E),
                      height: 1.4,
                    ),
                  ),
                  if (_tip?.source != null && _tip!.source.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      '— ${_tip!.source}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF4A8C4B),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}