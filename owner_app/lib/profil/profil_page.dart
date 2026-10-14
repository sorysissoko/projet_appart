import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/database_service.dart';

import '../core/navigation/main_wrapper.dart';
import '../core/theme/app_theme.dart';
import 'informations_personnelles_page.dart';

// ============================================================
// SKELETON WIDGETS
// ============================================================

class _SkeletonProfileHeader extends StatefulWidget {
  const _SkeletonProfileHeader();

  @override
  State<_SkeletonProfileHeader> createState() => _SkeletonProfileHeaderState();
}

class _SkeletonProfileHeaderState extends State<_SkeletonProfileHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            color: AppColors.foreground,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
            child: Row(
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEEB15B),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 19,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 100,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
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
          // Cercle décoratif
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
          // Carte statistiques
          Positioned(
            left: 16,
            right: 16,
            bottom: -30,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0F000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  _buildSkeletonStatItem(),
                  _buildSkeletonDivider(),
                  _buildSkeletonStatItem(),
                  _buildSkeletonDivider(),
                  _buildSkeletonStatItem(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonStatItem() {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 50,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FA),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _SkeletonInfoRow extends StatefulWidget {
  const _SkeletonInfoRow();

  @override
  State<_SkeletonInfoRow> createState() => _SkeletonInfoRowState();
}

class _SkeletonInfoRowState extends State<_SkeletonInfoRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonActionRow extends StatefulWidget {
  const _SkeletonActionRow();

  @override
  State<_SkeletonActionRow> createState() => _SkeletonActionRowState();
}

class _SkeletonActionRowState extends State<_SkeletonActionRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 80,
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 120,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final bool isInfoCard;

  const _SkeletonCard({this.isInfoCard = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              width: 150,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          if (isInfoCard) ...[
            const _SkeletonInfoRow(),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const _SkeletonInfoRow(),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const _SkeletonInfoRow(),
          ] else ...[
            const _SkeletonActionRow(),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const _SkeletonActionRow(),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const _SkeletonActionRow(),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// PAGE PROFIL
// ============================================================

class ProfilePage extends StatefulWidget {
  final NavigateCallback? onNavigate;

  const ProfilePage({
    super.key,
    this.onNavigate,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final DatabaseService _backendService = DatabaseService();

  Map<String, dynamic>? _profile;

  Map<String, dynamic> _stats = {
    'biens': 0,
    'reservations': 0,
    'avis': 0,
    'note': 0.0,
  };

  Map<String, dynamic> _certificationStatus = {
    'is_certified': false,
    'profile_complete': false,
    'identity_verified': false,
    'missing_fields': <String>[],
    'missing_documents': <String>[],
    'progress': 0.0,
  };

  String? _avatarUrl;

  bool _isLoading = true;
  String? _error;

  // ============================================================
  // COULEURS
  // ============================================================

  static const Color goldAccent = Color(0xFFEEB15B);
  static const Color textDark = Color(0xFF0F1B2D);
  static const Color textMuted = Color(0xFF0F172A);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }


  // CHARGEMENT PROFIL
  Future<void> _loadProfile() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final profile = await _backendService.getCurrentProfile();

      if (profile == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _error = 'Impossible de récupérer votre profil.';
        });
        return;
      }

      // ============================================================
      // CHARGEMENT URL AVATAR
      // ============================================================
      String? avatarUrl;
      final photoPath = profile['photo_profil']?.toString().trim();

      if (photoPath != null && photoPath.isNotEmpty) {
        try {
          avatarUrl = await _backendService.supabase.storage
              .from('avatars')
              .createSignedUrl(photoPath, 3600);
        } catch (e) {
          debugPrint('⚠️ Impossible de charger l’avatar : $e');
        }
      }

      // ============================================================
      // STATS + CERTIFICATION
      // ============================================================
      final stats = await _backendService.getOwnerStats();
      final certification = await _backendService.getCertificationStatus();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _stats = stats;
        _avatarUrl = avatarUrl;
        _certificationStatus = certification;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur chargement profil: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Une erreur est survenue lors du chargement.';
      });
    }
  }
  // ============================================================
// NAVIGATION : PAGE INFORMATIONS PERSONNELLES
// ============================================================

  Future<void> _openInformationsPersonnellesPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => InformationsPersonnellesPage(
          onBack: () => Navigator.pop(context),
        ),
      ),
    );

    // Recharger le profil au retour (au cas où des modifs)
    if (!mounted) return;
    await _loadProfile();
  }

  // ============================================================
  // GETTERS PROFIL
  // ============================================================

  String get _nom {
    return (_profile?['nom'] ?? '').toString().trim();
  }

  String get _prenom {
    return (_profile?['prenom'] ?? '').toString().trim();
  }

  String get _email {
    return (_profile?['email'] ?? '').toString().trim();
  }

  String get _telephone {
    return (_profile?['telephone'] ?? '').toString().trim();
  }

  String get _adresse {
    return (_profile?['adresse'] ?? '').toString().trim();
  }

  String get _role {
    return (_profile?['role'] ?? '').toString().trim();
  }

  String get _fullName {
    final name = '$_prenom $_nom'.trim();

    return name.isEmpty ? 'Utilisateur' : name;
  }

  String get _initials {
    final first = _prenom.isNotEmpty ? _prenom[0] : '';
    final last = _nom.isNotEmpty ? _nom[0] : '';

    final initials = '$first$last'.trim();

    return initials.isEmpty ? 'U' : initials.toUpperCase();
  }

  int get _nombreBiens {
    final value = _stats['biens'];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  int get _nombreReservations {
    final value = _stats['reservations'];

    if (value is int) return value;
    if (value is num) return value.toInt();

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  bool get _estCertifie {
    return _certificationStatus['is_certified'] == true;
  }

  bool get _profileComplete {
    return _certificationStatus['profile_complete'] == true;
  }

  bool get _identityVerified {
    return _certificationStatus['identity_verified'] == true;
  }

  double get _certificationProgress {
    final value = _certificationStatus['progress'];
    if (value is num) return value.toDouble();
    return 0.0;
  }

  List<String> get _missingFields {
    final value = _certificationStatus['missing_fields'];
    if (value is List) return value.cast<String>();
    return [];
  }

  List<String> get _missingDocuments {
    final value = _certificationStatus['missing_documents'];
    if (value is List) return value.cast<String>();
    return [];
  }

  double get _note {
    final value = _stats['note'];

    if (value is double) return value;
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  String get _roleLabel {
    switch (_role.toLowerCase()) {
      default:
        return _role.isEmpty ? 'Utilisateur' : _role;
    }
  }

  String get _sinceYear {
    final createdAt = _profile?['created_at'];

    if (createdAt == null) {
      return '';
    }

    try {
      final date = DateTime.parse(createdAt.toString());
      return date.year.toString();
    } catch (_) {
      return '';
    }
  }

  String get _memberDescription {
    if (_sinceYear.isNotEmpty) {
      return '$_roleLabel · Depuis $_sinceYear';
    }

    return _roleLabel;
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigate(AppPage page) {
    widget.onNavigate?.call(page);
  }

  // ============================================================
  // DÉCONNEXION
  // ============================================================

  Future<void> _confirmSignOut() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Se déconnecter ?',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          content: Text(
            'Voulez-vous vraiment vous déconnecter de votre compte ?',
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Annuler',
                style: GoogleFonts.nunito(
                  color: textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Déconnexion',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    try {
      await _backendService.supabase.auth.signOut();

      if (!mounted) return;

      // Retour vers dashboard.
      // Si ton AuthGate gère automatiquement la session,
      // il prendra ensuite le relais.
      _navigate(AppPage.dashboard);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la déconnexion : $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              color: AppColors.primary,
              padding: EdgeInsets.fromLTRB(
                12,
                topPadding + 8,
                20,
                12,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _navigate(AppPage.dashboard);
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    tooltip: 'Retour',
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                  ),

                  const SizedBox(width: 4),

                  Expanded(
                    child: Text(
                      'Mon Profile',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // CONTENU
            // ==================================================

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCertificationAlert() {
    String message;
    if (!_profileComplete && !_identityVerified) {
      message = 'Complétez votre profil et envoyez vos documents '
          'pour pouvoir publier vos appartements.';
    } else if (!_profileComplete) {
      final fields = _missingFields.take(3).join(', ');
      message = 'Complétez votre profil ($fields...) '
          'pour pouvoir publier vos appartements.';
    } else if (!_identityVerified) {
      message = "Envoyez une pièce d'identité valide "
          '(CNI recto+verso, passeport ou permis) '
          'pour pouvoir publier vos appartements.';
    } else {
      message =
      'Votre dossier est en cours de vérification par notre équipe.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8BF),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFD97706),
                  size: 24,
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
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF7C4A03),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      message,
                      style: GoogleFonts.nunito(
                        fontSize: 12.5,
                        height: 1.45,
                        color: const Color(0xFF8A642F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ======================================================
          // BARRE DE PROGRESSION (utilise _certificationProgress)
          // ======================================================
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression',
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF8A642F),
                ),
              ),
              Text(
                '${(_certificationProgress * 100).round()}%',
                style: GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: _certificationProgress,
              minHeight: 8,
              backgroundColor: const Color(0xFFFED7AA),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFF59E0B),
              ),
            ),
          ),

          // CHECKLIST
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildChecklistItem(
                  label: 'Profil complet',
                  done: _profileComplete,
                ),
                const SizedBox(height: 8),
                _buildChecklistItem(
                  label: "Pièce d'identité envoyée",
                  done: _identityVerified,
                ),
                const SizedBox(height: 8),
                _buildChecklistItem(
                  label: 'Vérification par notre équipe',
                  done: _estCertifie,
                ),
              ],
            ),
          ),

          // ======================================================
          // DOCUMENTS MANQUANTS (utilise _missingDocuments)
          // ======================================================
          if (_missingDocuments.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Manquant : ${_missingDocuments.join(', ')}',
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // BOUTON
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: () {
                if (!_profileComplete) {
                  _openInformationsPersonnellesPage();
                } else {
                  _navigate(AppPage.documents);
                }
              },
              icon: Icon(
                !_profileComplete
                    ? Icons.person_outline_rounded
                    : Icons.verified_user_rounded,
                size: 17,
              ),
              label: Text(
                !_profileComplete
                    ? 'Compléter mon profil'
                    : 'Envoyer mes documents',
                style: GoogleFonts.nunito(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// ITEM CHECKLIST
// ============================================================

  Widget _buildChecklistItem({
    required String label,
    required bool done,
  }) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: done
                ? const Color(0xFF10B981)
                : const Color(0xFFE2E8F0),
            shape: BoxShape.circle,
          ),
          child: Icon(
            done ? Icons.check : Icons.circle_outlined,
            color: done ? Colors.white : const Color(0xFF94A3B8),
            size: 12,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: done
                  ? const Color(0xFF065F46)
                  : const Color(0xFF8A642F),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_error != null) {
      return _buildErrorState();
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildProfileHeader(),

            const SizedBox(height: 50),

            // ALERTE CERTIFICATION
            if (!_estCertifie) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: _buildCertificationAlert(),
              ),

              const SizedBox(height: 20),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  // ==================================================
                  // INFORMATIONS PERSONNELLES
                  // ==================================================

                  // ==================================================
// INFORMATIONS PERSONNELLES
// ==================================================

                  _buildCard(
                    title: 'Informations personnelles',
                    titleIcon: Icons.person_outline_rounded,
                    onTitleTap: _openInformationsPersonnellesPage,
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    children: [
                      _buildInfoRow(
                        icon: Icons.person_outline,
                        iconBg: const Color(0xFFEDE9FE),
                        iconColor: const Color(0xFF6D28D9),
                        label: 'Nom complet',
                        value: _fullName,
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildInfoRow(
                        icon: Icons.mail_outline,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFFA855F7),
                        label: 'Email',
                        value: _email.isEmpty ? 'Non renseigné' : _email,
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildInfoRow(
                        icon: Icons.phone_android_outlined,
                        iconBg: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF4338CA),
                        label: 'Téléphone',
                        value: _telephone.isEmpty ? 'Non renseigné' : _telephone,
                      ),

                      if (_adresse.isNotEmpty) ...[
                        const Divider(
                          height: 1,
                          color: Color(0xFFF1F5F9),
                        ),
                        _buildInfoRow(
                          icon: Icons.location_on_outlined,
                          iconBg: const Color(0xFFDCFCE7),
                          iconColor: const Color(0xFF16A34A),
                          label: 'Adresse',
                          value: _adresse,
                        ),
                      ],

                      const SizedBox(height: 12),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // ACCÈS RAPIDE
                  // ==================================================

                  _buildCard(
                    title: 'Accès rapide',
                    children: [
                      _buildActionRow(
                        icon: Icons.home_rounded,
                        iconBg: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                        title: 'Mes appartements',
                        subtitle:
                        '$_nombreBiens bien${_nombreBiens > 1 ? 's' : ''} enregistré${_nombreBiens > 1 ? 's' : ''}',
                        onTap: () {
                          _navigate(AppPage.mesAppartements);
                        },
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.calendar_today_rounded,
                        iconBg: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0284C7),
                        title: 'Mes réservations',
                        subtitle:
                        '$_nombreReservations réservation${_nombreReservations > 1 ? 's' : ''}',
                        onTap: () {
                          _navigate(AppPage.reservations);
                        },
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.account_balance_wallet_rounded,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                        title: 'Mes revenus',
                        subtitle: 'Rapport mensuel disponible',
                        onTap: () {
                          _navigate(AppPage.revenus);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PARAMÈTRES
                  // ==================================================

                  _buildCard(
                    title: 'Paramètres',
                    children: [
                      _buildActionRow(
                        icon: Icons.notifications_rounded,
                        iconBg: const Color(0xFFFEF3C7),
                        iconColor: const Color(0xFFD97706),
                        title: 'Notifications',
                        subtitle: 'Push, email, SMS',
                        onTap: () {},
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.lock_rounded,
                        iconBg: const Color(0xFFFFEDD5),
                        iconColor: const Color(0xFFEA580C),
                        title: 'Sécurité',
                        subtitle: 'Mot de passe, 2FA',
                        onTap: () {},
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.credit_card_rounded,
                        iconBg: const Color(0xFFE0F2FE),
                        iconColor: const Color(0xFF0284C7),
                        title: 'Paiements',
                        subtitle: 'Méthodes de paiement',
                        onTap: () {},
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.description_rounded,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: const Color(0xFFA855F7),
                        title: 'Documents',
                        subtitle: "Pièce d'identité, documents",
                        onTap: () {
                          _navigate(AppPage.documents);
                        },
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.language_rounded,
                        iconBg: const Color(0xFFE0E7FF),
                        iconColor: const Color(0xFF4338CA),
                        title: 'Langue',
                        subtitle: 'Français',
                        onTap: () {},
                      ),

                      const Divider(
                        height: 1,
                        color: Color(0xFFF1F5F9),
                      ),

                      _buildActionRow(
                        icon: Icons.help_outline_rounded,
                        iconBg: const Color(0xFFFFE4E6),
                        iconColor: const Color(0xFFE11D48),
                        title: 'Aide & support',
                        subtitle: 'FAQ, contacter le support',
                        onTap: () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // DÉCONNEXION
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _confirmSignOut,
                      icon: const Icon(
                        Icons.logout_rounded,
                        size: 20,
                        color: Color(0xFFDC2626),
                      ),
                      label: Text(
                        'Se déconnecter',
                        style: GoogleFonts.nunito(
                          color: const Color(0xFFDC2626),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: const Color(0xFFFFF1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // LOADING STATE AVEC SKELETONS
  // ============================================================

  Widget _buildLoadingState() {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadProfile,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const _SkeletonProfileHeader(),
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const _SkeletonCard(isInfoCard: true),
                  const SizedBox(height: 16),
                  const _SkeletonCard(isInfoCard: false),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  const SizedBox(height: 70),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// PROFILE HEADER
// ============================================================

  Widget _buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // ======================================================
        // BANDEAU CLIQUABLE (avatar + nom + description)
        // ======================================================
        InkWell(
          onTap: _openInformationsPersonnellesPage,
          child: Container(
            width: double.infinity,
            color: AppColors.foreground,
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 60),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // ⚡ AVATAR : photo si dispo, sinon initiales
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: goldAccent.withValues(alpha: 0.5),
                          width: 2,
                        ),
                        color: goldAccent, // fallback si pas de photo
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: _avatarUrl != null
                          ? Image.network(
                        _avatarUrl!,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                        // Loader pendant le chargement
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return _buildInitialsAvatar();
                        },
                        // Fallback en cas d'erreur
                        errorBuilder: (context, error, stackTrace) {
                          return _buildInitialsAvatar();
                        },
                      )
                          : _buildInitialsAvatar(),
                    ),

                    if (_estCertifie)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1E293B),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 🏅 Badge certification
                          if (_estCertifie)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 11,
                                    color: Color(0xFF090D16),
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'VÉRIFIÉ',
                                    style: GoogleFonts.nunito(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      color: const Color(0xFF090D16),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'NON CERTIFIÉ',
                                style: GoogleFonts.nunito(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white70,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),

                          const SizedBox(width: 6),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Expanded(
                            child: Text(
                              _memberDescription,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
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

        // ======================================================
        // CERCLE DÉCORATIF
        // ======================================================
        Positioned(
          right: -30,
          top: -30,
          child: IgnorePointer(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.04),
              ),
            ),
          ),
        ),

        // ======================================================
        // CARTE STATISTIQUES (non cliquable)
        // ======================================================
        Positioned(
          left: 16,
          right: 16,
          bottom: -30,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0F000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              children: [
                _buildStatItem(
                  _nombreBiens.toString(),
                  'Biens',
                ),

                _buildDivider(),

                _buildStatItem(
                  _nombreReservations.toString(),
                  'Réservations',
                ),

                _buildDivider(),

                _buildStatItem(
                  _note > 0 ? '${_note.toStringAsFixed(1)} ★' : '—',
                  'Avis',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
// AVATAR PAR DÉFAUT (initiales)
// ============================================================

  Widget _buildInitialsAvatar() {
    return Container(
      width: 68,
      height: 68,
      alignment: Alignment.center,
      color: goldAccent,
      child: Text(
        _initials,
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  // ============================================================
  // CARD
  // ============================================================

  // ============================================================
// CARD
// ============================================================

  Widget _buildCard({
    required String title,
    required List<Widget> children,
    Widget? trailing,
    VoidCallback? onTitleTap,
    IconData? titleIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  if (titleIcon != null) ...[
                    Icon(
                      titleIcon,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                  ],

                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.inputText,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),

          ...children,
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.nunito(
                    fontSize: 12,
                    color: AppColors.inputText,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
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
  // ACTION ROW
  // ============================================================

  Widget _buildActionRow({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.inputText,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STAT ITEM
  // ============================================================

  Widget _buildStatItem(
      String value,
      String label,
      ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.inputText,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DIVIDER STAT
  // ============================================================

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }


  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person_off_outlined,
                size: 34,
                color: Color(0xFFE11D48),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Profil indisponible',
              style: GoogleFonts.nunito(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textDark,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              _error ??
                  'Impossible de charger votre profil.',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                'Réessayer',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// EXTENSION STATISTIQUES PROPRIÉTAIRE
// ============================================================================
//
// Ton BackendService actuel ne possède pas encore getOwnerStats().
// Cette extension permet de conserver ton BackendService tel quel.
//
// Elle récupère :
// - nombre de biens du propriétaire
// - nombre de réservations liées à ses biens
// - nombre d'avis
// - note moyenne
//
// ============================================================================

extension DatabaseServiceOwnerStats on DatabaseService {
  Future<Map<String, dynamic>> getOwnerStats() async {
    final userId = currentUserId();

    if (userId == null) {
      return {
        'biens': 0,
        'reservations': 0,
        'avis': 0,
        'note': 0.0,
      };
    }

    try {
      // 1. APPARTEMENTS DU PROPRIÉTAIRE
      final appartements = await supabase
          .from('appartements')
          .select('id')
          .eq('proprietaire_id', userId);

      final appartementList =
      List<Map<String, dynamic>>.from(appartements);

      final appartementIds =
      appartementList.map((item) => item['id'].toString()).toList();

      if (appartementIds.isEmpty) {
        return {
          'biens': 0,
          'reservations': 0,
          'avis': 0,
          'note': 0.0,
        };
      }

      // 2. RÉSERVATIONS
      final reservations = await supabase
          .from('reservations')
          .select('id')
          .inFilter('appartement_id', appartementIds);

      final nombreReservations = (reservations as List).length;

      // 3. AVIS
      final ratings = await supabase
          .from('ratings')
          .select('rating')
          .inFilter('appartement_id', appartementIds);

      final ratingList = List<Map<String, dynamic>>.from(ratings);

      double moyenne = 0.0;

      if (ratingList.isNotEmpty) {
        double total = 0;
        for (final rating in ratingList) {
          final value = rating['rating'];
          if (value is num) {
            total += value.toDouble();
          }
        }
        moyenne = total / ratingList.length;
      }

      return {
        'biens': appartementIds.length,
        'reservations': nombreReservations,
        'avis': ratingList.length,
        'note': moyenne,
      };
    } catch (e) {
      debugPrint('❌ getOwnerStats: $e');
      return {
        'biens': 0,
        'reservations': 0,
        'avis': 0,
        'note': 0.0,
      };
    }
  }
}

// ============================================================================
// EXTENSION CERTIFICATION PROPRIÉTAIRE
// ============================================================================

extension DatabaseServiceCertification on DatabaseService {
  Future<Map<String, dynamic>> getCertificationStatus() async {
    final userId = currentUserId();

    if (userId == null) {
      return {
        'is_certified': false,
        'profile_complete': false,
        'identity_verified': false,
        'missing_fields': <String>[],
        'missing_documents': <String>[],
        'progress': 0.0,
      };
    }

    try {
      final profile = await supabase
          .from('users')
          .select('''
            nom,
            prenom,
            email,
            telephone,
            pays,
            ville,
            adresse,
            date_naissance,
            est_certifie,
            identite_verifiee
          ''')
          .eq('id', userId)
          .maybeSingle();

      if (profile == null) {
        return {
          'is_certified': false,
          'profile_complete': false,
          'identity_verified': false,
          'missing_fields': <String>['Profil introuvable'],
          'missing_documents': <String>[],
          'progress': 0.0,
        };
      }

      final requiredFields = <String, String>{
        'nom': 'Nom',
        'prenom': 'Prénom',
        'email': 'Email',
        'telephone': 'Téléphone',
        'pays': 'Pays',
        'ville': 'Ville',
        'adresse': 'Adresse',
        'date_naissance': 'Date de naissance',
      };

      final missingFields = <String>[];

      for (final entry in requiredFields.entries) {
        final value = profile[entry.key]?.toString().trim() ?? '';
        if (value.isEmpty) {
          missingFields.add(entry.value);
        }
      }

      final profileComplete = missingFields.isEmpty;

      final docsResponse = await supabase
          .from('documents')
          .select('type_document, cote_document, statut, date_expiration')
          .eq('user_id', userId)
          .eq('categorie', 'identite');

      final docs = List<Map<String, dynamic>>.from(docsResponse);

      bool isValid(Map<String, dynamic> doc) {
        if (doc['statut'] != 'valide') return false;
        final exp = doc['date_expiration'];
        if (exp == null) return true;
        try {
          final date = DateTime.parse(exp.toString());
          return !date.isBefore(DateTime.now());
        } catch (_) {
          return true;
        }
      }

      final validDocs = docs.where(isValid).toList();

      final cniRectoValid = validDocs.any(
            (d) =>
        d['type_document'] == 'carte_identite' &&
            d['cote_document'] == 'recto',
      );

      final cniVersoValid = validDocs.any(
            (d) =>
        d['type_document'] == 'carte_identite' &&
            d['cote_document'] == 'verso',
      );

      final cniValid = cniRectoValid && cniVersoValid;

      final passportValid = validDocs.any(
            (d) => d['type_document'] == 'passeport',
      );

      final permisValid = validDocs.any(
            (d) => d['type_document'] == 'permis_conduire',
      );

      final identityVerified = cniValid || passportValid || permisValid;

      final missingDocuments = <String>[];

      if (!identityVerified) {
        missingDocuments.add("Pièce d'identité valide");
      }

      final dbCertified = profile['est_certifie'] == true;
      final dbVerified = profile['identite_verifiee'] == true;

      final isCertified =
          dbCertified && dbVerified && identityVerified;

      const totalPoints = 9;
      final filledPoints =
          (requiredFields.length - missingFields.length) +
              (identityVerified ? 1 : 0);

      final progress = (filledPoints / totalPoints).clamp(0.0, 1.0);

      return {
        'is_certified': isCertified,
        'profile_complete': profileComplete,
        'identity_verified': identityVerified,
        'missing_fields': missingFields,
        'missing_documents': missingDocuments,
        'progress': progress,
      };
    } catch (e) {
      debugPrint('❌ getCertificationStatus : $e');

      return {
        'is_certified': false,
        'profile_complete': false,
        'identity_verified': false,
        'missing_fields': <String>[],
        'missing_documents': <String>[],
        'progress': 0.0,
      };
    }
  }
}