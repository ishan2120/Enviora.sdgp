import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SupervisorReportDetailPage extends StatefulWidget {
  final String reportId;
  final Map<String, dynamic> reportData;

  const SupervisorReportDetailPage({
    Key? key,
    required this.reportId,
    required this.reportData,
  }) : super(key: key);

  @override
  State<SupervisorReportDetailPage> createState() => _SupervisorReportDetailPageState();
}

class _SupervisorReportDetailPageState extends State<SupervisorReportDetailPage> {
  late String _currentStatus;
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.reportData['status'] ?? 'pending';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _updateReport() async {
    setState(() => _isSaving = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      final updateData = {
        'status': _currentStatus,
        'supervisorNote': _noteController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'updatedBy': user?.uid,
      };

      await FirebaseFirestore.instance
          .collection('reports')
          .doc(widget.reportId)
          .update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report updated successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update report: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: const Text('Report Details'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildSectionTitle('Update Status'),
            const SizedBox(height: 12),
            _buildStatusDropdown(),
            const SizedBox(height: 24),
            _buildSectionTitle('Supervisor Note'),
            const SizedBox(height: 12),
            _buildNoteField(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ID: ${widget.reportId.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              _buildStatusBadge(_currentStatus),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          _buildDetailRow('Type', widget.reportData['issueType'] ?? 'Unknown'),
          _buildDetailRow('Description', widget.reportData['description'] ?? 'No description provided'),
          _buildDetailRow('Location', widget.reportData['location'] ?? 'Unknown location'),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending': return 'PENDING';
      case 'accepted': return 'ACCEPTED';
      case 'inProgress': return 'IN PROGRESS';
      case 'resolved': return 'RESOLVED';
      default: return status.toUpperCase();
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, color: Color(0xFF2E3E32))),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E3E32)),
    );
  }

  Widget _buildStatusDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _currentStatus,
          isExpanded: true,
          items: ['pending', 'accepted', 'inProgress', 'resolved'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(_formatStatus(value)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                _currentStatus = newValue;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return TextField(
      controller: _noteController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: 'Add a note for the citizen...',
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _updateReport,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF48702E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(color: Colors.white)
            : Column(
                children: [
                  if (_currentStatus == 'pending') ...[
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () {
                          setState(() => _currentStatus = 'accepted');
                          _updateReport();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Accept Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateReport,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF48702E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update Report', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}
