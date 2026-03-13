import 'package:flutter/foundation.dart'; // This is for kReleaseMode
import 'package:flutter/material.dart';



class EcoApp extends StatelessWidget {
  const EcoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D5A2E)),
      ),
      home: const FindCenterScreen(),
    );
  }
}

// ─── Data Models ────────────────────────────────────────────────────────────

enum WasteCategory { organic, glass, paper }

class DropOffLocation {
  final String name;
  final String status;
  final String statusDetail;
  final String distance;
  final String? address;
  final List<WasteCategory> accepts;
  final bool isOpen;
  final double fillPercent; // 0-1, -1 = not applicable

  const DropOffLocation({
    required this.name,
    required this.status,
    required this.statusDetail,
    required this.distance,
    this.address,
    required this.accepts,
    required this.isOpen,
    this.fillPercent = -1,
  });
}

const _locations = [
  DropOffLocation(
    name: 'EcoPoint North Hub',
    status: 'Open until 6.00 PM',
    statusDetail: '',
    distance: '0.5km away',
    accepts: [WasteCategory.organic, WasteCategory.glass, WasteCategory.paper],
    isOpen: true,
  ),
  DropOffLocation(
    name: 'Central Park Bio-Bin',
    status: '85% Full',
    statusDetail: '',
    distance: '1.2 KM away',
    address: 'Alexanderplatz4',
    accepts: [WasteCategory.organic],
    isOpen: false,
    fillPercent: 0.85,
  ),
];

// ─── Main Screen ─────────────────────────────────────────────────────────────

class FindCenterScreen extends StatefulWidget {
  const FindCenterScreen({super.key});

  @override
  State<FindCenterScreen> createState() => _FindCenterScreenState();
}

