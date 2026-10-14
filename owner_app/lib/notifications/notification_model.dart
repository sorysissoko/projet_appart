class NotificationModel {
  final String id;
  final String userId;
  final String message;
  final bool isRead;
  final String type;
  final String? link;
  final Map<String, dynamic> metadata;
  final DateTime? readAt;
  final String icon;
  final String priority;
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.isRead,
    required this.type,
    this.link,
    required this.metadata,
    this.readAt,
    required this.icon,
    required this.priority,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      isRead: map['is_read'] == true,
      type: map['type']?.toString() ?? 'system',
      link: map['link']?.toString(),
      metadata: map['metadata'] is Map
          ? Map<String, dynamic>.from(map['metadata'])
          : <String, dynamic>{},
      readAt: map['read_at'] != null
          ? DateTime.tryParse(map['read_at'].toString())
          : null,
      icon: map['icon']?.toString() ?? 'info',
      priority: map['priority']?.toString() ?? 'medium',
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(
        map['created_at'].toString(),
      ) ??
          DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'message': message,
      'is_read': isRead,
      'type': type,
      'link': link,
      'metadata': metadata,
      'read_at': readAt?.toIso8601String(),
      'icon': icon,
      'priority': priority,
      'created_at': createdAt.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? message,
    bool? isRead,
    String? type,
    String? link,
    Map<String, dynamic>? metadata,
    DateTime? readAt,
    String? icon,
    String? priority,
    DateTime? createdAt,

    // Permet de supprimer explicitement readAt.
    bool clearReadAt = false,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      link: link ?? this.link,
      metadata: metadata ?? this.metadata,
      readAt: clearReadAt ? null : (readAt ?? this.readAt),
      icon: icon ?? this.icon,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get title {
    switch (type) {
      case 'reservation':
        return 'Réservation';

      case 'payment':
        return 'Paiement';

      case 'certification':
        return 'Certification';

      case 'photo':
        return 'Photo';

      case 'message':
        return 'Message';

      case 'promotion':
        return 'Promotion';

      case 'appartement_soumis':
        return 'Appartement soumis';

      case 'appartement_publie':
        return 'Appartement publié';

      case 'appartement_refuse':
        return 'Appartement refusé';

      case 'info':
        return 'Information';

      case 'system':
      default:
        return 'Notification';
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'urgent':
        return 'Urgent';

      case 'high':
        return 'Important';

      case 'low':
        return 'Faible';

      case 'medium':
      default:
        return 'Normal';
    }
  }

  bool get isUrgent => priority == 'urgent';

  bool get isHighPriority =>
      priority == 'high' || priority == 'urgent';
}