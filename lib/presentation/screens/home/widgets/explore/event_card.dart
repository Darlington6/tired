import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rovify/presentation/screens/home/widgets/explore/event_detail_screen.dart';

class EventCard extends StatefulWidget {
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
  final price;

  const EventCard({
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
    required this.price,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool isLiked = false;
  late Future<String> _hostNameFuture;

  @override
  void initState() {
    super.initState();
    _hostNameFuture = _fetchHostName();
  }

  Future<String> _fetchHostName() async {
    if (widget.hostId.isEmpty) {
      return 'Unknown';
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.hostId)
          .get();

      return snapshot.data()?['displayName'] ?? 'Unknown';
    } catch (e) {
      debugPrint('Error fetching host name: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d').format(widget.dateTime);
    final formattedTime = DateFormat('h:mm a').format(widget.dateTime);

    // Safely handle price conversion
    if (widget.price is num) {
    } else if (widget.price is String) {
    }

    final priceText = widget.price > 0
    ? 'Kes ${widget.price.toStringAsFixed(2)}' 
    : 'FREE';
    
    return GestureDetector(
      onTap: () => _navigateToEventDetails(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 100,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                color: Colors.grey[200],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
                child: Image.network(
                  widget.thumbnailUrl,
                  width: 100,
                  height: 120,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(Icons.broken_image, size: 30),
                  ),
                ),
              ),
            ),

            // Event details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Onest',
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Date and time
                        Row(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(
                                color: Colors.orange,
                                fontFamily: 'Onest',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• $formattedTime',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontFamily: 'Onest',
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Location and host
                        FutureBuilder<String>(
                          future: _hostNameFuture,
                          builder: (context, snapshot) {
                            final hostText = snapshot.connectionState == ConnectionState.waiting
                                ? 'Loading...'
                                : 'Hosted by ${snapshot.data ?? 'Unknown'}';
                            
                            return Text(
                              '${widget.location} • $hostText',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontFamily: 'Onest',
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          },
                        ),

                        const SizedBox(height: 6),

                        // Price and category
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              priceText,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Onest',
                                fontSize: 13,
                                color: Colors.orange,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                widget.category,
                                style: TextStyle(
                                  color: Colors.grey[800],
                                  fontFamily: 'Onest',
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Like button
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.black,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                          // TODO: Implement like functionality
                        },
                      ),
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

  void _navigateToEventDetails(BuildContext context) {
    // Get the host name from the future for navigation
    _hostNameFuture.then((hostName) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EventDetailsScreen(
            eventId: widget.eventId,
            title: widget.title,
            thumbnailUrl: widget.thumbnailUrl,
            dateTime: widget.dateTime,
            location: widget.location,
            hostId: widget.hostId,
            category: widget.category,
            type: widget.type,
            description: widget.description,
            status: widget.status,
            ticketType: widget.ticketType,
            price: widget.price,
            hostName: hostName,
          ),
        ),
      );
    });
  }
}