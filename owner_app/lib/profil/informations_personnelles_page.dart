import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:service/database_service.dart';

// ============================================================
// PAGE
// ============================================================

class InformationsPersonnellesPage extends StatefulWidget {
  final VoidCallback? onBack;

  const InformationsPersonnellesPage({
    super.key,
    this.onBack,
  });

  @override
  State<InformationsPersonnellesPage> createState() =>
      _InformationsPersonnellesPageState();
}

class _InformationsPersonnellesPageState
    extends State<InformationsPersonnellesPage> {
  // ============================================================
  // SERVICES
  // ============================================================

  final DatabaseService _backendService = DatabaseService();
  final ImagePicker _picker = ImagePicker();

  // ============================================================
  // CONTRÔLEURS
  // ============================================================

  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _urgencephoneController = TextEditingController();
  final _dateNaissanceController = TextEditingController();
  final _paysController = TextEditingController();
  final _villeController = TextEditingController();
  final _adresseController = TextEditingController();

  // ============================================================
  // ÉTATS
  // ============================================================

  bool _isLoading = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _error;

  File? _newPhoto;
  String? _existingPhotoPath; // chemin dans le bucket

  DateTime? _createdAt;
  DateTime? _updatedAt;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _urgencephoneController.dispose();
    _dateNaissanceController.dispose();
    _paysController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  // ============================================================
  // CHARGEMENT PROFIL
  // ============================================================

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

      _prenomController.text =
          (profile['prenom'] ?? '').toString().trim();
      _nomController.text =
          (profile['nom'] ?? '').toString().trim();
      _emailController.text =
          (profile['email'] ?? '').toString().trim();
      _telephoneController.text =
          (profile['telephone'] ?? '').toString().trim();
      _urgencephoneController.text =
          (profile['urgencephone'] ?? '').toString().trim();
      _paysController.text =
          (profile['pays'] ?? '').toString().trim();
      _villeController.text =
          (profile['ville'] ?? '').toString().trim();
      _adresseController.text =
          (profile['adresse'] ?? '').toString().trim();

      final dateNaissance = profile['date_naissance'];
      if (dateNaissance != null && dateNaissance.toString().isNotEmpty) {
        try {
          final parsed = DateTime.parse(dateNaissance.toString());
          _dateNaissanceController.text =
              DateFormat('yyyy-MM-dd').format(parsed);
        } catch (_) {}
      }

      // Photo de profil (chemin dans le bucket)
      _existingPhotoPath =
          profile['photo_profil']?.toString().trim();

      // Dates
      _createdAt = _parseDate(profile['created_at']);
      _updatedAt = _parseDate(profile['updated_at']);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e, st) {
      debugPrint('❌ Erreur chargement profil : $e');
      debugPrint('$st');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = 'Une erreur est survenue lors du chargement.';
      });
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    try {
      return DateTime.parse(value.toString());
    } catch (_) {
      return null;
    }
  }

  // ============================================================
  // CHOISIR PHOTO
  // ============================================================

  Future<void> _handlePhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );

      if (picked == null) return;

      setState(() {
        _newPhoto = File(picked.path);
      });
    } catch (e) {
      debugPrint('❌ Erreur sélection photo : $e');
      _showError('Impossible de sélectionner l’image.');
    }
  }

  // ============================================================
  // CHOISIR DATE DE NAISSANCE
  // ============================================================

  Future<void> _pickDateNaissance() async {
    DateTime initial = DateTime(1990, 1, 1);

    final current = _dateNaissanceController.text;
    if (current.isNotEmpty) {
      try {
        initial = DateTime.parse(current);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _dateNaissanceController.text =
          DateFormat('yyyy-MM-dd').format(picked);
    });
  }

  // ============================================================
  // SAUVEGARDE
  // ============================================================

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();

    if (prenom.isEmpty || nom.isEmpty) {
      _showError('Le prénom et le nom sont obligatoires.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      // --------------------------------------------------------
      // 1. UPLOAD PHOTO (si nouvelle photo)
      // --------------------------------------------------------
      if (_newPhoto != null) {
        final bytes = await _newPhoto!.readAsBytes();

        final extension =
        _newPhoto!.path.split('.').last.toLowerCase();

        // Détermine le MIME
        String mimeType = 'image/jpeg';
        if (extension == 'png') mimeType = 'image/png';
        if (extension == 'webp') mimeType = 'image/webp';

        await _backendService.uploadCurrentUserAvatar(
          bytes: bytes,
          extension: extension,
          mimeType: mimeType,
        );
      }

      // --------------------------------------------------------
      // 2. UPDATE PROFIL
      // --------------------------------------------------------
      await _backendService.updateProfile(
        nom: nom,
        prenom: prenom,
        telephone: _telephoneController.text.trim().isEmpty
            ? null
            : _telephoneController.text.trim(),
        urgencephone: _urgencephoneController.text.trim().isEmpty
            ? null
            : _urgencephoneController.text.trim(),
        ville: _villeController.text.trim().isEmpty
            ? null
            : _villeController.text.trim(),
        pays: _paysController.text.trim().isEmpty
            ? null
            : _paysController.text.trim(),
        adresse: _adresseController.text.trim().isEmpty
            ? null
            : _adresseController.text.trim(),
        dateNaissance: _dateNaissanceController.text.trim().isEmpty
            ? null
            : DateTime.tryParse(_dateNaissanceController.text.trim()),
      );

      if (!mounted) return;

      setState(() {
        _isSaving = false;
        _saved = true;
        _newPhoto = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modifications enregistrées'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF10B981),
        ),
      );

      // Recharge le profil pour rafraîchir la photo + updated_at
      await _loadProfile();

      if (!mounted) return;

      setState(() => _saved = false);
    } catch (e, st) {
      debugPrint('❌ Erreur sauvegarde profil : $e');
      debugPrint('$st');

      if (!mounted) return;

      setState(() => _isSaving = false);

      _showError('Impossible d’enregistrer les modifications.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }

  // ============================================================
  // GETTERS
  // ============================================================

  String get _initials {
    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();

    final first = prenom.isNotEmpty ? prenom[0] : '';
    final last = nom.isNotEmpty ? nom[0] : '';

    final result = '$first$last'.trim();
    return result.isEmpty ? '?' : result.toUpperCase();
  }


// BUILD
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Column(
          children: [
            // ====================================================
            // HEADER FIXE (ne défile pas)
            // ====================================================
            _buildHeader(),

            // ====================================================
            // CONTENU SCROLLABLE
            // ====================================================
            Expanded(
              child: _isLoading
                  ? _buildLoadingState()
                  : _error != null
                  ? _buildErrorState()
                  : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPhotoCard(),
                    const SizedBox(height: 14),
                    _buildIdentityCard(),
                    const SizedBox(height: 14),
                    _buildAddressCard(),
                    const SizedBox(height: 14),
                    _buildHistoryCard(),
                    const SizedBox(height: 14),
                    _buildSaveButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


// HEADER (style uniforme avec DocumentsPage — sans stats)
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12.w,
        MediaQuery.of(context).padding.top + 8.h,
        20.w,
        28.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ======================================================
          // CERCLE DÉCORATIF
          // ======================================================
          Positioned(
            right: -30.w,
            top: 0,
            child: Container(
              width: 140.w,
              height: 140.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          // ======================================================
          // CONTENU
          // ======================================================
          Row(
            children: [
              // Bouton retour
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    if (widget.onBack != null) {
                      widget.onBack!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // Titre + sous-titre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations personnelles',
                      style: GoogleFonts.outfit(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Mettez à jour les données de votre profil',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: Colors.white.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PHOTO CARD
  // ============================================================

  Widget _buildPhotoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              children: [
                _buildAvatar(),
                Positioned(
                  right: -2,
                  bottom: 2,
                  child: InkWell(
                    onTap: _handlePhoto,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Photo de profil',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'JPG ou PNG, 5 Mo maximum',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Nouvelle photo sélectionnée
    if (_newPhoto != null) {
      return ClipOval(
        child: Image.file(
          _newPhoto!,
          width: 86,
          height: 86,
          fit: BoxFit.cover,
        ),
      );
    }

    // Photo existante
    if (_existingPhotoPath != null && _existingPhotoPath!.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 86,
          height: 86,
          child: FutureBuilder<String?>(
            future: _backendService.supabase.storage
                .from('avatars')
                .createSignedUrl(_existingPhotoPath!, 3600),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  color: const Color(0xFFEEF2FA),
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2563EB),
                  ),
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return _buildDefaultAvatar();
              }

              return Image.network(
                snapshot.data!,
                width: 86,
                height: 86,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              );
            },
          ),
        ),
      );
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      width: 86,
      height: 86,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF97316), Color(0xFFFB923C)],
        ),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontSize: 30,
        ),
      ),
    );
  }

  // ============================================================
  // IDENTITÉ CARD
  // ============================================================

  Widget _buildIdentityCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Identité et contact',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 17),
          Row(
            children: [
              Expanded(
                child: _buildField(
                  controller: _prenomController,
                  label: 'Prénom',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildField(
                  controller: _nomController,
                  label: 'Nom',
                ),
              ),
            ],
          ),
          _buildField(
            controller: _emailController,
            label: 'Adresse email',
            keyboardType: TextInputType.emailAddress,
            readOnly: true,
          ),
          _buildField(
            controller: _telephoneController,
            label: 'Téléphone',
            keyboardType: TextInputType.phone,
          ),
          _buildField(
            controller: _urgencephoneController,
            label: 'Téléphone d’urgence',
            keyboardType: TextInputType.phone,
          ),
          _buildField(
            controller: _dateNaissanceController,
            label: 'Date de naissance',
            readOnly: true,
            onTap: _pickDateNaissance,
            suffixIcon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ADRESSE CARD
  // ============================================================

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adresse',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 17),
          _buildField(controller: _paysController, label: 'Pays'),
          _buildField(controller: _villeController, label: 'Ville'),
          _buildField(
            controller: _adresseController,
            label: 'Adresse complète',
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HISTORIQUE CARD
  // ============================================================

  Widget _buildHistoryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, size: 17, color: Color(0xFF2563EB)),
              const SizedBox(width: 9),
              Text(
                'Historique du compte',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: const Color(0xFF1E3A5F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildHistoryTile(
                  'created_at',
                  _formatFullDate(_createdAt),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildHistoryTile(
                  'updated_at',
                  _formatFullDate(_updatedAt),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime? date) {
    if (date == null) return '—';

    try {
      return DateFormat("d MMM yyyy, HH:mm", 'fr_FR').format(date);
    } catch (_) {
      return DateFormat("d MMM yyyy, HH:mm").format(date);
    }
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    IconData? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: const Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 7),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: readOnly
                  ? const Color(0xFF64748B)
                  : const Color(0xFF1E3A5F),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly
                  ? const Color(0xFFF1F5F9)
                  : Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              suffixIcon: suffixIcon != null
                  ? Icon(
                suffixIcon,
                size: 18,
                color: const Color(0xFF64748B),
              )
                  : null,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF2563EB),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOUTON ENREGISTRER
  // ============================================================

  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      decoration: BoxDecoration(
        color: _saved
            ? const Color(0xFF10B981)
            : const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSaving || _saved ? null : _handleSave,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 17),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSaving) ...[
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Enregistrement...',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ] else if (_saved) ...[
                  const Icon(Icons.check, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Modifications enregistrées',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ] else
                  Text(
                    'Enregistrer les modifications',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoadingState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(40),
        child: CircularProgressIndicator(color: Color(0xFF2563EB)),
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE4E6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 34,
                color: Color(0xFFE11D48),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Erreur de chargement',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F1B2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Impossible de charger votre profil.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DÉCORATION CARTE
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
}