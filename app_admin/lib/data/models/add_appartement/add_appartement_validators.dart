class AddAppartementValidators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName obligatoire';
    }
    return null;
  }

  static String? validateMinLength(String? value, int minLength, String fieldName) {
    final error = validateRequired(value, fieldName);
    if (error != null) return error;
    if (value!.trim().length < minLength) {
      return '$fieldName trop court (min. $minLength caractères)';
    }
    return null;
  }

  static String? validateNumber(String? value) {
    if (value != null && value.isNotEmpty) {
      if (int.tryParse(value) == null && double.tryParse(value) == null) {
        return 'Entrez un nombre valide';
      }
    }
    return null;
  }

  static String? validatePrix(double prix) {
    if (prix <= 0) return 'Prix invalide!';
    if (prix < 10000) return 'Le prix doit être au moins 10 000 XOF';
    if (prix > 1000000000) return 'Le prix ne peut pas dépasser 1 000 000 000 XOF';
    return null;
  }

  static String? validateTime(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName obligatoire';
    }
    final parts = value.split(':');
    if (parts.length != 2) {
      return 'Format d\'heure invalide';
    }
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null || hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return 'Heure invalide';
    }
    return null;
  }
}