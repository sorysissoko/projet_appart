import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'session_timeout_service.dart';

class SessionActivityDetector extends StatefulWidget {
  final Widget child;

  const SessionActivityDetector({
    super.key,
    required this.child,
  });

  @override
  State<SessionActivityDetector> createState() =>
      _SessionActivityDetectorState();
}

class _SessionActivityDetectorState
    extends State<SessionActivityDetector> {

  DateTime? _lastRegisteredActivity;

  static const Duration _activityDebounce =
  Duration(seconds: 2);

  void _registerActivity() {
    final now = DateTime.now();

    // Éviter d'écrire dans SharedPreferences
    // à chaque mouvement/clic.
    if (_lastRegisteredActivity != null &&
        now.difference(_lastRegisteredActivity!) <
            _activityDebounce) {
      return;
    }

    _lastRegisteredActivity = now;

    unawaited(
      SessionTimeoutService()
          .registerActivity(),
    );
  }

  bool _handleKeyEvent(
      KeyEvent event,
      ) {
    _registerActivity();

    return false;
  }

  @override
  void initState() {
    super.initState();

    HardwareKeyboard.instance.addHandler(
      _handleKeyEvent,
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(
      _handleKeyEvent,
    );

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,

      // Souris / tactile
      onPointerDown: (_) {
        _registerActivity();
      },

      // Molette
      onPointerSignal: (_) {
        _registerActivity();
      },

      child: widget.child,
    );
  }
}
