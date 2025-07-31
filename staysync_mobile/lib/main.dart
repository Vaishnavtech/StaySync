import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// TODO: Make sure to add your own firebase_options.dart file
// by running `flutterfire configure` in your terminal.
import 'firebase_options.dart';

// --- Main Application Entry Point ---
void main() async {
  // Ensure Flutter bindings are initialized before calling Firebase
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

// --- Root Application Widget ---
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swagat Staff App',
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
  final Timestamp createdAt;

  ServiceRequest({
    required this.id,
    required this.roomNumber,
    required this.serviceType,
    required this.notes,
    required this.status,
    required this.createdAt,
  });

  // Factory constructor to create a ServiceRequest from a Firestore document
  factory ServiceRequest.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ServiceRequest(
      id: doc.id,
      roomNumber: data['room_number'] ?? 0,
      serviceType: data['serviceType'] ?? 'Unknown Service',
      notes: data['notes'] ?? '',
      status: data['status'] ?? 'Pending',
      createdAt: data['createdAt'] ?? Timestamp.now(),
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
  // State to track the selected filter chip
  String _selectedStatus = 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'StaySync Requests',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: const [
          // Real-time status indicator
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Icon(Icons.circle, color: Colors.green, size: 12),
                SizedBox(width: 6),
                Text('Live', style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Bar
          _buildFilterChips(),
          
          // Real-time list of requests
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // Listen to the 'StaySync' collection, ordered by creation time
              stream: FirebaseFirestore.instance
                  .collection('StaySync')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                // Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                // Handle error state
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                // Handle no data
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No service requests found.'));
                }

                // Convert Firestore documents to a list of ServiceRequest objects
                final requests = snapshot.data!.docs
                    .map((doc) => ServiceRequest.fromFirestore(doc))
                    .toList();
                
                // Apply the filter based on the selected status
                final filteredRequests = requests.where((req) {
                  if (_selectedStatus == 'All') {
                    // Show "Pending" and "In Progress" in the "All" view
                    return req.status == 'Pending' || req.status == 'In Progress';
                  }
                  return req.status == _selectedStatus;
                }).toList();

                if (filteredRequests.isEmpty) {
                  return Center(child: Text('No $_selectedStatus requests.'));
                }

                // Build the list view
                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    return RequestCard(request: filteredRequests[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget for the filter chips
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FilterChip(
            label: const Text('Pending'),
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
            label: const Text('All Active'),
            selected: _selectedStatus == 'All',
            onSelected: (selected) {
              if (selected) setState(() => _selectedStatus = 'All');
            },
            selectedColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}

// --- Request Card Widget (Stateless) ---
class RequestCard extends StatelessWidget {
  final ServiceRequest request;

  const RequestCard({super.key, required this.request});

  // Helper to determine color based on status
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

  // Helper to format the timestamp into a relative string
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final requestTime = timestamp.toDate();
    final difference = now.difference(requestTime);

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
        onTap: () {
          // TODO: Navigate to a detail screen to update status
          print('Tapped on request for Room ${request.roomNumber}');
        },
        child: Row(
          children: [
            // Status Indicator Bar
            Container(
              width: 8,
              height: 90, // Set a fixed height for consistency
              decoration: BoxDecoration(
                color: _getStatusColor(request.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
              ),
            ),
            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: Room Number and Timestamp
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
                    // Bottom Row: Service Type and Notes Icon
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