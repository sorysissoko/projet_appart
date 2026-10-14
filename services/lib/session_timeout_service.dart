import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'service_locator.dart';

/// SESSION TIMEOUT ADMIN
class SessionTimeoutService with WidgetsBindingObserver {
  SessionTimeoutService._internal();

  static final SessionTimeoutService instance =
  SessionTimeoutService._internal();

  factory SessionTimeoutService() => instance;

  // CONFIGURATION
  static const Duration inactivityLimit =
  Duration(minutes: 15);

  static const Duration checkInterval =
  Duration(seconds: 30);

  static const String _lastActivityKey =
      'admin_last_activity';

  // ÉTAT
  Timer? _timer;

  DateTime? _lastActivity;

  bool _initialized = false;

  bool _isLoggingOut = false;

  // SUPABASE
  SupabaseClient get _supabase =>
      Supabase.instance.client;

  // INITIALISATION
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;

    WidgetsBinding.instance.addObserver(this);

    // RÉCUPÉRER LA DERNIÈRE ACTIVITÉ
    await _loadLastActivity();

    // SI AUCUNE ACTIVITÉ ENREGISTRÉE
    if (_lastActivity == null) {
      await registerActivity();
    }

    // VÉRIFICATION IMMÉDIATE
    await checkExpiration();

    // VÉRIFICATION PÉRIODIQUE
    _timer = Timer.periodic(
      checkInterval,
          (_) {
        unawaited(checkExpiration());
      },
    );

    debugPrint(
      'SessionTimeoutService initialisé.',
    );
    debugPrint(
      'Expiration après : ${inactivityLimit.inMinutes} minutes.',
    );
  }

  // CHARGER DERNIÈRE ACTIVITÉ
  Future<void> _loadLastActivity() async {
    try {
      final prefs =
      await SharedPreferences.getInstance();

      final timestamp =
      prefs.getInt(_lastActivityKey);

      if (timestamp != null) {
        _lastActivity =
            DateTime.fromMillisecondsSinceEpoch(
              timestamp,
            );

        debugPrint(
          'Dernière activité : $_lastActivity',
        );
      }
    } catch (e) {
      debugPrint(
        'Impossible de charger la dernière activité : $e',
      );
    }
  }

  // ENREGISTRER ACTIVITÉ
  Future<void> registerActivity() async {
    if (_isLoggingOut) {
      return;
    }

    // SEULEMENT SI UNE SESSION EXISTE
    final user =
        _supabase.auth.currentUser;

    if (user == null) {
      return;
    }

    final now = DateTime.now();

    _lastActivity = now;

    try {
      final prefs =
      await SharedPreferences.getInstance();

      await prefs.setInt(
        _lastActivityKey,
        now.millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint(
        "Impossible d'enregistrer l'activité : $e",
      );
    }
  }

  // VÉRIFIER EXPIRATION
  Future<bool> checkExpiration() async {
    // Si une déconnexion est déjà en cours,
    // on considère la session comme expirée.
    if (_isLoggingOut) {
      return true;
    }

    final supabase = Supabase.instance.client;

    // Aucun utilisateur connecté.
    // Ce n'est pas un timeout.
    if (supabase.auth.currentUser == null) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      final timestamp = prefs.getInt(_lastActivityKey);

      // Aucun historique d'activité.
      //
      // Cela peut arriver :
      // - première connexion
      // - ancienne version de l'application
      // - données locales supprimées
      //
      // On initialise simplement l'activité.
      if (timestamp == null) {
        await registerActivity();
        return false;
      }

      final lastActivity =
      DateTime.fromMillisecondsSinceEpoch(timestamp);

      final now = DateTime.now();

      final elapsed = now.difference(lastActivity);

      debugPrint(
        '⏱️ Dernière activité : $lastActivity',
      );

      debugPrint(
        'Inactivité : ${elapsed.inMinutes} min '
            '${elapsed.inSeconds % 60} sec',
      );

      // SESSION EXPIRÉE
      if (elapsed >= inactivityLimit) {
        debugPrint(
          'SESSION EXPIRÉE — '
              'plus de ${inactivityLimit.inMinutes} minutes '
              'd\'inactivité.',
        );

        await _expireSession();

        return true;
      }

      // SESSION TOUJOURS VALIDE
      return false;
    } catch (e) {
      debugPrint(
        'Erreur vérification expiration session : $e',
      );

      return false;
    }
  }

  // EXPIRER SESSION
  Future<void> _expireSession() async {
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;

    debugPrint(
      'SESSION ADMIN EXPIRÉE APRÈS '
          '${inactivityLimit.inMinutes} MINUTES.',
    );

    try {

      // SUPABASE SIGN OUT
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint(
        'Erreur pendant la déconnexion automatique : $e',
      );
    }

    // SUPPRIMER DERNIÈRE ACTIVITÉ
    try {
      final prefs =
      await SharedPreferences.getInstance();

      await prefs.remove(
        _lastActivityKey,
      );
    } catch (_) {}

    _lastActivity = null;

    // NAVIGATION LOGIN
    try {
      ServiceLocator.navigation.goToLogin();
    } catch (e) {
      debugPrint(
        'Navigation Login impossible : $e',
      );
    }

    _isLoggingOut = false;
  }

  // RETOUR APPLICATION
  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state,
      ) {
    if (!_initialized) {
      return;
    }

    // RETOUR APRÈS VEILLE / ARRIÈRE-PLAN
    if (state == AppLifecycleState.resumed) {
      debugPrint(
        'Application reprise. Vérification session...',
      );

      unawaited(
        checkExpiration(),
      );
    }
  }

  // RESET APRÈS CONNEXION
  Future<void> resetAfterLogin() async {
    _isLoggingOut = false;

    await registerActivity();

    debugPrint(
      'Session Admin démarrée.',
    );
  }

  // ARRÊT
  void dispose() {
    _timer?.cancel();
    _timer = null;

    WidgetsBinding.instance.removeObserver(this);

    _initialized = false;
  }
}
