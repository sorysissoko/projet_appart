class Conversation {
  final int id;
  final String name;
  final String apt;
  final String last;
  final String time;
  final int unread;
  final String avatar;
  final bool online;

  const Conversation({
    required this.id,
    required this.name,
    required this.apt,
    required this.last,
    required this.time,
    required this.unread,
    required this.avatar,
    required this.online,
  });
}