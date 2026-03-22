import '../utils/schedule_api_service.dart';
import '../widgets/custom_bottom_nav.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Collection schedule page widget
class CollectionSchedulePage extends StatefulWidget {
  const CollectionSchedulePage({super.key});

  @override
  State<CollectionSchedulePage> createState() => _CollectionSchedulePageState();
}

class _CollectionSchedulePageState extends State<CollectionSchedulePage> {
  // Service for fetching schedule data from the API
  final _apiService = ScheduleApiService();
  List<ScheduleItem> _fullSchedule = [];
  bool _isLoading = true;
  String? _error;
  
  DateTime _selectedDate = DateTime(2026, 3, 21); // Start of target range
  final DateTime _rangeStart = DateTime(2026, 3, 21);
  final DateTime _rangeEnd = DateTime(2026, 4, 21);

  @override
  void initState() {
    super.initState();
    _fetchSchedule();  // Load schedule data when the page first opens
  }
  /// Fetches the user's collection schedule from the API.
  /// Uses the current Firebase Auth user's email to identify them.
  /// Falls back to an error message if the request fails.
  Future<void> _fetchSchedule() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      final user = FirebaseAuth.instance.currentUser;
      final email = user?.email;
      final results = await _apiService.getMySchedule(email: email);
      setState(() {
        _fullSchedule = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Failed to load schedule. Using offline data.";
        _isLoading = false;
      });
    }
  }

  List<ScheduleItem> get _filteredSchedule {
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
    return _fullSchedule.where((s) => s.date == dateStr).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF2F8F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Collection schedule",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Location Field
            Padding(
              padding: EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_on_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "My home - 123, Green St",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Weekly / Monthly Toggle
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text("Weekly"),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      child: Text("Monthly"),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),

            // Week days row
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 14, // Show 2 weeks for selection
                itemBuilder: (context, index) {
                  final date = _rangeStart.add(Duration(days: index));
                  final dayName = DateFormat('E').format(date);
                  final dayDate = DateFormat('d').format(date);
                  bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(_selectedDate);

                  return GestureDetector(
                    onTap: () => setState(() => _selectedDate = date),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green.shade100 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: Colors.green) : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(dayName, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          const SizedBox(height: 5),
                          Text(dayDate, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (_isLoading)
               const Padding(
                 padding: EdgeInsets.all(40.0),
                 child: CircularProgressIndicator(),
               )
            else if (_error != null)
               Padding(
                 padding: const EdgeInsets.all(20.0),
                 child: Text(_error!, style: const TextStyle(color: Colors.red)),
               )
            else ...[
              sectionTitle("Collections for ${DateFormat('MMMM d').format(_selectedDate)}"),
              if (_filteredSchedule.isEmpty)
                Container(
                  padding: const EdgeInsets.all(40),
                  child: const Column(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No collections scheduled for this day", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              else
                ..._filteredSchedule.map((s) => collectionCard(
                  icon: s.type.contains('Recyclable') ? Icons.recycling : Icons.delete,
                  title: s.type,
                  subtitle: "${s.time} (Ward: ${s.ward})",
                  status: "Scheduled",
                  statusColor: Colors.blue,
                )),
            ],

            SizedBox(height: 20),

            Container(
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 10),
                  Text("No more collections this week"),
                ],
              ),
            ),

            SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
    );
  }

  Widget sectionTitle(String title) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget collectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 5),
                Text(subtitle, style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor)),
          ),
        ],
      ),
    );
  }
}
