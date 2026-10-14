import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/backend_service.dart';

import '../../core/navigation/main_wrapper.dart';
import '../core/theme/app_theme.dart';
import 'notification_model.dart';
import 'notification_service.dart';

class NotificationsPage extends StatefulWidget {
  final NavigateCallback onNavigate;

  const NotificationsPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<NotificationsPage> createState() =>
      _NotificationsPageState();
}

class _NotificationsPageState
    extends State<NotificationsPage> {
  final NotificationService _notificationService =
      NotificationService.instance;

  final BackendService _backendService = BackendService();
  List<NotificationModel> _notifications = [];

  bool _isLoading = true;
  bool _isMarkingAll = false;
  bool _isCertified = true;
  bool _isLoadingCertification = true;

  String _selectedFilter = 'Toutes';

  StreamSubscription<NotificationRealtimeEvent>?
  _realtimeSubscription;

  static const Color pageBg =
  Color(0xFFF4F6FB);

  static const Color goldAccent =
  Color(0xFFC9913A);

  static const Color textDark =
  Color(0xFF0F1B2D);

  static const Color textMuted =
  Color(0xFF8A94A6);

  @override
  void initState() {
    super.initState();

    _loadNotifications();
    _loadCertification();
    _listenRealtime();
  }

  @override
  void dispose() {
    _realtimeSubscription?.cancel();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT
  // ============================================================

  Future<void> _loadNotifications() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final notifications =
      await _notificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showError(
        'Impossible de charger les notifications.',
      );
    }
  }

  Future<void> _loadCertification() async {
    try {
      final profile = await _backendService.getCurrentProfile();

      if (!mounted) return;

      final value = profile?['est_certifie'];

      bool certified = false;

      if (value is bool) {
        certified = value;
      } else if (value is String) {
        certified = value.toLowerCase() == 'true';
      }

      setState(() {
        _isCertified = certified;
        _isLoadingCertification = false;
      });
    } catch (e, stack) {
      debugPrint('ERREUR CERTIFICATION : $e');
      debugPrint(stack.toString());

      if (!mounted) return;

      setState(() {
        _isCertified = false;
        _isLoadingCertification = false;
      });
    }
  }

  // ============================================================
  // REALTIME
  // ============================================================

  void _listenRealtime() {
    _realtimeSubscription =
        _notificationService.realtimeEvents.listen(
              (event) {
            if (!mounted) return;

            switch (event.type) {
              case NotificationRealtimeEventType.inserted:
                _handleRealtimeInsert(event);
                break;

              case NotificationRealtimeEventType.updated:
                _handleRealtimeUpdate(event);
                break;

              case NotificationRealtimeEventType.deleted:
                _handleRealtimeDelete(event);
                break;
            }
          },
        );
  }

  // ============================================================
  // INSERT
  // ============================================================

  void _handleRealtimeInsert(
      NotificationRealtimeEvent event,
      ) {
    final notification = event.notification;

    if (notification == null) {
      return;
    }

    setState(() {
      final exists = _notifications.any(
            (item) => item.id == notification.id,
      );

      if (!exists) {
        _notifications.insert(
          0,
          notification,
        );
      }
    });
  }

  // ============================================================
  // UPDATE
  // ============================================================

  void _handleRealtimeUpdate(
      NotificationRealtimeEvent event,
      ) {
    final notification = event.notification;

    if (notification == null) {
      return;
    }

    setState(() {
      final index = _notifications.indexWhere(
            (item) => item.id == notification.id,
      );

      if (index != -1) {
        _notifications[index] = notification;
      }
    });
  }

  // ============================================================
  // DELETE
  // ============================================================

  void _handleRealtimeDelete(
      NotificationRealtimeEvent event,
      ) {
    final notificationId =
        event.notificationId;

    if (notificationId == null) {
      return;
    }

    setState(() {
      _notifications.removeWhere(
            (notification) =>
        notification.id == notificationId,
      );
    });
  }

  // ============================================================
  // ACTUALISER
  // ============================================================

  Future<void> _refresh() async {
    await _loadNotifications();
  }

  // ============================================================
  // MARQUER COMME LUE
  // ============================================================

  Future<void> _markAsRead(
      NotificationModel notification,
      ) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _notificationService.markAsRead(
        notification.id,
      );

      if (!mounted) return;

      // On met à jour immédiatement l'interface.
      // Le Realtime UPDATE synchronisera ensuite les autres
      // composants de l'application.
      setState(() {
        final index = _notifications.indexWhere(
              (item) => item.id == notification.id,
        );

        if (index != -1) {
          _notifications[index] =
              notification.copyWith(
                isRead: true,
                readAt: DateTime.now(),
              );
        }
      });
    } catch (_) {
      _showError(
        'Impossible de modifier la notification.',
      );
    }
  }

  // ============================================================
  // TOUT MARQUER COMME LU
  // ============================================================

  Future<void> _markAllAsRead() async {
    if (_isMarkingAll) {
      return;
    }

    final unread = _notifications
        .where(
          (notification) =>
      !notification.isRead,
    )
        .toList();

    if (unread.isEmpty) {
      return;
    }

    setState(() {
      _isMarkingAll = true;
    });

    try {
      await _notificationService.markAllAsRead();

      if (!mounted) return;

      final now = DateTime.now();

      setState(() {
        _notifications =
            _notifications.map(
                  (notification) {
                return notification.copyWith(
                  isRead: true,
                  readAt: now,
                );
              },
            ).toList();

        _isMarkingAll = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isMarkingAll = false;
      });

      _showError(
        'Impossible de modifier les notifications.',
      );
    }
  }

  // ============================================================
  // SUPPRIMER
  // ============================================================

  Future<void> _deleteNotification(
      NotificationModel notification,
      ) async {
    try {
      await _notificationService.deleteNotification(
        notification.id,
      );

      if (!mounted) return;

      setState(() {
        _notifications.removeWhere(
              (item) => item.id == notification.id,
        );
      });
    } catch (_) {
      _showError(
        'Impossible de supprimer la notification.',
      );
    }
  }

  // ============================================================
  // FILTRE
  // ============================================================

  List<NotificationModel>
  get _filteredNotifications {
    switch (_selectedFilter) {
      case 'Non lues':
        return _notifications
            .where(
              (notification) =>
          !notification.isRead,
        )
            .toList();

      case 'Réservations':
        return _notifications
            .where(
              (notification) =>
          notification.type ==
              'reservation',
        )
            .toList();

      case 'Paiements':
        return _notifications
            .where(
              (notification) =>
          notification.type ==
              'payment',
        )
            .toList();

      case 'Appartements':
        return _notifications
            .where(
              (notification) =>
          notification.type ==
              'appartement_soumis' ||
              notification.type ==
                  'appartement_publie' ||
              notification.type ==
                  'appartement_refuse',
        )
            .toList();

      default:
        return _notifications;
    }
  }

  // ============================================================
  // COMPTEUR
  // ============================================================

  int get _unreadCount {
    return _notifications
        .where(
          (notification) =>
      !notification.isRead,
    )
        .length;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBg,
      body: Column(
        children: [
          // HEADER + BARRE SYSTÈME
          _buildHeader(),

          // CONTENU SOUS LE HEADER
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // FILTRES
                  _buildFilters(),

                  // ALERTE CERTIFICATION
                  if (!_isLoadingCertification && !_isCertified)
                    _buildCertificationAlert(),

                  // NOTIFICATIONS
                  Expanded(
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        20,
        topPadding + 20,
        20,
        22,
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: goldAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  color: goldAccent,
                  size: 25,
                ),
                if (_unreadCount > 0)
                  Positioned(
                    right: 7,
                    top: 6,
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 17,
                        minHeight: 17,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _unreadCount > 99
                            ? '99+'
                            : '$_unreadCount',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style: GoogleFonts.nunito(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _unreadCount == 0
                      ? 'Aucune notification non lue'
                      : '$_unreadCount notification'
                      '${_unreadCount > 1 ? 's' : ''} non lue'
                      '${_unreadCount > 1 ? 's' : ''}',
                  style: GoogleFonts.nunito(
                    fontSize: 13,
                    color: Colors.white.withValues(
                      alpha: 0.55,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_unreadCount > 0)
            TextButton(
              onPressed: _isMarkingAll
                  ? null
                  : _markAllAsRead,
              child: _isMarkingAll
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: goldAccent,
                ),
              )
                  : Text(
                'Tout lire',
                style: GoogleFonts.nunito(
                  color: goldAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // FILTRES
  Widget _buildFilters() {
    final filters = [
      'Toutes',
      'Non lues',
      'Réservations',
      'Paiements',
      'Appartements',
    ];

    return Container(
      width: double.infinity,
      color: AppColors.foreground,
      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12,
      ),
      child: SingleChildScrollView(
        scrollDirection:
        Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final selected =
                _selectedFilter == filter;

            return Padding(
              padding:
              const EdgeInsets.only(
                right: 8,
              ),
              child: ChoiceChip(
                label: Text(filter),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                },
                selectedColor:
                Color(0x56FF0000).withValues(
                  alpha: 0.12,
                ),
                backgroundColor:
                const Color(0xFFF4F6FB),
                side: BorderSide(
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                labelStyle:
                GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: selected
                      ? AppColors.primaryForeground
                      : textMuted,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // BODY
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    final notifications =
        _filteredNotifications;

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView.builder(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          14,
          16,
          30,
        ),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification =
          notifications[index];

          return _buildNotificationCard(
            notification,
          );
        },
      ),
    );
  }

  Widget _buildCertificationAlert() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        4,
      ),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8ED),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF4C46A),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8BF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: Color(0xFFD97706),
              size: 23,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compte non certifié',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'Votre compte n’est pas encore certifié. '
                      'Certifiez votre compte pour pouvoir publier '
                      'vos appartements et proposer vos biens à la '
                      'location sur DS APPARTS.',
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    height: 1.45,
                    color: const Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      widget.onNavigate(
                        AppPage.documents,
                      );
                    },
                    icon: const Icon(
                      Icons.verified_user_rounded,
                      size: 16,
                    ),
                    label: Text(
                      'Certifier mon compte',
                      style: GoogleFonts.nunito(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARD
  // ============================================================

  Widget _buildNotificationCard(
      NotificationModel notification,
      ) {
    return Dismissible(
      key: ValueKey(notification.id),
      direction:
      DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteNotification(
          notification,
        );

        return false;
      },
      background: Container(
        margin:
        const EdgeInsets.only(bottom: 10),
        alignment:
        Alignment.centerRight,
        padding:
        const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius:
          BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Colors.red,
        ),
      ),
      child: GestureDetector(
        onTap: () async {
          await _markAsRead(
            notification,
          );

          _handleNotificationTap(
            notification,
          );
        },
        child: AnimatedContainer(
          duration:
          const Duration(milliseconds: 200),
          margin:
          const EdgeInsets.only(bottom: 10),
          padding:
          const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : const Color(0xFFF8FAFF),
            borderRadius:
            BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xFFE9EDF4)
                  : AppColors.primary.withValues(
                alpha: 0.18,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: notification.isRead
                      ? 0.035
                      : 0.06,
                ),
                blurRadius:
                notification.isRead
                    ? 7
                    : 12,
                offset:
                const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(
                notification,
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style:
                            GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight:
                              notification
                                  .isRead
                                  ? FontWeight
                                  .w600
                                  : FontWeight
                                  .bold,
                              color: textDark,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(
                          _formatDate(
                            notification
                                .createdAt,
                          ),
                          style:
                          GoogleFonts.nunito(
                            fontSize: 10,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style:
                      GoogleFonts.nunito(
                        fontSize: 12.5,
                        height: 1.45,
                        fontWeight:
                        notification.isRead
                            ? FontWeight
                            .normal
                            : FontWeight
                            .w500,
                        color:
                        notification.isRead
                            ? textMuted
                            : textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeBadge(
                          notification,
                        ),
                        if (notification
                            .isHighPriority) ...[
                          const SizedBox(
                            width: 7,
                          ),
                          _buildPriorityBadge(
                            notification,
                          ),
                        ],
                        const Spacer(),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration:
                            const BoxDecoration(
                              color:
                              AppColors.primary,
                              shape:
                              BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICÔNE
  // ============================================================

  Widget _buildNotificationIcon(
      NotificationModel notification,
      ) {
    IconData icon;
    Color background;
    Color foreground;

    switch (notification.type) {
      case 'reservation':
        icon =
            Icons.calendar_month_rounded;
        background =
            Colors.blue.withValues(
              alpha: 0.10,
            );
        foreground = Colors.blue;
        break;

      case 'payment':
        icon =
            Icons.payments_outlined;
        background =
            Colors.green.withValues(
              alpha: 0.10,
            );
        foreground =
            Colors.green.shade700;
        break;

      case 'certification':
        icon =
            Icons.verified_user_outlined;
        background =
            Colors.purple.withValues(
              alpha: 0.10,
            );
        foreground = Colors.purple;
        break;

      case 'photo':
        icon =
            Icons.photo_camera_outlined;
        background =
            Colors.orange.withValues(
              alpha: 0.10,
            );
        foreground =
            Colors.orange.shade800;
        break;

      case 'message':
        icon =
            Icons.chat_bubble_outline_rounded;
        background =
            Colors.indigo.withValues(
              alpha: 0.10,
            );
        foreground = Colors.indigo;
        break;

      case 'promotion':
        icon =
            Icons.local_offer_outlined;
        background =
            Colors.pink.withValues(
              alpha: 0.10,
            );
        foreground = Colors.pink;
        break;

      case 'appartement_soumis':
        icon =
            Icons.home_work_outlined;
        background =
            Colors.orange.withValues(
              alpha: 0.10,
            );
        foreground =
            Colors.orange.shade800;
        break;

      case 'appartement_publie':
        icon =
            Icons.home_work_rounded;
        background =
            Colors.green.withValues(
              alpha: 0.10,
            );
        foreground =
            Colors.green.shade700;
        break;

      case 'appartement_refuse':
        icon =
            Icons.home_work_outlined;
        background =
            Colors.red.withValues(
              alpha: 0.10,
            );
        foreground =
            Colors.red.shade700;
        break;

      case 'info':
        icon =
            Icons.info_outline_rounded;
        background =
            Colors.blueGrey.withValues(
              alpha: 0.10,
            );
        foreground = Colors.blueGrey;
        break;

      case 'system':
      default:
        icon =
            Icons.notifications_none_rounded;
        background =
            goldAccent.withValues(
              alpha: 0.12,
            );
        foreground = goldAccent;
        break;
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: background,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: foreground,
        size: 21,
      ),
    );
  }

  // ============================================================
  // BADGE TYPE
  // ============================================================

  Widget _buildTypeBadge(
      NotificationModel notification,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color:
        const Color(0xFFF1F4F8),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Text(
        notification.title,
        style: GoogleFonts.nunito(
          fontSize: 9.5,
          fontWeight:
          FontWeight.w700,
          color: textMuted,
        ),
      ),
    );
  }

  // ============================================================
  // BADGE PRIORITÉ
  // ============================================================

  Widget _buildPriorityBadge(
      NotificationModel notification,
      ) {
    final isUrgent =
        notification.priority ==
            'urgent';

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.red.withValues(
          alpha: 0.10,
        )
            : Colors.orange.withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(8),
      ),
      child: Text(
        notification.priorityLabel,
        style: GoogleFonts.nunito(
          fontSize: 9.5,
          fontWeight:
          FontWeight.w700,
          color: isUrgent
              ? Colors.red.shade700
              : Colors.orange.shade800,
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    String title;
    String message;

    if (_selectedFilter == 'Non lues') {
      title = 'Tout est à jour';
      message =
      'Vous n’avez aucune notification non lue.';
    } else {
      title = 'Aucune notification';
      message =
      'Vous n’avez pas encore reçu de notification.';
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.25,
          ),
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration:
              BoxDecoration(
                color:
                AppColors.primary.withValues(
                  alpha: 0.08,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 38,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 18,
                fontWeight:
                FontWeight.bold,
                color: textDark,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 40,
            ),
            child: Text(
              message,
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.nunito(
                fontSize: 13,
                color: textMuted,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CLICK NOTIFICATION
  // ============================================================

  void _handleNotificationTap(
      NotificationModel notification,
      ) {
    final metadata =
        notification.metadata;

    debugPrint(
      'Notification sélectionnée : '
          '${notification.type}',
    );

    debugPrint(
      'Metadata : $metadata',
    );

    /*
     * La navigation pourra être branchée ici.
     *
     * Exemple owner_app :
     *
     * reservation
     *     -> ReservationsPage
     *
     * appartement_publie
     *     -> DetailsAppartementPage
     *
     * appartement_refuse
     *     -> DetailsAppartementPage
     */
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final now = DateTime.now();

    final difference =
    now.difference(date);

    if (difference.inSeconds < 60) {
      return 'À l’instant';
    }

    if (difference.inMinutes < 60) {
      return 'Il y a '
          '${difference.inMinutes} min';
    }

    if (difference.inHours < 24) {
      return 'Il y a '
          '${difference.inHours} h';
    }

    if (difference.inDays == 1) {
      return 'Hier';
    }

    if (difference.inDays < 7) {
      return 'Il y a '
          '${difference.inDays} j';
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  // ============================================================
  // ERREUR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.nunito(
            color: Colors.white,
          ),
        ),
        backgroundColor:
        Colors.red.shade700,
        behavior:
        SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(12),
        ),
      ),
    );
  }
}