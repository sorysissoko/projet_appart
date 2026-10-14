// lib/appartements/details_appartement_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/navigation/main_wrapper.dart';

// ============================================================
// SKELETON WIDGETS
// ============================================================

class _SkeletonCarousel extends StatefulWidget {
  const _SkeletonCarousel();

  @override
  State<_SkeletonCarousel> createState() => _SkeletonCarouselState();
}

class _SkeletonCarouselState extends State<_SkeletonCarousel>
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
      child: SizedBox(
        height: 350,
        child: Stack(
          children: [
            // Image skeleton
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1B3A6B).withValues(alpha: 0.6),
                    const Color(0xFF0F1B2D).withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
            // Retour skeleton
            Positioned(
              top: MediaQuery.of(context).padding.top - 20,
              left: 12,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Statut skeleton
            Positioned(
              top: MediaQuery.of(context).padding.top - 10,
              right: 16,
              child: Container(
                width: 80,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            // Titre skeleton
            Positioned(
              left: 16,
              right: 16,
              bottom: 90,
              child: Container(
                height: 21,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            // Prix skeleton
            Positioned(
              left: 16,
              right: 16,
              bottom: 40,
              child: Row(
                children: [
                  Container(
                    width: 120,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Colors.white70,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 40,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
            // Adresse skeleton
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Row(
                children: [
                  Container(
                    width: 17,
                    height: 17,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
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

class _SkeletonSectionCard extends StatefulWidget {
  final bool hasMultipleLines;

  const _SkeletonSectionCard({this.hasMultipleLines = true});

  @override
  State<_SkeletonSectionCard> createState() => _SkeletonSectionCardState();
}

class _SkeletonSectionCardState extends State<_SkeletonSectionCard>
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
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
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
            // Titre skeleton
            Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 12),
            // Lignes skeleton
            if (widget.hasMultipleLines) ...[
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ] else ...[
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 14,
                width: 150,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SkeletonActionButtons extends StatefulWidget {
  const _SkeletonActionButtons();

  @override
  State<_SkeletonActionButtons> createState() => _SkeletonActionButtonsState();
}

class _SkeletonActionButtonsState extends State<_SkeletonActionButtons>
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
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FA),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAGE DETAILS APPARTEMENT
// ============================================================

class DetailsAppartementPage extends StatefulWidget {
  final NavigateCallback onNavigate;
  final String? appartementId;

  const DetailsAppartementPage({
    super.key,
    required this.onNavigate,
    this.appartementId,
  });

  @override
  State<DetailsAppartementPage> createState() =>
      _DetailsAppartementPageState();
}

class _DetailsAppartementPageState extends State<DetailsAppartementPage> {
  // ============================================================
  // SUPABASE
  // ============================================================

  SupabaseClient get _supabase => Supabase.instance.client;

  // ============================================================
  // ÉTAT
  // ============================================================

  bool _isLoading = true;
  String? _errorMessage;

  Map<String, dynamic>? _appartement;
  Map<String, dynamic>? _infos;
  Map<String, dynamic>? _role;

  final List<String> _photos = [];

  Map<String, bool> _equipements = {};

  int _currentPhotoIndex = 0;

  // ============================================================
  // CONSTANTES
  // ============================================================

  static const Color _primaryColor = Color(0xFF1B3A6B);
  static const Color _darkColor = Color(0xFF0F1B2D);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _backgroundColor = Color(0xFFF4F6FB);
  static const Color _greenColor = Color(0xFF10B981);
  static const Color _orangeColor = Color(0xFFD97706);
  static const Color _redColor = Color(0xFFEF4444);

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  // ============================================================
  // CHARGEMENT GLOBAL
  // ============================================================

  Future<void> _loadDetails() async {
    final appartementId = widget.appartementId?.trim();

    if (appartementId == null || appartementId.isEmpty) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Aucun ID d\'appartement fourni.';
      });

      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _currentPhotoIndex = 0;
      });
    }

    try {
      // ==========================================================
      // 1. RÉCUPÉRER L'APPARTEMENT
      // ==========================================================

      final appartementResponse = await _supabase
          .from('appartements')
          .select('*')
          .eq('id', appartementId)
          .maybeSingle();

      if (appartementResponse == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'Appartement introuvable.';
        });

        return;
      }

      _appartement = Map<String, dynamic>.from(appartementResponse);

      // ==========================================================
      // 2. RÉINITIALISER LES DONNÉES ASSOCIÉES
      // ==========================================================

      _infos = null;
      _role = null;
      _photos.clear();
      _equipements = {};

      // ==========================================================
      // 3. CHARGEMENT EN PARALLÈLE
      // ==========================================================

      await Future.wait([
        _fetchProprietaire(),
        _fetchInfos(appartementId),
        _fetchRole(appartementId),
        _fetchPhotos(appartementId),
        _fetchEquipements(appartementId),
      ]);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      debugPrint(
        '✅ Tous les détails chargés pour l\'appartement $appartementId',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Erreur chargement détails : $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = _getFriendlyError(e);
      });
    }
  }

  // ============================================================
  // PROPRIÉTAIRE
  // ============================================================

  Future<void> _fetchProprietaire() async {
    final proprietaireId =
    _appartement?['proprietaire_id']?.toString().trim();

    if (proprietaireId == null || proprietaireId.isEmpty) {
      return;
    }

    try {
      final userResponse = await _supabase
          .from('users')
          .select(
        'id, nom, prenom, email, telephone, photo_profil',
      )
          .eq('id', proprietaireId)
          .maybeSingle();

      if (userResponse != null && _appartement != null) {
        _appartement!['users'] = Map<String, dynamic>.from(userResponse);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur récupération propriétaire : $e');
    }
  }

  // ============================================================
  // INFORMATIONS
  // ============================================================

  Future<void> _fetchInfos(String appartementId) async {
    try {
      final response = await _supabase
          .from('appartement_infos')
          .select('*')
          .eq('appartement_id', appartementId)
          .maybeSingle();

      if (response != null) {
        _infos = Map<String, dynamic>.from(response);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur récupération infos : $e');
    }
  }

  // ============================================================
  // RÈGLES
  // ============================================================

  Future<void> _fetchRole(String appartementId) async {
    try {
      final response = await _supabase
          .from('appartement_role')
          .select('*')
          .eq('appartement_id', appartementId)
          .maybeSingle();

      if (response != null) {
        _role = Map<String, dynamic>.from(response);
      }
    } catch (e) {
      debugPrint('⚠️ Erreur récupération règles : $e');
    }
  }

  // ============================================================
  // PHOTOS
  // ============================================================

  Future<void> _fetchPhotos(String appartementId) async {
    try {
      final response = await _supabase
          .from('photo_appartements')
          .select('*')
          .eq('appartement_id', appartementId)
          .order('est_principale', ascending: false)
          .order('ordre_affichage', ascending: true);

      final photoRows = List<Map<String, dynamic>>.from(response);

      _photos.clear();

      for (final photo in photoRows) {
        final filename =
            photo['fichiername']?.toString().trim() ?? '';

        if (filename.isEmpty) {
          continue;
        }

        final url = _getStoragePublicUrl(
          appartementId,
          filename,
        );

        if (url.isNotEmpty) {
          _photos.add(url);
        }
      }

      _currentPhotoIndex = 0;
    } catch (e) {
      debugPrint('⚠️ Erreur récupération photos : $e');
    }
  }

  // ============================================================
  // ÉQUIPEMENTS
  // ============================================================

  Future<void> _fetchEquipements(String appartementId) async {
    try {
      final response = await _supabase
          .from('appartements')
          .select('autres_equipements')
          .eq('id', appartementId)
          .maybeSingle();

      if (response == null) {
        return;
      }

      final rawEquipements = response['autres_equipements'];

      if (rawEquipements is Map) {
        final Map<String, bool> parsedEquipements = {};

        rawEquipements.forEach((key, value) {
          final equipementKey = key.toString();

          bool enabled = false;

          if (value is bool) {
            enabled = value;
          } else if (value is String) {
            enabled = value.toLowerCase() == 'true';
          } else if (value is num) {
            enabled = value != 0;
          }

          parsedEquipements[equipementKey] = enabled;
        });

        _equipements = parsedEquipements;
      }
    } catch (e) {
      debugPrint('⚠️ Erreur récupération équipements : $e');
    }
  }

  // ============================================================
  // URL STORAGE SUPABASE
  // ============================================================

  String _getStoragePublicUrl(
      String appartementId,
      String filename,
      ) {
    if (filename.isEmpty || appartementId.isEmpty) {
      return '';
    }

    if (filename.startsWith('http://') ||
        filename.startsWith('https://')) {
      return filename;
    }

    return 'https://rcaujtlhfyumkuwdfpcm.supabase.co/storage/v1/object/public/appartements/$appartementId/$filename';
  }

  // ============================================================
  // ERREURS
  // ============================================================

  String _getFriendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Impossible de contacter le serveur. Vérifiez votre connexion Internet.';
    }

    if (message.contains('permission') ||
        message.contains('rls') ||
        message.contains('unauthorized') ||
        message.contains('forbidden')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }

    return 'Impossible de charger les détails de l\'appartement. Veuillez réessayer.';
  }

  // ============================================================
  // FORMATAGE PRIX
  // ============================================================

  String _formatPrice(dynamic price) {
    num numericPrice = 0;

    if (price is num) {
      numericPrice = price;
    } else if (price is String) {
      numericPrice = num.tryParse(price) ?? 0;
    }

    if (numericPrice <= 0) {
      return 'Prix non défini';
    }

    final value = numericPrice.toInt().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      if (i > 0 && (value.length - i) % 3 == 0) {
        buffer.write(' ');
      }

      buffer.write(value[i]);
    }

    return '${buffer.toString()} FCFA';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null || _appartement == null) {
      return _buildErrorState();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _backgroundColor,
        body: CustomScrollView(
          slivers: [
            // HEADER / CAROUSEL
            SliverToBoxAdapter(
              child: _buildTopCarousel(),
            ),

            // CONTENU
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // DESCRIPTION
                    if (_hasDescription()) ...[
                      _buildDescription(),
                      const SizedBox(height: 16),
                    ],

                    // CARACTÉRISTIQUES
                    if (_infos != null) ...[
                      _buildCaracteristiques(),
                      const SizedBox(height: 16),
                    ],

                    // ÉQUIPEMENTS
                    if (_hasActiveEquipements()) ...[
                      _buildEquipements(),
                      const SizedBox(height: 16),
                    ],

                    // RÈGLES
                    if (_role != null) ...[
                      _buildRegles(),
                      const SizedBox(height: 16),
                    ],

                    // ACTIONS
                    _buildActions(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // HELPERS
  bool _hasDescription() {
    final description =
        _appartement?['description']?.toString().trim() ?? '';

    return description.isNotEmpty;
  }

  bool _hasActiveEquipements() {
    return _equipements.entries.any(
          (entry) => entry.value == true,
    );
  }

  // ============================================================
  // GALERIE PHOTO PLEIN ÉCRAN
  // ============================================================

  void _openPhotoGallery(int initialIndex) {
    if (_photos.isEmpty) return;

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: Stack(
                  children: [
                    // ==================================================
                    // GALERIE
                    // ==================================================

                    PageView.builder(
                      controller: PageController(
                        initialPage: initialIndex,
                      ),
                      itemCount: _photos.length,
                      onPageChanged: (index) {
                        setDialogState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 4.0,
                            panEnabled: true,
                            scaleEnabled: true,
                            child: Image.network(
                              _photos[index],
                              fit: BoxFit.contain,
                              width: double.infinity,
                              height: double.infinity,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }

                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: Colors.white70,
                                    size: 70,
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),

                    // ==================================================
                    // BOUTON FERMER
                    // ==================================================

                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.45,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // COMPTEUR
                    // ==================================================

                    Positioned(
                      top: 18,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(
                            alpha: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentIndex + 1}/${_photos.length}',
                          style: GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    // ==================================================
                    // INDICATION ZOOM
                    // ==================================================

                    if (_photos.length == 1)
                      Positioned(
                        bottom: 25,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(
                                alpha: 0.45,
                              ),
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.zoom_in,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Pincez pour zoomer',
                                  style: GoogleFonts.nunito(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ============================================================
  // HEADER + CAROUSEL
  // ============================================================

  Widget _buildTopCarousel() {
    final titre =
        _appartement?['titre']?.toString().trim() ?? 'Appartement';

    final ville =
        _appartement?['ville']?.toString().trim() ?? '';

    final adresse =
        _appartement?['adresse']?.toString().trim() ?? '';

    final prix = _appartement?['prix'] ?? 0;

    final status =
        _appartement?['disponibilite_status']?.toString().trim() ?? 'disponible';

    final nombreSejours =
        _appartement?['nbre_sejour'] ?? 0;

    final statusColor = _getStatusColor(status);
    final statusLabel = _getStatusLabel(status);

    final adresseComplete = [
      adresse,
      ville,
    ].where((element) => element.isNotEmpty).join(' / ');

    return SizedBox(
      height: 350,
      child: Stack(
        children: [
          // ========================================================
          // CAROUSEL
          // ========================================================

          PageView.builder(
            itemCount: _photos.isEmpty ? 1 : _photos.length,
            onPageChanged: (index) {
              if (!mounted) return;

              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              // ----------------------------------------------------
              // AUCUNE PHOTO
              // ----------------------------------------------------

              if (_photos.isEmpty) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0F1B2D),
                        Color(0xFF1B3A6B),
                        Color(0xFF2C5F8A),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.home_work_outlined,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                );
              }

              // PHOTO
              return GestureDetector(
                onTap: () {
                  _openPhotoGallery(index);
                },
                child: Image.network(
                  _photos[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (
                      context,
                      error,
                      stackTrace,
                      ) {
                    return Container(
                      color: _darkColor,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image_outlined,
                          color: Colors.white70,
                          size: 60,
                        ),
                      ),
                    );
                  },
                  loadingBuilder: (
                      context,
                      child,
                      loadingProgress,
                      ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return Container(
                      color: _darkColor,
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                          AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),

          // DÉGRADÉ
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [
                      0.0,
                      0.45,
                      1.0,
                    ],
                    colors: [
                      Colors.black54,
                      Colors.transparent,
                      Colors.black87,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // RETOUR
          Positioned(
            top: MediaQuery.of(context).padding.top - 20,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {
                  widget.onNavigate(
                    AppPage.mesAppartements,
                  );
                },
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 19,
                ),
              ),
            ),
          ),

          // STATUT
          Positioned(
            top: MediaQuery.of(context).padding.top - 10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.9),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    statusLabel,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TITRE
          Positioned(
            left: 16,
            right: 16,
            bottom: 90,
            child: Text(
              titre.isNotEmpty ? titre : 'Appartement',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w800,
                shadows: const [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // PRIX + SÉJOURS
          Positioned(
            left: 16,
            right: 16,
            bottom: 40,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    _formatPrice(prix),
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.white70,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 5),

                Text(
                  '$nombreSejours',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ADRESSE
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: Colors.white,
                  size: 17,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    adresseComplete.isNotEmpty
                        ? adresseComplete
                        : 'Adresse non renseignée',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white.withValues(
                        alpha: 0.92,
                      ),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // COMPTEUR PHOTOS
          if (_photos.length > 1)
            Positioned(
              bottom: 20,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_currentPhotoIndex + 1}/${_photos.length}',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUT
  // ============================================================

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'disponible':
        return _greenColor;

      case 'occupied':
      case 'occupe':
      case 'occupé':
        return _orangeColor;

      case 'maintenance':
        return _redColor;

      default:
        return _secondaryTextColor;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'disponible':
        return 'Disponible';

      case 'occupied':
      case 'occupe':
      case 'occupé':
        return 'Occupé';

      case 'maintenance':
        return 'Maintenance';

      default:
        return status.isNotEmpty ? status : 'Inconnu';
    }
  }

  // ============================================================
  // DESCRIPTION
  // ============================================================

  Widget _buildDescription() {
    final description =
        _appartement?['description']?.toString().trim() ?? '';

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _darkColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CARACTÉRISTIQUES
  // ============================================================

  Widget _buildCaracteristiques() {
    final items = <Map<String, dynamic>>[
      {
        'icon': Icons.bed_outlined,
        'label': 'Chambres',
        'value': _infos?['chambre'] ?? 0,
      },
      {
        'icon': Icons.weekend_outlined,
        'label': 'Salons',
        'value': _infos?['salon'] ?? 0,
      },
      {
        'icon': Icons.shower_outlined,
        'label': 'SDB',
        'value': _infos?['douche'] ?? 0,
      },
      {
        'icon': Icons.kitchen_outlined,
        'label': 'Cuisines',
        'value': _infos?['cuisine'] ?? 0,
      },
      {
        'icon': Icons.stairs_outlined,
        'label': 'Étage',
        'value': _infos?['etage'] ?? 0,
      },
      {
        'icon': Icons.square_foot_outlined,
        'label': 'Superficie',
        'value': '${_infos?['taille'] ?? 0} m²',
      },
    ];

    final activeItems = items.where((item) {
      final value = item['value'];

      if (value is num) {
        return value > 0;
      }

      final stringValue = value.toString().trim();

      return stringValue.isNotEmpty &&
          stringValue != '0' &&
          stringValue != '0.0';
    }).toList();

    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caractéristiques',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _darkColor,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeItems.map((item) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 16,
                      color: _secondaryTextColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${item['label']}: ${item['value']}',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: _darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ÉQUIPEMENTS
  // ============================================================

  Widget _buildEquipements() {
    final activeEquipements = _equipements.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (activeEquipements.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Équipements',
                style: GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _darkColor,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${activeEquipements.length}',
                  style: GoogleFonts.nunito(
                    color: _darkColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeEquipements.map((equipement) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FA),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 14,
                      color: _greenColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _formatEquipementName(equipement),
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: _darkColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOMS DES ÉQUIPEMENTS
  // ============================================================

  String _formatEquipementName(String key) {
    const names = <String, String>{
      'piscine': 'Piscine',
      'ascenseur': 'Ascenseur',
      'baignoire': 'Baignoire',
      'seche_cheveux': 'Sèche-cheveux',
      'produits_nettoyage': 'Produits de nettoyage',
      'shampooing': 'Shampooing',
      'savon_corps': 'Savon corps',
      'eau_chaude': 'Eau chaude',
      'gel_douche': 'Gel douche',
      'laveuse_gratuite': 'Laveuse gratuite',
      'secheuse_gratuite': 'Sècheuse gratuite',
      'serviettes_draps': 'Serviettes et draps',
      'cintres': 'Cintres',
      'fer_repasser': 'Fer à repasser',
      'sechoir_vetements': 'Séchoir à vêtements',
      'refrigerateur': 'Réfrigérateur',
      'micro_ondes': 'Micro-ondes',
      'bases_cuisine': 'Bases de cuisine',
      'plats_argenterie': 'Plats et argenterie',
      'congelateur': 'Congélateur',
      'lave_vaisselle': 'Lave-vaisselle',
      'cuisiniere_gaz': 'Cuisinière à gaz',
      'four': 'Four',
      'bouilloire': 'Bouilloire',
      'cafetiere': 'Cafetière',
      'verres_vin': 'Verres à vin',
      'grille_pain': 'Grille-pain',
      'mixeur': 'Mixeur',
      'table_manger': 'Table à manger',
      'serrure_chambre': 'Serrure de chambre',
      'camera_exterieure': 'Caméra extérieure',
      'alarme_monoxyde_carbone':
      'Alarme monoxyde de carbone',
      'television': 'Télévision',
    };

    return names[key] ??
        key.replaceAll('_', ' ').trim();
  }

  // ============================================================
  // RÈGLES
  // ============================================================

  Widget _buildRegles() {
    if (_role == null) {
      return const SizedBox.shrink();
    }

    final heureArrivee =
        _role?['heure_arrive']?.toString() ?? '14:00';

    final heureDepart =
        _role?['heure_depart']?.toString() ?? '12:00';

    final nombreClient =
        _role?['nombre_client'] ?? 1;

    final description =
        _role?['description']?.toString().trim() ?? '';

    final List<Map<String, dynamic>> regles = [
      if (description.isNotEmpty)
        {
          'icon': Icons.description_outlined,
          'label': 'Règles',
          'value': description,
        },
      {
        'icon': Icons.login_outlined,
        'label': 'Arrivée',
        'value': heureArrivee,
      },
      {
        'icon': Icons.logout_outlined,
        'label': 'Départ',
        'value': heureDepart,
      },
      {
        'icon': Icons.people_outlined,
        'label': 'Max. clients',
        'value': '$nombreClient',
      },
    ];

    if (regles.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Règles du séjour',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _darkColor,
            ),
          ),
          const SizedBox(height: 12),

          ...regles.map((regle) {
            final iconData =
            regle['icon'] as IconData;

            final label =
            regle['label'] as String;

            final value =
            regle['value'] as String;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                    child: Icon(
                      iconData,
                      size: 19,
                      color: _secondaryTextColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color:
                            _secondaryTextColor,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          value,
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: _darkColor,
                            fontWeight:
                            FontWeight.w600,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIONS
  // ============================================================

  Widget _buildActions() {
    return Row(
      children: [
        // MODIFIER
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onNavigate(
                AppPage.modifierAppartement,
                appartementId:
                widget.appartementId,
              );
            },
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
            ),
            label: Text(
              'Modifier',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // PHOTOS
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              widget.onNavigate(
                AppPage.gestionPhotos,
                appartementId:
                widget.appartementId,
              );
            },
            icon: const Icon(
              Icons.photo_library_outlined,
              size: 18,
            ),
            label: Text(
              'Photos',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orangeColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets.symmetric(
                vertical: 14,
              ),
              shape:
              RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CARD COMMUNE
  // ============================================================

  Widget _buildCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color:
            Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  // ============================================================
  // LOADING STATE AVEC SKELETONS
  // ============================================================

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Carousel skeleton
            const SliverToBoxAdapter(
              child: _SkeletonCarousel(),
            ),

            // Contenu skeleton
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    // Description skeleton
                    const _SkeletonSectionCard(hasMultipleLines: true),
                    const SizedBox(height: 16),

                    // Caractéristiques skeleton
                    const _SkeletonSectionCard(hasMultipleLines: false),
                    const SizedBox(height: 16),

                    // Équipements skeleton
                    const _SkeletonSectionCard(hasMultipleLines: false),
                    const SizedBox(height: 16),

                    // Règles skeleton
                    const _SkeletonSectionCard(hasMultipleLines: true),
                    const SizedBox(height: 16),

                    // Actions skeleton
                    const _SkeletonActionButtons(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                // ICON
                const Icon(
                  Icons.error_outline,
                  color: _redColor,
                  size: 64,
                ),

                const SizedBox(height: 16),

                // TITRE
                Text(
                  'Erreur',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _darkColor,
                  ),
                ),

                const SizedBox(height: 8),

                // MESSAGE
                Text(
                  _errorMessage ??
                      'Une erreur est survenue.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color:
                    _secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 20),

                // RÉESSAYER
                ElevatedButton.icon(
                  onPressed: _loadDetails,
                  icon: const Icon(
                    Icons.refresh,
                  ),
                  label: Text(
                    'Réessayer',
                    style: GoogleFonts.nunito(
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    _primaryColor,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // RETOUR
                TextButton(
                  onPressed: () {
                    widget.onNavigate(
                      AppPage.mesAppartements,
                    );
                  },
                  child: Text(
                    'Retour à la liste',
                    style: GoogleFonts.nunito(
                      color:
                      _secondaryTextColor,
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
}