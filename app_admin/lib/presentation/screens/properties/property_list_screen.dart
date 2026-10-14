import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service/database_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/main_layout.dart';
import '../../widgets/update_appartement_modal/update_appartement_dialog.dart';
import 'appartement/CRUD/detail/apartment_detail_modal.dart';

class PropertyListScreen extends StatefulWidget {
  final String city;
  final String propertyType;
  final String title;

  final String? initialResidenceId;
  final String? initialAppartementId;
  final String? focusResidenceId;

  const PropertyListScreen({
    super.key,
    required this.city,
    required this.propertyType,
    required this.title,
    this.initialResidenceId,
    this.initialAppartementId,
    this.focusResidenceId,
  });

  @override
  State<PropertyListScreen> createState() => _PropertyListScreenState();
}

class _PropertyListScreenState extends State<PropertyListScreen> {
  final DatabaseService _dbService = DatabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;

  // RÉSIDENCES
  List<Map<String, dynamic>> residences = [];
  List<Map<String, dynamic>> filteredResidences = [];

  Map<String, dynamic>? selectedResidence;

  bool isFetchingResidences = true;
  bool isFetchingApartments = false;

  String? _focusedResidenceId;

  // ACCORDÉON / CACHE
  final Set<String> _expandedResidenceIds = {};
  final Map<String, List<Map<String, dynamic>>> _apartmentsByResidence = {};
  final Set<String> _loadingApartmentsForResidence = {};
  final Map<String, int> _pendingDocsByResidence = {};

  // SCROLL
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _residenceKeys = {};

  // APPARTEMENTS
  List<Map<String, dynamic>> properties = [];
  List<Map<String, dynamic>> filteredProperties = [];

  String selectedFilter = 'Tous';

  final List<String> filterOptions = [
    'Tous',
    'En attente',
    'Publié',
    'Refusé',
  ];

  bool _initialNotificationHandled = false;

  // CONTRÔLEURS
  final TextEditingController titreController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController villeController = TextEditingController();

  final MoneyMaskedTextController prixController = MoneyMaskedTextController(
    decimalSeparator: '',
    thousandSeparator: ' ',
    leftSymbol: 'XOF ',
    precision: 0,
  );

