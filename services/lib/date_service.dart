import 'package:intl/intl.dart';

class DateService {

  // FORMAT AFFICHÉ : dd/MM/yyyy
  static String formatToDisplay(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // PARSE AFFICHAGE : dd/MM/yyyy -> DateTime
  static DateTime? parseFromDisplay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateFormat('dd/MM/yyyy').parseStrict(value.trim());
    } catch (_) {
      return null;
    }
  }

  // PARSE BASE DE DONNÉES
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


  // FORMAT BASE DE DONNÉES
  static String formatToDatabase(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }


  // COMPATIBILITÉ ANCIEN CODE
  static String formatToDb(DateTime date) {
    return formatToDatabase(date);
  }
}