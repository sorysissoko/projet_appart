import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/navigation/main_wrapper.dart';
import '../core/theme/app_theme.dart';


// CONFIGURATION DES STATUTS
class StatusConfig {
  final String label;
  final Color color;
  final Color bg;

  const StatusConfig({
    required this.label,
    required this.color,
    required this.bg,
  });
}

const Map<String, StatusConfig> statusConfig = {
  'confirmed': StatusConfig(
    label: 'Confirmée',
    color: Color(0xFF10B981),
    bg: Color(0xFFECFDF5),
  ),
  'pending': StatusConfig(
    label: 'En attente',
    color: Color(0xFFC9913A),
    bg: Color(0xFFFEF9EC),
  ),
  'cancelled': StatusConfig(
    label: 'Annulée',
    color: Color(0xFFEF4444),
    bg: Color(0xFFFEF2F2),
  ),
};

// MODÈLE RÉSERVATION
class Reservation {
  final String id;
  final String appartementId;
  final String name;
  final String avatar;
  final String? photoLocataireUrl;
  final String apt;
  final DateTime checkIn;
  final DateTime checkOut;
  final int nights;
  final num total;
  final num prixProprietaire;
  final num fraisService;
  final num reduction;
  final String status;
  final String phone;
  final String img;
  final int adulte;
  final int enfant;
  final String? message;

  const Reservation({
    required this.id,
    required this.appartementId,
    required this.name,
    required this.avatar,
    this.photoLocataireUrl,
    required this.apt,
    required this.checkIn,
    required this.checkOut,
    required this.nights,
    required this.total,
    required this.prixProprietaire,
    required this.fraisService,
    required this.reduction,
    required this.status,
    required this.phone,
    required this.img,
    required this.adulte,
    required this.enfant,
    required this.message,
  });
}

// SKELETON CARD AVEC ANIMATION

class _SkeletonCard extends StatefulWidget {
  const _SkeletonCard();

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
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
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.06),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFEEF2FA),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 16,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FA),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 60,
                              height: 20,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 20,
                              height: 16,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FA),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FA),
                                  borderRadius: BorderRadius.circular(4),
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
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Container(
                          width: 35,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 50,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 40,
                          height: 10,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 60,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FA),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// SKELETON STAT CARD
class _SkeletonStatCard extends StatelessWidget {
  const _SkeletonStatCard();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 50,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// PAGE RÉSERVATIONS
class ReservationsPage extends StatefulWidget {
  final NavigateCallback onNavigate;

  const ReservationsPage({
    super.key,
    required this.onNavigate,
  });

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  SupabaseClient get _supabase {
    return Supabase.instance.client;
  }

