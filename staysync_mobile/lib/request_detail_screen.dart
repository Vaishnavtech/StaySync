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
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.request.status;
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Supabase.instance.client
          .from('staysync')
          .update({'status': newStatus}).eq('id', widget.request.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop the screen and return true to signal a refresh is needed
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          ],
        ),
      ),
      persistentFooterButtons: _isLoading
          ? [const Center(child: CircularProgressIndicator())]
          : _buildActionButtons(),
    );
  }

  List<Widget> _buildActionButtons() {
    if (_currentStatus == 'Pending') {
      return [
        ElevatedButton(
          onPressed: () => _updateStatus('In Progress'),
          child: const Text('Mark as In Progress'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.blue,
          ),
        ),
      ];
    }
    if (_currentStatus == 'In Progress') {
      return [
        ElevatedButton(
          onPressed: () => _updateStatus('Completed'),
          child: const Text('Mark as Completed'),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: Colors.green,
          ),
        ),
      ];
    }
    return []; // No buttons if status is Completed or anything else
  }
}