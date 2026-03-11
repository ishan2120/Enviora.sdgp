import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';

class SegregationGuideScreen extends StatefulWidget {
  const SegregationGuideScreen({super.key});

  @override
  State<SegregationGuideScreen> createState() => _SegregationGuideScreenState();
}

class _SegregationGuideScreenState extends State<SegregationGuideScreen> {
  // Text controller for search bar
  final TextEditingController _searchController = TextEditingController();

  // List of all categories
  final List<Map<String, dynamic>> _allCategories = [
    {
      'title': 'Organic',
      'subtitle': 'Food scraps and garden waste',
      'imagePath': 'assets/images/organic_waste.jpg',
      'color': Color(0xFF2D5F2E),
    },
    {
      'title': 'Recyclable',
      'subtitle': 'Plastic, metal & glass',
      'imagePath': 'assets/images/recyclables.jpg',
      'color': Color(0xFF1976D2),
    },
    {
      'title': 'Paper',
      'subtitle': 'Cardboard & newspapers',
      'imagePath': 'assets/images/paper.jpg',
      'color': Color(0xFFD4A574),
    },
    {
      'title': 'Hazardous',
      'subtitle': 'Batteries & electronics',
      'imagePath': 'assets/images/hazardous.jpg',
      'color': Color(0xFF424242),
    },
    {
      'title': 'Glass',
      'subtitle': 'Bottles & jars',
      'imagePath': 'assets/images/glass.jpg',
      'color': Color(0xFFFF9800),
    },
    {
      'title': 'Residual',
      'subtitle': 'Non - recyclable trash',
      'imagePath': 'assets/images/residual.jpg',
      'color': Color(0xFF757575),
    },
  ];

  // Filtered categories based on search
  List<Map<String, dynamic>> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = _allCategories;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Search filter function
  void _filterCategories(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = _allCategories;
      } else {
        _filteredCategories = _allCategories.where((category) {
          final titleLower = category['title'].toLowerCase();
          final subtitleLower = category['subtitle'].toLowerCase();
          final searchLower = query.toLowerCase();
          return titleLower.contains(searchLower) ||
              subtitleLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ENVIORA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4CAF50),
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Segregation Guide',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Section
                    Align(
                      alignment: Alignment.centerLeft,
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          children: [
                            TextSpan(
                              text: 'What are you\n',
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                            TextSpan(
                              text: 'throwing away ',
                              style: TextStyle(color: Color(0xFF4CAF50)),
                            ),
                            TextSpan(
                              text: 'today?',
                              style: TextStyle(color: Color(0xFF000000)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // INTERACTIVE Search Bar
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFE0E0E0),
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterCategories,
                        decoration: const InputDecoration(
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF999999),
                            size: 20,
                          ),
                          hintText: 'Search for an item',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF999999),
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Waste Categories Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Waste Categories',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF000000),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Show all categories
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Showing all categories'),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                          child: const Text(
                            'View all',
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

                    // Show message if no results
                    if (_filteredCategories.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No categories found',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Waste Categories Grid
                    if (_filteredCategories.isNotEmpty)
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.85,
                        ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredCategories.length,
                        itemBuilder: (context, index) {
                          final category = _filteredCategories[index];
                          return _buildCategoryCard(
                            title: category['title'],
                            subtitle: category['subtitle'],
                            imagePath: category['imagePath'],
                            color: category['color'],
                          );
                        },
                      ),

                    const SizedBox(height: 20),

                    // Did You Know Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4E7D4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFF2D5F2E),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Did you know?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF2D5F2E),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Rinsing your plastic containers before recycling increases the quality of the recycled material significantly!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF2D5F2E),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildCategoryCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        // Show details when card is tapped
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    imagePath,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: color.withOpacity(0.1),
                        child: Icon(Icons.image, color: color, size: 50),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  'Items that belong in $title waste category:',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getCategoryDetails(title),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
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
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Container(
                height: 110,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: color.withOpacity(0.1),
                      child: Icon(
                        Icons.image,
                        color: color,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF000000),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
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

  String _getCategoryDetails(String category) {
    switch (category) {
      case 'Organic':
        return '• Fruit and vegetable peels\n• Eggshells\n• Coffee grounds\n• Tea bags\n• Garden waste\n• Plant trimmings';
      case 'Recyclable':
        return '• Plastic bottles\n• Aluminum cans\n• Metal containers\n• Clean plastic packaging\n• Beverage cartons';
      case 'Paper':
        return '• Newspapers\n• Magazines\n• Cardboard boxes\n• Office paper\n• Paper bags\n• Notebooks';
      case 'Hazardous':
        return '• Batteries\n• Electronics\n• Light bulbs\n• Paint cans\n• Chemicals\n• Pesticides';
      case 'Glass':
        return '• Glass bottles\n• Glass jars\n• Wine bottles\n• Beer bottles\n• Food containers';
      case 'Residual':
        return '• Dirty diapers\n• Cigarette butts\n• Used tissues\n• Ceramic items\n• Broken glass\n• Styrofoam';
      default:
        return 'Tap to learn more about this category.';
    }
  }
}
