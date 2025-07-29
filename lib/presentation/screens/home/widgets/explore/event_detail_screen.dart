import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  final String title;
  final String thumbnailUrl;
  final DateTime dateTime;
  final String location;
  final String hostId;
  final String category;
  final String type;
  final String description;
  final String status;
  final String ticketType;
  final String? hostName;
  final  price;

  const EventDetailsScreen({
    super.key,
    required this.eventId,
    required this.title,
    required this.thumbnailUrl,
    required this.dateTime,
    required this.location,
    required this.hostId,
    required this.category,
    required this.type,
    required this.description,
    required this.status,
    required this.ticketType,
    this.hostName,
    required this.price, // Made price required and removed default value
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  int _ticketCount = 1;
  bool _isBooking = false;

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('EEEE, MMMM d, y').format(widget.dateTime);
    final formattedTime = DateFormat('h:mm a').format(widget.dateTime);
    final totalPrice = widget.price * _ticketCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(widget.thumbnailUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Event Details
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Onest',
                      color: Colors.black
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Date and Time
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '$formattedDate at $formattedTime',
                        style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                      
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Location
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        widget.location,
                        style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Host
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Hosted by ${widget.hostName ?? "Unknown"}',
                        style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Onest',
                      color: Colors.black87
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                  ),
                  const SizedBox(height: 24),

                  // Ticket Information
                  const Text(
                    'Ticket Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Onest',
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.ticketType} Ticket',
                        style: const TextStyle(fontSize: 16, fontFamily: 'Onest'),
                      ),
                      Text(
                        'Kes ${widget.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Onest',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Ticket Counter
                  Row(
                    children: [
                      const Text('Quantity:', style: TextStyle(fontSize: 16)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (_ticketCount > 1) {
                            setState(() => _ticketCount--);
                          }
                        },
                      ),
                      Text('$_ticketCount', style: const TextStyle(fontSize: 18)),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() => _ticketCount++);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Total Price
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Kes ${totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Book Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.orange,
                      ),
                      onPressed: _isBooking ? null : _bookEvent,
                      child: _isBooking
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'BOOK NOW',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookEvent() async {
    setState(() => _isBooking = true);

    try {
      final totalPrice = widget.price * _ticketCount;
      
      // 1. Create ticket in Firestore
      final ticketRef = await FirebaseFirestore.instance
          .collection('tickets')
          .add({
            'eventID': widget.eventId,
            'userID': FirebaseAuth.instance.currentUser?.uid ?? '',
            'walletAddress': '', // Get from user profile
            'qrCodeUrl': '', // Generate after payment
            'metadata': {
              'ticketType': widget.ticketType,
              'quantity': _ticketCount,
              'totalPaid': totalPrice, // Now properly using double
            },
            'checkedIn': false,
            'issuedAt': FieldValue.serverTimestamp(),
          });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ticket booked successfully!')),
      );

      // TODO: Implement payment processing
      // TODO: Generate QR code
      // TODO: Navigate to ticket confirmation

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking ticket: $e')),
      );
    } finally {
      setState(() => _isBooking = false);
    }
  }
}