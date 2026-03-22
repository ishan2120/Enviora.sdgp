import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/supervisor_models.dart';
import '../../models/models.dart';

class SupervisorVehicleDetailPage extends StatefulWidget {
  final SupervisorVehicle vehicle;

  const SupervisorVehicleDetailPage({
    Key? key,
    required this.vehicle,
  }) : super(key: key);

  @override
  State<SupervisorVehicleDetailPage> createState() => _SupervisorVehicleDetailPageState();
}

class _SupervisorVehicleDetailPageState extends State<SupervisorVehicleDetailPage> {
  TrackingStatus _currentStatus = TrackingStatus.enRoute;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.vehicle.status;
  }

  Future<void> _updateStatus(TrackingStatus newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('vehicles')
          .doc(widget.vehicle.vehicleId)
          .update({
        'status': newStatus.toString().split('.').last,
        'lastUpdated': DateTime.now().toIso8601String(),
      });
      
      setState(() => _currentStatus = newStatus);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vehicle status updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F8F2),
      appBar: AppBar(
        title: Text('Vehicle ${widget.vehicle.vehicleId}'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDriverCard(),
            const SizedBox(height: 24),
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildInfoRow('License Plate', widget.vehicle.licensePlate),
            _buildInfoRow('Last Updated', widget.vehicle.lastUpdated),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: const Color(0xFF48702E).withOpacity(0.1),
            child: const Icon(Icons.person, color: Color(0xFF48702E), size: 30),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.vehicle.driverName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  widget.vehicle.driverPhone,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.phone, color: Color(0xFF48702E)),
            onPressed: () {
              // Add call logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Status',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatusOption(TrackingStatus.enRoute, 'En Route', Colors.blue),
            _buildStatusOption(TrackingStatus.arrived, 'Arrived', Colors.green),
            _buildStatusOption(TrackingStatus.delayed, 'Delayed', Colors.red),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusOption(TrackingStatus status, String label, Color color) {
    bool isSelected = _currentStatus == status;
    return GestureDetector(
      onTap: () => _updateStatus(status),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? color : Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? Colors.white : Colors.grey,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              foregroundColor: const Color(0xFF48702E),
              side: const BorderSide(color: Color(0xFF48702E)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Assign Route'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF48702E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Send Alert'),
          ),
        ),
      ],
    );
  }
}
