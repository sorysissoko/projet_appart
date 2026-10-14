// service/error_handler.dart

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  ErrorHandler._();

  static String clean(dynamic error) {
    if (error == null) {
      return 'Une erreur inconnue est survenue.';
    }

    String message = error.toString();

    message = message.replaceFirst(
      RegExp(r'^Exception:\s*'),
      '',
    );

    if (error is AuthException) {
      return _cleanAuthError(error);
    }

    if (error is PostgrestException) {
      return _cleanDatabaseError(error);
    }

    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (message.contains('User already registered')) {
      return 'Cette adresse email est déjà utilisée.';
    }

    if (message.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre adresse email.';
    }

    return message.trim().isEmpty
        ? 'Une erreur est survenue.'
        : message.trim();
  }

  static String _cleanAuthError(AuthException error) {
    final message = error.message;

    if (message.contains('Invalid login credentials')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (message.contains('User already registered')) {
      return 'Cette adresse email est déjà utilisée.';
    }

    if (message.contains('Email not confirmed')) {
      return 'Veuillez confirmer votre adresse email.';
    }

    if (message.contains('Password should be')) {
      return 'Le mot de passe ne respecte pas les exigences.';
    }

    return message;
  }

  static String _cleanDatabaseError(
      PostgrestException error,
      ) {
    switch (error.code) {
      case '23505':
        return 'Cette donnée existe déjà.';

      case '23503':
        return 'Cette opération est liée à une autre donnée.';

      case '42501':
        return 'Vous n’avez pas les autorisations nécessaires.';

      case 'PGRST116':
        return 'Aucune donnée trouvée.';

      default:
        return error.message;
    }
  }

  static void log(
      dynamic error, {
        String? context,
      }) {
    if (kDebugMode) {
      debugPrint(
        '❌ ${context ?? 'Erreur'} : ${clean(error)}',
      );
    }
  }
}