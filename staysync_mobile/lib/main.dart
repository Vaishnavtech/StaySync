import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:staysync_mobile/analytics_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:staysync_mobile/auth_screen.dart';
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
        brightness: Brightness.dark,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Inter',
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthScreen(),
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
    String emptyListTitle = _selectedStatus;
    if (_selectedStatus == 'Pending') {
      emptyListTitle = 'New';
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'StaySync',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: Colors.white),
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
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/background.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                _buildFilterTabs(),
                Expanded(
                  child: FutureBuilder<List<ServiceRequest>>(
                    future: _fetchRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.white));
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
                      }
                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(child: Text('No $emptyListTitle requests.', style: const TextStyle(color: Colors.white70)));
                      }

                      final requests = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return RequestCard(
                            request: requests[index],
                            onUpdate: () {
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
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterTab('New', 'Pending'),
          _buildFilterTab('In Progress', 'In Progress'),
          _buildFilterTab('Completed', 'Completed'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, String status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: BlurryContainer(
        blur: isSelected ? 2 : 5,
        color: isSelected ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
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
        return Colors.orangeAccent;
      case 'In Progress':
        return Colors.blueAccent;
      case 'Completed':
        return Colors.greenAccent;
      default:
        return Colors.grey;
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
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) => RequestDetailScreen(
            request: request,
            onUpdate: onUpdate,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: BlurryContainer(
          blur: 8,
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  color: _getStatusColor(request.status),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room ${request.roomNumber}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      request.serviceType,
                      style: const TextStyle(fontSize: 16, color: Colors.white70),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                _formatTimestamp(request.createdAt),
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
