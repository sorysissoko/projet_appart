import 'package:intl/intl.dart';

class DateService {
  DateService._();

  // ============================================================
  // FORMAT AFFICHÉ
  // ============================================================

  /// Convertit une DateTime en :
  /// dd/MM/yyyy
  ///
  /// Exemple :
  /// 2026-08-20 -> 20/08/2026
  static String formatToDisplay(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('dd/MM/yyyy').format(date);
  }

  // ============================================================
  // PARSING DEPUIS L'AFFICHAGE
  // ============================================================

  /// Convertit une date affichée au format :
  /// dd/MM/yyyy
  ///
  /// Exemple :
  /// 20/08/2026 -> DateTime(2026, 8, 20)
  ///
  /// Retourne null si la date est invalide.
  static DateTime? parseFromDisplay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      final cleanedValue = value.trim();

      return DateFormat('dd/MM/yyyy').parseStrict(
        cleanedValue,
      );
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FORMAT SUPABASE / BASE DE DONNÉES
  // ============================================================

  /// Convertit une date de la base de données en DateTime.
  ///
  /// Accepte par exemple :
  /// 2026-08-20
  /// 2026-08-20T00:00:00
  /// 2026-08-20T00:00:00.000Z
  static DateTime? parseFromDatabase(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // FORMAT POUR SUPABASE
  // ============================================================

  /// Convertit une DateTime en :
  /// yyyy-MM-dd
  ///
  /// Exemple :
  /// DateTime(2026, 8, 20)
  /// -> 2026-08-20
  static String formatToDatabase(DateTime? date) {
    if (date == null) {
      return '';
    }

    return DateFormat('yyyy-MM-dd').format(date);
  }

  // ============================================================
  // FORMAT DATE + HEURE
  // ============================================================

  static String formatDateTimeToDisplay(DateTime? dateTime) {
    if (dateTime == null) {
      return '';
    }

    return DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(dateTime);
  }

  // ============================================================
  // PARSING DATE + HEURE
  // ============================================================

  static DateTime? parseDateTimeFromDisplay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateFormat(
        'dd/MM/yyyy HH:mm',
      ).parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }
}