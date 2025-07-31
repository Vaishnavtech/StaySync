import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // Assuming ServiceRequest is in main.dart

class RequestDetailScreen extends StatefulWidget {
  final ServiceRequest request;

  const RequestDetailScreen({super.key, required this.request});

  @override
  _RequestDetailScreenState createState() => _RequestDetailScreenState();
}

class _RequestDetailScreenState extends State<RequestDetailScreen> {
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await Supabase.instance.client
          .from('staysync')
          .update({'status': newStatus}).eq('id', widget.request.id);

      setState(() {
        _currentStatus = newStatus;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update status: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room ${widget.request.roomNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Service: ${widget.request.serviceType}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Status: $_currentStatus',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Notes:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
                widget.request.notes.isNotEmpty
                    ? widget.request.notes
                    : 'No notes provided.',
                style: const TextStyle(fontSize: 16)),
            const Spacer(),
            if (_currentStatus == 'Pending')
              ElevatedButton(
                onPressed: () => _updateStatus('In Progress'),
                child: const Text('Mark as In Progress'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
            if (_currentStatus == 'In Progress')
              ElevatedButton(
                onPressed: () => _updateStatus('Completed'),
                child: const Text('Mark as Completed'),
                style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50)),
              ),
          ],
        ),
      ),
    );
  }
}