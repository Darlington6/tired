import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/event_model.dart';

abstract class EventRemoteDataSource {
  Future<void> createEvent(EventModel event, File imageFile);
  Future<List<EventModel>> fetchEvents();
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

   EventRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<void> createEvent(EventModel event, File imageFile) async {
    try {
      // Upload the image to Firebase Storage
      final ref = storage.ref().child('event_thumbnails/${event.id}.jpg');
      await ref.putFile(imageFile);
      final thumbnailUrl = await ref.getDownloadURL();

      // Save event to Firestore
      await firestore.collection('events').doc(event.id).set(
            event.copyWith(thumbnailUrl: thumbnailUrl).toJson(),
          );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> fetchEvents() async {
    try {
      final snapshot = await firestore
      .collection('events')
      .get()
      .timeout(const Duration(seconds: 10)); // Timeout protection
      return snapshot.docs
          .map((doc) => EventModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}

extension EventModelCopyWith on EventModel {
  EventModel copyWith({
    String? id,
    String? title,
    String? hostName,
    String? thumbnailUrl,
    String? hostImageUrl,
    int? viewers,
    int? followers,
    bool? isLive,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      hostName: hostName ?? this.hostName,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      viewers: viewers ?? this.viewers,
      followers: followers ?? this.followers,
      isLive: isLive ?? this.isLive, 
      hostImageUrl: '', 
      category: null,
    );
  }
}