import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/models.dart';
import 'supervisor_report_detail_page.dart';

class SupervisorReportsPage extends StatefulWidget {
  const SupervisorReportsPage({Key? key}) : super(key: key);

  @override
  State<SupervisorReportsPage> createState() => _SupervisorReportsPageState();
}

class _SupervisorReportsPageState extends State<SupervisorReportsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: const Text('Reports Management', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF48702E),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF48702E),
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Accepted'),
            Tab(text: 'In Progress'),
            Tab(text: 'Resolved'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportsList(null), // All
                _buildReportsList(ReportStatus.pending),
                _buildReportsList(null, customStatus: 'accepted'),
                _buildReportsList(ReportStatus.inProgress),
                _buildReportsList(ReportStatus.resolved),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by Report ID or Type...',
          prefixIcon: const Icon(Icons.search, color: Color(0xFF48702E)),
          filled: true,
          fillColor: const Color(0xFFF2F8F2),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Widget _buildReportsList(ReportStatus? filterStatus, {String? customStatus}) {
    Query query = FirebaseFirestore.instance.collection('reports');

    if (customStatus != null) {
      query = query.where('status', isEqualTo: customStatus);
    } else if (filterStatus != null) {
      query = query.where('status', isEqualTo: filterStatus.toString().split('.').last);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = List<DocumentSnapshot>.from(snapshot.data!.docs);

        // Sort in memory
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;
          final aDate = (aData['reportedDate'] as Timestamp?)?.toDate() ?? DateTime(0);
          final bDate = (bData['reportedDate'] as Timestamp?)?.toDate() ?? DateTime(0);
          return bDate.compareTo(aDate);
        });

        final reports = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final id = doc.id.toLowerCase();
          final type = (data['issueType'] ?? '').toString().toLowerCase();
          return id.contains(_searchQuery) || type.contains(_searchQuery);
        }).toList();

        if (reports.isEmpty) {
          return const Center(child: Text('No reports found.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final doc = reports[index];
            final data = doc.data() as Map<String, dynamic>;
            
            return _buildReportCard(doc.id, data);
          },
        );
      },
    );
  }

  Widget _buildReportCard(String id, Map<String, dynamic> data) {
    final statusStr = data['status'] ?? 'pending';
    final typeStr = data['issueType'] ?? 'Unknown';
    final date = (data['reportedDate'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('ID: ${id.substring(0, 8).toUpperCase()}', style: const TextStyle(fontWeight: FontWeight.bold)),
            _buildStatusBadge(statusStr),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(typeStr, style: const TextStyle(fontSize: 16, color: Color(0xFF2E3E32))),
            const SizedBox(height: 4),
            Text(
              'Reported on: ${date.day}/${date.month}/${date.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupervisorReportDetailPage(reportId: id, reportData: data),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'pending': color = Colors.orange; break;
      case 'accepted': color = Colors.blue; break;
      case 'inprogress':
      case 'in progress': color = Colors.cyan; break;
      case 'resolved': color = Colors.green; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
