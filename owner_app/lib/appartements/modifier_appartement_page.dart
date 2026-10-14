import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/navigation/main_wrapper.dart';

// SKELETON WIDGETS
class _SkeletonPreviewCard extends StatefulWidget {
  const _SkeletonPreviewCard();

  @override
  State<_SkeletonPreviewCard> createState() => _SkeletonPreviewCardState();
}

class _SkeletonPreviewCardState extends State<_SkeletonPreviewCard>
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 12,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image skeleton
              Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFEEF2FA),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titre skeleton
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Status buttons skeleton
                    Row(
                      children: List.generate(
                        3,
                            (index) => Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FA),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonFormField extends StatefulWidget {
  const _SkeletonFormField();

  @override
  State<_SkeletonFormField> createState() => _SkeletonFormFieldState();
}

class _SkeletonFormFieldState extends State<_SkeletonFormField>
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
        padding: const EdgeInsets.only(bottom: 14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 80,
              height: 13,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PAGE MODIFIER APPARTEMENT
class ModifierAppartementPage extends StatefulWidget {
  final NavigateCallback onNavigate;
  final String? appartementId;

  const ModifierAppartementPage({
    super.key,
    required this.onNavigate,
    this.appartementId,
  });

  @override
  State<ModifierAppartementPage> createState() =>
      _ModifierAppartementPageState();
}

class _ModifierAppartementPageState extends State<ModifierAppartementPage> {
  // SUPABASE
  SupabaseClient get _supabase => Supabase.instance.client;

  // ÉTAT
  bool _isLoading = true;
  bool _isSaving = false;
  bool _saved = false;
  String? _errorMessage;

  // Données de l'appartement
  String _disponibiliteStatus = 'disponible';
  String _appartementTitre = '';
  String _appartementId = '';

  // Controllers
  late TextEditingController _nomController;
  late TextEditingController _adresseController;
  late TextEditingController _villeController;
  late TextEditingController _superficieController;
  late TextEditingController _prixController;
  late TextEditingController _descriptionController;

  // URL de la photo
  String _photoUrl = '';

  // INITIALISATION
  @override
  void initState() {
    super.initState();

    _nomController = TextEditingController();
    _adresseController = TextEditingController();
    _villeController = TextEditingController();
    _superficieController = TextEditingController();
    _prixController = TextEditingController();
    _descriptionController = TextEditingController();

    _loadAppartementData();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _villeController.dispose();
    _superficieController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // CHARGEMENT DES DONNÉES
  Future<void> _loadAppartementData() async {
    if (widget.appartementId == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Aucun ID d\'appartement fourni.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appartementId = widget.appartementId.toString();

      // Récupérer les données de l'appartement
      final response = await _supabase
          .from('appartements')
          .select('''
            *,
            appartement_infos (
              chambre,
              salon,
              douche,
              cuisine,
              etage,
              taille,
              service_inclus,
              internet,
              stationnement,
              meuble,
              climatisation
            ),
            photo_appartements (
              id,
              fichiername,
              extension,
              est_principale,
              ordre_affichage
            )
          ''')
          .eq('id', appartementId)
          .maybeSingle();

      if (response == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Appartement introuvable.';
        });
        return;
      }

      // Remplir les controllers avec les données
      _appartementId = response['id']?.toString() ?? '';
      _appartementTitre = response['titre']?.toString() ?? '';

      _nomController.text = response['titre']?.toString() ?? '';
      _adresseController.text = response['adresse']?.toString() ?? '';
      _villeController.text = response['ville']?.toString() ?? '';
      _prixController.text = response['prix']?.toString() ?? '0';
      _descriptionController.text = response['description']?.toString() ?? '';
      _disponibiliteStatus = response['disponibilite_status']?.toString() ?? 'disponible';

      // Récupérer la superficie depuis appartement_infos
      final infos = response['appartement_infos'];
      if (infos != null && infos is Map) {
        final taille = infos['taille']?.toString() ?? '0';
        _superficieController.text = taille;
      }

      // Récupérer la photo principale
      final photos = response['photo_appartements'];
      if (photos != null && photos is List && photos.isNotEmpty) {
        // Trouver la photo principale ou prendre la première
        Map<String, dynamic>? mainPhoto;
        for (var photo in photos) {
          if (photo['est_principale'] == true) {
            mainPhoto = photo;
            break;
          }
        }
        if (mainPhoto == null && photos.isNotEmpty) {
          mainPhoto = photos.first;
        }

        if (mainPhoto != null) {
          final filename = mainPhoto['fichiername']?.toString() ?? '';
          if (filename.isNotEmpty) {
            _photoUrl = _getStoragePublicUrl(_appartementId, filename);
          }
        }
      }

      setState(() {
        _isLoading = false;
      });

      debugPrint('✅ Appartement chargé : $_appartementTitre');
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur chargement appartement : $e');
      debugPrint('$stackTrace');

      setState(() {
        _isLoading = false;
        _errorMessage = _getFriendlyError(e);
      });
    }
  }

  // URL STORAGE
  String _getStoragePublicUrl(String appartementId, String filename) {
    if (filename.isEmpty || appartementId.isEmpty) {
      return '';
    }

    if (filename.startsWith('http://') || filename.startsWith('https://')) {
      return filename;
    }

    return 'https://rcaujtlhfyumkuwdfpcm.supabase.co/storage/v1/object/public/appartements/$appartementId/$filename';
  }

  // MESSAGE D'ERREUR
  String _getFriendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion Internet.';
    }

    if (message.contains('permission') || message.contains('rls')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }

    return 'Impossible de charger les données de l\'appartement. Veuillez réessayer.';
  }

  // SAUVEGARDE
  Future<void> _handleSave() async {
    if (_isSaving) return;

    // Validation
    if (_nomController.text.trim().isEmpty) {
      _showError('Veuillez saisir le nom du bien.');
      return;
    }

    if (_adresseController.text.trim().isEmpty) {
      _showError('Veuillez saisir l\'adresse.');
      return;
    }

    final prix = double.tryParse(_prixController.text.trim());
    if (prix == null || prix <= 0) {
      _showError('Veuillez saisir un prix valide.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final appartementId = _appartementId;

      //Mettre à jour l'appartement
      await _supabase.from('appartements').update({
        'titre': _nomController.text.trim(),
        'adresse': _adresseController.text.trim(),
        'ville': _villeController.text.trim(),
        'prix': prix,
        'description': _descriptionController.text.trim(),
        'disponibilite_status': _disponibiliteStatus,
      }).eq('id', appartementId);

      //superficie
      final superficie = double.tryParse(_superficieController.text.trim()) ?? 0;

      //Vérifier si appartement_infos existe
      final existingInfos = await _supabase
          .from('appartement_infos')
          .select('id')
          .eq('appartement_id', appartementId)
          .maybeSingle();

      if (existingInfos != null) {
        //Mettre à jour
        await _supabase.from('appartement_infos').update({
          'taille': superficie,
        }).eq('appartement_id', appartementId);
      } else {
        //Créer
        await _supabase.from('appartement_infos').insert({
          'appartement_id': appartementId,
          'taille': superficie,
          'chambre': 0,
          'salon': 0,
          'douche': 0,
          'cuisine': 0,
          'etage': 0,
          'service_inclus': 'non',
          'internet': 'non',
          'stationnement': 'non',
          'meuble': 'non',
          'climatisation': 'non',
        });
      }

      setState(() {
        _saved = true;
        _isSaving = false;
      });

      _showSuccess('Modifications enregistrées avec succès !');

      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() => _saved = false);
        widget.onNavigate(AppPage.mesAppartements);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur sauvegarde : $e');
      debugPrint('$stackTrace');

      setState(() {
        _isSaving = false;
      });

      _showError('Erreur lors de la sauvegarde : $e');
    }
  }

  //SNACKBAR
  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.nunito()),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  void _showSuccess(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message, style: GoogleFonts.nunito()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Column(
        children: [

          // TITRE COLLÉ AU HEADER DU MAIN WRAPPER
          Container(
            width: double.infinity,
            color: Colors.transparent,
            padding: const EdgeInsets.fromLTRB(
              16,
              2,
              16,
              2,
            ),
            child: _buildPageTitle(),
          ),

          // CONTENU
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                5,
                16,
                10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // PHOTO + STATUT
                  _buildPreviewAndStatusCard(),

                  const SizedBox(height: 16),

                  // INFORMATIONS
                  _buildFormCard(),

                  const SizedBox(height: 16),

                  // ZONE DANGEREUSE
                  _buildDangerZone(),

                  const SizedBox(height: 16),

                  // ENREGISTRER
                  _buildSaveButton(),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // LOADING STATE AVEC SKELETONS
  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Column(
          children: [
            // Titre skeleton
            Container(
              width: double.infinity,
              color: Colors.transparent,
              padding: const EdgeInsets.fromLTRB(16, 2, 16, 2),
              child: Row(
                children: [
                  Container(
                    width: 90,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 20,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Contenu skeleton
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 5, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const _SkeletonPreviewCard(),
                    const SizedBox(height: 16),
                    // Form card skeleton
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const _SkeletonFormField(),
                          const _SkeletonFormField(),
                          const _SkeletonFormField(),
                          Row(
                            children: [
                              Expanded(child: const _SkeletonFormField()),
                              const SizedBox(width: 10),
                              Expanded(child: const _SkeletonFormField()),
                            ],
                          ),
                          const _SkeletonFormField(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Danger zone skeleton
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFFEE2E2)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.06),
                            blurRadius: 12,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 130,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF2F2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Save button skeleton
                    Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ERROR STATE
  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Color(0xFFEF4444),
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Erreur',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F1B2D),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _loadAppartementData,
                  icon: const Icon(Icons.refresh),
                  label: Text(
                    'Réessayer',
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B3A6B),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => widget.onNavigate(AppPage.mesAppartements),
                  child: Text(
                    'Retour à la liste',
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // PAGE TITLE
  Widget _buildPageTitle() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () {
            widget.onNavigate(AppPage.mesAppartements);
          },
          icon: const Icon(
            Icons.arrow_back_ios_new_outlined,
            size: 24,
          ),
          label: Text(
            'Retour',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF1B3A6B),
            side: const BorderSide(
              color: Color(0xFFD9E1EF),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),

        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bien #${widget.appartementId ?? '?'} · $_appartementTitre',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // PREVIEW & STATUS
  Widget _buildPreviewAndStatusCard() {
    final disponibiliteList = [
      {
        'key': 'disponible',
        'label': '🟢 Disponible',
      },
      {
        'key': 'occupe',
        'label': '🟡 Occupé',
      },
      {
        'key': 'maintenance',
        'label': '🔴 Maintenance',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _photoUrl.isNotEmpty
                    ? Image.network(
                  _photoUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF1B3A6B),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      _buildImagePlaceholder(),
                )
                    : _buildImagePlaceholder(),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: ElevatedButton(
                    onPressed: () => widget.onNavigate(
                      AppPage.gestionPhotos,
                      appartementId: widget.appartementId,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black.withValues(alpha: 0.65),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '📷 Gérer les photos',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statut du bien',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F1B2D),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: disponibiliteList.map((s) {
                      final isSelected = _disponibiliteStatus == s['key'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _disponibiliteStatus = s['key']!;
                              });
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFEEF2FA)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF1B3A6B)
                                      : const Color(0xFFE2E8F0),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  s['label']!,
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected
                                        ? const Color(0xFF1B3A6B)
                                        : const Color(0xFF8A94A6),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // IMAGE PLACEHOLDER
  Widget _buildImagePlaceholder() {
    return Container(
      height: 140,
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(
          Icons.home_work_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  // FORM CARD
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informations',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F1B2D),
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(label: 'Nom du bien', controller: _nomController),
          _buildTextField(label: 'Adresse', controller: _adresseController),
          _buildTextField(label: 'Ville', controller: _villeController),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'Superficie (m²)',
                  controller: _superficieController,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTextField(
                  label: 'Prix / nuit (FCFA)',
                  controller: _prixController,
                  keyboardType: TextInputType.number,
                  isPrice: true,
                ),
              ),
            ],
          ),
          _buildTextField(
            label: 'Description',
            controller: _descriptionController,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool isPrice = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF0F1B2D),
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: isPrice
                ? GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFC9913A),
            )
                : GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF0F1B2D),
            ),
            decoration: InputDecoration(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                  color: Color(0xFF1B3A6B),
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DANGER ZONE
  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFEE2E2)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Zone dangereuse',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showDeleteConfirmation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: const BorderSide(color: Color(0xFFFEE2E2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                '🗑️ Supprimer ce bien',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // DELETE CONFIRMATION
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Supprimer le bien',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ce bien ? Cette action est irréversible.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.outfit(
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAppartement();
            },
            child: Text(
              'Supprimer',
              style: GoogleFonts.outfit(
                color: const Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAppartement() async {
    if (_appartementId.isEmpty) return;

    try {
      await _supabase
          .from('appartements')
          .delete()
          .eq('id', _appartementId);

      _showSuccess('Appartement supprimé avec succès.');

      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        widget.onNavigate(AppPage.mesAppartements);
      }
    } catch (e) {
      _showError('Erreur lors de la suppression : $e');
    }
  }

  // ============================================================
  // SAVE BUTTON
  // ============================================================

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: _saved
                ? const Color(0xFF10B981)
                : _isSaving
                ? const Color(0xFF94A3B8)
                : const Color(0xFF1B3A6B),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _isSaving
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            _saved
                ? '✓ Modifications enregistrées !'
                : 'Enregistrer les modifications',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}