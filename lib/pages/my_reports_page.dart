import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/custom_bottom_nav.dart';
import '../models/models.dart';
import 'file_complaint_page.dart';

class MyReportsPage extends StatefulWidget {
  const MyReportsPage({super.key});

  @override
  State<MyReportsPage> createState() => _MyReportsPageState();
}

class _MyReportsPageState extends State<MyReportsPage> {
  ReportStatus? _selectedFilter;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';







  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Reports',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Status Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _FilterTab(
                  label: 'All',
                  isSelected: _selectedFilter == null,
                  onTap: () {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _FilterTab(
                  label: 'Pending',
                  isSelected: _selectedFilter == ReportStatus.pending,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    setState(() {
                      _selectedFilter = ReportStatus.pending;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _FilterTab(
                  label: 'In Progress',
                  isSelected: _selectedFilter == ReportStatus.inProgress,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    setState(() {
                      _selectedFilter = ReportStatus.inProgress;
                    });
                  },
                ),
                const SizedBox(width: 12),
                _FilterTab(
                  label: 'Resolved',
                  isSelected: _selectedFilter == ReportStatus.resolved,
                  color: const Color(0xFF4CAF50),
                  onTap: () {
                    setState(() {
                      _selectedFilter = ReportStatus.resolved;
                    });
                  },
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search report ID or type...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.green[400]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Reports List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reports')
                  .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                final reports = docs.map((doc) => Report.fromFirestore(doc)).toList();

                // Sort in memory
                reports.sort((a, b) => b.reportedDate.compareTo(a.reportedDate));

                // Apply filters in memory
                final filteredReports = reports.where((r) {
                  // Filter by status
                  if (_selectedFilter != null && r.status != _selectedFilter) {
                    return false;
                  }
                  // Filter by search query
                  if (_searchQuery.isNotEmpty) {
                    final query = _searchQuery.toLowerCase();
                    return r.id.toLowerCase().contains(query) ||
                        r.typeString.toLowerCase().contains(query) ||
                        r.issueType.toLowerCase().contains(query);
                  }
                  return true;
                }).toList();

                if (filteredReports.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('No reports found', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return _ReportCard(report: report);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FileComplaintPage()),
          );
        },
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add, size: 32),
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: -1),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: isSelected ? (color ?? Colors.black) : Colors.grey,
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;

  const _ReportCard({required this.report});

  Color _getStatusColor() {
    switch (report.status) {
      case ReportStatus.pending:
        return const Color(0xFFFFA726);
      case ReportStatus.inProgress:
        return const Color(0xFF42A5F5);
      case ReportStatus.resolved:
        return Colors.black87;
    }
  }

  Color _getStatusBackgroundColor() {
    switch (report.status) {
      case ReportStatus.pending:
        return const Color(0xFFFFF3E0);
      case ReportStatus.inProgress:
        return const Color(0xFFE3F2FD);
      case ReportStatus.resolved:
        return Colors.grey[200]!;
    }
  }

  IconData _getReportIcon() {
    switch (report.type) {
      case ReportType.missedCollection:
        return Icons.delete_outline;
      case ReportType.illegalDumping:
        return Icons.warning_amber_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusBackgroundColor(),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    report.statusString,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getStatusColor(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  report.typeString,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reported on ${DateFormat('MMM dd').format(report.reportedDate)} #${report.id}',
                  style: TextStyle(fontSize: 14, color: Colors.green[600]),
                ),
                if (report.location != null && report.location!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.location!,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () {
                    // Navigate to history page
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View History',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.green[700],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          size: 16,
                          color: Colors.green[700],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: report.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      report.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(_getReportIcon(),
                            size: 40, color: Colors.grey[600]);
                      },
                    ),
                  )
                : Icon(_getReportIcon(), size: 40, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}


