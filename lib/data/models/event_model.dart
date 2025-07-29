import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rovify/domain/entities/event.dart';

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.title,
    required super.hostName,
    required super.hostImageUrl,
    required super.thumbnailUrl,
    required super.viewers,
    required super.followers,
    required super.isLive,
    super.hostId,        
    super.category,      
  });

  /// From Firestore Document Snapshot
  factory EventModel.fromMap(Map<String, dynamic> data, String docId) {
    return EventModel(
      id: docId,
      title: data['title'] ?? 'No Title',
      hostName: data['hostName'] ?? 'Unknown Host',
      hostImageUrl: data['hostImageUrl'] ?? 'https://via.placeholder.com/150', 
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      viewers: data['viewers'] ?? 0,
      followers: data['followers'] ?? 0,
      isLive: data['isLive'] ?? false,
      hostId: data['hostId'],                   
      category: data['category'] ?? 'Popular',   
    );
  }

  /// To JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'hostName': hostName,
      'hostImageUrl': hostImageUrl,
      'thumbnailUrl': thumbnailUrl,
      'viewers': viewers,
      'followers': followers,
      'isLive': isLive,
      'hostId': hostId,           
      'category': category,       
    };
  }

  /// From Domain Entity ➜ Model
  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      hostName: event.hostName,
      hostImageUrl: event.hostImageUrl,
      thumbnailUrl: event.thumbnailUrl,
      viewers: event.viewers,
      followers: event.followers,
      isLive: event.isLive,
      hostId: event.hostId,       
      category: event.category,  
    );
  }

  /// From Model ➜ Domain Entity
  Event toEntity() {
    return Event(
      id: id,
      title: title,
      hostName: hostName,
      hostImageUrl: hostImageUrl,
      thumbnailUrl: thumbnailUrl,
      viewers: viewers,
      followers: followers,
      isLive: isLive,
      hostId: hostId,             
      category: category,         
    );
  }

  static fromFirestore(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    return EventModel.fromMap(doc.data(), doc.id);
  }
}