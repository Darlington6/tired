import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rovify/presentation/screens/home/widgets/creator/edit_event_screen.dart'; // Changed to EditEventScreen

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String userId;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.userId,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  late Stream<DocumentSnapshot> _eventStream;
  late Stream<QuerySnapshot> _ticketsStream;
  final Map<String, String> _userDisplayNames = {};

  @override
  void initState() {
    super.initState();
    _eventStream = _firestore.collection('events').doc(widget.eventId).snapshots();
    _ticketsStream = _firestore
        .collection('tickets')
        .where('eventID', isEqualTo: widget.eventId)
        .snapshots();
  }

  Future<String> _getUserDisplayName(String userId) async {
    if (userId.isEmpty) return 'Guest';
    if (_userDisplayNames.containsKey(userId)) {
      return _userDisplayNames[userId]!;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final displayName = userDoc.data()?['displayName'] ?? 'Guest';
      if (displayName != 'Guest') {
        _userDisplayNames[userId] = displayName;
      }
      return displayName;
    } catch (e) {
      return 'Guest';
    }
  }

  Future<void> _editEvent(BuildContext context) async {
    final eventDoc = await _firestore.collection('events').doc(widget.eventId).get();
    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEventScreen( // Changed to EditEventScreen
          eventData: eventDoc.data() as Map<String, dynamic>,
          eventId: widget.eventId,
          userId: widget.userId,
        ),
      ),
    );
  }

  Future<void> _deleteEvent(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: const Text('Are you sure you want to delete this event and all tickets?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final tickets = await _firestore
            .collection('tickets')
            .where('eventID', isEqualTo: widget.eventId)
            .get();

        final batch = _firestore.batch();
        for (var ticket in tickets.docs) {
          batch.delete(ticket.reference);
        }
        batch.delete(_firestore.collection('events').doc(widget.eventId));
        await batch.commit();

        if (context.mounted) Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Event deleted successfully')),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete event')),
          );
        }
      }
    }
  }

  Future<void> _toggleCheckIn(String ticketId, bool status) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).update({
        'isCheckedIn': status,
        'checkInTime': status ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update check-in')),
        );
      }
    }
  }

  Future<void> _refundTicket(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).delete();
      await _firestore.collection('events').doc(widget.eventId).update({
        'ticketsSold': FieldValue.increment(-1),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ticket refunded')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to refund ticket')),
        );
      }
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTicketStats(Map<String, dynamic> event) {
    final sold = event['ticketsSold'] ?? 0;
    final total = event['totalTickets'] ?? '∞';
    return '$sold/$total';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editEvent(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _deleteEvent(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<DocumentSnapshot>(
          stream: _eventStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final event = snapshot.data!.data() as Map<String, dynamic>;
            final dateTime = (event['datetime'] as Timestamp).toDate();
            final isPast = dateTime.isBefore(DateTime.now());

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title'] ?? 'No title',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 18),
                    const SizedBox(width: 8),
                    Text(DateFormat('EEE, MMM d, yyyy • h:mm a').format(dateTime)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 8),
                    Text(event['location'] ?? 'No location'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(event['description'] ?? 'No description'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildStatCard(
                      'Tickets',
                      _getTicketStats(event),
                      Icons.confirmation_number,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      'Status',
                      isPast ? 'Completed' : 'Upcoming',
                      isPast ? Icons.check_circle : Icons.upcoming,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Attendees',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _ticketsStream,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const CircularProgressIndicator();
                      final tickets = snapshot.data!.docs;
                      if (tickets.isEmpty) return const Text('No tickets sold yet');

                      return ListView.builder(
                        itemCount: tickets.length,
                        itemBuilder: (context, i) {
                          final ticket = tickets[i].data() as Map<String, dynamic>;
                          final id = tickets[i].id;
                          final isCheckedIn = ticket['isCheckedIn'] ?? false;
                          final attendeeId = ticket['attendeeId'] ?? '';

                          return FutureBuilder<String>(
                            future: _getUserDisplayName(attendeeId),
                            builder: (context, snapshot) {
                              final name = snapshot.data ?? 'Loading...';

                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: Icon(
                                    isCheckedIn ? Icons.check_circle : Icons.person,
                                    color: isCheckedIn ? Colors.green : Colors.blue,
                                  ),
                                  title: Text(name),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Ticket ID: ${id.substring(0, 8)}'),
                                      if (ticket['checkInTime'] != null)
                                        Text(
                                          'Checked in: ${DateFormat('h:mm a').format((ticket['checkInTime'] as Timestamp).toDate())}',
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(isCheckedIn ? Icons.undo : Icons.check),
                                    color: isCheckedIn ? Colors.grey : Colors.green,
                                    onPressed: () => _toggleCheckIn(id, !isCheckedIn),
                                  ),
                                  onLongPress: () => _refundTicket(id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}