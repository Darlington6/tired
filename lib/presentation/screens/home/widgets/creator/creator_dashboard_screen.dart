import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:rovify/presentation/pages/explore/widgets/creator_dashboard screen.dart';
// import 'package:rovify/presentation/pages/explore/widgets/create_event_screen.dart';

class CreatorDashboardScreen extends StatefulWidget {
  const CreatorDashboardScreen({super.key});

  @override
  State<CreatorDashboardScreen> createState() => _CreatorDashboardScreenState();
}

class _CreatorDashboardScreenState extends State<CreatorDashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Creator Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatorDashboardScreen(),
              ),
            ),
          ),
        ],
      ),
      body: _getSelectedScreen(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event),
            label: 'My Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Attendees',
          ),
        ],
      ),
    );
  }

  Widget _getSelectedScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardScreen();
      case 1:
        return _buildMyEventsScreen();
      case 2:
        return _buildAttendeesScreen();
      default:
        return _buildDashboardScreen();
    }
  }

  Widget _buildDashboardScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Welcome to your Creator Dashboard',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreatorDashboardScreen(),
              ),
            ),
            child: const Text('Create New Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildMyEventsScreen() {
    final userId = _auth.currentUser?.uid;
    
    if (userId == null) {
      return const Center(child: Text('Please sign in'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('events')
          .where('hostId', isEqualTo: userId)
          .orderBy('dateTime')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data?.docs ?? [];

        if (events.isEmpty) {
          return const Center(child: Text('No events created yet'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index].data() as Map<String, dynamic>;
            return ListTile(
              title: Text(event['title'] ?? 'No title'),
              subtitle: Text(event['dateTime']?.toDate().toString() ?? 'No date'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to event management screen
              },
            );
          },
        );
      },
    );
  }

  Widget _buildAttendeesScreen() {
    return const Center(
      child: Text('Attendees will appear here'),
    );
  }
}