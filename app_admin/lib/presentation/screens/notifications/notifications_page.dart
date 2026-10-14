import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_service.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({
    super.key,
  });

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final NotificationService _notificationService =
  NotificationService();

  StreamSubscription<NotificationRealtimeEvent>?
  _notificationSubscription;

  // ============================================================
  // DONNÉES
  // ============================================================

  List<Map<String, dynamic>> _notifications = [];

  bool _isLoading = true;
  bool _isRefreshing = false;

  String _selectedFilter = 'Toutes';

  final List<String> _filters = [
    'Toutes',
    'Non lues',
    'Résidences',
    'Appartements',
    'Réservations',
    'Système',
  ];

  // ============================================================
  // ROUTE DE LA PAGE DES BIENS ADMIN
  // ============================================================
  //
  // Cette route doit afficher PropertyListScreen.
  //
  // PropertyListScreen reçoit :
  //
  // initialResidenceId
  // initialAppartementId
  //
  // afin d'ouvrir automatiquement :
  //
  // Résidence
  //    ↓
  // Appartement
  //
  // ============================================================

// ============================================================
// ROUTE PROPERTY LIST (dynamique selon la ville)
// ============================================================

  String _buildPropertyListRoute(String ville) {
    final normalizedCity = ville
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(' ', '_');

    return '/list_appart_$normalizedCity';
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadNotifications();
    _startRealtime();
  }

  // ============================================================
  // CHARGEMENT
  // ============================================================

  Future<void> _loadNotifications() async {
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

  // ============================================================
  // REALTIME
  // ============================================================

  Future<void> _startRealtime() async {
    try {
      await _notificationService.startRealtime();

      _notificationSubscription =
          _notificationService.events.listen(
            _handleRealtimeEvent,
          );
    } catch (e) {
      debugPrint(
        '⚠️ Erreur initialisation realtime notifications : $e',
      );
    }
  }

  void _handleRealtimeEvent(
      NotificationRealtimeEvent event,
      ) {
    if (!mounted) return;

    setState(() {
      switch (event.type) {
      // ======================================================
      // INSERTION
      // ======================================================

        case NotificationRealtimeType.inserted:
          final notification = event.notification;

          if (notification == null) return;

          final id = notification['id']?.toString();

          final exists = _notifications.any(
                (item) => item['id']?.toString() == id,
          );

          if (!exists) {
            _notifications.insert(
              0,
              notification,
            );
          }

          break;

      // ======================================================
      // MODIFICATION
      // ======================================================

        case NotificationRealtimeType.updated:
          final notification = event.notification;

          if (notification == null) return;

          final id = notification['id']?.toString();

          final index = _notifications.indexWhere(
                (item) => item['id']?.toString() == id,
          );

          if (index != -1) {
            _notifications[index] = notification;
          }

          break;

      // ======================================================
      // SUPPRESSION
      // ======================================================

        case NotificationRealtimeType.deleted:
          final id = event.notificationId;

          if (id == null) return;

          _notifications.removeWhere(
                (item) => item['id']?.toString() == id,
          );

          break;
      }
    });
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      final notifications =
      await _notificationService.getNotifications();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isRefreshing = false;
      });

      _showError(
        'Erreur lors de l’actualisation.',
      );
    }
  }

  // ============================================================
  // NOTIFICATIONS FILTRÉES
  // ============================================================

  List<Map<String, dynamic>> get _filteredNotifications {
    switch (_selectedFilter) {
    // --------------------------------------------------------
    // NON LUES
    // --------------------------------------------------------

      case 'Non lues':
        return _notifications
            .where(
              (notification) =>
          notification['is_read'] != true,
        )
            .toList();

    // --------------------------------------------------------
    // RÉSIDENCES
    // --------------------------------------------------------

      case 'Résidences':
        return _notifications.where((notification) {
          final type =
              notification['type']?.toString() ?? '';

          return type == 'residence_soumise' ||
              type == 'residence_validee' ||
              type == 'residence_refusee';
        }).toList();

    // --------------------------------------------------------
    // APPARTEMENTS
    // --------------------------------------------------------

      case 'Appartements':
        return _notifications.where((notification) {
          final type =
              notification['type']?.toString() ?? '';

          return type == 'appartement_soumis' ||
              type == 'appartement_publie' ||
              type == 'appartement_refuse';
        }).toList();

    // --------------------------------------------------------
    // RÉSERVATIONS
    // --------------------------------------------------------

      case 'Réservations':
        return _notifications.where((notification) {
          final type =
              notification['type']?.toString() ?? '';

          return type == 'reservation';
        }).toList();

    // --------------------------------------------------------
    // SYSTÈME
    // --------------------------------------------------------

      case 'Système':
        return _notifications.where((notification) {
          final type =
              notification['type']?.toString() ?? '';

          return type == 'system' ||
              type == 'info' ||
              type == 'message' ||
              type == 'certification' ||
              type == 'payment' ||
              type == 'photo' ||
              type == 'promotion';
        }).toList();

      default:
        return _notifications;
    }
  }

  // ============================================================
  // NOMBRE DE NON LUES
  // ============================================================

  int get _unreadCount {
    return _notifications
        .where(
          (notification) =>
      notification['is_read'] != true,
    )
        .length;
  }

  // ============================================================
  // MARQUER UNE NOTIFICATION COMME LUE
  // ============================================================

  Future<void> _markAsRead(
      Map<String, dynamic> notification,
      ) async {
    final id = notification['id']?.toString();

    if (id == null ||
        notification['is_read'] == true) {
      return;
    }

    // ----------------------------------------------------------
    // Mise à jour optimiste
    // ----------------------------------------------------------

    setState(() {
      final index = _notifications.indexWhere(
            (item) => item['id']?.toString() == id,
      );

      if (index != -1) {
        _notifications[index] = {
          ..._notifications[index],
          'is_read': true,
        };
      }
    });

    try {
      await _notificationService.markAsRead(id);
    } catch (e) {
      _showError(
        'Impossible de marquer la notification comme lue.',
      );

      await _refresh();
    }
  }

  // ============================================================
  // MARQUER TOUTES COMME LUES
  // ============================================================

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) return;

    try {
      await _notificationService.markAllAsRead();

      await _refresh();
    } catch (e) {
      _showError(
        'Impossible de marquer toutes les notifications comme lues.',
      );
    }
  }

  // ============================================================
  // SUPPRESSION
  // ============================================================

  Future<void> _deleteNotification(
      Map<String, dynamic> notification,
      ) async {
    final id = notification['id']?.toString();

    if (id == null) return;

    // ----------------------------------------------------------
    // Suppression optimiste
    // ----------------------------------------------------------

    setState(() {
      _notifications.removeWhere(
            (item) => item['id']?.toString() == id,
      );
    });

    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      _showError(
        'Impossible de supprimer la notification.',
      );

      await _refresh();
    }
  }

  // ============================================================
  // SUPPRIMER TOUTES
  // ============================================================

  Future<void> _deleteAllNotifications() async {
    if (_notifications.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111622),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Text(
            'Supprimer les notifications ?',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Toutes les notifications seront supprimées.',
            style: GoogleFonts.manrope(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Annuler',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Supprimer',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _notificationService
          .deleteAllNotifications();

      if (!mounted) return;

      setState(() {
        _notifications.clear();
      });
    } catch (e) {
      _showError(
        'Impossible de supprimer les notifications.',
      );
    }
  }

  // ============================================================
  // ICÔNES
  // ============================================================

  IconData _getNotificationIcon(
      String? type,
      ) {
    switch (type) {
    // --------------------------------------------------------
    // RÉSIDENCES
    // --------------------------------------------------------

      case 'residence_soumise':
        return Icons.apartment_rounded;

      case 'residence_validee':
        return Icons.domain_rounded;

      case 'residence_refusee':
        return Icons.domain_disabled_rounded;

    // --------------------------------------------------------
    // APPARTEMENTS
    // --------------------------------------------------------

      case 'appartement_soumis':
        return Icons.home_work_rounded;

      case 'appartement_publie':
        return Icons.home_rounded;

      case 'appartement_refuse':
        return Icons.home_work_outlined;

    // --------------------------------------------------------
    // AUTRES
    // --------------------------------------------------------

      case 'reservation':
        return Icons.calendar_month_rounded;

      case 'payment':
        return Icons.payments_rounded;

      case 'certification':
        return Icons.verified_rounded;

      case 'photo':
        return Icons.photo_library_rounded;

      case 'message':
        return Icons.message_rounded;

      case 'promotion':
        return Icons.local_offer_rounded;

      case 'info':
        return Icons.info_rounded;

      case 'system':
        return Icons.settings_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  // ============================================================
  // COULEUR PRIORITÉ
  // ============================================================

  Color _getPriorityColor(
      String? priority,
      ) {
    switch (priority) {
      case 'urgent':
        return Colors.red;

      case 'high':
        return Colors.orange;

      case 'low':
        return Colors.grey;

      default:
        return const Color(0xFFFFC107);
    }
  }

  // ============================================================
  // TITRE NOTIFICATION
  // ============================================================

  String _getNotificationTitle(
      String? type,
      ) {
    switch (type) {
    // --------------------------------------------------------
    // RÉSIDENCES
    // --------------------------------------------------------

      case 'residence_soumise':
        return 'Résidence soumise';

      case 'residence_validee':
        return 'Résidence validée';

      case 'residence_refusee':
        return 'Résidence refusée';

    // --------------------------------------------------------
    // APPARTEMENTS
    // --------------------------------------------------------

      case 'appartement_soumis':
        return 'Appartement soumis';

      case 'appartement_publie':
        return 'Appartement publié';

      case 'appartement_refuse':
        return 'Appartement refusé';

    // --------------------------------------------------------
    // AUTRES
    // --------------------------------------------------------

      case 'reservation':
        return 'Réservation';

      case 'payment':
        return 'Paiement';

      case 'certification':
        return 'Certification';

      case 'photo':
        return 'Photos';

      case 'message':
        return 'Message';

      case 'promotion':
        return 'Promotion';

      case 'info':
        return 'Information';

      case 'system':
        return 'Système';

      default:
        return 'Notification';
    }
  }

  // ============================================================
  // EXTRACTION DES METADATA
  // ============================================================

  Map<String, dynamic> _getMetadata(
      Map<String, dynamic> notification,
      ) {
    final metadata = notification['metadata'];

    if (metadata is Map) {
      return Map<String, dynamic>.from(
        metadata,
      );
    }

    return {};
  }

  // ============================================================
  // OUVRIR UNE RÉSIDENCE
  // ============================================================

  Future<void> _openResidence({
    required String residenceId,
    String? appartementId,
  }) async {
    if (residenceId.isEmpty) {
      _showError('Identifiant de résidence manquant.');
      return;
    }

    try {
      // ✅ Récupérer la ville de la résidence pour construire la route
      final residence = await Supabase.instance.client
          .from('residences')
          .select('id, ville')
          .eq('id', residenceId)
          .maybeSingle();

      if (residence == null) {
        _showError('Résidence introuvable.');
        return;
      }

      final ville = residence['ville']?.toString() ?? 'Bamako';
      final route = _buildPropertyListRoute(ville);

      debugPrint('🏢 Ouverture résidence');
      debugPrint('➡️ ville = $ville');
      debugPrint('➡️ route = $route');
      debugPrint('➡️ residenceId = $residenceId');
      debugPrint('➡️ appartementId = $appartementId (ignoré pour auto-ouverture)');

      if (!mounted) return;

      final navigator = Navigator.of(context);

      // Fermer le modal notifications
      navigator.pop();

      // Attendre un frame pour éviter les conflits de navigation
      await Future.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      // ✅ Redirection avec focusResidenceId (reste sur la LISTE - image 3)
      navigator.pushNamed(
        route,
        arguments: {
          'focusResidenceId': residenceId,
        },
      );
    } catch (e, st) {
      debugPrint('❌ Erreur _openResidence : $e');
      debugPrint('$st');
      _showError('Impossible d’ouvrir la résidence.');
    }
  }

  // ============================================================
  // NOTIFICATION RÉSIDENCE
  // ============================================================

  Future<void> _handleResidenceNotification(
      Map<String, dynamic> notification,
      ) async {
    final data = _getMetadata(notification);

    String? residenceId =
    data['residence_id']?.toString();

    // ----------------------------------------------------------
    // Si metadata absente → récupérer depuis link
    // ----------------------------------------------------------

    if (residenceId == null ||
        residenceId.isEmpty) {
      final link =
      notification['link']?.toString();

      residenceId =
          _extractUuidFromLink(
            link,
          );
    }

    if (residenceId == null ||
        residenceId.isEmpty) {
      debugPrint(
        '⚠️ Notification résidence sans residence_id',
      );

      _showError(
        'Cette notification ne contient pas l’identifiant de la résidence.',
      );

      return;
    }

    debugPrint(
      '🏢 RESIDENCE NOTIFICATION',
    );

    debugPrint(
      '➡️ metadata = $data',
    );

    await _openResidence(
      residenceId: residenceId,
    );
  }

  // ============================================================
  // NOTIFICATION APPARTEMENT
  // ============================================================

  Future<void> _handleAppartementNotification(
      Map<String, dynamic> notification,
      ) async {
    final data = _getMetadata(notification);

    String? appartementId =
    data['appartement_id']?.toString();

    String? residenceId =
    data['residence_id']?.toString();

    debugPrint(
      '🏠 NOTIFICATION APPARTEMENT',
    );

    debugPrint(
      '➡️ appartementId = $appartementId',
    );

    debugPrint(
      '➡️ residenceId = $residenceId',
    );

    debugPrint(
      '➡️ metadata = $data',
    );

    // ----------------------------------------------------------
    // Vérification appartement
    // ----------------------------------------------------------

    if (appartementId == null ||
        appartementId.isEmpty) {
      debugPrint(
        '⚠️ Notification appartement sans appartement_id',
      );

      _showError(
        'Cette notification ne contient pas l’identifiant du bien.',
      );

      return;
    }

    try {
      // --------------------------------------------------------
      // Si residence_id absent dans metadata,
      // on le récupère directement depuis l'appartement.
      // --------------------------------------------------------

      if (residenceId == null ||
          residenceId.isEmpty) {
        final appartement =
        await Supabase.instance.client
            .from('appartements')
            .select(
          'id, residence_id',
        )
            .eq(
          'id',
          appartementId,
        )
            .maybeSingle();

        if (appartement == null) {
          debugPrint(
            '⚠️ Appartement introuvable : $appartementId',
          );

          _showError(
            'Le bien concerné par cette notification est introuvable.',
          );

          return;
        }

        residenceId =
            appartement['residence_id']
                ?.toString();

        debugPrint(
          '🔎 residence_id récupéré depuis appartements = $residenceId',
        );
      }

      // --------------------------------------------------------
      // L'appartement doit appartenir à une résidence
      // pour suivre la nouvelle navigation admin.
      // --------------------------------------------------------

      if (residenceId == null ||
          residenceId.isEmpty) {
        debugPrint(
          '⚠️ Appartement sans résidence.',
        );

        _showError(
          'Cet appartement n’est rattaché à aucune résidence.',
        );

        return;
      }

      // --------------------------------------------------------
      // Navigation :
      //
      // Résidence
      //     ↓
      // Appartement
      // --------------------------------------------------------

      await _openResidence(
        residenceId: residenceId,
        appartementId: appartementId,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Erreur ouverture notification appartement : $e',
      );

      debugPrint(
        '$stackTrace',
      );

      _showError(
        'Impossible d’ouvrir le bien concerné.',
      );
    }
  }

  // ============================================================
// CERTIFICATION
// ============================================================

  Future<void> _handleCertificationNotification(
      Map<String, dynamic> notification,
      ) async {
    final data = _getMetadata(notification);

    String? userId = data['user_id']?.toString();
    String? documentId = data['document_id']?.toString();

    debugPrint('🔔 CERTIFICATION NOTIFICATION');
    debugPrint('➡️ userId = $userId');
    debugPrint('➡️ documentId = $documentId');
    debugPrint('➡️ metadata = $data');

    // ----------------------------------------------------------
    // FALLBACK 1 : extraire depuis le link si metadata absente
    // Format attendu : /owners?userId=xxx&documentId=yyy
    // ----------------------------------------------------------

    if (userId == null || userId.isEmpty) {
      final link = notification['link']?.toString();

      if (link != null && link.isNotEmpty) {
        final uri = Uri.tryParse(link);

        userId = uri?.queryParameters['userId'];
        documentId ??= uri?.queryParameters['documentId'];

        debugPrint('🔎 userId extrait du link = $userId');
        debugPrint('🔎 documentId extrait du link = $documentId');
      }
    }

    // ----------------------------------------------------------
    // VÉRIFICATION FINALE
    // ----------------------------------------------------------

    if (userId == null || userId.isEmpty) {
      debugPrint('⚠️ Notification certification sans user_id');

      _showError(
        'Cette notification ne contient pas l’utilisateur concerné.',
      );

      return;
    }

    // ----------------------------------------------------------
    // Rôle : metadata puis fallback DB
    // ----------------------------------------------------------

    String? role = data['role']
        ?.toString()
        .trim()
        .toLowerCase();

    if (role == null || role.isEmpty) {
      try {
        final user = await Supabase.instance.client
            .from('users')
            .select('role')
            .eq('id', userId)
            .maybeSingle();

        role = user?['role']
            ?.toString()
            .trim()
            .toLowerCase();

        debugPrint('🔎 Rôle récupéré depuis users = $role');
      } catch (e) {
        debugPrint('❌ Impossible de récupérer le rôle : $e');

        _showError(
          'Impossible d’identifier le type d’utilisateur.',
        );

        return;
      }
    }

    debugPrint('➡️ role final = $role');

    // ----------------------------------------------------------
    // Choix de la route
    // ----------------------------------------------------------

    String? route;

    if (role == 'proprietaire') {
      route = '/owners';
    } else if (role == 'locataire') {
      route = '/users';
    } else {
      debugPrint('⚠️ Rôle utilisateur invalide : $role');

      _showError(
        'Le rôle de cet utilisateur est invalide.',
      );

      return;
    }

    debugPrint('➡️ ROUTE CHOISIE = $route');

    // ----------------------------------------------------------
    // Navigation
    // ----------------------------------------------------------

    if (!mounted) return;

    Navigator.of(context).pushNamed(
      route,
      arguments: {
        'userId': userId,
        if (documentId != null && documentId.isNotEmpty)
          'documentId': documentId,
      },
    );
  }

  // ============================================================
  // EXTRAIRE UUID DEPUIS UN LINK
  // ============================================================

  String? _extractUuidFromLink(
      String? link,
      ) {
    if (link == null ||
        link.trim().isEmpty) {
      return null;
    }

    final parts = link
        .split('/')
        .where(
          (part) => part.trim().isNotEmpty,
    )
        .toList();

    if (parts.isEmpty) return null;

    final candidate = parts.last.trim();

    // UUID standard
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[1-5][0-9a-fA-F]{3}-'
      r'[89abAB][0-9a-fA-F]{3}-'
      r'[0-9a-fA-F]{12}$',
    );

    if (uuidRegex.hasMatch(candidate)) {
      return candidate;
    }

    return null;
  }

  // ============================================================
  // CLICK NOTIFICATION
  // ============================================================

  Future<void> _handleNotificationTap(
      Map<String, dynamic> notification,
      ) async {
    // ----------------------------------------------------------
    // Marquer comme lue
    // ----------------------------------------------------------

    await _markAsRead(
      notification,
    );

    if (!mounted) return;

    final type =
    notification['type']?.toString();

    final link =
    notification['link']?.toString();

    debugPrint(
      '🔔 Notification cliquée',
    );

    debugPrint(
      '➡️ type = $type',
    );

    debugPrint(
      '➡️ link = $link',
    );

    // ==========================================================
    // CERTIFICATION
    // ==========================================================

    if (type == 'certification') {
      await _handleCertificationNotification(
        notification,
      );

      return;
    }

    // ==========================================================
    // RÉSIDENCE
    // ==========================================================

    if (type == 'residence_soumise' ||
        type == 'residence_validee' ||
        type == 'residence_refusee') {
      await _handleResidenceNotification(
        notification,
      );

      return;
    }

    // ==========================================================
    // APPARTEMENT
    // ==========================================================

    if (type == 'appartement_soumis' ||
        type == 'appartement_publie' ||
        type == 'appartement_refuse') {
      await _handleAppartementNotification(
        notification,
      );

      return;
    }

    // ==========================================================
    // AUTRES NOTIFICATIONS
    // ==========================================================

    if (link != null &&
        link.isNotEmpty) {
      debugPrint(
        '🔗 Notification avec lien : $link',
      );
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
      dynamic value,
      ) {
    if (value == null) {
      return '';
    }

    try {
      final date =
      DateTime.parse(
        value.toString(),
      ).toLocal();

      final now =
      DateTime.now();

      final difference =
      now.difference(date);

      if (difference.inSeconds < 60) {
        return 'À l’instant';
      }

      if (difference.inMinutes < 60) {
        return 'Il y a ${difference.inMinutes} min';
      }

      if (difference.inHours < 24) {
        return 'Il y a ${difference.inHours} h';
      }

      if (difference.inDays == 1) {
        return 'Hier';
      }

      if (difference.inDays < 7) {
        return 'Il y a ${difference.inDays} jours';
      }

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return '';
    }
  }

  // ============================================================
  // MESSAGE ERREUR
  // ============================================================

  void _showError(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.manrope(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Center(
          child: Container(
            width: _getModalWidth(context),
            height: _getModalHeight(context),
            margin: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 20.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF090D16),
              borderRadius: BorderRadius.circular(
                22.r,
              ),
              border: Border.all(
                color: Colors.white.withValues(
                  alpha: 0.08,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.45,
                  ),
                  blurRadius: 35,
                  spreadRadius: 5,
                  offset: const Offset(
                    0,
                    15,
                  ),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildHeader(),
                _buildFilters(),
                Expanded(
                  child:
                  _buildNotificationContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20.w,
        18.h,
        12.w,
        12.h,
      ),
      child: Row(
        children: [
          // ------------------------------------------------------
          // ICÔNE
          // ------------------------------------------------------

          Container(
            padding: EdgeInsets.all(
              11.w,
            ),
            decoration: BoxDecoration(
              color:
              const Color(0xFFFFC107)
                  .withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(
                13.r,
              ),
            ),
            child: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFFFFC107),
            ),
          ),

          SizedBox(
            width: 12.w,
          ),

          // ------------------------------------------------------
          // TITRE
          // ------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Notifications',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 21.sp,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 3.h,
                ),
                Text(
                  _unreadCount == 0
                      ? 'Aucune notification non lue'
                      : '$_unreadCount notification'
                      '${_unreadCount > 1 ? 's' : ''} non lue'
                      '${_unreadCount > 1 ? 's' : ''}',
                  style:
                  GoogleFonts.manrope(
                    color: Colors.white54,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),

          // ------------------------------------------------------
          // ACTUALISER
          // ------------------------------------------------------

          IconButton(
            tooltip: 'Actualiser',
            onPressed:
            _isRefreshing
                ? null
                : _refresh,
            icon: _isRefreshing
                ? const SizedBox(
              width: 18,
              height: 18,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
                color:
                Color(0xFFFFC107),
              ),
            )
                : const Icon(
              Icons.refresh_rounded,
              color: Colors.white70,
            ),
          ),

          // ------------------------------------------------------
          // TOUT LIRE
          // ------------------------------------------------------

          if (_unreadCount > 0)
            IconButton(
              tooltip:
              'Tout marquer comme lu',
              onPressed:
              _markAllAsRead,
              icon: const Icon(
                Icons.done_all_rounded,
                color:
                Color(0xFFFFC107),
              ),
            ),

          // ------------------------------------------------------
          // SUPPRIMER TOUT
          // ------------------------------------------------------

          if (_notifications.isNotEmpty)
            IconButton(
              tooltip:
              'Tout supprimer',
              onPressed:
              _deleteAllNotifications,
              icon: const Icon(
                Icons.delete_sweep_rounded,
                color:
                Colors.redAccent,
              ),
            ),

          // ------------------------------------------------------
          // FERMER
          // ------------------------------------------------------

          IconButton(
            tooltip: 'Fermer',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FILTRES
  // ============================================================

  Widget _buildFilters() {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection:
        Axis.horizontal,
        padding:
        EdgeInsets.symmetric(
          horizontal: 20.w,
        ),
        itemCount:
        _filters.length,
        separatorBuilder:
            (_, __) =>
            SizedBox(
              width: 8.w,
            ),
        itemBuilder:
            (context, index) {
          final filter =
          _filters[index];

          final selected =
              filter ==
                  _selectedFilter;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter =
                    filter;
              });
            },
            child:
            AnimatedContainer(
              duration:
              const Duration(
                milliseconds: 200,
              ),
              padding:
              EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration:
              BoxDecoration(
                color: selected
                    ? const Color(
                  0xFFFFC107,
                )
                    : const Color(
                  0xFF111622,
                ),
                borderRadius:
                BorderRadius.circular(
                  20.r,
                ),
                border:
                Border.all(
                  color: selected
                      ? const Color(
                    0xFFFFC107,
                  )
                      : Colors.white
                      .withValues(
                    alpha: 0.06,
                  ),
                ),
              ),
              child: Text(
                filter,
                style:
                GoogleFonts.manrope(
                  color: selected
                      ? Colors.black
                      : Colors.white70,
                  fontSize: 12.sp,
                  fontWeight: selected
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CARD NOTIFICATION
  // ============================================================

  Widget _buildNotificationCard(
      Map<String, dynamic> notification,
      ) {
    final bool isRead =
        notification['is_read'] == true;

    final type =
    notification['type']?.toString();

    final priority =
    notification['priority']?.toString();

    final message =
        notification['message']
            ?.toString() ??
            'Nouvelle notification';

    final createdAt =
    notification['created_at'];

    final priorityColor =
    _getPriorityColor(
      priority,
    );

    return Material(
      color: Colors.transparent,
      borderRadius:
      BorderRadius.circular(
        16.r,
      ),
      child:
      AnimatedContainer(
        duration:
        const Duration(
          milliseconds: 200,
        ),
        decoration:
        BoxDecoration(
          color: isRead
              ? const Color(
            0xFF111622,
          )
              : const Color(
            0xFF151B29,
          ),
          borderRadius:
          BorderRadius.circular(
            16.r,
          ),
          border:
          Border.all(
            color: isRead
                ? Colors.white
                .withValues(
              alpha: 0.05,
            )
                : const Color(
              0xFFFFC107,
            ).withValues(
              alpha: 0.35,
            ),
          ),
        ),
        child: InkWell(
          borderRadius:
          BorderRadius.circular(
            16.r,
          ),
          onTap: () =>
              _handleNotificationTap(
                notification,
              ),
          child: Padding(
            padding:
            EdgeInsets.all(
              16.w,
            ),
            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment
                  .start,
              children: [
                // ------------------------------------------------
                // ICÔNE
                // ------------------------------------------------

                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration:
                  BoxDecoration(
                    color:
                    priorityColor
                        .withValues(
                      alpha: 0.12,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      13.r,
                    ),
                  ),
                  child: Icon(
                    _getNotificationIcon(
                      type,
                    ),
                    color:
                    priorityColor,
                    size: 22.sp,
                  ),
                ),

                SizedBox(
                  width: 13.w,
                ),

                // ------------------------------------------------
                // CONTENU
                // ------------------------------------------------

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getNotificationTitle(
                                type,
                              ),
                              style:
                              GoogleFonts.manrope(
                                color:
                                Colors.white,
                                fontSize:
                                14.sp,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!isRead)
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration:
                              const BoxDecoration(
                                color:
                                Color(
                                  0xFFFFC107,
                                ),
                                shape:
                                BoxShape
                                    .circle,
                              ),
                            ),
                        ],
                      ),

                      SizedBox(
                        height: 6.h,
                      ),

                      Text(
                        message,
                        style:
                        GoogleFonts.manrope(
                          color:
                          Colors.white70,
                          fontSize:
                          12.sp,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(
                        height: 9.h,
                      ),

                      Text(
                        _formatDate(
                          createdAt,
                        ),
                        style:
                        GoogleFonts.manrope(
                          color:
                          Colors.white38,
                          fontSize:
                          10.sp,
                        ),
                      ),
                    ],
                  ),
                ),

                // ------------------------------------------------
                // MENU
                // ------------------------------------------------

                PopupMenuButton<
                    String>(
                  color:
                  const Color(
                    0xFF111622,
                  ),
                  icon:
                  const Icon(
                    Icons
                        .more_vert_rounded,
                    color:
                    Colors.white38,
                  ),
                  onSelected:
                      (value) async {
                    if (value ==
                        'read') {
                      await _markAsRead(
                        notification,
                      );
                    }

                    if (value ==
                        'delete') {
                      await _deleteNotification(
                        notification,
                      );
                    }
                  },
                  itemBuilder:
                      (_) => [
                    if (!isRead)
                      const PopupMenuItem(
                        value:
                        'read',
                        child: Text(
                          'Marquer comme lue',
                          style:
                          TextStyle(
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    const PopupMenuItem(
                      value:
                      'delete',
                      child: Text(
                        'Supprimer',
                        style:
                        TextStyle(
                          color:
                          Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ÉTAT VIDE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        EdgeInsets.all(
          30.w,
        ),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              padding:
              EdgeInsets.all(
                22.w,
              ),
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFFFC107,
                ).withValues(
                  alpha: 0.08,
                ),
                shape:
                BoxShape.circle,
              ),
              child: Icon(
                Icons
                    .notifications_off_outlined,
                color:
                Colors.white24,
                size: 50.sp,
              ),
            ),

            SizedBox(
              height: 18.h,
            ),

            Text(
              'Aucune notification',
              style:
              GoogleFonts.manrope(
                color:
                Colors.white,
                fontSize:
                18.sp,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            SizedBox(
              height: 7.h,
            ),

            Text(
              'Les nouvelles notifications apparaîtront ici automatiquement.',
              textAlign:
              TextAlign.center,
              style:
              GoogleFonts.manrope(
                color:
                Colors.white38,
                fontSize:
                12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CONTENU
  // ============================================================

  Widget _buildNotificationContent() {
    final notifications =
        _filteredNotifications;

    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          Color(0xFFFFC107),
        ),
      );
    }

    if (notifications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      color:
      const Color(0xFFFFC107),
      backgroundColor:
      const Color(0xFF111622),
      onRefresh:
      _refresh,
      child:
      ListView.separated(
        physics:
        const BouncingScrollPhysics(),
        padding:
        EdgeInsets.fromLTRB(
          20.w,
          12.h,
          20.w,
          30.h,
        ),
        itemCount:
        notifications.length,
        separatorBuilder:
            (_, __) =>
            SizedBox(
              height: 10.h,
            ),
        itemBuilder:
            (context, index) {
          return _buildNotificationCard(
            notifications[index],
          );
        },
      ),
    );
  }

  // DIMENSIONS MODAL
  double _getModalWidth(
      BuildContext context,
      ) {
    final width =
        MediaQuery.of(context)
            .size
            .width;

    if (width >= 1400) {
      return 720.w;
    }

    if (width >= 900) {
      return 680.w;
    }

    return width - 40.w;
  }

  double _getModalHeight(
      BuildContext context,
      ) {
    final height =
        MediaQuery.of(context)
            .size
            .height;

    if (height >= 900) {
      return 720.h;
    }

    if (height >= 700) {
      return height * 0.82;
    }

    return height - 40.h;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _notificationSubscription
        ?.cancel();

    super.dispose();
  }
}