import 'package:flutter/material.dart';
import '../utils/segregation_api_service.dart';
import 'item_detail_screen.dart';

class CategoryItemsScreen extends StatefulWidget {
  final WasteCategory category;
  const CategoryItemsScreen({super.key, required this.category});

  @override
  State<CategoryItemsScreen> createState() => _CategoryItemsScreenState();
}

class _CategoryItemsScreenState extends State<CategoryItemsScreen> {
  final _api = EnvioraApiService();
  final _scrollController = ScrollController();

  final List<WasteItem> _items = [];
  int _page = 1;
  bool _loading = false;
  bool _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);
    try {
      final result = await _api.getItems(
        categoryId: widget.category.id,
        page: _page,
        limit: 12,
      );
      setState(() {
        _items.addAll(result.items);
        _hasMore = result.hasNext;
        _page++;
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Color get _color {
    try {
      return Color(int.parse(widget.category.colorHex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return const Color(0xFF4CAF50);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App bar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: _color,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black87),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.category.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${widget.category.itemCount} items',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  widget.category.imageUrl.isNotEmpty
                      ? (widget.category.imageUrl.startsWith('http')
                          ? Image.network(widget.category.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: _color))
                          : Image.asset(widget.category.imageUrl, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: _color)))
                      : Container(color: _color),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Items grid ───────────────────────────────────────
          if (_items.isEmpty && !_loading && _error == null)
            const SliverFillRemaining(
              child: Center(child: Text('No items found.')),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= _items.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
                        ),
                      );
                    }
                    return _buildItemCard(_items[index]);
                  },
                  childCount: _items.length + (_hasMore ? 1 : 0),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
              ),
            ),

          if (_error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(children: [
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () { _error = null; _loadMore(); },
                    child: const Text('Retry'),
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildItemCard(WasteItem item) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ItemDetailScreen(itemId: item.id)),
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: SizedBox(
                height: 110,
                width: double.infinity,
                child: item.imageUrl.isNotEmpty
                    ? (item.imageUrl.startsWith('http')
                        ? Image.network(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _color.withOpacity(0.1),
                              child: Icon(Icons.image, color: _color, size: 36),
                            ),
                          )
                        : Image.asset(
                            item.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: _color.withOpacity(0.1),
                              child: Icon(Icons.image, color: _color, size: 36),
                            ),
                          ))
                    : Container(
                        color: _color.withOpacity(0.1),
                        child: Icon(Icons.image, color: _color, size: 36),
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
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.shortDescription,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF888888),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
