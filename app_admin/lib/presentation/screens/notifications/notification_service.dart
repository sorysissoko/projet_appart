import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

enum NotificationRealtimeType {
  inserted,
  updated,
  deleted,
}

class NotificationRealtimeEvent {
  final NotificationRealtimeType type;
  final Map<String, dynamic>? notification;
  final String? notificationId;

  /// Utilisé principalement pour DELETE.
  final bool? oldIsRead;

  /// Utilisé pour UPDATE.
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
  static final NotificationService _instance =
  NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  RealtimeChannel? _channel;

  String? _subscribedUserId;

  final StreamController<NotificationRealtimeEvent> _controller =
  StreamController<NotificationRealtimeEvent>.broadcast();

  Stream<NotificationRealtimeEvent> get events => _controller.stream;

  // ============================================================
  // UTILITAIRE : USER CONNECTÉ
  // ============================================================

  String? get currentUserId {
    return _supabase.auth.currentUser?.id;
  }

  // ============================================================
  // RÉCUPÉRER LES NOTIFICATIONS
  // ============================================================

  Future<List<Map<String, dynamic>>> getNotifications({
    int limit = 100,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      return [];
    }

    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Erreur récupération notifications : $e');
      rethrow;
    }
  }

  // ============================================================
  // NOMBRE DE NOTIFICATIONS NON LUES
  // ============================================================

  Future<int> getUnreadCount() async {
    final userId = currentUserId;

    if (userId == null) {
      return 0;
    }

    try {
      final response = await _supabase
          .from('notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return response.length;
    } catch (e) {
      print('❌ Erreur compteur notifications : $e');
      return 0;
    }
  }

  // ============================================================
  // MARQUER UNE NOTIFICATION COMME LUE
  // ============================================================

  Future<void> markAsRead(String notificationId) async {
    final userId = currentUserId;

    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({
        'is_read': true,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      print('❌ Erreur markAsRead : $e');
      rethrow;
    }
  }

  // ============================================================
  // MARQUER TOUT COMME LU
  // ============================================================

  Future<void> markAllAsRead() async {
    final userId = currentUserId;

    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .update({
        'is_read': true,
        'read_at': DateTime.now().toUtc().toIso8601String(),
      })
          .eq('user_id', userId)
          .eq('is_read', false);
    } catch (e) {
      print('❌ Erreur markAllAsRead : $e');
      rethrow;
    }
  }

  // ============================================================
  // SUPPRIMER UNE NOTIFICATION
  // ============================================================

  Future<void> deleteNotification(String notificationId) async {
    final userId = currentUserId;

    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', userId);
    } catch (e) {
      print('❌ Erreur suppression notification : $e');
      rethrow;
    }
  }

  // ============================================================
  // SUPPRIMER TOUTES LES NOTIFICATIONS
  // ============================================================

  Future<void> deleteAllNotifications() async {
    final userId = currentUserId;

    if (userId == null) return;

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId);
    } catch (e) {
      print('❌ Erreur suppression notifications : $e');
      rethrow;
    }
  }

  // ============================================================
  // REALTIME
  // ============================================================

  Future<void> startRealtime() async {
    final userId = currentUserId;

    if (userId == null) {
      return;
    }

    // Déjà connecté pour cet utilisateur.
    if (_channel != null && _subscribedUserId == userId) {
      return;
    }

    await stopRealtime();

    _subscribedUserId = userId;

    final channel = _supabase.channel(
      'admin_notifications_$userId',
    );

    // ----------------------------------------------------------
    // INSERT
    // ----------------------------------------------------------

    channel.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final record =
        Map<String, dynamic>.from(payload.newRecord);

        _controller.add(
          NotificationRealtimeEvent(
            type: NotificationRealtimeType.inserted,
            notification: record,
            notificationId: record['id']?.toString(),
            newIsRead: record['is_read'] == true,
          ),
        );
      },
    );

    // ----------------------------------------------------------
    // UPDATE
    // ----------------------------------------------------------

    channel.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final newRecord =
        Map<String, dynamic>.from(payload.newRecord);

        final oldRecord =
        Map<String, dynamic>.from(payload.oldRecord);

        _controller.add(
          NotificationRealtimeEvent(
            type: NotificationRealtimeType.updated,
            notification: newRecord,
            notificationId: newRecord['id']?.toString(),
            oldIsRead: oldRecord['is_read'] == true,
            newIsRead: newRecord['is_read'] == true,
          ),
        );
      },
    );

    // ----------------------------------------------------------
    // DELETE
    // ----------------------------------------------------------

    channel.onPostgresChanges(
      event: PostgresChangeEvent.delete,
      schema: 'public',
      table: 'notifications',
      filter: PostgresChangeFilter(
        type: PostgresChangeFilterType.eq,
        column: 'user_id',
        value: userId,
      ),
      callback: (payload) {
        final oldRecord =
        Map<String, dynamic>.from(payload.oldRecord);

        _controller.add(
          NotificationRealtimeEvent(
            type: NotificationRealtimeType.deleted,
            notificationId: oldRecord['id']?.toString(),
            oldIsRead: oldRecord['is_read'] == true,
          ),
        );
      },
    );

    _channel = channel;

    await channel.subscribe();

    print('🟢 Realtime notifications connecté');
  }

  // ============================================================
  // ARRÊTER REALTIME
  // ============================================================

  Future<void> stopRealtime() async {
    final channel = _channel;

    if (channel != null) {
      try {
        await _supabase.removeChannel(channel);
      } catch (e) {
        print('⚠️ Erreur fermeture realtime : $e');
      }
    }

    _channel = null;
    _subscribedUserId = null;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await stopRealtime();

    await _controller.close();
  }
}