  String _filter = 'all';
  String? _expandedId;
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // CHARGEMENT DES RÉSERVATIONS
  Future<void> _loadReservations({
    bool refresh = false,
  }) async {
    if (refresh) {
      if (mounted) {
        setState(() {
          _isRefreshing = true;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = true;
          _errorMessage = null;
        });
      }
    }

    try {
      final user = _supabase.auth.currentUser;

      if (user == null) {
        throw Exception('Aucun propriétaire connecté.');
      }

      debugPrint(
        'Chargement des réservations du propriétaire ${user.id}',
      );


      //RÉCUPÉRER LES APPARTEMENTS AVEC LEUR RÉSIDENCE
      final appartementsResponse = await _supabase
          .from('appartements')
          .select('''
            *,
            residence:residences!appartements_residence_id_fkey (
              id,
              nom,
              ville
            )
          ''')
          .eq('proprietaire_id', user.id);

      final appartements =
      List<Map<String, dynamic>>.from(appartementsResponse);

      debugPrint('🏠 Appartements trouvés : ${appartements.length}');

      if (appartements.isEmpty) {
        if (!mounted) return;

        setState(() {
          _reservations = [];
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = null;
        });

        return;
      }


      // 2. IDS DES APPARTEMENTS
      final appartementIds = appartements
          .map((apt) => apt['id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toList();

      if (appartementIds.isEmpty) {
        if (!mounted) return;

        setState(() {
          _reservations = [];
          _isLoading = false;
          _isRefreshing = false;
        });

        return;
      }

      //RÉCUPÉRER LES RÉSERVATIONS
      final reservationsResponse = await _supabase
          .from('reservations')
          .select('*')
          .inFilter('appartement_id', appartementIds)
          .order('created_at', ascending: false);

      final reservationsRaw =
      List<Map<String, dynamic>>.from(reservationsResponse);

      debugPrint('Réservations trouvées : ${reservationsRaw.length}');


      //IDS DES LOCATAIRES
      final locataireIds = reservationsRaw
          .map((r) => r['locataire_id']?.toString())
          .whereType<String>()
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      //RÉCUPÉRER LES LOCATAIRES VIA RPC
      final Map<String, Map<String, dynamic>> locataires = {};

      if (locataireIds.isNotEmpty) {
        try {
          final usersResponse = await _supabase.rpc(
            'get_locataires_pour_proprietaire',
            params: {
              'p_locataire_ids': locataireIds,
            },
          );

          final users =
          List<Map<String, dynamic>>.from(usersResponse as List);

          // ✅ NOUVEAU : Générer les URLs signées des photos
          for (final userData in users) {
            final id = userData['id']?.toString();

            if (id == null || id.isEmpty) continue;

            final photoPath =
                userData['photo_profil']?.toString().trim() ?? '';

            String? photoUrl;

            if (photoPath.isNotEmpty) {
              // Déjà une URL complète
              if (photoPath.startsWith('http://') ||
                  photoPath.startsWith('https://')) {
                photoUrl = photoPath;
              }
              // Chemin invalide
              else if (photoPath.contains('://')) {
                debugPrint('⚠️ Chemin photo invalide : $photoPath');
              }
              // Chemin Storage → générer l'URL signée
              else {
                try {
                  photoUrl = await _supabase.storage
                      .from('avatars')
                      .createSignedUrl(photoPath, 3600);

                  debugPrint('✅ Photo signée pour locataire $id');
                } catch (e) {
                  debugPrint('⚠️ Impossible de signer la photo de $id : $e');
                }
              }
            }

            locataires[id] = {
              ...userData,
              'photo_url': photoUrl,
            };
          }

          debugPrint('👤 ${locataires.length} locataires chargés');
        } catch (e) {
          debugPrint('Impossible de charger les locataires : $e');
        }
      }


      //INDEX DES APPARTEMENTS
      final Map<String, Map<String, dynamic>> appartementsMap = {};

      for (final appartement in appartements) {
        final id = appartement['id']?.toString();

        if (id != null && id.isNotEmpty) {
          appartementsMap[id] = appartement;
        }
      }


      //CHARGEMENT DES PHOTOS
      final Map<String, String> photos = {};

      for (final appartementId in appartementIds) {
        final photo = await _loadAppartementPhoto(appartementId);

        if (photo != null && photo.isNotEmpty) {
          photos[appartementId] = photo;
        }
      }


      //CONVERSION DES RÉSERVATIONS
      final List<Reservation> loadedReservations = [];

      for (final reservation in reservationsRaw) {
        try {
          final reservationId = reservation['id']?.toString();
          final appartementId = reservation['appartement_id']?.toString();
          final locataireId = reservation['locataire_id']?.toString();

          if (reservationId == null ||
              reservationId.isEmpty ||
              appartementId == null ||
              appartementId.isEmpty) {
            continue;
          }

          final appartement = appartementsMap[appartementId];
          final locataire =
          locataireId == null ? null : locataires[locataireId];


          // NOM DU LOCATAIRE
          final prenom = locataire?['prenom']?.toString().trim() ?? '';
          final nom = locataire?['nom']?.toString().trim() ?? '';

          final fullName = '$prenom $nom'.trim();

          final displayName = fullName.isNotEmpty
              ? fullName
              : 'Locataire';

          final avatar = _buildInitials(prenom, nom);


          // APPARTEMENT RÉSIDENCE
          final appartementTitre =
              appartement?['titre']?.toString().trim() ??
                  appartement?['nom']?.toString().trim() ??
                  'Appartement';

          final residenceData = appartement?['residence'];

          String? residenceNom;

          if (residenceData is Map) {
            residenceNom = residenceData['nom']?.toString().trim();
          } else if (residenceData is List && residenceData.isNotEmpty) {
            residenceNom =
                residenceData.first['nom']?.toString().trim();
          }

          final appartementName =
          (residenceNom != null && residenceNom.isNotEmpty)
              ? '$appartementTitre • $residenceNom'
              : appartementTitre;


          // DATES
          final dateDebut = _parseDate(reservation['date_debut']);
          final dateFin = _parseDate(reservation['date_fin']);

          if (dateDebut == null || dateFin == null) {
            debugPrint(
              '⚠️ Dates invalides pour réservation $reservationId',
            );
            continue;
          }

          final nights = dateFin.difference(dateDebut).inDays;


          // PRIX
          final prixTotal = _toNum(reservation['prix_total']);
          final prixProprietaire =
          _toNum(reservation['prix_proprietaire']);
          final fraisService = _toNum(reservation['frais_service']);
          final reduction = _toNum(reservation['reduction']);

          // STATUT
          final databaseStatus =
              reservation['statut']?.toString().trim().toLowerCase() ??
                  'en_attente';

          final uiStatus = _convertStatus(databaseStatus);

          // TÉLÉPHONE
          final phone = locataire?['telephone']?.toString().trim() ?? '';

          // PHOTO
          final image = photos[appartementId] ?? '';


          // VOYAGEURS
          final adulte = _toInt(reservation['adulte']);
          final enfant = _toInt(reservation['enfant']);


          // MESSAGE
          final message = reservation['message']?.toString();

          final photoLocataireUrl =
          locataire?['photo_url']?.toString();

          // AJOUT
          loadedReservations.add(
            Reservation(
              id: reservationId,
              appartementId: appartementId,
              name: displayName,
              avatar: avatar,
              photoLocataireUrl: photoLocataireUrl,
              apt: appartementName,
              checkIn: dateDebut,
              checkOut: dateFin,
              nights: nights,
              total: prixTotal,
              prixProprietaire: prixProprietaire,
              fraisService: fraisService,
              reduction: reduction,
              status: uiStatus,
              phone: phone,
              img: image,
              adulte: adulte,
              enfant: enfant,
              message: message,
            ),
          );
        } catch (e) {
          debugPrint('Erreur conversion réservation : $e');
        }
      }

      if (!mounted) return;

      setState(() {
        _reservations = loadedReservations;
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = null;
      });

      debugPrint('${loadedReservations.length} réservations chargées');
    } catch (e, stackTrace) {
      debugPrint('ReservationsPage._loadReservations : $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isRefreshing = false;
        _errorMessage = _friendlyError(e);
      });
    }
  }


  // CHARGER PHOTO APPARTEMENT
  Future<String?> _loadAppartementPhoto(String appartementId) async {
    try {
      final response = await _supabase
          .from('photo_appartements')
          .select('*')
          .eq('appartement_id', appartementId)
          .limit(1);

      final photos = List<Map<String, dynamic>>.from(response);

      if (photos.isEmpty) return null;

      final photo = photos.first;

      const possibleUrlKeys = [
        'url',
        'photo_url',
        'image_url',
        'image',
        'src',
      ];

      for (final key in possibleUrlKeys) {
        final value = photo[key]?.toString().trim();

        if (value != null &&
            value.isNotEmpty &&
            value.startsWith('http')) {
          return value;
        }
      }

      const possiblePathKeys = [
        'path',
        'storage_path',
        'file_path',
        'nom_fichier',
        'filename',
      ];

      for (final key in possiblePathKeys) {
        final value = photo[key]?.toString().trim();

        if (value != null && value.isNotEmpty) {
          try {
            return _supabase.storage
                .from('appartements')
                .getPublicUrl(value);
          } catch (e) {
            debugPrint('Impossible URL Storage : $e');
          }
        }
      }

      return null;
    } catch (e) {
      debugPrint('Photo appartement $appartementId : $e');
      return null;
    }
  }


  // CONVERSION STATUT
  String _convertStatus(String status) {
    switch (status) {
      case 'confirmee':
      case 'confirmée':
      case 'confirmed':
        return 'confirmed';
      case 'annulee':
      case 'annulée':
      case 'cancelled':
        return 'cancelled';
      case 'en_attente':
      case 'en attente':
      case 'pending':
        return 'pending';
      case 'refuse':
      case 'refusée':
      case 'refused':
        return 'cancelled';
      case 'terminee':
      case 'terminée':
      case 'completed':
        return 'confirmed';
      default:
        return 'pending';
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

  num _toNum(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value;
    return num.tryParse(value.toString()) ?? 0;
  }

  int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  String _buildInitials(String prenom, String nom) {
    final first = prenom.isNotEmpty ? prenom[0] : '';
    final last = nom.isNotEmpty ? nom[0] : '';
    final initials = '$first$last'.trim();
    return initials.isEmpty ? 'L' : initials.toUpperCase();
  }

  String _friendlyError(Object error) {
    final message = error.toString().toLowerCase();

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return 'Vérifiez votre connexion Internet.';
    }

    if (message.contains('permission') ||
        message.contains('row level security') ||
        message.contains('rls')) {
      return 'Vous n’avez pas les autorisations nécessaires.';
    }

    return 'Impossible de charger les réservations.';
  }

  String _formatFcfa(num value) {
    final number = value.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < number.length; i++) {
      if (i > 0 && (number.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(number[i]);
    }

    return '${buffer.toString()} FCFA';
  }

  String _formatDate(DateTime date) {
    const months = [
      'janv.',
      'févr.',
      'mars',
      'avr.',
      'mai',
      'juin',
      'juil.',
      'août',
      'sept.',
      'oct.',
      'nov.',
      'déc.',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }


  // BUILD
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_errorMessage != null && _reservations.isEmpty) {
      return _buildErrorState();
    }

    final confirmedCount =
        _reservations.where((r) => r.status == 'confirmed').length;
    final pendingCount =
        _reservations.where((r) => r.status == 'pending').length;
    final totalRevenu = _reservations
        .where((r) => r.status != 'cancelled')
        .fold<num>(0, (sum, r) => sum + r.prixProprietaire);

    final filteredReservations = _filter == 'all'
        ? _reservations
        : _reservations.where((r) => r.status == _filter).toList();

    return Column(
      children: [
        _buildHeader(confirmedCount, pendingCount, totalRevenu),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _loadReservations(refresh: true),
            color: AppColors.primary,
            backgroundColor: const Color(0xFFF4F6FB),
            strokeWidth: 3,
            displacement: 20,
            child: ListView(
              padding: const EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              physics: const AlwaysScrollableScrollPhysics(
                parent: ClampingScrollPhysics(),
              ),
              children: [
                if (filteredReservations.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredReservations.map(
                        (reservation) =>
                        _buildReservationCard(reservation),
                  ),
                if (_isRefreshing)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        _buildSkeletonHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: 20,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              _SkeletonCard(),
              SizedBox(height: 12),
              _SkeletonCard(),
              SizedBox(height: 12),
              _SkeletonCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonHeader() {
    return Container(
      color: AppColors.foreground,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          Row(
            children: const [
              _SkeletonStatCard(),
              SizedBox(width: 10),
              _SkeletonStatCard(),
              SizedBox(width: 10),
              _SkeletonStatCard(),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: List.generate(
                4,
                    (index) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: index == 0
                          ? Colors.white
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 10,
                        decoration: BoxDecoration(
                          color: index == 0
                              ? AppColors.inputText.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      children: [
        _buildHeader(0, 0, 0),
        Expanded(
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 80),
              Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEF2F2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Color(0xFFEF4444),
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Impossible de charger',
                    style: GoogleFonts.nunito(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: AppColors.inputText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage ?? 'Une erreur est survenue.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadReservations,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(
                      'Réessayer',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final bool hasFilter = _filter != 'all';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasFilter
                  ? Icons.filter_list_off_rounded
                  : Icons.calendar_month_rounded,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            hasFilter
                ? 'Aucune réservation'
                : 'Aucune réservation pour le moment',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilter
                ? 'Aucune réservation ne correspond à ce filtre.'
                : 'Les réservations de vos appartements apparaîtront ici.',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          if (hasFilter) ...[
            const SizedBox(height: 18),
            TextButton(
              onPressed: () {
                setState(() {
                  _filter = 'all';
                });
              },
              child: Text(
                'Voir toutes les réservations',
                style: GoogleFonts.nunito(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(int confirmed, int pending, num totalRevenu) {
    return Container(
      color: AppColors.foreground,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatCard(
                label: 'Confirmées',
                value: '$confirmed',
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                label: 'En attente',
                value: '$pending',
                color: const Color(0xFFC9913A),
              ),
              const SizedBox(width: 10),
              _buildStatCard(
                label: 'Total revenus',
                value: _formatFcfa(totalRevenu),
                color: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.17),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildFilterTab(key: 'all', label: 'Toutes'),
                _buildFilterTab(key: 'confirmed', label: 'Confirmées'),
                _buildFilterTab(key: 'pending', label: 'En attente'),
                _buildFilterTab(key: 'cancelled', label: 'Annulées'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTab({
    required String key,
    required String label,
  }) {
    final bool isSelected = _filter == key;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _filter = key;
            _expandedId = null;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 11,
                color: isSelected
                    ? AppColors.inputText
                    : Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReservationCard(Reservation r) {
    final sc = statusConfig[r.status]!;
    final bool isExpanded = _expandedId == r.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.06),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedId = isExpanded ? null : r.id;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFEEF2FA),
                        ),
                        child: ClipOval(
                          child: (r.photoLocataireUrl != null &&
                              r.photoLocataireUrl!.isNotEmpty)
                              ? Image.network(
                            r.photoLocataireUrl!,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) {
                              // Fallback sur les initiales si l'image échoue
                              return Center(
                                child: Text(
                                  r.avatar,
                                  style: GoogleFonts.nunito(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                    color: AppColors.avatarRes,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFFE85D26),
                                  ),
                                ),
                              );
                            },
                          )
                              : Center(
                            child: Text(
                              r.avatar,
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                color: AppColors.avatarRes,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    r.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: AppColors.inputText,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: sc.bg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    sc.label,
                                    style: GoogleFonts.nunito(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: sc.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: _buildApartmentThumbnail(r),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    r.apt,
                                    style: GoogleFonts.nunito(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textSecondary,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Arrivée',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(r.checkIn),
                              style: GoogleFonts.nunito(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: AppColors.inputText,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                              'Durée',
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.inputText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${r.nights} nuits',
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.inputText,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Départ',
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(r.checkOut),
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: AppColors.inputText,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatFcfa(r.total),
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.inputText,
                        ),
                      ),
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF8A94A6),
                          size: 25,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildExpandedReservation(r),
        ],
      ),
    );
  }

  Widget _buildApartmentThumbnail(Reservation r) {
    if (r.img.isEmpty) {
      return _buildApartmentImagePlaceholder();
    }

    return Image.network(
      r.img,
      width: 20,
      height: 16,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) {
        return _buildApartmentImagePlaceholder();
      },
    );
  }

  Widget _buildApartmentImagePlaceholder() {
    return Container(
      width: 20,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.home_rounded,
        size: 11,
        color: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildExpandedReservation(Reservation r) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    'Voyageurs',
                    '${r.adulte} adulte${r.adulte > 1 ? 's' : ''} · '
                        '${r.enfant} enfant${r.enfant > 1 ? 's' : ''}',
                  ),
                  const SizedBox(height: 7),
                  _buildDetailRow(
                    'Prix propriétaire',
                    _formatFcfa(r.prixProprietaire),
                  ),
                  const SizedBox(height: 7),
                  _buildDetailRow(
                    'Frais de service',
                    _formatFcfa(r.fraisService),
                  ),
                  if (r.reduction > 0) ...[
                    const SizedBox(height: 7),
                    _buildDetailRow(
                      'Réduction',
                      '- ${_formatFcfa(r.reduction)}',
                    ),
                  ],
                  if (r.message != null &&
                      r.message!.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Message du locataire',
                        style: GoogleFonts.nunito(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        r.message!,
                        style: GoogleFonts.nunito(
                          fontSize: 13,
                          color: AppColors.inputText,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (r.status == 'pending') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateReservationStatus(
                        r,
                        'confirmee',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '✓ Accepter',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateReservationStatus(
                        r,
                        'refuse',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        elevation: 0,
                        padding:
                        const EdgeInsets.symmetric(vertical: 11),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '✗ Refuser',
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.danger,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _contactLocataire(r),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cardbo,
                      elevation: 0,
                      padding:
                      const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      '📞 Contacter',
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: AppColors.inputText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.nunito(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _updateReservationStatus(
      Reservation reservation,
      String newStatus,
      ) async {
    try {
      final bool isConfirm = newStatus == 'confirmee';
      final statusLabel = isConfirm ? 'confirmer' : 'refuser';

      final confirmed = await _showConfirmationDialog(
        title: isConfirm
            ? 'Confirmer la réservation'
            : 'Refuser la réservation',
        message: 'Voulez-vous vraiment '
            '$statusLabel cette réservation ?',
        isDanger: !isConfirm,
      );

      if (!confirmed) return;

      await _supabase
          .from('reservations')
          .update({
        'statut': newStatus,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', reservation.id);

      if (!mounted) return;

      setState(() {
        _expandedId = null;
      });

      _showSuccessSnackBar(
        isConfirm
            ? 'Réservation confirmée.'
            : 'Réservation refusée.',
      );

      await _loadReservations(refresh: true);
    } catch (e) {
      debugPrint('❌ Mise à jour réservation : $e');

      if (!mounted) return;

      _showErrorSnackBar(
        'Impossible de modifier la réservation.',
      );
    }
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String message,
    required bool isDanger,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
              color: AppColors.inputText,
              fontSize: 20,
            ),
          ),
          content: Text(
            message,
            style: GoogleFonts.nunito(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Annuler',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: isDanger
                    ? AppColors.danger
                    : const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Confirmer',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  void _contactLocataire(Reservation reservation) {
    if (reservation.phone.isEmpty) {
      _showErrorSnackBar(
        'Le numéro du locataire n’est pas disponible.',
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            'Contacter ${reservation.name}',
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w900,
            ),
          ),
          content: Text(
            reservation.phone,
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.removeCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}