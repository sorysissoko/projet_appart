import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_model.dart';

enum NotificationRealtimeEventType {
  inserted,
  updated,
  deleted,
}

class NotificationRealtimeEvent {
  final NotificationRealtimeEventType type;

  final NotificationModel? notification;

  final String? notificationId;

  final bool? oldIsRead;
  final bool? newIsRead;

  const NotificationRealtimeEvent({
    required this.type,
    this.notification,
    this.notificationId,
    this.oldIsRead,
    this.newIsRead,
  });
}

class NotificationService {
  final SupabaseClient _supabase;

  NotificationService({
    SupabaseClient? supabase,
  }) : _supabase = supabase ?? Supabase.instance.client;

  static const String _table = 'notifications';

  // ============================================================
  // SINGLETON
  // ============================================================

  static final NotificationService instance =
  NotificationService();

  // ============================================================
  // REALTIME
  // ============================================================

  RealtimeChannel? _realtimeChannel;

  final StreamController<NotificationRealtimeEvent>
  _realtimeController =
  StreamController<NotificationRealtimeEvent>.broadcast();

  bool _realtimeStarted = false;

  Stream<NotificationRealtimeEvent>
  get realtimeEvents =>
      _realtimeController.stream;

  // ============================================================
  // UTILISATEUR CONNECTÉ
  // ============================================================

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // ============================================================
  // RÉCUPÉRER LES NOTIFICATIONS
  // ============================================================

  Future<List<NotificationModel>> getNotifications({
    int limit = 100,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .order(
        'created_at',
        ascending: false,
      )
          .limit(limit);

      return (response as List)
          .map(
            (item) => NotificationModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      throw Exception(
        'Impossible de récupérer les notifications : $e',
      );
    }
  }

  // ============================================================
  // NOTIFICATIONS NON LUES
  // ============================================================

  Future<List<NotificationModel>>
  getUnreadNotifications() async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    try {
      final response = await _supabase
          .from(_table)
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order(
        'created_at',
        ascending: false,
      );

      return (response as List)
          .map(
            (item) => NotificationModel.fromMap(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    } catch (e) {
      throw Exception(
        'Impossible de récupérer les notifications non lues : $e',
      );
    }
  }

  // ============================================================
  // COMPTER LES NON LUES
  // ============================================================

  Future<int> getUnreadCount() async {
    final userId = currentUserId;

    if (userId == null) {
      return 0;
    }

    try {
      final response = await _supabase
          .from(_table)
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      return 0;
    }
  }

  // ============================================================
  // MARQUER UNE NOTIFICATION COMME LUE
  // ============================================================

  Future<void> markAsRead(
      String notificationId,
      ) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from(_table)
          .update({
        'is_read': true,
        'read_at':
        DateTime.now().toUtc().toIso8601String(),
      })
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception(
        'Impossible de marquer la notification comme lue : $e',
      );
    }
  }

  // ============================================================
  // MARQUER TOUTES COMME LUES
  // ============================================================

  Future<void> markAllAsRead() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from(_table)
          .update({
        'is_read': true,
        'read_at':
        DateTime.now().toUtc().toIso8601String(),
      })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      throw Exception(
        'Impossible de modifier les notifications : $e',
      );
    }
  }

  // ============================================================
  // SUPPRIMER UNE NOTIFICATION
  // ============================================================

  Future<void> deleteNotification(
      String notificationId,
      ) async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      throw Exception(
        'Impossible de supprimer la notification : $e',
      );
    }
  }

  // ============================================================
  // SUPPRIMER TOUTES
  // ============================================================

  Future<void> deleteAllNotifications() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    try {
      await _supabase
          .from(_table)
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      throw Exception(
        'Impossible de supprimer les notifications : $e',
      );
    }
  }

  // ============================================================
  // CRÉER UNE NOTIFICATION
  //
  // Les notifications automatiques doivent venir des
  // triggers PostgreSQL.
  // ============================================================

  Future<NotificationModel?> createNotification({
    required String userId,
    required String message,
    String type = 'system',
    String? link,
    Map<String, dynamic>? metadata,
    String icon = 'info',
    String priority = 'medium',
  }) async {
    try {
      final response = await _supabase
          .from(_table)
          .insert({
        'user_id': userId,
        'message': message,
        'type': type,
        'link': link,
        'metadata': metadata ?? {},
        'icon': icon,
        'priority': priority,
        'is_read': false,
      })
          .select()
          .single();

      return NotificationModel.fromMap(
        Map<String, dynamic>.from(response),
      );
    } catch (e) {
      throw Exception(
        'Impossible de créer la notification : $e',
      );
    }
  }

  // ============================================================
  // DÉMARRER REALTIME
  // ============================================================

  Future<void> startRealtime() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    if (_realtimeStarted) {
      return;
    }

    _realtimeStarted = true;

    final channelName =
        'owner_notifications_$userId';

    _realtimeChannel =
        _supabase.channel(channelName);

    _realtimeChannel!
        .onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: _table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        try {
          final data = Map<String, dynamic>.from(
            payload.newRecord,
          );

          final notification =
          NotificationModel.fromMap(data);

          _realtimeController.add(
            NotificationRealtimeEvent(
              type:
              NotificationRealtimeEventType.inserted,
              notification: notification,
            ),
          );
        } catch (e) {
          // Événement Realtime invalide.
        }
      },
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: _table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        try {
          final newData =
          Map<String, dynamic>.from(
            payload.newRecord,
          );

          final oldData =
          Map<String, dynamic>.from(
            payload.oldRecord,
          );

          final notification =
          NotificationModel.fromMap(newData);

          final oldIsRead =
              oldData['is_read'] == true;

          final newIsRead =
              newData['is_read'] == true;

          _realtimeController.add(
            NotificationRealtimeEvent(
              type:
              NotificationRealtimeEventType.updated,
              notification: notification,
              notificationId: notification.id,
              oldIsRead: oldIsRead,
              newIsRead: newIsRead,
            ),
          );
        } catch (e) {
          // Événement Realtime invalide.
        }
      },
    )
        .onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: _table,
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        try {
          final oldData =
          Map<String, dynamic>.from(
            payload.oldRecord,
          );

          final id =
          oldData['id']?.toString();

          if (id == null || id.isEmpty) {
            return;
          }

          final oldIsRead =
              oldData['is_read'] == true;

          _realtimeController.add(
            NotificationRealtimeEvent(
              type:
              NotificationRealtimeEventType.deleted,
              notificationId: id,
              oldIsRead: oldIsRead,
            ),
          );
        } catch (e) {
          // Événement Realtime invalide.
        }
      },
    );

    _realtimeChannel!.subscribe();
  }

  // ============================================================
  // ARRÊTER REALTIME
  // ============================================================

  Future<void> stopRealtime() async {
    if (_realtimeChannel != null) {
      await _supabase.removeChannel(
        _realtimeChannel!,
      );

      _realtimeChannel = null;
    }

    _realtimeStarted = false;
  }

  // ============================================================
  // COMPATIBILITÉ ANCIEN CODE
  // ============================================================

  Stream<NotificationModel> watchNotifications() {
    return realtimeEvents
        .where(
          (event) =>
      event.type ==
          NotificationRealtimeEventType
              .inserted &&
          event.notification != null,
    )
        .map(
          (event) => event.notification!,
    );
  }

  Future<void> dispose() async {
    await stopRealtime();

    if (!_realtimeController.isClosed) {
      await _realtimeController.close();
    }
  }
}