  final TextEditingController dateDebutController = TextEditingController();
  final TextEditingController dateFinController = TextEditingController();

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _focusedResidenceId = widget.focusResidenceId;
    _fetchResidences();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    titreController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    adresseController.dispose();
    villeController.dispose();
    prixController.dispose();
    dateDebutController.dispose();
    dateFinController.dispose();
    super.dispose();
  }

  // ============================================================
  // SCROLL VERS UNE RÉSIDENCE
  // ============================================================

  void _scrollToResidence(String residenceId) {
    final key = _residenceKeys[residenceId];
    if (key == null) return;

    final ctx = key.currentContext;
    if (ctx == null) return;

    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      alignment: 0.15,
    );
  }

  // ============================================================
  // CHARGEMENT DES RÉSIDENCES
  // ============================================================

  Future<void> _fetchResidences() async {
    if (mounted) {
      setState(() => isFetchingResidences = true);
    }

    try {
      debugPrint('🏢 CHARGEMENT DES RÉSIDENCES - ${widget.city}');

      final data = await _supabase
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
            validated_by,
            validated_at,
            refusal_reason,
            created_at,
            updated_at
          ''')
          .eq('ville', widget.city)
          .order('created_at', ascending: false);

      final loadedResidences = List<Map<String, dynamic>>.from(data);

      debugPrint('🏢 ${loadedResidences.length} résidences récupérées');

      final futures = loadedResidences.map((residence) async {
        final residenceId = residence['id']?.toString();
        final proprietaireId = residence['proprietaire_id']?.toString();

        residence['proprietaire'] = null;
        residence['appartements_count'] = 0;

        final results = await Future.wait<dynamic>([
          (proprietaireId != null && proprietaireId.isNotEmpty)
              ? _supabase
              .from('users')
              .select(
              'id, nom, prenom, email, telephone, adresse, urgencephone')
              .eq('id', proprietaireId)
              .maybeSingle()
              : Future<Map<String, dynamic>?>.value(null),
          (residenceId != null && residenceId.isNotEmpty)
              ? _supabase
              .from('appartements')
              .select('id')
              .eq('residence_id', residenceId)
              : Future<List<dynamic>>.value(<dynamic>[]),
        ]);

        final proprietaire = results[0];
        if (proprietaire is Map) {
          residence['proprietaire'] =
          Map<String, dynamic>.from(proprietaire);
        }

        final apartments = results[1];
        if (apartments is List) {
          residence['appartements_count'] = apartments.length;
        }
      });

      await Future.wait(futures);

      try {
        final residenceIds = loadedResidences
            .map((r) => r['id']?.toString())
            .whereType<String>()
            .toList();

        final counts =
        await _dbService.fetchPendingDocsCountByResidence(residenceIds);

        if (mounted) {
          _pendingDocsByResidence
            ..clear()
            ..addAll(counts);
        }
      } catch (e) {
        debugPrint('⚠️ Compteur docs: $e');
      }

      if (!mounted) return;

      setState(() {
        residences = loadedResidences;
        filteredResidences =
        List<Map<String, dynamic>>.from(loadedResidences);
        isFetchingResidences = false;
      });

      if (_focusedResidenceId != null && _focusedResidenceId!.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Future.delayed(const Duration(milliseconds: 250), () {
            if (!mounted) return;
            _scrollToResidence(_focusedResidenceId!);
          });
        });
      }

      if (!_initialNotificationHandled &&
          widget.initialResidenceId != null &&
          widget.initialResidenceId!.isNotEmpty) {
        _initialNotificationHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _openResidenceFromNotification(widget.initialResidenceId!);
        });
        return;
      }

      if (!_initialNotificationHandled &&
          widget.initialAppartementId != null &&
          widget.initialAppartementId!.isNotEmpty) {
        _initialNotificationHandled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _openAppartementFromNotification(widget.initialAppartementId!);
        });
      }

      debugPrint('✅ Résidences chargées');
    } catch (e, st) {
      debugPrint('❌ ERREUR RÉSIDENCES : $e');
      debugPrint('$st');

      if (!mounted) return;

      setState(() {
        residences = [];
        filteredResidences = [];
        isFetchingResidences = false;
      });

      _safeShowSnackBar(
        'Erreur lors du chargement des résidences',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  Future<void> _openResidence(Map<String, dynamic> residence) async {
    final residenceId = residence['id']?.toString();

    if (residenceId == null || residenceId.isEmpty) {
      _safeShowSnackBar(
        'Identifiant de résidence invalide.',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return;
    }

    if (mounted) {
      setState(() {
        selectedResidence = residence;
        isFetchingApartments = true;
        properties = [];
        filteredProperties = [];
        selectedFilter = 'Tous';
      });
    }

    await _fetchApartmentsForResidence(residenceId);
  }

  // ============================================================
  // VALIDER / REFUSER DOCUMENT
  // ============================================================

  Future<Map<String, dynamic>?> _validerDocumentResidence(
      Map<String, dynamic> document) async {
    final documentId = document['id']?.toString();

    if (documentId == null || documentId.isEmpty) {
      _safeShowSnackBar(
        'Identifiant du document introuvable.',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return null;
    }

    try {
      await _supabase.rpc(
        'valider_document',
        params: {'p_document_id': documentId},
      );

      if (!mounted) return null;

      _safeShowSnackBar(
        'Document validé.',
        const Color(0xFF10B981),
        Icons.check_circle,
      );

      return {
        ...document,
        'statut': 'valide',
      };
    } catch (e) {
      debugPrint('❌ Erreur validation document : $e');

      if (!mounted) return null;

      _safeShowSnackBar(
        'Impossible de valider : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return null;
    }
  }

  Future<Map<String, dynamic>?> _refuserDocumentResidence(
      Map<String, dynamic> document) async {
    final documentId = document['id']?.toString();

    if (documentId == null || documentId.isEmpty) {
      _safeShowSnackBar(
        'Identifiant du document introuvable.',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return null;
    }

    final motifController = TextEditingController();

    final motif = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text(
          'Refuser le document',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: motifController,
          maxLines: 4,
          autofocus: true,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Motif du refus...',
            hintStyle: GoogleFonts.manrope(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF090D16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Annuler',
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final m = motifController.text.trim();
              if (m.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Veuillez saisir le motif du refus.'),
                  ),
                );
                return;
              }
              Navigator.of(dialogContext).pop(m);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    motifController.dispose();

    if (motif == null || motif.trim().isEmpty) return null;

    try {
      await _supabase.rpc(
        'refuser_document',
        params: {
          'p_document_id': documentId,
          'p_motif': motif.trim(),
        },
      );

      if (!mounted) return null;

      _safeShowSnackBar(
        'Document refusé.',
        const Color(0xFFEF4444),
        Icons.cancel,
      );

      return {
        ...document,
        'statut': 'refuse',
        'motif_refus': motif.trim(),
      };
    } catch (e) {
      debugPrint('❌ Erreur refus document : $e');

      if (!mounted) return null;

      _safeShowSnackBar(
        'Impossible de refuser : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return null;
    }
  }

  Future<void> _telechargerDocumentResidence(
      Map<String, dynamic> document) async {
    final chemin = document['chemin_fichier']?.toString();

    if (chemin == null || chemin.trim().isEmpty) {
      _safeShowSnackBar(
        'Fichier introuvable.',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
      return;
    }

    try {
      final signedUrl = await _supabase.storage
          .from('documents')
          .createSignedUrl(chemin, 60 * 10);

      final uri = Uri.parse(signedUrl);

      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _safeShowSnackBar(
          'Impossible d’ouvrir le document.',
          const Color(0xFFEF4444),
          Icons.error_outline,
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur téléchargement : $e');

      if (!mounted) return;

      _safeShowSnackBar(
        'Impossible de télécharger.',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  Future<void> _ouvrirLocalisation(String localisation) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(localisation)}',
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible d’ouvrir la localisation.')),
        );
      }
    } catch (e) {
      debugPrint('❌ Erreur ouverture localisation : $e');
    }
  }

  // ============================================================
  // CHARGER APPARTEMENTS (AVEC JOINTURE RÉSIDENCE)
  // ============================================================

  Future<void> _fetchApartmentsForResidence(String residenceId) async {
    if (mounted) setState(() => isFetchingApartments = true);

    try {
      final data = await _supabase
          .from('appartements')
          .select('''
            id,
            proprietaire_id,
            residence_id,
            titre,
            description,
            type,
            prix,
            prix_proprietaire,
            frais_service,
            nbre_sejour,
            etage,
            taille,
            status,
            disponibilite_status,
            validated_by,
            validated_at,
            refusal_reason,
            autres_equipements,
            rating,
            ratings_count,
            created_at,
            updated_at,
            residence:residences (
              id,
              nom,
              ville,
              adresse,
              localisation
            ),
            photo_appartements (
              id,
              fichiername,
              extension,
              titre,
              est_principale,
              ordre_affichage
            )
          ''')
          .eq('residence_id', residenceId)
          .order('created_at', ascending: false);

      final loadedProperties = List<Map<String, dynamic>>.from(data);

      // ✅ Aplatir les infos de la résidence
      for (final property in loadedProperties) {
        final residence = property['residence'];
        if (residence is Map) {
          property['ville'] = residence['ville'];
          property['adresse'] = residence['adresse'];
          property['localisation'] = residence['localisation'];
          property['residence_nom'] = residence['nom'];
        }
      }

      // Charger les propriétaires en parallèle
      await Future.wait(loadedProperties.map((property) async {
        final proprietaireId = property['proprietaire_id']?.toString();
        property['proprietaire'] = null;

        if (proprietaireId == null || proprietaireId.isEmpty) return;

        try {
          final proprietaire = await _supabase
              .from('users')
              .select(
              'id, nom, prenom, email, telephone, adresse, urgencephone')
              .eq('id', proprietaireId)
              .maybeSingle();

          if (proprietaire != null) {
            property['proprietaire'] =
            Map<String, dynamic>.from(proprietaire);
          }
        } catch (_) {}
      }));

      if (!mounted) return;

      setState(() {
        properties = loadedProperties;
        filteredProperties =
        List<Map<String, dynamic>>.from(loadedProperties);
        isFetchingApartments = false;
      });

      _applyFilter(selectedFilter, rebuild: false);
    } catch (e, st) {
      debugPrint('❌ Erreur appartements : $e');
      debugPrint('$st');

      if (!mounted) return;

      setState(() {
        properties = [];
        filteredProperties = [];
        isFetchingApartments = false;
      });

      _safeShowSnackBar(
        'Erreur lors du chargement',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  void _backToResidences() {
    if (!mounted) return;
    setState(() {
      selectedResidence = null;
      properties = [];
      filteredProperties = [];
      selectedFilter = 'Tous';
    });
  }

  // ============================================================
  // NOTIFICATIONS
  // ============================================================

  Future<void> _openResidenceFromNotification(String residenceId) async {
    Map<String, dynamic>? residence;

    try {
      residence = residences.cast<Map<String, dynamic>?>().firstWhere(
            (r) => r?['id']?.toString() == residenceId,
        orElse: () => null,
      );
    } catch (_) {}

    if (residence == null) {
      try {
        final result = await _supabase
            .from('residences')
            .select('''
              id, proprietaire_id, nom, description, ville, adresse,
              localisation, status, validated_by, validated_at,
              refusal_reason, created_at, updated_at
            ''')
            .eq('id', residenceId)
            .maybeSingle();

        if (result != null) {
          residence = Map<String, dynamic>.from(result);
        }
      } catch (e) {
        debugPrint('❌ Erreur notif résidence : $e');
      }
    }

    if (!mounted || residence == null) {
      _safeShowSnackBar(
        'Résidence introuvable.',
        Colors.orange,
        Icons.warning_amber_rounded,
      );
      return;
    }

    await _openResidence(residence);
  }

  Future<void> _openAppartementFromNotification(String appartementId) async {
    try {
      final apartment = await _supabase
          .from('appartements')
          .select('id, residence_id')
          .eq('id', appartementId)
          .maybeSingle();

      if (apartment == null) {
        _safeShowSnackBar(
          'Bien introuvable.',
          Colors.orange,
          Icons.warning_amber_rounded,
        );
        return;
      }

      final residenceId = apartment['residence_id']?.toString();

      if (residenceId == null || residenceId.isEmpty) {
        await _openAppartementDirectement(appartementId);
        return;
      }

      Map<String, dynamic>? residence;

      try {
        residence = residences.cast<Map<String, dynamic>?>().firstWhere(
              (r) => r?['id']?.toString() == residenceId,
          orElse: () => null,
        );
      } catch (_) {}

      if (residence == null) return;

      await _openResidence(residence);

      if (!mounted) return;

      final index = properties.indexWhere(
            (p) => p['id']?.toString() == appartementId,
      );

      if (index == -1) return;

      await Future<void>.delayed(const Duration(milliseconds: 100));

      if (!mounted) return;

      _openModalDetail(property: properties[index]);
    } catch (e) {
      debugPrint('❌ Erreur notif appartement : $e');
    }
  }

  Future<void> _openAppartementDirectement(String appartementId) async {
    try {
      final data = await _supabase
          .from('appartements')
          .select('''
            id, proprietaire_id, residence_id, titre, description, type,
            prix, prix_proprietaire, frais_service, nbre_sejour, etage, taille,
            status, disponibilite_status, validated_by, validated_at,
            refusal_reason, autres_equipements, rating, ratings_count,
            created_at, updated_at,
            residence:residences (
              id,
              nom,
              ville,
              adresse,
              localisation
            ),
            photo_appartements (
              id, fichiername, extension, titre, est_principale, ordre_affichage
            )
          ''')
          .eq('id', appartementId)
          .maybeSingle();

      if (data == null) return;

      final property = Map<String, dynamic>.from(data);

      // ✅ Aplatir les infos de la résidence
      final residence = property['residence'];
      if (residence is Map) {
        property['ville'] = residence['ville'];
        property['adresse'] = residence['adresse'];
        property['localisation'] = residence['localisation'];
        property['residence_nom'] = residence['nom'];
      }

      if (!mounted) return;

      _openModalDetail(property: property);
    } catch (e) {
      debugPrint('❌ Erreur : $e');
    }
  }

  // ============================================================
  // FILTRE
  // ============================================================

  void _applyFilter(String filter, {bool rebuild = true}) {
    List<Map<String, dynamic>> result;

    if (filter == 'Tous') {
      result = List.from(properties);
    } else if (filter == 'En attente') {
      result = properties.where((p) => p['status'] == 'en_attente').toList();
    } else if (filter == 'Publié') {
      result = properties.where((p) => p['status'] == 'publie').toList();
    } else if (filter == 'Refusé') {
      result = properties.where((p) => p['status'] == 'refuse').toList();
    } else {
      result = List.from(properties);
    }

    if (!mounted) return;

    if (rebuild) {
      setState(() {
        selectedFilter = filter;
        filteredProperties = result;
      });
    } else {
      selectedFilter = filter;
      filteredProperties = result;
    }
  }

  Map<String, int> _getStats() => {
    'Tous': properties.length,
    'En attente':
    properties.where((a) => a['status'] == 'en_attente').length,
    'Publié': properties.where((a) => a['status'] == 'publie').length,
    'Refusé': properties.where((a) => a['status'] == 'refuse').length,
  };

  void _safeShowSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color.withValues(alpha: 0.9),
          margin: EdgeInsets.all(16.w),
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Future<void> _openModalUpdate(Map<String, dynamic> property) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => UpdateAppartementDialog(appartement: property),
    );

    if (result != true || !mounted) return;

    final residenceId = property['residence_id']?.toString() ??
        selectedResidence?['id']?.toString();

    if (residenceId == null || residenceId.isEmpty) return;

    if (_apartmentsByResidence.containsKey(residenceId)) {
      final updated =
      await _dbService.fetchAppartementsWithInfos(residenceId);

      if (!mounted) return;

      setState(() => _apartmentsByResidence[residenceId] = updated);
    } else {
      await _fetchApartmentsForResidence(residenceId);
    }
  }

  Future<void> _deletePropertyAndRefresh({
    required String appartementId,
    required String residenceId,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text('Confirmer',
            style: GoogleFonts.manrope(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: Text('Supprimer cet appartement ?',
            style: GoogleFonts.manrope(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Annuler',
                style: GoogleFonts.manrope(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _dbService.deleteAppartement(appartementId);

      if (!mounted) return;

      final updated =
      await _dbService.fetchAppartementsWithInfos(residenceId);

      if (!mounted) return;

      setState(() {
        _apartmentsByResidence[residenceId] = updated;

        final residenceIndex =
        residences.indexWhere((r) => r['id']?.toString() == residenceId);

        if (residenceIndex != -1) {
          residences[residenceIndex]['appartements_count'] = updated.length;
        }
      });

      _safeShowSnackBar(
        'Appartement supprimé',
        const Color(0xFF10B981),
        Icons.check_circle,
      );
    } catch (e) {
      _safeShowSnackBar(
        'Erreur lors de la suppression',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  // ============================================================
  // OUVRIR MODAL DÉTAIL (AVEC INJECTION RÉSIDENCE + REFRESH)
  // ============================================================

  Future<void> _openModalDetail({required Map<String, dynamic> property}) async {
    // ✅ Injecter ville / adresse / localisation depuis la résidence
    final residenceId = property['residence_id']?.toString();

    Map<String, dynamic>? residence;

    if (selectedResidence != null &&
        selectedResidence!['id']?.toString() == residenceId) {
      residence = selectedResidence;
    } else if (residenceId != null && residenceId.isNotEmpty) {
      try {
        residence = residences.cast<Map<String, dynamic>?>().firstWhere(
              (r) => r?['id']?.toString() == residenceId,
          orElse: () => null,
        );
      } catch (_) {}
    }

    if (residence != null) {
      property['ville'] = residence['ville'];
      property['adresse'] = residence['adresse'];
      property['localisation'] = residence['localisation'];
      property['residence_nom'] = residence['nom'];
    }

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: ApartmentDetailModal(
          appartement: property,
          supabaseClient: Supabase.instance.client,
        ),
      ),
    );

    // ✅ Si le modal a modifié le statut → recharger
    if (result == true && mounted) {
      debugPrint('🔄 Modal a modifié le statut → rafraîchissement');

      final resId = property['residence_id']?.toString() ??
          selectedResidence?['id']?.toString();

      if (resId == null || resId.isEmpty) return;

      if (selectedResidence != null) {
        await _fetchApartmentsForResidence(resId);
      }

      if (_apartmentsByResidence.containsKey(resId)) {
        final updated =
        await _dbService.fetchAppartementsWithInfos(resId);

        if (!mounted) return;

        setState(() {
          _apartmentsByResidence[resId] = updated;
        });
      }

      await _fetchResidences();
    }
  }

  Color _getResidenceStatusColor(String? status) {
    switch (status) {
      case 'validee':
        return const Color(0xFF10B981);
      case 'refusee':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getResidenceStatusText(String? status) {
    switch (status) {
      case 'validee':
        return 'Validée';
      case 'refusee':
        return 'Refusée';
      default:
        return 'En attente';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final viewingResidence = selectedResidence != null;

    final pageTitle = viewingResidence
        ? (selectedResidence!['nom']?.toString().trim().isNotEmpty == true
        ? selectedResidence!['nom'].toString()
        : 'Résidence')
        : 'Résidences - ${widget.city}';

    return MainLayout(
      title: pageTitle,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh,
              color: Color(0xFFFFC107), size: 30),
          onPressed: () async {
            if (selectedResidence == null) {
              await _fetchResidences();
            } else {
              final residenceId = selectedResidence!['id']?.toString();
              if (residenceId != null && residenceId.isNotEmpty) {
                await _fetchApartmentsForResidence(residenceId);
              }
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.search,
              color: Colors.white54, size: 26),
          onPressed: _showSearchDialog,
        ),
      ],
      child: selectedResidence == null
          ? _buildResidencesView()
          : _buildResidenceApartmentsView(),
    );
  }

  Widget _buildResidencesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildResidenceHeader(),
        SizedBox(height: 24.h),
        _buildResidencesTable(),
      ],
    );
  }

  Widget _buildResidenceHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${filteredResidences.length} résidence(s)',
          style: GoogleFonts.manrope(
            color: Colors.white60,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: const Color(0xFFFFC107).withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.location_city,
                  color: Color(0xFFFFC107), size: 24),
              SizedBox(width: 8.w),
              Text(
                widget.city,
                style: GoogleFonts.manrope(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.bold,
                  fontSize: 30.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResidencesTable() {
    if (isFetchingResidences) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(color: Color(0xFFFFC107)),
        ),
      );
    }

    if (filteredResidences.isEmpty) {
      return _buildEmptyResidences();
    }

    return ListView.separated(
      controller: _scrollController,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredResidences.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final residence = filteredResidences[index];
        final residenceId = residence['id']?.toString() ?? '';

        _residenceKeys.putIfAbsent(residenceId, () => GlobalKey());

        return _buildResidenceCard(
          residence,
          key: _residenceKeys[residenceId],
        );
      },
    );
  }

  Widget _buildResidenceCard(Map<String, dynamic> residence,
      {Key? key}) {
    final residenceId = residence['id']?.toString() ?? '';
    final isExpanded = _expandedResidenceIds.contains(residenceId);
    final isFocused = _focusedResidenceId == residenceId;

    final nom = residence['nom']?.toString() ?? 'Résidence';
    final ville = residence['ville']?.toString() ?? '';
    final adresse = residence['adresse']?.toString() ?? '';
    final apartmentCount = residence['appartements_count'] ?? 0;
    final pendingDocs = _pendingDocsByResidence[residenceId] ?? 0;

    final apartments = _apartmentsByResidence[residenceId] ?? [];
    final isLoadingApartments =
    _loadingApartmentsForResidence.contains(residenceId);

    return Container(
      key: key,
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isFocused
              ? const Color(0xFFFFC107)
              : isExpanded
              ? const Color(0xFFFFC107).withValues(alpha: 0.35)
              : Colors.white.withValues(alpha: 0.05),
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused
            ? [
          BoxShadow(
            color: const Color(0xFFFFC107).withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 22.h),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.apartment_rounded,
                    color: const Color(0xFFFFC107),
                    size: 30.sp,
                  ),
                ),
                SizedBox(width: 18.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              nom,
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22.sp,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (pendingDocs > 0) ...[
                            SizedBox(width: 12.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 5.h,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFC107)
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(
                                  color: const Color(0xFFFFC107)
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '$pendingDocs doc${pendingDocs > 1 ? 's' : ''} en attente',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFFFC107),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              color: Colors.white38, size: 20),
                          SizedBox(width: 5.w),
                          Text(
                            '$ville, $adresse',
                            style: GoogleFonts.manrope(
                              color: Colors.white54,
                              fontSize: 18.sp,
                            ),
                          ),
                          SizedBox(width: 18.w),
                          const Icon(Icons.meeting_room_outlined,
                              color: Colors.white38, size: 20),
                          SizedBox(width: 5.w),
                          Text(
                            '$apartmentCount appartement${apartmentCount > 1 ? 's' : ''}',
                            style: GoogleFonts.manrope(
                                color: Colors.white54, fontSize: 18.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 14.w),
                OutlinedButton.icon(
                  onPressed: () =>
                      _openResidenceAboutModal(residence: residence),
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: Text(
                    'À propos',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700,
                      fontSize: 17.sp,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFFC107),
                    side: BorderSide(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  borderRadius: BorderRadius.circular(8.r),
                  onTap: () => _toggleResidence(residence),
                  child: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: Colors.white70,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
            if (isLoadingApartments)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: const Center(
                  child:
                  CircularProgressIndicator(color: Color(0xFFFFC107)),
                ),
              )
            else
              _buildApartmentsTable(residenceId, apartments),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleResidence(Map<String, dynamic> residence) async {
    final residenceId = residence['id']?.toString();
    if (residenceId == null || residenceId.isEmpty) return;

    if (_expandedResidenceIds.contains(residenceId)) {
      setState(() => _expandedResidenceIds.remove(residenceId));
      return;
    }

    setState(() => _expandedResidenceIds.add(residenceId));

    if (!_apartmentsByResidence.containsKey(residenceId)) {
      setState(() => _loadingApartmentsForResidence.add(residenceId));

      final data = await _dbService.fetchAppartementsWithInfos(residenceId);

      if (!mounted) return;

      setState(() {
        _apartmentsByResidence[residenceId] = data;
        _loadingApartmentsForResidence.remove(residenceId);
      });
    }
  }

  Widget _buildApartmentsTable(
      String residenceId, List<Map<String, dynamic>> apartments) {
    if (apartments.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 30.h),
        child: Center(
          child: Text(
            'Aucun appartement dans cette résidence',
            style: GoogleFonts.manrope(
                color: Colors.white38, fontSize: 15.sp),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(flex: 3, child: _tableHeader('APPARTEMENT')),
              Expanded(flex: 2, child: _tableHeader('ÉTAGE')),
              Expanded(flex: 2, child: _tableHeader('SUPERFICIE')),
              Expanded(flex: 3, child: _tableHeader('LOYER MENSUEL')),
              Expanded(flex: 2, child: _tableHeader('STATUT')),
              SizedBox(width: 48.w),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),
        ...apartments.map((apt) => _buildApartmentRow(apt, residenceId)),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: Colors.white38,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildApartmentRow(Map<String, dynamic> apt, String residenceId) {
    final titre = apt['titre']?.toString() ?? 'Sans titre';
    final etageText = _formatEtage(apt['etage']);
    final tailleText = _formatTaille(apt['taille']);
    final prixText = _formatPrixLoyer(apt['prix']);
    final statut = apt['disponibilite_status']?.toString() ?? 'disponible';

    return InkWell(
      onTap: () => _openModalDetail(property: apt),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(titre,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  )),
            ),
            Expanded(
              flex: 2,
              child: Text(etageText,
                  style: GoogleFonts.manrope(
                      color: Colors.white70, fontSize: 18.sp)),
            ),
            Expanded(
              flex: 2,
              child: Text(tailleText,
                  style: GoogleFonts.manrope(
                      color: Colors.white70, fontSize: 18.sp)),
            ),
            Expanded(
              flex: 3,
              child: Text(prixText,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFC107),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  )),
            ),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildDispoStatusChip(statut),
              ),
            ),
            SizedBox(
              width: 48.w,
              child: PopupMenuButton<String>(
                tooltip: 'Actions',
                icon: const Icon(Icons.more_vert,
                    color: Colors.white60, size: 22),
                color: const Color(0xFF111622),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'detail':
                      _openModalDetail(property: apt);
                      break;
                    case 'modifier':
                      _openModalUpdate(apt);
                      break;
                    case 'supprimer':
                      _deletePropertyAndRefresh(
                        appartementId: apt['id'].toString(),
                        residenceId: residenceId,
                      );
                      break;
                  }
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'detail',
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          color: Colors.white, size: 20),
                      SizedBox(width: 12.w),
                      Text('Détails',
                          style: GoogleFonts.manrope(
                              color: Colors.white, fontSize: 15.sp)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'modifier',
                    child: Row(children: [
                      const Icon(Icons.edit_outlined,
                          color: Color(0xFFFFC107), size: 20),
                      SizedBox(width: 12.w),
                      Text('Modifier',
                          style: GoogleFonts.manrope(
                              color: const Color(0xFFFFC107),
                              fontSize: 15.sp)),
                    ]),
                  ),
                  PopupMenuItem(
                    value: 'supprimer',
                    child: Row(children: [
                      const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      SizedBox(width: 12.w),
                      Text('Supprimer',
                          style: GoogleFonts.manrope(
                              color: Colors.red, fontSize: 15.sp)),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDispoStatusChip(String statut) {
    late Color color;
    late String label;

    switch (statut) {
      case 'occupe':
        color = const Color(0xFF3B82F6);
        label = 'Occupé';
        break;
      case 'en_maintenance':
        color = const Color(0xFFF59E0B);
        label = 'En maintenance';
        break;
      case 'libre':
      case 'disponible':
      default:
        color = const Color(0xFF10B981);
        label = 'Libre';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: color,
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatEtage(dynamic etage) {
    if (etage == null) return '—';
    final value = int.tryParse(etage.toString());
    if (value == null) return etage.toString();
    if (value == 0) return 'RDC';
    if (value == 1) return '1er';
    return '${value}ème';
  }

  String _formatTaille(dynamic taille) {
    if (taille == null) return '—';
    final value = double.tryParse(taille.toString());
    if (value == null) return '—';
    final rounded = value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(1);
    return '$rounded m²';
  }

  String _formatPrixLoyer(dynamic prix) {
    if (prix == null) return '—';
    final value = num.tryParse(prix.toString()) ?? 0;
    return '${NumberFormat.decimalPattern('fr_FR').format(value)} F';
  }

  Widget _buildEmptyResidences() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.business_outlined,
                size: 70.w, color: Colors.white24),
            SizedBox(height: 16.h),
            Text('Aucune résidence trouvée',
                style: GoogleFonts.manrope(
                  color: Colors.white38,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                )),
            SizedBox(height: 8.h),
            Text('Aucune résidence à ${widget.city}.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                    color: Colors.white24, fontSize: 16.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildResidenceApartmentsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSelectedResidenceHeader(),
        SizedBox(height: 24.h),
        _buildFilterChipsLayout(),
      ],
    );
  }

  Widget _buildSelectedResidenceHeader() {
    final residence = selectedResidence!;
    final status = residence['status']?.toString();
    final nom = residence['nom']?.toString() ?? 'Résidence';
    final adresse = residence['adresse']?.toString() ?? '';

    return Row(
      children: [
        IconButton(
          onPressed: _backToResidences,
          tooltip: 'Retour',
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
        ),
        SizedBox(width: 8.w),
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(Icons.business_outlined,
              color: const Color(0xFFFFC107), size: 30.sp),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(nom,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                  )),
              SizedBox(height: 5.h),
              Row(children: [
                const Icon(Icons.location_on_outlined,
                    color: Colors.white38, size: 18),
                SizedBox(width: 5.w),
                Flexible(
                  child: Text(adresse,
                      style: GoogleFonts.manrope(
                          color: Colors.white54, fontSize: 16.sp),
                      overflow: TextOverflow.ellipsis),
                ),
              ]),
            ],
          ),
        ),
        OutlinedButton.icon(
          onPressed: () => _openResidenceAboutModal(),
          icon: const Icon(Icons.info_outline, size: 20),
          label: Text('À propos',
              style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700, fontSize: 16.sp)),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFFFFC107),
            side: BorderSide(
                color: const Color(0xFFFFC107).withValues(alpha: 0.45)),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
        ),
        SizedBox(width: 14.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: _getResidenceStatusColor(status).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(7.r),
          ),
          child: Text(_getResidenceStatusText(status),
              style: GoogleFonts.manrope(
                color: _getResidenceStatusColor(status),
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              )),
        ),
      ],
    );
  }

  Widget _buildFilterChipsLayout() {
    final stats = _getStats();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((filter) {
          final count = stats[filter] ?? 0;
          final isSelected = selectedFilter == filter;

          Color activeColor = const Color(0xFFFFC107);
          if (filter == 'Publié') activeColor = const Color(0xFF10B981);
          if (filter == 'Refusé') activeColor = const Color(0xFFEF4444);
          if (filter == 'En attente') activeColor = const Color(0xFFF59E0B);

          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: ChoiceChip(
              label: Text('$filter ($count)',
                  style: GoogleFonts.manrope(
                    color: isSelected
                        ? const Color(0xFF090D16)
                        : Colors.white70,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  )),
              selected: isSelected,
              selectedColor: activeColor,
              backgroundColor: const Color(0xFF111622),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color: isSelected
                      ? activeColor
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              onSelected: (_) => _applyFilter(filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _openResidenceAboutModal({
    Map<String, dynamic>? residence,
  }) async {
    final targetResidence = residence ?? selectedResidence;
    if (targetResidence == null) return;

    final residenceId = targetResidence['id']?.toString();
    if (residenceId == null || residenceId.isEmpty) return;

    try {
      final apartmentsResponse = await _supabase
          .from('appartements')
          .select('id')
          .eq('residence_id', residenceId);

      final apartmentCount = (apartmentsResponse as List).length;

      final documentsResponse = await _supabase
          .from('documents')
          .select('''
            id, user_id, residence_id, appartement_id, categorie,
            type_document, cote_document, nom_fichier, chemin_fichier,
            mime_type, taille_fichier, numero_document, date_emission,
            date_expiration, pays_emission, statut, motif_refus,
            verifie_par, date_verification, obligatoire,
            created_at, updated_at
          ''')
          .eq('residence_id', residenceId)
          .order('created_at', ascending: false);

      final documents =
      List<Map<String, dynamic>>.from(documentsResponse as List);

      if (!mounted) return;

      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) {
          return _ResidenceAboutDialog(
            residence: Map<String, dynamic>.from(targetResidence),
            apartmentCount: apartmentCount,
            documents: documents,
            onValidateDocument: _validerDocumentResidence,
            onRefuseDocument: _refuserDocumentResidence,
            onDownloadDocument: _telechargerDocumentResidence,
            onOpenLocation: _ouvrirLocalisation,
            onValidateResidence: () => _validerResidence(residenceId),
            onRefuseResidence: () => _refuserResidence(residenceId),
          );
        },
      );

      if (mounted) _fetchResidences();
    } catch (e) {
      debugPrint('❌ Erreur modal : $e');
    }
  }

  Future<void> _validerResidence(String residenceId) async {
    try {
      final docsResponse = await _supabase
          .from('documents')
          .select('id, statut')
          .eq('residence_id', residenceId);

      final docs = List<Map<String, dynamic>>.from(docsResponse);

      if (docs.isEmpty) {
        _safeShowSnackBar(
          'Aucun document trouvé.',
          Colors.orange,
          Icons.warning_amber_rounded,
        );
        return;
      }

      final pendingDocs = docs.where((d) {
        final s = d['statut']?.toString().toLowerCase() ?? '';
        return s == 'en_attente' || s == 'en_verification';
      }).length;

      if (pendingDocs > 0) {
        _safeShowSnackBar(
          'Impossible : $pendingDocs doc${pendingDocs > 1 ? 's' : ''} en attente.',
          const Color(0xFFEF4444),
          Icons.error_outline,
        );
        return;
      }

      await _supabase.rpc(
        'valider_residence',
        params: {'p_residence_id': residenceId},
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _safeShowSnackBar(
        'Résidence validée avec succès.',
        const Color(0xFF10B981),
        Icons.check_circle,
      );

      await _fetchResidences();
    } catch (e) {
      debugPrint('❌ Erreur validation : $e');

      if (!mounted) return;

      _safeShowSnackBar(
        'Impossible de valider : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  Future<void> _refuserResidence(String residenceId) async {
    final motifController = TextEditingController();

    final motif = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text('Refuser la résidence',
            style: GoogleFonts.manrope(
                color: Colors.white, fontWeight: FontWeight.w700)),
        content: TextField(
          controller: motifController,
          maxLines: 4,
          autofocus: true,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Motif du refus...',
            hintStyle: GoogleFonts.manrope(color: Colors.white54),
            filled: true,
            fillColor: const Color(0xFF090D16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Annuler',
                style: GoogleFonts.manrope(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              final m = motifController.text.trim();
              if (m.isEmpty) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                      content: Text('Veuillez saisir le motif.')),
                );
                return;
              }
              Navigator.of(dialogContext).pop(m);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    motifController.dispose();

    if (motif == null || motif.trim().isEmpty) return;

    try {
      await _supabase.rpc(
        'refuser_residence',
        params: {
          'p_residence_id': residenceId,
          'p_motif': motif.trim(),
        },
      );

      if (!mounted) return;

      Navigator.of(context).pop();

      _safeShowSnackBar(
        'Résidence refusée.',
        const Color(0xFFEF4444),
        Icons.cancel,
      );

      await _fetchResidences();
    } catch (e) {
      _safeShowSnackBar(
        'Impossible de refuser : $e',
        const Color(0xFFEF4444),
        Icons.error_outline,
      );
    }
  }

  void _showSearchDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r)),
        title: Text(
          selectedResidence == null
              ? 'Rechercher une résidence'
              : 'Rechercher un appartement',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: selectedResidence == null
                ? 'Nom, adresse...'
                : 'Titre, adresse...',
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
          onChanged: (value) {
            final query = value.toLowerCase().trim();

            if (selectedResidence == null) {
              setState(() {
                if (query.isEmpty) {
                  filteredResidences = List.from(residences);
                } else {
                  filteredResidences = residences.where((r) {
                    final nom = r['nom']?.toString().toLowerCase() ?? '';
                    final adresse =
                        r['adresse']?.toString().toLowerCase() ?? '';
                    final ville =
                        r['ville']?.toString().toLowerCase() ?? '';
                    final prop =
                    r['proprietaire'] as Map<String, dynamic>?;
                    final propText = prop != null
                        ? '${prop['prenom'] ?? ''} ${prop['nom'] ?? ''}'
                        .toLowerCase()
                        : '';
                    return nom.contains(query) ||
                        adresse.contains(query) ||
                        ville.contains(query) ||
                        propText.contains(query);
                  }).toList();
                }
              });
            } else {
              setState(() {
                if (query.isEmpty) {
                  _applyFilter(selectedFilter);
                } else {
                  filteredProperties = properties.where((p) {
                    final titre =
                        p['titre']?.toString().toLowerCase() ?? '';
                    final type = p['type']?.toString().toLowerCase() ?? '';
                    return titre.contains(query) || type.contains(query);
                  }).toList();
                }
              });
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Fermer',
                style: GoogleFonts.manrope(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (selectedResidence == null) {
                setState(() => filteredResidences = List.from(residences));
              } else {
                _applyFilter(selectedFilter);
              }
              Navigator.pop(context);
            },
            child: Text('Réinitialiser',
                style: GoogleFonts.manrope(
                    color: const Color(0xFFFFC107))),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DIALOG À PROPOS (STATEFUL - INSTANTANÉ)
// ============================================================

class _ResidenceAboutDialog extends StatefulWidget {
  final Map<String, dynamic> residence;
  final int apartmentCount;
  final List<Map<String, dynamic>> documents;

  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> document)
  onValidateDocument;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic> document)
  onRefuseDocument;
  final Future<void> Function(Map<String, dynamic> document)
  onDownloadDocument;
  final VoidCallback onValidateResidence;
  final VoidCallback onRefuseResidence;
  final Future<void> Function(String localisation) onOpenLocation;

  const _ResidenceAboutDialog({
    required this.residence,
    required this.apartmentCount,
    required this.documents,
    required this.onValidateDocument,
    required this.onRefuseDocument,
    required this.onDownloadDocument,
    required this.onValidateResidence,
    required this.onRefuseResidence,
    required this.onOpenLocation,
  });

  @override
  State<_ResidenceAboutDialog> createState() => _ResidenceAboutDialogState();
}

class _ResidenceAboutDialogState extends State<_ResidenceAboutDialog> {
  late List<Map<String, dynamic>> _documents;
  String? _processingDocId;

  static const Color _bg = Color(0xFF0B1220);
  static const Color _card = Color(0xFF111C2E);
  static const Color _border = Color(0xFF1E2A3D);
  static const Color _gold = Color(0xFFF5C34A);
  static const Color _textPrimary = Color(0xFFFFFFFF);
  static const Color _textSecondary = Color(0xFF8A98AC);
  static const Color _green = Color(0xFF10B981);
  static const Color _red = Color(0xFFEF4444);
  static const Color _orange = Color(0xFFF59E0B);

  @override
  void initState() {
    super.initState();
    _documents = List<Map<String, dynamic>>.from(widget.documents);
  }

  Future<void> _handleValidateDocument(Map<String, dynamic> doc) async {
    final id = doc['id']?.toString();
    if (id == null) return;

    setState(() => _processingDocId = id);

    final updated = await widget.onValidateDocument(doc);

    if (!mounted) return;

    setState(() {
      _processingDocId = null;
      if (updated != null) {
        final idx = _documents.indexWhere((d) => d['id'] == id);
        if (idx != -1) _documents[idx] = updated;
      }
    });
  }

  Future<void> _handleRefuseDocument(Map<String, dynamic> doc) async {
    final id = doc['id']?.toString();
    if (id == null) return;

    setState(() => _processingDocId = id);

    final updated = await widget.onRefuseDocument(doc);

    if (!mounted) return;

    setState(() {
      _processingDocId = null;
      if (updated != null) {
        final idx = _documents.indexWhere((d) => d['id'] == id);
        if (idx != -1) _documents[idx] = updated;
      }
    });
  }

  bool get _allDocsValidated =>
      _documents.isNotEmpty &&
          _documents.every((doc) {
            final s = doc['statut']?.toString().toLowerCase() ?? '';
            return s == 'valide' || s == 'validee' || s == 'verifie';
          });

  int get _pendingDocsCount => _documents.where((doc) {
    final s = doc['statut']?.toString().toLowerCase() ?? '';
    return s == 'en_attente' || s == 'en_verification';
  }).length;

  @override
  Widget build(BuildContext context) {
    final residence = widget.residence;
    final status = residence['status']?.toString() ?? 'en_attente';
    final isPending = status == 'en_attente';

    final nom = residence['nom']?.toString() ?? 'Résidence';
    final ville = residence['ville']?.toString() ?? '';
    final adresse = residence['adresse']?.toString() ?? '';
    final localisation = residence['localisation']?.toString() ?? '';
    final description = residence['description']?.toString() ?? '';

    final proprietaire = residence['proprietaire'] as Map<String, dynamic>?;

    final proprietaireNom = proprietaire != null
        ? '${proprietaire['prenom'] ?? ''} ${proprietaire['nom'] ?? ''}'.trim()
        : 'Propriétaire inconnu';

    final totalDocs = _documents.length;

    return Dialog(
      backgroundColor: _bg,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 900.w, maxHeight: 860.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            Container(
              padding: EdgeInsets.fromLTRB(28.w, 26.h, 20.w, 26.h),
              decoration: const BoxDecoration(
                color: Color(0xFF0E1728),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: _gold.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(Icons.apartment_rounded,
                        color: _gold, size: 30.sp),
                  ),
                  SizedBox(width: 18.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom,
                            style: GoogleFonts.manrope(
                              color: _textPrimary,
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w800,
                            ),
                            overflow: TextOverflow.ellipsis),
                        SizedBox(height: 4.h),
                        Text('$proprietaireNom',
                            style: GoogleFonts.manrope(
                              color: _textSecondary,
                              fontSize: 20.sp,
                            ),
                            overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close,
                        color: _textSecondary, size: 26.sp),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.white.withValues(alpha: 0.05)),
            Flexible(
              child: SingleChildScrollView(
                padding:
                EdgeInsets.symmetric(horizontal: 28.w, vertical: 26.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('INFORMATIONS GÉNÉRALES'),
                    SizedBox(height: 16.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 500.w;
                        return Wrap(
                          spacing: 16.w,
                          runSpacing: 16.h,
                          children: [
                            _infoCard(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16.w) / 2,
                              icon: Icons.apartment_outlined,
                              label: 'Résidence',
                              value: nom,
                            ),
                            _infoCard(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16.w) / 2,
                              icon: Icons.tag,
                              label: 'Appartements',
                              value: '${widget.apartmentCount} unités',
                            ),
                            _infoCard(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16.w) / 2,
                              icon: Icons.location_on_outlined,
                              label: 'Ville',
                              value: ville.isNotEmpty ? ville : '—',
                            ),
                            _infoCard(
                              width: isNarrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 16.w) / 2,
                              icon: Icons.home_outlined,
                              label: 'Adresse',
                              value: adresse.isNotEmpty ? adresse : '—',
                            ),
                            if (localisation.trim().isNotEmpty)
                              InkWell(
                                onTap: () =>
                                    widget.onOpenLocation(localisation),
                                borderRadius: BorderRadius.circular(12.r),
                                child: Container(
                                  width: constraints.maxWidth,
                                  padding: EdgeInsets.all(18.w),
                                  decoration: BoxDecoration(
                                    color: _card,
                                    borderRadius:
                                    BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color:
                                      _gold.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.map_outlined,
                                          size: 20.sp, color: _gold),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text('Localisation GPS',
                                                style:
                                                GoogleFonts.manrope(
                                                  color: _textSecondary,
                                                  fontSize: 16.sp,
                                                  fontWeight:
                                                  FontWeight.w500,
                                                )),
                                            SizedBox(height: 6.h),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(localisation,
                                                      style: GoogleFonts
                                                          .manrope(
                                                        color: _gold,
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                        FontWeight
                                                            .w600,
                                                      ),
                                                      overflow:
                                                      TextOverflow
                                                          .ellipsis),
                                                ),
                                                Icon(Icons.open_in_new,
                                                    color: _gold,
                                                    size: 16.sp),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 28.h),
                    if (description.trim().isNotEmpty) ...[
                      _sectionTitle('DESCRIPTION'),
                      SizedBox(height: 16.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: _border),
                        ),
                        child: Text(description,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFFC4CFDF),
                              fontSize: 20.sp,
                              height: 1.7,
                            )),
                      ),
                      SizedBox(height: 28.h),
                    ],
                    Row(
                      children: [
                        _sectionTitle('DOCUMENTS DU PROPRIÉTAIRE'),
                        const Spacer(),
                        Text('$totalDocs fichier${totalDocs > 1 ? 's' : ''}',
                            style: GoogleFonts.manrope(
                              color: _textSecondary,
                              fontSize: 18.sp,
                            )),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    if (_documents.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(22.w),
                        decoration: BoxDecoration(
                          color: _card,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: _border),
                        ),
                        child: Text('Aucun document.',
                            style: GoogleFonts.manrope(
                                color: _textSecondary, fontSize: 14.sp)),
                      )
                    else
                      ..._documents.map((doc) => _buildDocumentTile(doc)),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            ),
            // FOOTER
            Container(
              padding:
              EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF0E1728),
                borderRadius:
                const BorderRadius.vertical(bottom: Radius.circular(16)),
                border: Border(
                  top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.05)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isPending && !_allDocsValidated) ...[
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.info_outline,
                              color: _orange, size: 18.sp),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              _pendingDocsCount > 0
                                  ? '$_pendingDocsCount document${_pendingDocsCount > 1 ? 's' : ''} en attente'
                                  : 'Tous les documents doivent être validés',
                              style: GoogleFonts.manrope(
                                color: _orange,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (isPending) ...[
                    OutlinedButton.icon(
                      onPressed: widget.onRefuseResidence,
                      icon: const Icon(Icons.close, size: 18),
                      label: Text('Refuser',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            fontSize: 17.sp,
                          )),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _red,
                        side: BorderSide(
                            color: _red.withValues(alpha: 0.5)),
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 13.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    ElevatedButton.icon(
                      onPressed:
                      _allDocsValidated ? widget.onValidateResidence : null,
                      icon: Icon(
                        _allDocsValidated
                            ? Icons.check
                            : Icons.lock_outline,
                        size: 18,
                      ),
                      label: Text('Valider la résidence',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            fontSize: 17.sp,
                          )),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _green,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor:
                        _green.withValues(alpha: 0.25),
                        disabledForegroundColor: Colors.white38,
                        padding: EdgeInsets.symmetric(
                            horizontal: 18.w, vertical: 13.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(width: 12.w),
                  ],
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _textSecondary,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.12)),
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 13.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text('Fermer',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w600,
                          fontSize: 17.sp,
                        )),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(text,
        style: GoogleFonts.manrope(
          color: _gold,
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ));
  }

  Widget _infoCard({
    required double width,
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: width,
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, size: 22.sp, color: _gold.withValues(alpha: 0.75)),
              SizedBox(width: 10.w),
              Text(label,
                  style: GoogleFonts.manrope(
                    color: _textSecondary,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                  )),
            ]),
            SizedBox(height: 10.h),
            Text(value,
                style: GoogleFonts.manrope(
                  color: _textPrimary,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTile(Map<String, dynamic> document) {
    final id = document['id']?.toString() ?? '';
    final type = document['type_document']?.toString() ?? 'Document';
    final nom = document['nom_fichier']?.toString() ?? 'Fichier';
    final statut = document['statut']?.toString() ?? 'inconnu';
    final taille = document['taille_fichier'];

    final isPending =
        statut == 'en_attente' || statut == 'en_verification';
    final isProcessing = _processingDocId == id;
    final statusStyle = _statusStyle(statut);

    String tailleText = '';
    if (taille is num && taille > 0) {
      final mo = taille / (1024 * 1024);
      tailleText = mo >= 1
          ? '${mo.toStringAsFixed(1)} Mo'
          : '${(taille / 1024).toStringAsFixed(0)} Ko';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isProcessing
              ? _gold.withValues(alpha: 0.5)
              : _border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: _gold.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: isProcessing
                ? Padding(
              padding: EdgeInsets.all(14.w),
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFF5C34A),
              ),
            )
                : Icon(Icons.description_outlined,
                color: _gold, size: 28.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type,
                    style: GoogleFonts.manrope(
                      color: _textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Text(tailleText.isNotEmpty ? '$tailleText · $nom' : nom,
                    style: GoogleFonts.manrope(
                      color: _textSecondary,
                      fontSize: 15.sp,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding:
            EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: statusStyle.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                  color: statusStyle.color.withValues(alpha: 0.35)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(statusStyle.icon,
                    size: 18.sp, color: statusStyle.color),
                SizedBox(width: 6.w),
                Text(statusStyle.label,
                    style: GoogleFonts.manrope(
                      color: statusStyle.color,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                    )),
              ],
            ),
          ),
          SizedBox(width: 14.w),
          Row(
            children: [
              _actionButton(
                icon: Icons.visibility_outlined,
                label: 'Voir',
                color: Colors.white70,
                onTap: isProcessing
                    ? null
                    : () => widget.onDownloadDocument(document),
              ),
              SizedBox(width: 8.w),
              _actionButton(
                icon: Icons.download_outlined,
                label: 'Télécharger',
                color: Colors.white70,
                onTap: isProcessing
                    ? null
                    : () => widget.onDownloadDocument(document),
              ),
              if (isPending) ...[
                SizedBox(width: 8.w),
                _actionButton(
                  icon: Icons.check,
                  label: 'Valider',
                  color: _green,
                  onTap: isProcessing
                      ? null
                      : () => _handleValidateDocument(document),
                ),
                SizedBox(width: 8.w),
                _actionButton(
                  icon: Icons.close,
                  label: 'Refuser',
                  color: _red,
                  onTap: isProcessing
                      ? null
                      : () => _handleRefuseDocument(document),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    final effectiveColor =
    isDisabled ? color.withValues(alpha: 0.3) : color;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
              color: effectiveColor.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22.sp, color: effectiveColor),
            SizedBox(width: 7.w),
            Text(label,
                style: GoogleFonts.manrope(
                  color: effectiveColor,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }

  _DocStatusStyle _statusStyle(String status) {
    switch (status) {
      case 'valide':
      case 'validee':
      case 'verifie':
        return _DocStatusStyle(
            color: _green,
            label: 'Validé',
            icon: Icons.check_circle_outline);
      case 'refuse':
      case 'refusee':
        return _DocStatusStyle(
            color: _red,
            label: 'Refusé',
            icon: Icons.cancel_outlined);
      case 'en_verification':
      case 'en_attente':
        return _DocStatusStyle(
            color: _orange,
            label: 'En attente',
            icon: Icons.access_time);
      case 'expire':
        return _DocStatusStyle(
            color: Colors.orange,
            label: 'Expiré',
            icon: Icons.warning_amber_rounded);
      default:
        return _DocStatusStyle(
            color: _textSecondary,
            label: 'Inconnu',
            icon: Icons.help_outline);
    }
  }
}

class _DocStatusStyle {
  final Color color;
  final String label;
  final IconData icon;

  _DocStatusStyle({
    required this.color,
    required this.label,
    required this.icon,
  });
}