class _FindCenterScreenState extends State<FindCenterScreen>
    with SingleTickerProviderStateMixin {
  WasteCategory _selected = WasteCategory.organic;
  late AnimationController _sheetController;
  late Animation<double> _sheetAnim;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _sheetAnim = CurvedAnimation(
      parent: _sheetController,
      curve: Curves.easeOutCubic,
    );
    _sheetController.forward();
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A2A1A),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────
            _TopBar(),
            const SizedBox(height: 12),

            // ── Search + Filter ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _SearchBar(),
                  const SizedBox(height: 12),
                  _CategoryFilter(
                    selected: _selected,
                    onSelect: (c) => setState(() => _selected = c),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Map ──────────────────────────────────────────────────
            Expanded(
              child: Stack(
                children: [
                  _MapPlaceholder(),

                  // ── Bottom sheet slides up ───────────────────────
                  AnimatedBuilder(
                    animation: _sheetAnim,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionalTranslation(
                          translation: Offset(0, 1 - _sheetAnim.value),
                          child: child,
                        ),
                      );
                    },
                    child: _BottomSheet(),
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

// ─── Top Bar ─────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          _CircleBtn(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () {},
            dark: true,
          ),
          const Expanded(
            child: Text(
              'Find Center',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ),
          const SizedBox(width: 40), // balance
        ],
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  const _CircleBtn({
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: dark
              ? Colors.white.withOpacity(0.15)
              : const Color(0xFFF5F7F2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: dark ? Colors.white : const Color(0xFF3D5A2E),
        ),
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
          const SizedBox(width: 10),
          Text(
            'Search Address',
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Filter ──────────────────────────────────────────────────────────

class _CategoryFilter extends StatelessWidget {
  final WasteCategory selected;
  final ValueChanged<WasteCategory> onSelect;

  const _CategoryFilter({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: WasteCategory.values.map((cat) {
        final active = cat == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _CategoryChip(
            category: cat,
            active: active,
            onTap: () => onSelect(cat),
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final WasteCategory category;
  final bool active;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.category,
    required this.active,
    required this.onTap,
  });

  static const _labels = {
    WasteCategory.organic: 'Organic',
    WasteCategory.glass: 'Glass',
    WasteCategory.paper: 'Paper',
  };

  static const _icons = {
    WasteCategory.organic: Icons.eco_rounded,
    WasteCategory.glass: Icons.local_bar_outlined,
    WasteCategory.paper: Icons.layers_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF3D5A2E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFF3D5A2E).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  )
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _icons[category],
              size: 16,
              color: active ? Colors.white : const Color(0xFF3D5A2E),
            ),
            const SizedBox(width: 6),
            Text(
              _labels[category]!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : const Color(0xFF3D5A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Map Placeholder ──────────────────────────────────────────────────────────

class _MapPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: const Color(0xFF1E2D1E),
      child: CustomPaint(
        painter: _MapGridPainter(),
        child: Stack(
          children: [
            // Street labels
            Positioned(
              left: 30,
              top: 60,
              child: _MapLabel('COLOMBO 03'),
            ),
            Positioned(
              right: 20,
              top: 30,
              child: _MapLabel('University\nof Colombo'),
            ),
            Positioned(
              left: 60,
              top: 100,
              child: _MapLabel('IIT City Campus\nRecently viewed'),
            ),
            Positioned(
              left: 10,
              bottom: 180,
              child: _MapLabel('Beach Colombo'),
            ),

            // Pin marker
            const Positioned(
              left: 140,
              top: 130,
              child: _MapPin(),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapLabel extends StatelessWidget {
  final String text;
  const _MapLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withOpacity(0.55),
        fontSize: 9,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFE84040),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 20),
        ),
        Container(
          width: 2,
          height: 8,
          color: const Color(0xFFE84040),
        ),
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: const Color(0xFFE84040).withOpacity(0.4),
            shape: BoxShape.circle,
          ),
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final roadPaint = Paint()
      ..color = const Color(0xFF2E4030)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final minorRoadPaint = Paint()
      ..color = const Color(0xFF263828)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Horizontal roads
    for (int i = 1; i < 6; i++) {
      final y = size.height * i / 6;
      canvas.drawLine(Offset(0, y), Offset(size.width, y),
          i % 2 == 0 ? roadPaint : minorRoadPaint);
    }

    // Vertical roads
    for (int i = 1; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height),
          i % 2 == 0 ? roadPaint : minorRoadPaint);
    }

    // Diagonal accent road
    canvas.drawLine(
      Offset(0, size.height * 0.2),
      Offset(size.width * 0.6, size.height * 0.8),
      minorRoadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Drop-offs',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2A1A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '3 locations found',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF7A8C7A),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D5A2E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Sort by Distance',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Cards
          ..._locations.map((loc) => _LocationCard(location: loc)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ─── Location Card ────────────────────────────────────────────────────────────

class _LocationCard extends StatelessWidget {
  final DropOffLocation location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + Category Icons
          Row(
            children: [
              Expanded(
                child: Text(
                  location.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2A1A),
                  ),
                ),
              ),
              _WasteIcons(categories: location.accepts),
            ],
          ),
          const SizedBox(height: 6),

          // Status
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: location.isOpen
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF8C00),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                location.status,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: location.isOpen
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Distance + Address
          Text(
            location.address != null
                ? '${location.distance} ${location.address}'
                : location.distance,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7A8C7A),
            ),
          ),

          // Fill bar (if applicable)
          if (location.fillPercent > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: location.fillPercent,
                minHeight: 6,
                backgroundColor: const Color(0xFFEEF0EC),
                valueColor: AlwaysStoppedAnimation<Color>(
                  location.fillPercent > 0.8
                      ? const Color(0xFFFF8C00)
                      : const Color(0xFF3D5A2E),
                ),
              ),
            ),
          ],

          const SizedBox(height: 14),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3D5A2E),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (location.isOpen) ...[
                    const Icon(Icons.navigation_rounded, size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Navigate',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ] else
                    const Text(
                      'View Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Waste Category Icons ─────────────────────────────────────────────────────

class _WasteIcons extends StatelessWidget {
  final List<WasteCategory> categories;

  const _WasteIcons({required this.categories});

  static const _iconData = {
    WasteCategory.organic: Icons.eco_rounded,
    WasteCategory.glass: Icons.local_bar_outlined,
    WasteCategory.paper: Icons.layers_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: categories.map((cat) {
        return Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF3EA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _iconData[cat],
              size: 15,
              color: const Color(0xFF3D5A2E),
            ),
          ),
        );
      }).toList(),
    );
  }
}
