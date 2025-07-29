class Event {
  final String id;
  final String title;
  final String hostName;
  final String hostImageUrl;
  final String thumbnailUrl;
  final int viewers;
  final int followers;
  final bool isLive;
  final String? hostId;
  final String? category; 

  Event({
    required this.id,
    required this.title,
    required this.hostName,
    required this.hostImageUrl,
    required this.thumbnailUrl,
    required this.viewers,
    required this.followers,
    required this.isLive,
    required this.hostId,
    required this.category,
  });
}