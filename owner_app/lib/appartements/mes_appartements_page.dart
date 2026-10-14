import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/navigation/main_wrapper.dart';
import '../core/theme/app_theme.dart';

// ============================================================
// STATUTS DES APPARTEMENTS
// ============================================================

enum DisponibiliteStatus {
  disponible,
  occupe,
  maintenance,
}

class StatusConfig {
  final String label;
  final Color color;
  final Color bg;
  final Color dot;

  const StatusConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.dot,
  });
}

const Map<DisponibiliteStatus, StatusConfig> statusConfigMap = {
  DisponibiliteStatus.disponible: StatusConfig(
    label: 'Disponible',
    color: Color(0xFF10B981),
    bg: Color(0xFFECFDF5),
    dot: Color(0xFF10B981),
  ),
  DisponibiliteStatus.occupe: StatusConfig(
    label: 'Occupé',
    color: Color(0xFFC9913A),
    bg: Color(0xFFFEF9EC),
    dot: Color(0xFFC9913A),
  ),
  DisponibiliteStatus.maintenance: StatusConfig(
    label: 'Maintenance',
    color: Color(0xFFEF4444),
    bg: Color(0xFFFEF2F2),
    dot: Color(0xFFEF4444),
  ),
};

// ============================================================
// STATUTS DES RÉSIDENCES
// ============================================================

class ResidenceStatusConfig {
  final String label;
  final Color color;
  final Color bg;
  final Color dot;

  const ResidenceStatusConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.dot,
  });
}

const Map<String, ResidenceStatusConfig>
residenceStatusConfigMap = {
  'en_attente': ResidenceStatusConfig(
    label: 'En attente',
    color: Color(0xFFD97706),
    bg: Color(0xFFFFF7ED),
    dot: Color(0xFFD97706),
  ),
  'en_verification': ResidenceStatusConfig(
    label: 'En vérification',
    color: Color(0xFF2563EB),
    bg: Color(0xFFEFF6FF),
    dot: Color(0xFF2563EB),
  ),
  'validee': ResidenceStatusConfig(
    label: 'Validée',
    color: Color(0xFF10B981),
    bg: Color(0xFFECFDF5),
    dot: Color(0xFF10B981),
  ),
  'refusee': ResidenceStatusConfig(
    label: 'Refusée',
    color: Color(0xFFEF4444),
    bg: Color(0xFFFEF2F2),
    dot: Color(0xFFEF4444),
  ),
  'supprimee': ResidenceStatusConfig(
    label: 'Supprimée',
    color: Color(0xFF64748B),
    bg: Color(0xFFF1F5F9),
    dot: Color(0xFF64748B),
  ),
};

// ============================================================
// MODÈLE APPARTEMENT
// ============================================================

class Appartement {
  final String id;
  final String name;
  final String address;
  final double price;
  final DisponibiliteStatus status;
  final String img;
  final double rating;
  final int reviews;
  final int taille;

  const Appartement({
    required this.id,
    required this.name,
    required this.address,
    required this.price,
    required this.status,
    required this.img,
    required this.rating,
    required this.reviews,
    required this.taille,
  });

  // ==========================================================
  // FROM MAP
  // ==========================================================

  factory Appartement.fromMap(
      Map<String, dynamic> data, {
        String photo = '',
      }) {
    return Appartement(
      id: data['id']?.toString() ?? '',
      name: _string(
        data['titre'],
        fallback: 'Appartement sans titre',
      ),
      address: _buildAddress(data),
      price: _parseDouble(
        data['prix'],
      ),
      status: _parseStatus(
        data['disponibilite_status'] ??
            data['status'],
      ),
      img: photo,
      rating: _parseDouble(
        data['rating'],
      ),
      reviews: _parseInt(
        data['ratings_count'],
      ),
      taille: _getTaille(data),
    );
  }

  // ==========================================================
  // STRING
  // ==========================================================

  static String _string(
      dynamic value, {
        String fallback = '',
      }) {
    final result =
        value?.toString().trim() ?? '';

    return result.isEmpty
        ? fallback
        : result;
  }

  // ==========================================================
  // INT
  // ==========================================================

  static int _parseInt(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is int) {
      return value;
    }

    if (value is double) {
      return value.round();
    }

    final cleaned = value
        .toString()
        .replaceAll(
      RegExp(r'[^0-9-]'),
      '',
    );

    return int.tryParse(
      cleaned,
    ) ??
        0;
  }

  // ==========================================================
  // DOUBLE
  // ==========================================================

  static double _parseDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is double) {
      return value;
    }

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
      value
          .toString()
          .replaceAll(',', '.'),
    ) ??
        0;
  }

  // ==========================================================
  // STATUT
  // ==========================================================

  static DisponibiliteStatus _parseStatus(
      dynamic value,
      ) {
    final status =
        value?.toString().trim().toLowerCase() ?? '';

    switch (status) {
      case 'disponible':
        return DisponibiliteStatus.disponible;

      case 'occupe':
      case 'occupé':
      case 'occupé':
        return DisponibiliteStatus.occupe;

      case 'maintenance':
      case 'maint':
      case 'maintenace':
        return DisponibiliteStatus.maintenance;

      default:
        return DisponibiliteStatus.disponible;
    }
  }

  // ==========================================================
  // ADRESSE
  // ==========================================================

  static String _buildAddress(
      Map<String, dynamic> data,
      ) {
    final residence = data['residences'];

    if (residence is! Map) {
      return 'Adresse non renseignée';
    }

    final adresse =
        residence['adresse']
            ?.toString()
            .trim() ??
            '';

    final ville =
        residence['ville']
            ?.toString()
            .trim() ??
            '';

    if (adresse.isNotEmpty &&
        ville.isNotEmpty) {
      return '$adresse, $ville';
    }

    if (adresse.isNotEmpty) {
      return adresse;
    }

    if (ville.isNotEmpty) {
      return ville;
    }

    return 'Adresse non renseignée';
  }

  // ==========================================================
  // TAILLE
  // ==========================================================

  static int _getTaille(
      Map<String, dynamic> data,
      ) {
    final infos = data['appartement_infos'];

    if (infos is List && infos.isNotEmpty) {
      final first = infos.first;

      if (first is Map) {
        return _parseInt(
          first['taille'],
        );
      }
    }

    if (infos is Map) {
      return _parseInt(
        infos['taille'],
      );
    }

    return 0;
  }
}

