import 'package:staysync_mobile/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'request_detail_screen.dart';
import 'notification_service.dart';

// --- Main Application Entry Point ---
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://tkhkvpquwqnyvwflfhpx.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRraGt2cHF1d3FueXZ3ZmxmaHB4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NjEyNjYsImV4cCI6MjA2OTUzNzI2Nn0.a5AZNhl4UawXaRfQUAFqdWRmAmY6rBLH1rshEkRSg6g',
  );

  // Initialize the notification service
  await NotificationService().init();

  runApp(const MyApp());
}

// --- Root Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff App',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF0F2F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 1,
        ),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

// --- Data Model for a Service Request ---
class ServiceRequest {
  final String id;
  final int roomNumber;
  final String serviceType;
  final String notes;
  final String status;
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.roomNumber,
    required this.serviceType,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  // Factory constructor to create a ServiceRequest from a Supabase record
  factory ServiceRequest.fromMap(Map<String, dynamic> data) {
    return ServiceRequest(
      id: data['id'],
      roomNumber: data['room_number'] ?? 0,
      serviceType: data['servicetype'] ?? 'Unknown Service',
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: DateTime.parse(data['createdat']),
    );
  }
}

// --- Home Screen Widget (Stateful) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedStatus = 'Pending';
  RealtimeChannel? _realtimeChannel;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListener();
  }

  @override
  void dispose() {
    // It's crucial to remove the channel subscription when the widget is disposed
    // to prevent memory leaks and unwanted background processing.
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  void _setupRealtimeListener() {
    _realtimeChannel = Supabase.instance.client.channel('public:staysync');
    _realtimeChannel!
        .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'staysync',
            callback: (payload) {
              final newRequest = ServiceRequest.fromMap(payload.newRecord);

              NotificationService().showNotification(
                id: newRequest.hashCode,
                title: 'New Service Request',
                body:
                    'Room ${newRequest.roomNumber} has requested ${newRequest.serviceType}.',
              );

              if (_selectedStatus == 'Pending') {
                setState(() {});
              }
            })
        .subscribe();
  }

  Future<List<ServiceRequest>> _fetchRequests() async {
    final supabase = Supabase.instance.client;
    
    // The query is now much simpler. It always fetches requests
    // where the status exactly matches the selected tab's status.
    final response = await supabase
        .from('staysync')
        .select()
        .eq('status', _selectedStatus)
        .order('createdat', ascending: false);

    final List<ServiceRequest> requests = [];
    for (final item in response) {
      requests.add(ServiceRequest.fromMap(item));
    }
    return requests;
  }

  @override
  Widget build(BuildContext context) {
    // Determine the title for the empty list message
    String emptyListTitle = _selectedStatus;
    if (_selectedStatus == 'Pending') {
      emptyListTitle = 'New';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StaySync Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined),
            tooltip: 'View Analytics',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AnalyticsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<ServiceRequest>>(
              future: _fetchRequests(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No $emptyListTitle requests.'));
                }

                final requests = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    return RequestCard(
                      request: requests[index],
                      onUpdate: () {
                        // When a request is updated, trigger a rebuild to refetch the data
                        setState(() {});
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilterChip(
            label: const Text('New'),
            selected: _selectedStatus == 'Pending',
            onSelected: (selected) {
              if (selected) setState(() => _selectedStatus = 'Pending');
            },
            selectedColor: Colors.orange.shade200,
          ),
          FilterChip(
            label: const Text('In Progress'),
            selected: _selectedStatus == 'In Progress',
            onSelected: (selected) {
              if (selected) setState(() => _selectedStatus = 'In Progress');
            },
            selectedColor: Colors.blue.shade200,
          ),
          FilterChip(
            label: const Text('Completed'),
            selected: _selectedStatus == 'Completed',
            onSelected: (selected) {
              if (selected) setState(() => _selectedStatus = 'Completed');
            },
            selectedColor: Colors.green.shade200,
          ),
        ],
      ),
    );
  }
}

// --- Request Card Widget (Stateless) ---
class RequestCard extends StatelessWidget {
  final ServiceRequest request;
  final VoidCallback onUpdate;

  const RequestCard({super.key, required this.request, required this.onUpdate});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'In Progress':
        return Colors.blue;
      case 'Completed':
        return Colors.green;
      case 'Cancelled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: InkWell(
        onTap: () async {
          // Navigate and wait for a result.
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => RequestDetailScreen(request: request),
            ),
          );

          // If the result is true, it means the status was updated.
          // Call the onUpdate callback to trigger a refresh on the HomeScreen.
          if (result == true) {
            onUpdate();
          }
        },
        child: Row(
          children: [
            Container(
              width: 8,
              height: 90,
              decoration: BoxDecoration(
                color: _getStatusColor(request.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Room ${request.roomNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          _formatTimestamp(request.createdAt),
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.serviceType,
                            style: const TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (request.notes.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.chat_bubble_outline,
                              color: Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
