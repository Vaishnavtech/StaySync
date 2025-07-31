import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'main.dart'; // Assuming ServiceRequest is in main.dart

class RequestDetailScreen extends StatefulWidget {
  final ServiceRequest request;
  final VoidCallback onUpdate;

  const RequestDetailScreen({super.key, required this.request, required this.onUpdate});

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
            duration: const Duration(seconds: 1),
          ),
        );
        // Pop the modal
        Navigator.of(context).pop();
        // Trigger the refresh on the home screen
        widget.onUpdate();
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
    return BlurryContainer(
      blur: 10,
      color: Colors.black.withOpacity(0.5),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.all(24.0),
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Room ${widget.request.roomNumber}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            Text('Service: ${widget.request.serviceType}', style: const TextStyle(fontSize: 20, color: Colors.white70)),
            const SizedBox(height: 16),
            const Text('Notes:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(
              widget.request.notes.isNotEmpty ? widget.request.notes : 'No notes provided.',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const Spacer(),
            if (_isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.white))
            else
              ..._buildActionButtons(),
          ],
        ),
      ),
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
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
            backgroundColor: Colors.greenAccent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ];
    }
    return [];
  }
}