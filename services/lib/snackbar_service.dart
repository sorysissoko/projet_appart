import 'package:flutter/material.dart';

// TYPES DE SNACKBAR
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// CONFIGURATION SNACKBAR
class SnackBarConfig {
  final String title;
  final IconData icon;
  final Color backgroundColor;

  const SnackBarConfig({
    required this.title,
    required this.icon,
    required this.backgroundColor,
  });
}

// SERVICE SNACKBAR
class SnackBarService {
  // SINGLETON
  static final SnackBarService _instance = SnackBarService._internal();

  factory SnackBarService() => _instance;

  SnackBarService._internal();

  // GLOBAL KEYS
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
  GlobalKey<ScaffoldMessengerState>();

  static final GlobalKey<NavigatorState> navigatorKey =
  GlobalKey<NavigatorState>();

  // CONFIGURATION
  DateTime? _lastCallTime;

  //Temps minimum entre deux SnackBar.
  static const Duration minInterval = Duration(milliseconds: 800);

  // REFRESH
  bool _isRefreshing = false;

  bool get isRefreshing => _isRefreshing;

  void setRefreshing(bool value) {
    _isRefreshing = value;
  }

  // SUCCESS
  void showSuccess(
      String message, {
        Duration duration = const Duration(seconds: 5),
      }) {
    if (_isRefreshing) return;

    _scheduleSnackBar(
      message: message,
      type: SnackBarType.success,
      duration: duration,
    );
  }

  // ERROR
  void showError(
      String message, {
        Duration duration = const Duration(seconds: 5),
      }) {
    if (_isRefreshing) return;

    _scheduleSnackBar(
      message: message,
      type: SnackBarType.error,
      duration: duration,
    );
  }

  // WARNING
  void showWarning(
      String message, {
        Duration duration = const Duration(seconds: 5),
      }) {
    if (_isRefreshing) return;

    _scheduleSnackBar(
      message: message,
      type: SnackBarType.warning,
      duration: duration,
    );
  }

  // INFO
  void showInfo(
      String message, {
        Duration duration = const Duration(seconds: 5),
      }) {
    if (_isRefreshing) return;

    _scheduleSnackBar(
      message: message,
      type: SnackBarType.info,
      duration: duration,
    );
  }

  // SCHEDULE
  void _scheduleSnackBar({
    required String message,
    required SnackBarType type,
    required Duration duration,
  }) {

    // MESSAGE VIDE
    if (message.trim().isEmpty) {
      debugPrint('⚠️ SnackBarService: Message vide ignoré.');
      return;
    }

    // REFRESH
    if (_isRefreshing) return;

    // ANTI-DOUBLON
    final now = DateTime.now();

    if (_lastCallTime != null && now.difference(_lastCallTime!) < minInterval) {
      debugPrint('⚠️ SnackBarService: Appel trop rapproché ignoré.');
      return;
    }

    _lastCallTime = now;

    // ATTENDRE LE PROCHAIN FRAME
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isRefreshing) return;

      _showSnackBar(
        message: message,
        type: type,
        duration: duration,
      );
    });
  }

  // AFFICHAGE
  void _showSnackBar({
    required String message,
    required SnackBarType type,
    required Duration duration,
  }) {
    final messenger = messengerKey.currentState;

    // MESSENGER NON DISPONIBLE
    if (messenger == null) {
      debugPrint('⚠️ SnackBarService: ScaffoldMessenger indisponible.');

      // RETRY UNIQUE
      Future.delayed(const Duration(milliseconds: 250), () {
        if (_isRefreshing) return;

        final retryMessenger = messengerKey.currentState;

        if (retryMessenger == null) {
          debugPrint('⚠️ SnackBarService: Impossible d\'afficher le message : $message');
          return;
        }

        _displaySnackBar(
          retryMessenger,
          message,
          type,
          duration,
        );
      });

      return;
    }

    // AFFICHAGE
    _displaySnackBar(
      messenger,
      message,
      type,
      duration,
    );
  }

  // DISPLAY
  void _displaySnackBar(
      ScaffoldMessengerState messenger,
      String message,
      SnackBarType type,
      Duration duration,
      ) {
    try {

      // CONFIGURATION
      final config = _getSnackBarConfig(type);


      // FERMER L'ANCIEN SNACKBAR
      messenger.hideCurrentSnackBar();

      // AFFICHER LE NOUVEAU
      messenger.showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              // ICÔNE
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  config.icon,
                  color: Colors.white,
                  size: 21,
                ),
              ),

              const SizedBox(width: 12),

              // TEXTE
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      config.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      message,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.95),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // BOUTON FERMER
              IconButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ],
          ),

          // STYLE
          backgroundColor: config.backgroundColor,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: duration,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ SnackBarService: Erreur affichage SnackBar : $e');
    }
  }

  // CONFIGURATION
  SnackBarConfig _getSnackBarConfig(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return const SnackBarConfig(
          title: 'Succès',
          icon: Icons.check_rounded,
          backgroundColor: Color(0xFF10B981),
        );

      case SnackBarType.error:
        return const SnackBarConfig(
          title: 'Erreur',
          icon: Icons.error_outline_rounded,
          backgroundColor: Color(0xFFEF4444),
        );

      case SnackBarType.warning:
        return const SnackBarConfig(
          title: 'Attention',
          icon: Icons.warning_amber_rounded,
          backgroundColor: Color(0xFFF59E0B),
        );

      case SnackBarType.info:
        return const SnackBarConfig(
          title: 'Information',
          icon: Icons.info_outline_rounded,
          backgroundColor: Color(0xFF2563EB),
        );
    }
  }

  // ACTION SNACKBAR
  void showActionSnackBar(
      String message, {
        required String actionLabel,
        required VoidCallback onAction,
        Duration duration = const Duration(seconds: 5),
      }) {

    // REFRESH
    if (_isRefreshing) return;

    // MESSAGE VIDE
    if (message.trim().isEmpty) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isRefreshing) return;

      final messenger = messengerKey.currentState;

      if (messenger == null) {
        debugPrint('⚠️ SnackBarService: Messenger indisponible pour ActionSnackBar.');
        return;
      }

      try {
        messenger.hideCurrentSnackBar();

        messenger.showSnackBar(
          SnackBar(
            content: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF1F2937),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            duration: duration,
            action: SnackBarAction(
              label: actionLabel,
              onPressed: onAction,
              textColor: Colors.orange,
            ),
          ),
        );
      } catch (e) {
        debugPrint('⚠️ SnackBarService: Erreur ActionSnackBar : $e');
      }
    });
  }

  // HIDE
  void hideCurrentSnackBar() {
    messengerKey.currentState?.hideCurrentSnackBar();
  }

  // REMOVE
  void removeCurrentSnackBar() {
    messengerKey.currentState?.removeCurrentSnackBar();
  }

  // CLEAR
  void clearAll() {
    final messenger = messengerKey.currentState;

    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.removeCurrentSnackBar();
  }
}