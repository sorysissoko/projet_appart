class SecurityService {
  SecurityService._();


  // RÔLES
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';
  static const String roleProprietaire = 'proprietaire';
  static const String roleLocataire = 'locataire';

  static const List<String> allowedRoles = [
    roleAdmin,
    roleSuperAdmin,
    roleProprietaire,
    roleLocataire,
  ];

  // NORMALISATION DU RÔLE
  static String normalizeRole(String? role) {
    return role?.trim().toLowerCase() ?? '';
  }


  // VALIDATION DU RÔLE
  static bool isValidRole(String? role) {
    return allowedRoles.contains(
      normalizeRole(role),
    );
  }


  // IDENTIFICATION DES RÔLES
  static bool isAdmin(String? role) {
    final normalized = normalizeRole(role);

    return normalized == roleAdmin ||
        normalized == roleSuperAdmin;
  }

  static bool isSuperAdmin(String? role) {
    return normalizeRole(role) == roleSuperAdmin;
  }

  static bool isProprietaire(String? role) {
    return normalizeRole(role) == roleProprietaire;
  }

  static bool isLocataire(String? role) {
    return normalizeRole(role) == roleLocataire;
  }

  // RÔLE PRIVILÉGIÉ
  static bool isPrivilegedRole(String? role) {
    return isAdmin(role) || isProprietaire(role);
  }

  // ACCÈS ESPACE ADMIN
  static bool canAccessAdmin(String? role) {
    return isAdmin(role);
  }

  // ACCÈS ESPACE PROPRIÉTAIRE
  static bool canAccessOwner(String? role) {
    return isAdmin(role) ||
        isProprietaire(role);
  }

  // ACCÈS ESPACE LOCATAIRE
  static bool canAccessTenant(String? role) {
    return isAdmin(role) ||
        isProprietaire(role) ||
        isLocataire(role);
  }


  // ACCÈS APPLICATION ADMIN
  static bool canAccessAdminApp(String? role) {
    final normalized = normalizeRole(role);

    return normalized == roleAdmin ||
        normalized == roleSuperAdmin;
  }


  // ACCÈS APPLICATION PROPRIÉTAIRE
  static bool canAccessOwnerApp(String? role) {
    final normalized = normalizeRole(role);

    return normalized == roleAdmin ||
        normalized == roleSuperAdmin ||
        normalized == roleProprietaire;
  }


  // ACCÈS APPLICATION LOCATAIRE
  static bool canAccessTenantApp(String? role) {
    final normalized = normalizeRole(role);

    return normalized == roleAdmin ||
        normalized == roleSuperAdmin ||
        normalized == roleProprietaire ||
        normalized == roleLocataire;
  }


  // AUTORISATION GÉNÉRIQUE
  static bool canAccessRole(
      String? currentRole,
      String targetRole,
      ) {
    final current = normalizeRole(currentRole);
    final target = normalizeRole(targetRole);

    //Un rôle inconnu n'a aucun accès.
    if (!isValidRole(current)) {
      return false;
    }

    switch (target) {
      case roleAdmin:
        return canAccessAdmin(current);

      case roleProprietaire:
        return canAccessOwner(current);

      case roleLocataire:
        return canAccessTenant(current);

      default:
        return false;
    }
  }

  // ACCÈS À UNE LISTE DE RÔLES
  static bool hasAnyRole(
      String? currentRole,
      List<String> roles,
      ) {
    final current = normalizeRole(currentRole);

    if (!isValidRole(current)) {
      return false;
    }

    return roles.any(
          (role) => normalizeRole(role) == current,
    );
  }


  // ESPACES ACCESSIBLES
  static List<String> accessibleRoles(String? role) {
    final normalized = normalizeRole(role);

    switch (normalized) {
      case roleAdmin:
      case roleSuperAdmin:
        return const [
          roleAdmin,
          roleProprietaire,
          roleLocataire,
        ];

      case roleProprietaire:
        return const [
          roleProprietaire,
          roleLocataire,
        ];

      case roleLocataire:
        return const [
          roleLocataire,
        ];

      default:
        return const [];
    }
  }


  // EMAIL
  static bool isValidEmail(String email) {
    final value = email.trim();

    if (value.isEmpty) {
      return false;
    }

    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(value);
  }


  // TÉLÉPHONE
  static bool isValidPhone(String phone) {
    final value = phone.trim();

    if (value.isEmpty) {
      return false;
    }

    return RegExp(
      r'^[0-9+\-() ]{8,20}$',
    ).hasMatch(value);
  }

  // NOM et PRÉNOM
  static bool isValidName(String value) {
    final name = value.trim();

    if (name.length < 2 || name.length > 100) {
      return false;
    }

    return RegExp(
      r"^[A-Za-zÀ-ÖØ-öø-ÿ' -]+$",
    ).hasMatch(name);
  }


  // ADRESSE
  static bool isValidAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return true;
    }

    return value.trim().length <= 300;
  }

  // PASSWORD LOCATAIRE
  //Mot de passe minimum pour un locataire : 8 caractères, 1 majuscule, 1 minuscule, 1 chiffre
  static bool isValidLocatairePassword(String password) {
    if (password.length < 8) {
      return false;
    }

    return RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password);
  }


  // PASSWORD FORT admin - proprietaire
  //12 caractères minimum, 1 majuscule, 1 minuscule, 1 chiffre, 1 caractère spécial
  static bool isValidStrongPassword(String password) {
    if (password.length < 12) {
      return false;
    }

    final upper = RegExp(r'[A-Z]').hasMatch(password);
    final lower = RegExp(r'[a-z]').hasMatch(password);
    final digit = RegExp(r'[0-9]').hasMatch(password);

    final special = RegExp(
      r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/'`;~]''',
    ).hasMatch(password);

    return upper &&
        lower &&
        digit &&
        special;
  }

  // PASSWORD SELON LE RÔLE
  static bool isValidPasswordForRole(
      String password,
      String? role,
      ) {
    final normalized = normalizeRole(role);

    switch (normalized) {
      case roleAdmin:
      case roleSuperAdmin:
      case roleProprietaire:
        return isValidStrongPassword(password);

      case roleLocataire:
        return isValidLocatairePassword(password);

      default:
        return false;
    }
  }


  // VALIDATION DÉTAILLÉE DU PASSWORD
  static PasswordValidationResult validatePasswordForRole({
    required String password,
    required String? role,
  }) {
    final normalized = normalizeRole(role);


    // RÔLE INVALIDE
    if (!isValidRole(normalized)) {
      return const PasswordValidationResult(
        isValid: false,
        message: 'Rôle utilisateur invalide.',
      );
    }

    // TYPE DE PASSWORD
    final bool isStrong =
        normalized == roleAdmin ||
            normalized == roleSuperAdmin ||
            normalized == roleProprietaire;

    final int minLength = isStrong ? 12 : 8;


    // LONGUEUR
    if (password.length < minLength) {
      return PasswordValidationResult(
        isValid: false,
        message:
        'Le mot de passe doit contenir au moins '
            '$minLength caractères.',
      );
    }


    // MAJUSCULE
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message:
        'Le mot de passe doit contenir au moins '
            'une majuscule.',
      );
    }


    // MINUSCULE
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message:
        'Le mot de passe doit contenir au moins '
            'une minuscule.',
      );
    }

    // CHIFFRE
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message:
        'Le mot de passe doit contenir au moins '
            'un chiffre.',
      );
    }

    // CARACTÈRE SPÉCIAL
    if (isStrong &&
        !RegExp(
          r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/'`;~]''',
        ).hasMatch(password)) {
      return const PasswordValidationResult(
        isValid: false,
        message:
        'Le mot de passe doit contenir au moins '
            'un caractère spécial.',
      );
    }

    // PASSWORD VALIDE
    return const PasswordValidationResult(
      isValid: true,
      message: '',
    );
  }


  // COMPATIBILITÉ
  static bool isValidSimplePassword(String password) {
    return isValidLocatairePassword(password);
  }

  static bool isValidPassword(String password) {
    return isValidStrongPassword(password);
  }

  // SANITIZATION
  static String sanitizeInput(String input) {
    return input
        .replaceAll('\u0000', '')
        .trim();
  }

  // CONTENU DANGEREUX
  static bool hasMaliciousContent(String input) {
    final value = input.toLowerCase();

    final patterns = [
      RegExp(r'<script'),
      RegExp(r'</script>'),
      RegExp(r'javascript:'),
      RegExp(r'vbscript:'),
      RegExp(r'data:text/html'),
      RegExp(r'onerror\s*='),
      RegExp(r'onload\s*='),
      RegExp(r'onclick\s*='),
      RegExp(r'onmouseover\s*='),
      RegExp(r'<iframe'),
      RegExp(r'<object'),
      RegExp(r'<embed'),
    ];

    return patterns.any(
          (pattern) => pattern.hasMatch(value),
    );
  }

  // CONFIRMATION PASSWORD
  static bool passwordsMatch(
      String password,
      String confirmation,
      ) {
    return password == confirmation;
  }

  // SESSION LOCALE
  static bool isSessionValid(
      DateTime? lastActivity,
      int timeoutMinutes,
      ) {
    if (lastActivity == null ||
        timeoutMinutes <= 0) {
      return false;
    }

    return DateTime.now()
        .difference(lastActivity)
        .inMinutes <
        timeoutMinutes;
  }


  // SESSION EXPIRÉE
  static bool isSessionExpired(
      DateTime? lastActivity,
      int timeoutMinutes,
      ) {
    return !isSessionValid(
      lastActivity,
      timeoutMinutes,
    );
  }
}

// PASSWORD VALIDATION RESULT
class PasswordValidationResult {
  final bool isValid;
  final String message;

  const PasswordValidationResult({
    required this.isValid,
    required this.message,
  });
}