// ============================================================
// MODÈLE RÉSIDENCE
// ============================================================

class Residence {
  final String id;
  final String nom;
  final String ville;
  final String adresse;
  final String status;
  final List<Appartement> appartements;

  const Residence({
    required this.id,
    required this.nom,
    required this.ville,
    required this.adresse,
    required this.status,
    required this.appartements,
  });

  int get nombreAppartements =>
      appartements.length;
}

// ============================================================
// PAGE MES APPARTEMENTS
// ============================================================

class MesAppartementsPage extends StatefulWidget {
  final NavigateCallback onNavigate;

  const MesAppartementsPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<MesAppartementsPage> createState() =>
      _MesAppartementsPageState();
}

class _MesAppartementsPageState
    extends State<MesAppartementsPage> {
  // ==========================================================
  // SUPABASE
  // ==========================================================

  SupabaseClient get _supabase =>
      Supabase.instance.client;

  // ==========================================================
  // ÉTAT
  // ==========================================================

  List<Residence> _residences = [];

  /// Liste aplatie de tous les appartements.
  /// Utilisée pour les statistiques.
  List<Appartement> _disponibleStatus = [];

  /// Résidences actuellement ouvertes.
  final Set<String> _expandedResidenceIds = {};

  DisponibiliteStatus? selectedFilter;

  bool _isLoading = true;
  bool _isRefreshing = false;

  String? _errorMessage;

  // ==========================================================
  // INITIALISATION
  // ==========================================================

  @override
  void initState() {
    super.initState();

    _loadAppartements();
  }

  // ==========================================================
  // CHARGEMENT
  // ==========================================================

  Future<void> _loadAppartements({
    bool refresh = false,
  }) async {
    if (!mounted) {
      return;
    }

    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }

      _errorMessage = null;
    });

    try {
      final user =
          _supabase.auth.currentUser;

      if (user == null) {
        throw Exception(
          'Aucun utilisateur connecté.',
        );
      }

      debugPrint(
        '🏠 Chargement des résidences de ${user.id}',
      );

      // ======================================================
      // RÉCUPÉRER LES RÉSIDENCES
      //
      // On part maintenant de "residences" et non de
      // "appartements".
      //
      // Cela permet d'afficher une résidence même si elle
      // ne contient encore aucun appartement.
      // ======================================================

      final response = await _supabase
          .from('residences')
          .select('''
            id,
            proprietaire_id,
            nom,
            description,
            ville,
            adresse,
            localisation,
            status,
            created_at,
            updated_at,

            appartements (
              id,
              proprietaire_id,
              residence_id,
              titre,
              description,
              type,
              prix,
              prix_proprietaire,
              nbre_sejour,
              status,
              disponibilite_status,
              rating,
              ratings_count,
              created_at,

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
              )
            )
          ''')
          .eq(
        'proprietaire_id',
        user.id,
      )
          .order(
        'created_at',
        ascending: false,
      );

      final residenceRows =
      List<Map<String, dynamic>>.from(
        response,
      );

      debugPrint(
        '🏢 ${residenceRows.length} résidence(s) trouvée(s)',
      );

      // ======================================================
      // RÉCUPÉRER TOUS LES APPARTEMENT IDS
      // ======================================================

      final List<String> appartementIds = [];

      for (final residenceRow
      in residenceRows) {
        final rawAppartements =
        residenceRow['appartements'];

        if (rawAppartements is! List) {
          continue;
        }

        for (final rawAppartement
        in rawAppartements) {
          if (rawAppartement is! Map) {
            continue;
          }

          final id =
              rawAppartement['id']
                  ?.toString()
                  .trim() ??
                  '';

          if (id.isNotEmpty) {
            appartementIds.add(id);
          }
        }
      }

      // ======================================================
      // RÉCUPÉRER LES PHOTOS
      // ======================================================

      final Map<String, String> photosMap =
      {};

      if (appartementIds.isNotEmpty) {
        try {
          final photoResponse =
          await _supabase
              .from('photo_appartements')
              .select('''
                    appartement_id,
                    fichiername,
                    extension,
                    est_principale,
                    ordre_affichage
                  ''')
              .inFilter(
            'appartement_id',
            appartementIds,
          )
              .order(
            'est_principale',
            ascending: false,
          )
              .order(
            'ordre_affichage',
            ascending: true,
          );

          final photoRows =
          List<Map<String, dynamic>>.from(
            photoResponse,
          );

          // ==================================================
          // LA PREMIÈRE PHOTO TROUVÉE POUR CHAQUE APPARTEMENT
          // EST UTILISÉE
          // ==================================================

          for (final photo in photoRows) {
            final appartementId =
                photo['appartement_id']
                    ?.toString()
                    .trim() ??
                    '';

            final filename =
                photo['fichiername']
                    ?.toString()
                    .trim() ??
                    '';

            if (appartementId.isEmpty ||
                filename.isEmpty) {
              continue;
            }

            final url =
            _getStoragePublicUrl(
              appartementId,
              filename,
            );

            if (url.isNotEmpty &&
                !photosMap.containsKey(
                  appartementId,
                )) {
              photosMap[appartementId] =
                  url;
            }
          }

          debugPrint(
            '📸 ${photosMap.length} appartement(s) avec photo',
          );
        } catch (e, stackTrace) {
          debugPrint(
            '⚠️ Impossible de charger les photos : $e',
          );

          debugPrint(
            '$stackTrace',
          );
        }
      }

      // ======================================================
      // CONSTRUIRE LES RÉSIDENCES
      // ======================================================

      final List<Residence> loadedResidences =
      [];

      final List<Appartement> allAppartements =
      [];

      for (final residenceRow
      in residenceRows) {
        final residenceId =
            residenceRow['id']
                ?.toString()
                .trim() ??
                '';

        if (residenceId.isEmpty) {
          continue;
        }

        final nom =
            residenceRow['nom']
                ?.toString()
                .trim() ??
                '';

        final ville =
            residenceRow['ville']
                ?.toString()
                .trim() ??
                '';

        final adresse =
            residenceRow['adresse']
                ?.toString()
                .trim() ??
                '';

        final residenceStatus =
            residenceRow['status']
                ?.toString()
                .trim() ??
                'en_attente';

        // ================================================
        // APPARTEMENTS DE CETTE RÉSIDENCE
        // ================================================

        final List<Appartement> appartements =
        [];

        final rawAppartements =
        residenceRow['appartements'];

        if (rawAppartements is List) {
          for (final rawAppartement
          in rawAppartements) {
            if (rawAppartement is! Map) {
              continue;
            }

            final apartmentMap =
            Map<String, dynamic>.from(
              rawAppartement,
            );

            // Appartement.fromMap() attend une relation
            // "residences" pour construire l'adresse.
            apartmentMap['residences'] =
            <String, dynamic>{
              'id': residenceId,
              'nom': nom,
              'ville': ville,
              'adresse': adresse,
              'status':
              residenceStatus,
            };

            final appartementId =
                apartmentMap['id']
                    ?.toString()
                    .trim() ??
                    '';

            final appartement =
            Appartement.fromMap(
              apartmentMap,
              photo:
              photosMap[
              appartementId] ??
                  '',
            );

            appartements.add(
              appartement,
            );

            allAppartements.add(
              appartement,
            );
          }
        }

        loadedResidences.add(
          Residence(
            id: residenceId,
            nom: nom.isNotEmpty
                ? nom
                : 'Résidence sans nom',
            ville: ville,
            adresse: adresse,
            status: residenceStatus,
            appartements: appartements,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      // ======================================================
      // METTRE À JOUR L'ÉTAT
      // ======================================================

      setState(() {
        _residences =
            loadedResidences;

        _disponibleStatus =
            allAppartements;

        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = null;
      });

      debugPrint(
        '✅ ${loadedResidences.length} résidence(s) chargée(s)',
      );

      debugPrint(
        '✅ ${allAppartements.length} appartement(s) chargé(s)',
      );
    } catch (e, stackTrace) {
      debugPrint(
        '❌ Erreur MesAppartementsPage : $e',
      );

      debugPrint(
        '$stackTrace',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _isRefreshing = false;

        _errorMessage =
            _getFriendlyError(e);
      });
    }
  }

  // ==========================================================
  // URL STORAGE
  // ==========================================================

  String _getStoragePublicUrl(
      String appartementId,
      String filename,
      ) {
    if (filename.isEmpty) {
      return '';
    }

    if (filename.startsWith('http://') ||
        filename.startsWith('https://')) {
      return filename;
    }

    final url =
        'https://rcaujtlhfyumkuwdfpcm.supabase.co/'
        'storage/v1/object/public/appartements/'
        '$appartementId/$filename';

    debugPrint(
      '📁 URL construite : $url',
    );

    return url;
  }

  // ==========================================================
  // MESSAGE ERREUR
  // ==========================================================

  String _getFriendlyError(
      Object error,
      ) {
    final message =
    error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Impossible de contacter le serveur. '
          'Vérifiez votre connexion Internet.';
    }

    if (message.contains('permission') ||
        message.contains('rls') ||
        message.contains('row-level') ||
        message.contains('42501')) {
      return 'Vous n’avez pas les permissions '
          'nécessaires pour consulter vos biens.';
    }

    if (message.contains('timeout')) {
      return 'Le serveur met trop de temps à répondre.';
    }

    if (message.contains('column') &&
        message.contains('does not exist')) {
      return 'Une colonne nécessaire est absente '
          'de la base de données.';
    }

    if (message.contains('relationship') ||
        message.contains('could not find')) {
      return 'La relation entre les résidences et les appartements '
          'n’est pas correctement configurée.';
    }

    return 'Impossible de charger vos biens. '
        'Veuillez réessayer.';
  }

  // ==========================================================
  // FORMAT PRIX
  // ==========================================================

  String _formatPrice(
      double price,
      ) {
    if (price <= 0) {
      return 'Prix non défini';
    }

    final value =
    price.toStringAsFixed(
      price % 1 == 0 ? 0 : 2,
    );

    final parts =
    value.split('.');

    final integerPart =
        parts.first;

    final buffer =
    StringBuffer();

    for (
    int i = 0;
    i < integerPart.length;
    i++
    ) {
      if (i > 0 &&
          (integerPart.length - i) %
              3 ==
              0) {
        buffer.write(' ');
      }

      buffer.write(
        integerPart[i],
      );
    }

    if (parts.length > 1) {
      buffer.write(
        ',${parts[1]}',
      );
    }

    return '${buffer.toString()} FCFA';
  }

  // ==========================================================
  // STATISTIQUES
  // ==========================================================

  int get _totalCount =>
      _disponibleStatus.length;

  int get _availableCount =>
      _disponibleStatus
          .where(
            (a) =>
        a.status ==
            DisponibiliteStatus
                .disponible,
      )
          .length;

  int get _occupiedCount =>
      _disponibleStatus
          .where(
            (a) =>
        a.status ==
            DisponibiliteStatus
                .occupe,
      )
          .length;

  int get _maintenanceCount =>
      _disponibleStatus
          .where(
            (a) =>
        a.status ==
            DisponibiliteStatus
                .maintenance,
      )
          .length;

  // ==========================================================
  // APPARTEMENTS FILTRÉS D'UNE RÉSIDENCE
  // ==========================================================

  List<Appartement>
  _filteredAppartementsForResidence(
      Residence residence,
      ) {
    if (selectedFilter == null) {
      return residence.appartements;
    }

    return residence.appartements
        .where(
          (apt) =>
      apt.status ==
          selectedFilter,
    )
        .toList();
  }

  // ==========================================================
  // RÉSIDENCES VISIBLES
  // ==========================================================

  List<Residence>
  get _visibleResidences {
    // "Tous" :
    // on affiche toutes les résidences, même celles
    // qui n'ont aucun appartement.
    if (selectedFilter == null) {
      return _residences;
    }

    // Filtre :
    // on masque une résidence si elle ne contient aucun
    // appartement correspondant au filtre.
    return _residences
        .where(
          (residence) =>
      _filteredAppartementsForResidence(
        residence,
      ).isNotEmpty,
    )
        .toList();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null &&
        _residences.isEmpty) {
      return _buildErrorState();
    }

    final visibleResidences =
        _visibleResidences;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () =>
          _loadAppartements(
            refresh: true,
          ),
      child: ListView(
        padding: EdgeInsets.zero,
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          // ==================================================
          // HEADER
          // ==================================================

          Container(
            color:
            AppColors.foreground,
            padding:
            const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Column(
              children: [
                Align(
                  alignment:
                  Alignment.centerRight,
                  child:
                  ElevatedButton(
                    onPressed: () {
                      widget.onNavigate(
                        AppPage
                            .ajouterAppartement,
                      );
                    },
                    style:
                    ElevatedButton
                        .styleFrom(
                      backgroundColor:
                      const Color(
                        0xFFD97706,
                      ),
                      elevation: 0,
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          12,
                        ),
                      ),
                    ),
                    child: Text(
                      '+ Ajouter',
                      style:
                      GoogleFonts
                          .nunito(
                        fontWeight:
                        FontWeight
                            .w800,
                        fontSize: 15,
                        color:
                        Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                // ==================================================
                // FILTRES
                // ==================================================

                SingleChildScrollView(
                  scrollDirection:
                  Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        'Tous ($_totalCount)',
                        null,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _buildFilterChip(
                        'Dispos ($_availableCount)',
                        DisponibiliteStatus
                            .disponible,
                        dotColor:
                        const Color(
                          0xFF10B981,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _buildFilterChip(
                        'Occupés ($_occupiedCount)',
                        DisponibiliteStatus
                            .occupe,
                        dotColor:
                        const Color(
                          0xFFD97706,
                        ),
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _buildFilterChip(
                        'Maint. ($_maintenanceCount)',
                        DisponibiliteStatus
                            .maintenance,
                        dotColor:
                        const Color(
                          0xFFEF4444,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // ERREUR PARTIELLE
          // ==================================================

          if (_errorMessage != null)
            _buildSmallErrorBanner(),

          // ==================================================
          // AUCUNE RÉSIDENCE
          // ==================================================

          if (_residences.isEmpty)
            _buildEmptyState(),

          // ==================================================
          // AUCUN RÉSULTAT FILTRE
          // ==================================================

          if (_residences.isNotEmpty &&
              visibleResidences.isEmpty)
            _buildNoFilterResult(),

          // ==================================================
          // LISTE DES RÉSIDENCES
          // ==================================================

          if (visibleResidences.isNotEmpty)
            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                24,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .stretch,
                children: [
                  Text(
                    'MES RÉSIDENCES',
                    style:
                    GoogleFonts.nunito(
                      fontSize: 14,
                      fontWeight:
                      FontWeight.w900,
                      letterSpacing:
                      0.5,
                      color:
                      AppColors
                          .textSecondary,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  ...visibleResidences.map(
                        (residence) =>
                        _buildResidenceCard(
                          residence,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // CARTE RÉSIDENCE
  // ==========================================================

  Widget _buildResidenceCard(
      Residence residence,
      ) {
    final isExpanded =
    _expandedResidenceIds
        .contains(
      residence.id,
    );

    final filteredApartments =
    _filteredAppartementsForResidence(
      residence,
    );

    final residenceConfig =
        residenceStatusConfigMap[
        residence.status] ??
            residenceStatusConfigMap[
            'en_attente']!;

    return Container(
      margin:
      const EdgeInsets.only(
        bottom: 16,
      ),
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withValues(
              alpha: 0.04,
            ),
            blurRadius: 10,
            offset:
            const Offset(
              0,
              4,
            ),
          ),
        ],
      ),
      clipBehavior:
      Clip.antiAlias,
      child: Column(
        children: [
          // ==================================================
          // EN-TÊTE RÉSIDENCE
          // ==================================================

          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!mounted) {
                  return;
                }

                setState(() {
                  if (isExpanded) {
                    _expandedResidenceIds
                        .remove(
                      residence.id,
                    );
                  } else {
                    _expandedResidenceIds
                        .add(
                      residence.id,
                    );
                  }
                });
              },
              child: Padding(
                padding:
                const EdgeInsets.all(
                  14,
                ),
                child: Row(
                  children: [
                    // ========================================
                    // ICÔNE
                    // ========================================

                    Container(
                      width: 48,
                      height: 48,
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xFFEFF6FF,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),
                      ),
                      child:
                      const Icon(
                        Icons
                            .apartment_rounded,
                        color:
                        Color(
                          0xFF2563EB,
                        ),
                        size: 25,
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    // ========================================
                    // NOM + LOCALISATION
                    // ========================================

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child:
                                Text(
                                  residence
                                      .nom
                                      .isNotEmpty
                                      ? residence
                                      .nom
                                      : 'Résidence sans nom',
                                  maxLines:
                                  1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  GoogleFonts
                                      .nunito(
                                    fontSize:
                                    17,
                                    fontWeight:
                                    FontWeight
                                        .w900,
                                    color:
                                    AppColors
                                        .inputText,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .location_on_outlined,
                                size: 14,
                                color:
                                AppColors
                                    .iconcolor,
                              ),
                              const SizedBox(
                                width: 3,
                              ),
                              Expanded(
                                child:
                                Text(
                                  _buildResidenceLocation(
                                    residence,
                                  ),
                                  maxLines:
                                  1,
                                  overflow:
                                  TextOverflow
                                      .ellipsis,
                                  style:
                                  GoogleFonts
                                      .nunito(
                                    fontSize:
                                    12,
                                    color:
                                    AppColors
                                        .textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 6,
                          ),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .home_work_outlined,
                                size: 14,
                                color:
                                Color(
                                  0xFF64748B,
                                ),
                              ),

                              const SizedBox(
                                width: 4,
                              ),

                              Text(
                                '${residence.nombreAppartements} appartement${residence.nombreAppartements > 1 ? 's' : ''}',
                                style:
                                GoogleFonts
                                    .nunito(
                                  fontSize:
                                  12,
                                  fontWeight:
                                  FontWeight
                                      .w700,
                                  color:
                                  const Color(
                                    0xFF64748B,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    // ========================================
                    // STATUT + FLÈCHE
                    // ========================================

                    Column(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .end,
                      children: [
                        Container(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            residenceConfig
                                .bg,
                            borderRadius:
                            BorderRadius
                                .circular(
                              20,
                            ),
                          ),
                          child: Row(
                            mainAxisSize:
                            MainAxisSize
                                .min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration:
                                BoxDecoration(
                                  color:
                                  residenceConfig
                                      .dot,
                                  shape:
                                  BoxShape
                                      .circle,
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Text(
                                residenceConfig
                                    .label,
                                style:
                                GoogleFonts
                                    .nunito(
                                  fontSize:
                                  10,
                                  color:
                                  residenceConfig
                                      .color,
                                  fontWeight:
                                  FontWeight
                                      .w800,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        AnimatedRotation(
                          turns:
                          isExpanded
                              ? 0.5
                              : 0,
                          duration:
                          const Duration(
                            milliseconds: 220,
                          ),
                          child:
                          const Icon(
                            Icons
                                .keyboard_arrow_down_rounded,
                            size: 24,
                            color:
                            Color(
                              0xFF64748B,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==================================================
          // CONTENU DÉPLIABLE
          // ==================================================

          AnimatedSize(
            duration:
            const Duration(
              milliseconds: 250,
            ),
            curve:
            Curves.easeOutCubic,
            child: isExpanded
                ? Column(
              children: [
                const Divider(
                  height: 1,
                  thickness: 1,
                  color:
                  Color(
                    0xFFE2E8F0,
                  ),
                ),

                if (filteredApartments
                    .isEmpty)
                  Padding(
                    padding:
                    const EdgeInsets
                        .all(
                      20,
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons
                              .home_work_outlined,
                          size: 38,
                          color:
                          Color(
                            0xFF94A3B8,
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          selectedFilter ==
                              null
                              ? 'Aucun appartement dans cette résidence'
                              : 'Aucun appartement correspondant au filtre',
                          textAlign:
                          TextAlign
                              .center,
                          style:
                          GoogleFonts
                              .nunito(
                            fontSize:
                            13,
                            fontWeight:
                            FontWeight
                                .w700,
                            color:
                            const Color(
                              0xFF64748B,
                            ),
                          ),
                        ),

                        if (selectedFilter ==
                            null) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          TextButton.icon(
                            onPressed:
                                () {
                              widget
                                  .onNavigate(
                                AppPage
                                    .ajouterAppartement,
                              );
                            },
                            icon:
                            const Icon(
                              Icons
                                  .add_rounded,
                              size: 18,
                            ),
                            label:
                            Text(
                              'Ajouter un appartement',
                              style:
                              GoogleFonts
                                  .nunito(
                                fontWeight:
                                FontWeight
                                    .w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  Padding(
                    padding:
                    const EdgeInsets
                        .fromLTRB(
                      14,
                      14,
                      14,
                      0,
                    ),
                    child: Column(
                      children:
                      filteredApartments
                          .map(
                            (
                            apartment,
                            ) =>
                            _buildAppartementCard(
                              apartment,
                            ),
                      )
                          .toList(),
                    ),
                  ),
              ],
            )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCALISATION RÉSIDENCE
  // ==========================================================

  String _buildResidenceLocation(
      Residence residence,
      ) {
    final ville =
    residence.ville.trim();

    final adresse =
    residence.adresse.trim();

    if (adresse.isNotEmpty &&
        ville.isNotEmpty) {
      return '$adresse, $ville';
    }

    if (adresse.isNotEmpty) {
      return adresse;
    }

    if (ville.isNotEmpty) {
      return ville;
    }

    return 'Adresse non renseignée';
  }

  // ==========================================================
  // CARTE APPARTEMENT
  // ==========================================================

  Widget _buildAppartementCard(
      Appartement apt,
      ) {
    final sc =
    statusConfigMap[apt.status]!;

    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 14,
      ),
      child: Container(
        decoration:
        BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(
            18,
          ),
          border:
          Border.all(
            color:
            const Color(
              0xFFE2E8F0,
            ),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: 0.025,
              ),
              blurRadius: 8,
              offset:
              const Offset(
                0,
                3,
              ),
            ),
          ],
        ),
        clipBehavior:
        Clip.antiAlias,
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==================================================
            // IMAGE
            // ==================================================

            Stack(
              children: [
                _buildAppartementImage(
                  apt,
                ),

                // ============================================
                // STATUS
                // ============================================

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration:
                    BoxDecoration(
                      color: sc.bg,
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize
                          .min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration:
                          BoxDecoration(
                            color: sc.dot,
                            shape:
                            BoxShape
                                .circle,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          sc.label,
                          style:
                          GoogleFonts
                              .nunito(
                            fontSize: 12,
                            color:
                            sc.color,
                            fontWeight:
                            FontWeight
                                .w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ============================================
                // PRIX
                // ============================================

                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFF2C3F5C,
                      ).withValues(
                        alpha: 0.85,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        8,
                      ),
                    ),
                    child: RichText(
                      text:
                      TextSpan(
                        style:
                        GoogleFonts
                            .nunito(
                          color:
                          Colors.white,
                        ),
                        children: [
                          TextSpan(
                            text:
                            _formatPrice(
                              apt.price,
                            ),
                            style:
                            GoogleFonts
                                .nunito(
                              fontWeight:
                              FontWeight
                                  .w800,
                              fontSize:
                              14,
                            ),
                          ),
                          TextSpan(
                            text:
                            ' /nuit',
                            style:
                            GoogleFonts
                                .nunito(
                              fontWeight:
                              FontWeight
                                  .normal,
                              fontSize:
                              12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ==================================================
            // INFORMATIONS
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.all(
                14,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  // ==========================================
                  // TITRE + NOTE
                  // ==========================================

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          apt.name,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          GoogleFonts
                              .nunito(
                            fontWeight:
                            FontWeight
                                .w800,
                            fontSize: 17,
                            color:
                            AppColors
                                .inputText,
                          ),
                        ),
                      ),

                      if (apt.rating >
                          0)
                        Row(
                          mainAxisSize:
                          MainAxisSize
                              .min,
                          children: [
                            const Icon(
                              Icons
                                  .star_rounded,
                              size: 16,
                              color:
                              Color(
                                0xFFEAB308,
                              ),
                            ),

                            const SizedBox(
                              width: 2,
                            ),

                            Text(
                              apt.rating
                                  .toStringAsFixed(
                                1,
                              ),
                              style:
                              GoogleFonts
                                  .nunito(
                                fontWeight:
                                FontWeight
                                    .w800,
                                fontSize:
                                12,
                                color:
                                AppColors
                                    .inputText,
                              ),
                            ),

                            if (apt.reviews >
                                0)
                              Text(
                                ' (${apt.reviews})',
                                style:
                                GoogleFonts
                                    .nunito(
                                  fontSize:
                                  12,
                                  color:
                                  AppColors
                                      .muted,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  // ==========================================
                  // ADRESSE
                  // ==========================================

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .location_on_outlined,
                        size: 15,
                        color:
                        AppColors
                            .iconcolor,
                      ),

                      const SizedBox(
                        width: 4,
                      ),

                      Expanded(
                        child: Text(
                          apt.taille > 0
                              ? '${apt.address} · ${apt.taille} m²'
                              : apt.address,
                          maxLines: 1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          GoogleFonts
                              .nunito(
                            fontSize: 13,
                            color:
                            AppColors
                                .textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  // ==========================================
                  // ACTIONS
                  // ==========================================

                  Row(
                    children: [
                      _buildActionButton(
                        label: 'Modifier',
                        icon: Icons
                            .edit_outlined,
                        bgColor:
                        AppColors
                            .cardbo,
                        textColor:
                        AppColors
                            .inputText,
                        onPressed: () {
                          widget.onNavigate(
                            AppPage
                                .modifierAppartement,
                            appartementId:
                            apt.id,
                          );
                        },
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _buildActionButton(
                        label: 'Détails',
                        icon: Icons
                            .info_outline_rounded,
                        bgColor:
                        AppColors
                            .cardbo,
                        textColor:
                        AppColors
                            .inputText,
                        onPressed: () {
                          debugPrint(
                            '🔍 Navigation vers détails avec ID: ${apt.id}',
                          );

                          widget.onNavigate(
                            AppPage.details,
                            appartementId:
                            apt.id,
                          );
                        },
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      _buildActionButton(
                        label: 'Rés.',
                        icon: Icons
                            .calendar_month_outlined,
                        bgColor:
                        AppColors.card,
                        textColor:
                        Colors.white,
                        onPressed: () {
                          widget.onNavigate(
                            AppPage.reservations,
                            appartementId:
                            apt.id,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // IMAGE APPARTEMENT
  // ==========================================================

  Widget _buildAppartementImage(
      Appartement apt,
      ) {
    final imageUrl =
    apt.img.trim();

    if (imageUrl.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Image.network(
      imageUrl,
      height: 160,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {
        if (loadingProgress == null) {
          return child;
        }

        return Container(
          height: 160,
          width: double.infinity,
          color:
          const Color(
            0xFFEFF3F8,
          ),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
          ),
        );
      },
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        debugPrint(
          '❌ Image impossible à charger : $imageUrl',
        );

        return _buildImagePlaceholder();
      },
    );
  }

  // ==========================================================
  // PLACEHOLDER
  // ==========================================================

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      color:
      const Color(
        0xFFEFF3F8,
      ),
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const Icon(
            Icons
                .home_work_outlined,
            size: 46,
            color:
            Color(
              0xFF94A3B8,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Aucune photo',
            style:
            GoogleFonts.nunito(
              color:
              const Color(
                0xFF64748B,
              ),
              fontSize: 13,
              fontWeight:
              FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FILTRE CHIP
  // ==========================================================

  Widget _buildFilterChip(
      String label,
      DisponibiliteStatus? filterKey, {
        Color? dotColor,
      }) {
    final isSelected =
        selectedFilter ==
            filterKey;

    return InkWell(
      onTap: () {
        if (!mounted) {
          return;
        }

        setState(() {
          selectedFilter =
              filterKey;
        });
      },
      borderRadius:
      BorderRadius.circular(
        20,
      ),
      child: Container(
        padding:
        const EdgeInsets
            .symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration:
        BoxDecoration(
          color: isSelected
              ? const Color(
            0xFFD97706,
          )
              : Colors.white
              .withValues(
            alpha: 0.12,
          ),
          borderRadius:
          BorderRadius.circular(
            20,
          ),
        ),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            if (dotColor != null &&
                !isSelected) ...[
              Container(
                width: 10,
                height: 10,
                decoration:
                BoxDecoration(
                  color: dotColor,
                  shape:
                  BoxShape.circle,
                ),
              ),
              const SizedBox(
                width: 6,
              ),
            ],
            Text(
              label,
              style:
              GoogleFonts.nunito(
                color: isSelected
                    ? Colors.white
                    : Colors.white
                    .withValues(
                  alpha: 0.8,
                ),
                fontWeight:
                FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // BOUTON ACTION
  // ==========================================================

  Widget _buildActionButton({
    required String label,
    IconData? icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return Expanded(
      child: SizedBox(
        height: 38,
        child: TextButton(
          onPressed: onPressed,
          style:
          TextButton.styleFrom(
            backgroundColor:
            bgColor,
            shape:
            RoundedRectangleBorder(
              borderRadius:
              BorderRadius
                  .circular(
                10,
              ),
            ),
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 6,
            ),
          ),
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .center,
            mainAxisSize:
            MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 17,
                  color:
                  textColor,
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow:
                  TextOverflow
                      .ellipsis,
                  style:
                  GoogleFonts
                      .nunito(
                    fontWeight:
                    FontWeight.w800,
                    fontSize: 13,
                    color:
                    textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // LOADING
  // ==========================================================

  Widget _buildLoadingState() {
    return ListView(
      padding: EdgeInsets.zero,
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          color:
          AppColors.foreground,
          padding:
          const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            16,
          ),
          child: Column(
            children: [
              Align(
                alignment:
                Alignment.centerRight,
                child: Container(
                  width: 105,
                  height: 38,
                  decoration:
                  BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              SingleChildScrollView(
                scrollDirection:
                Axis.horizontal,
                child: Row(
                  children: [
                    _buildLoadingChip(
                      width: 70,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildLoadingChip(
                      width: 85,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildLoadingChip(
                      width: 90,
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    _buildLoadingChip(
                      width: 75,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding:
          const EdgeInsets.all(
            16,
          ),
          child: Column(
            children: [
              _buildSkeletonResidence(),
              const SizedBox(
                height: 16,
              ),
              _buildSkeletonResidence(),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // LOADING CHIP
  // ==========================================================

  Widget _buildLoadingChip({
    required double width,
  }) {
    return Container(
      width: width,
      height: 30,
      decoration:
      BoxDecoration(
        color: Colors.white
            .withValues(
          alpha: 0.10,
        ),
        borderRadius:
        BorderRadius.circular(
          20,
        ),
      ),
    );
  }

  // ==========================================================
  // SKELETON RÉSIDENCE
  // ==========================================================

  Widget _buildSkeletonResidence() {
    return Container(
      height: 88,
      decoration:
      BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(
          18,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(
          14,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFE2E8F0,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  14,
                ),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Container(
                    height: 16,
                    width: 160,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFE2E8F0,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        6,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Container(
                    height: 12,
                    width: 120,
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFE2E8F0,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 24,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFFE2E8F0,
                ),
                borderRadius:
                BorderRadius
                    .circular(
                  20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // ERREUR
  // ==========================================================

  Widget _buildErrorState() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.all(
        24,
      ),
      children: [
        const SizedBox(
          height: 70,
        ),
        Container(
          padding:
          const EdgeInsets.all(
            24,
          ),
          decoration:
          BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(
              20,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration:
                const BoxDecoration(
                  color:
                  Color(
                    0xFFFEF2F2,
                  ),
                  shape:
                  BoxShape.circle,
                ),
                child:
                const Icon(
                  Icons
                      .cloud_off_rounded,
                  color:
                  Color(
                    0xFFEF4444,
                  ),
                  size: 32,
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                'Impossible de charger vos biens',
                textAlign:
                TextAlign.center,
                style:
                GoogleFonts.nunito(
                  fontSize: 18,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  AppColors
                      .inputText,
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              Text(
                _errorMessage ??
                    'Une erreur est survenue.',
                textAlign:
                TextAlign.center,
                style:
                GoogleFonts.nunito(
                  fontSize: 13,
                  color:
                  AppColors
                      .textSecondary,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton.icon(
                onPressed:
                _isRefreshing
                    ? null
                    : () =>
                    _loadAppartements(),
                icon:
                const Icon(
                  Icons
                      .refresh_rounded,
                ),
                label: Text(
                  'Réessayer',
                  style:
                  GoogleFonts
                      .nunito(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),
                style:
                ElevatedButton
                    .styleFrom(
                  backgroundColor:
                  AppColors
                      .primary,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // PETITE BANNIÈRE ERREUR
  // ==========================================================

  Widget _buildSmallErrorBanner() {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        0,
      ),
      child: Container(
        padding:
        const EdgeInsets.all(
          12,
        ),
        decoration:
        BoxDecoration(
          color:
          const Color(
            0xFFFEF2F2,
          ),
          borderRadius:
          BorderRadius.circular(
            12,
          ),
          border:
          Border.all(
            color:
            const Color(
              0xFFFECACA,
            ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .warning_amber_rounded,
              color:
              Color(
                0xFFEF4444,
              ),
              size: 20,
            ),
            const SizedBox(
              width: 8,
            ),
            Expanded(
              child: Text(
                _errorMessage!,
                style:
                GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w700,
                  color:
                  const Color(
                    0xFFB91C1C,
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  _loadAppartements(
                    refresh: true,
                  ),
              child: Text(
                'Réessayer',
                style:
                GoogleFonts.nunito(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  const Color(
                    0xFFB91C1C,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Padding(
      padding:
      const EdgeInsets.all(
        24,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 45,
          ),
          Container(
            width: 82,
            height: 82,
            decoration:
            const BoxDecoration(
              color:
              Color(
                0xFFFFF7ED,
              ),
              shape:
              BoxShape.circle,
            ),
            child:
            const Icon(
              Icons
                  .home_work_outlined,
              color:
              Color(
                0xFFD97706,
              ),
              size: 40,
            ),
          ),
          const SizedBox(
            height: 18,
          ),
          Text(
            'Aucune résidence',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.nunito(
              fontSize: 20,
              fontWeight:
              FontWeight.w800,
              color:
              AppColors.inputText,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            'Vous n’avez encore créé aucune résidence. '
                'Commencez par créer votre première résidence '
                'avant d’ajouter vos appartements.',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.nunito(
              fontSize: 14,
              height: 1.4,
              color:
              AppColors
                  .textSecondary,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton.icon(
            onPressed: () {
              widget.onNavigate(
                AppPage
                    .ajouterAppartement,
              );
            },
            icon:
            const Icon(
              Icons.add_rounded,
            ),
            label: Text(
              'Ajouter mon premier bien',
              style:
              GoogleFonts.nunito(
                fontWeight:
                FontWeight.w800,
              ),
            ),
            style:
            ElevatedButton
                .styleFrom(
              backgroundColor:
              const Color(
                0xFFD97706,
              ),
              foregroundColor:
              Colors.white,
              elevation: 0,
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 18,
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
        ],
      ),
    );
  }

  // ==========================================================
  // AUCUN RÉSULTAT FILTRE
  // ==========================================================

  Widget _buildNoFilterResult() {
    final config =
    selectedFilter == null
        ? null
        : statusConfigMap[
    selectedFilter!];

    return Padding(
      padding:
      const EdgeInsets.all(
        24,
      ),
      child: Column(
        children: [
          const SizedBox(
            height: 40,
          ),
          const Icon(
            Icons
                .filter_alt_off_rounded,
            size: 42,
            color:
            Color(
              0xFF94A3B8,
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            config == null
                ? 'Aucun résultat'
                : 'Aucun bien ${config.label.toLowerCase()}',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.nunito(
              fontSize: 17,
              fontWeight:
              FontWeight.w800,
              color:
              AppColors.inputText,
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            'Aucune résidence ne contient actuellement '
                'un appartement correspondant à ce filtre.',
            textAlign:
            TextAlign.center,
            style:
            GoogleFonts.nunito(
              fontSize: 13,
              color:
              AppColors
                  .textSecondary,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          TextButton(
            onPressed: () {
              setState(() {
                selectedFilter =
                null;
              });
            },
            child: Text(
              'Afficher tous les biens',
              style:
              GoogleFonts.nunito(
                fontWeight:
                FontWeight.w800,
                color:
                AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}