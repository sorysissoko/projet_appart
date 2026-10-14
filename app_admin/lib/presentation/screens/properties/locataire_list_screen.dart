import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/database_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../widgets/main_layout.dart';
import 'package:service/service_locator.dart';

class LocataireListScreen extends StatefulWidget {
  final String? initialUserId;
  final String? initialDocumentId;

  const LocataireListScreen({
    super.key,
    this.initialUserId,
    this.initialDocumentId,
  });

  @override
  State<LocataireListScreen> createState() => _LocataireListScreenState();
}


// DÉFINITIONS DES DOCUMENTS REQUIS
class _AdminDocumentDef {
  final String key;
  final String label;
  final String sub;
  final IconData icon;
  final String typeDocument;
  final String categorie;
  final bool identity;
  final bool identitySideRequired;

  const _AdminDocumentDef({
    required this.key,
    required this.label,
    required this.sub,
    required this.icon,
    required this.typeDocument,
    required this.categorie,
    this.identity = false,
    this.identitySideRequired = false,
  });
}

class _LocataireListScreenState extends State<LocataireListScreen> {

  // DONNÉES
  List<Map<String, dynamic>> locataires = [];
  List<Map<String, dynamic>> filteredLocataires = [];

  String selectedFilter = 'Tous';
  bool isFetching = true;
  String searchQuery = '';
  String? errorMessage;

  bool _initialNotificationHandled = false;

  final List<String> filterOptions = [
    'Tous',
    'Actifs',
    'Inactifs',
    'Suspendus',
  ];

  final DatabaseService _dbService = ServiceLocator.database;

  // DOCUMENTS REQUIS (UNIQUEMENT IDENTITÉ POUR LOCATAIRE)
  static const List<_AdminDocumentDef> _requiredDocuments = [
    _AdminDocumentDef(
      key: 'identite',
      label: "Pièce d'identité",
      sub: "CNI, permis ou passeport en cours de validité",
      icon: Icons.badge_outlined,
      typeDocument: "Carte d'identité",
      categorie: "identite",
      identity: true,
      identitySideRequired: true,
    ),
  ];


  // CHAMPS DE PROFIL OBLIGATOIRES
  static const List<String> _requiredProfileFields = [
    'nom',
    'prenom',
    'email',
    'telephone',
    'date_naissance',
    'ville',
    'pays',
    'adresse',
  ];

  List<String> _getMissingProfileFields(Map<String, dynamic> locataire) {
    final labels = {
      'nom': 'Nom',
      'prenom': 'Prénom',
      'email': 'Email',
      'telephone': 'Téléphone',
      'date_naissance': 'Date de naissance',
      'ville': 'Ville',
      'pays': 'Pays',
      'adresse': 'Adresse',
    };

    final missing = <String>[];

    for (final key in _requiredProfileFields) {
      final value = locataire[key]?.toString().trim() ?? '';
      if (value.isEmpty) {
        missing.add(labels[key] ?? key);
      }
    }

    return missing;
  }


  // INIT
  @override
  void initState() {
    super.initState();
    _fetchLocataires();
  }


  // CHARGEMENT LOCATAIRES
  Future<void> _fetchLocataires() async {
    if (mounted) {
      setState(() {
        isFetching = true;
        errorMessage = null;
      });
    }

    try {
      final response = await _dbService.supabase
          .from('users')
          .select('''
            id,
            prenom,
            nom,
            telephone,
            adresse,
            email,
            urgencephone,
            created_at,
            role,
            date_naissance,
            statut,
            pays,
            ville,
            updated_at,
            est_certifie,
            date_certification,
            certifie_par,
            identite_verifiee,
            date_verification_identite,
            verifie_par,
            photo_profil
          ''')
          .eq('role', 'locataire')
          .order('created_at', ascending: false);

      debugPrint('${response.length} locataires chargés');

      if (!mounted) return;

      setState(() {
        locataires = response.cast<Map<String, dynamic>>();
        _rebuildFilteredList();
        isFetching = false;
      });

      if (!_initialNotificationHandled &&
          widget.initialUserId != null &&
          widget.initialUserId!.isNotEmpty) {
        _initialNotificationHandled = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final index = locataires.indexWhere(
                (locataire) =>
            locataire['id']?.toString() == widget.initialUserId,
          );

          if (index == -1) {
            _safeShowSnackBar(
              'Le locataire concerné par cette notification est introuvable.',
              Colors.orange,
              Icons.warning_amber_rounded,
            );
            return;
          }

          final locataire = locataires[index];

          _showLocataireDetails(
            locataire,
            highlightedDocumentId: widget.initialDocumentId,
          );
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement locataires : $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Erreur lors du chargement des locataires : $e';
        locataires = [];
        filteredLocataires = [];
        isFetching = false;
      });

      _safeShowSnackBar(
        'Erreur lors du chargement',
        Colors.red,
        Icons.error_outline,
      );
    }
  }


  // CERTIFIER UN LOCATAIRE (NOUVEAU)
  Future<bool> _certifierLocataire(String userId) async {
    try {
      await _dbService.supabase.rpc(
        'certifier_utilisateur',
        params: {'p_user_id': userId},
      );

      _safeShowSnackBar(
        'Compte certifié avec succès',
        Colors.green,
        Icons.verified_rounded,
      );

      await _fetchLocataires();

      return true;
    } catch (e) {
      debugPrint('Erreur certification locataire : $e');
      _safeShowSnackBar(
        'Erreur lors de la certification : $e',
        Colors.red,
        Icons.error_outline,
      );
      return false;
    }
  }


  // FILTRES
  void _applyFilter(String filter) {
    if (!mounted) return;

    setState(() {
      selectedFilter = filter;
      _rebuildFilteredList();
    });
  }

  void _rebuildFilteredList() {
    var filtered = List<Map<String, dynamic>>.from(locataires);

    if (selectedFilter == 'Actifs') {
      filtered = filtered.where((l) => l['statut'] == 'actif').toList();
    } else if (selectedFilter == 'Inactifs') {
      filtered = filtered.where((l) => l['statut'] == 'inactif').toList();
    } else if (selectedFilter == 'Suspendus') {
      filtered = filtered.where((l) => l['statut'] == 'suspendu').toList();
    }

    final query = searchQuery.trim().toLowerCase();

    if (query.isNotEmpty) {
      filtered = filtered.where((l) {
        final nom = l['nom']?.toString().toLowerCase() ?? '';
        final prenom = l['prenom']?.toString().toLowerCase() ?? '';
        final email = l['email']?.toString().toLowerCase() ?? '';
        final telephone = l['telephone']?.toString().toLowerCase() ?? '';
        final ville = l['ville']?.toString().toLowerCase() ?? '';
        final pays = l['pays']?.toString().toLowerCase() ?? '';

        return nom.contains(query) ||
            prenom.contains(query) ||
            email.contains(query) ||
            telephone.contains(query) ||
            ville.contains(query) ||
            pays.contains(query);
      }).toList();
    }

    filteredLocataires = filtered;
  }

  Map<String, int> _getStats() {
    return {
      'Tous': locataires.length,
      'Actifs': locataires.where((l) => l['statut'] == 'actif').length,
      'Inactifs': locataires.where((l) => l['statut'] == 'inactif').length,
      'Suspendus': locataires.where((l) => l['statut'] == 'suspendu').length,
    };
  }


  // SNACKBAR
  void _safeShowSnackBar(String message, Color color, IconData icon) {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: color.withValues(alpha: 0.92),
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


  // DATES
  String _formatDate(dynamic date) {
    if (date == null) return 'Non disponible';

    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy').format(date);
      }

      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return date.toString();
    }
  }

  String _formatDateNaissance(dynamic date) {
    if (date == null) return 'Non renseignée';

    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy').format(date);
      }

      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (_) {
      return date.toString();
    }
  }


  // NOM LOCATAIRE
  String _fullName(Map<String, dynamic> locataire) {
    final prenom = locataire['prenom']?.toString().trim() ?? '';
    final nom = locataire['nom']?.toString().trim() ?? '';
    final result = '$prenom $nom'.trim();
    return result.isEmpty ? 'Locataire' : result;
  }

  String _initials(Map<String, dynamic> locataire) {
    final prenom = locataire['prenom']?.toString().trim() ?? '';
    final nom = locataire['nom']?.toString().trim() ?? '';
    final first = prenom.isNotEmpty ? prenom.substring(0, 1).toUpperCase() : '';
    final second = nom.isNotEmpty ? nom.substring(0, 1).toUpperCase() : '';
    final result = '$first$second';
    return result.isEmpty ? '?' : result;
  }


  // STATUT LOCATAIRE
  Color _getLocataireStatusColor(String? statut) {
    switch (statut) {
      case 'actif':
        return Colors.green;
      case 'inactif':
        return Colors.red;
      case 'suspendu':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }


  // FETCH DOCUMENTS
  Future<List<Map<String, dynamic>>> _fetchIdentityDocuments(
      String userId,
      ) async {
    try {
      final response = await _dbService.supabase
          .from('documents')
          .select('''
            id,
            user_id,
            residence_id,
            appartement_id,
            categorie,
            type_document,
            nom_fichier,
            chemin_fichier,
            mime_type,
            taille_fichier,
            numero_document,
            date_emission,
            date_expiration,
            pays_emission,
            statut,
            motif_refus,
            verifie_par,
            date_verification,
            obligatoire,
            cote_document,
            created_at,
            updated_at
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Erreur documents locataire $userId : $e');
      return [];
    }
  }

  // TYPE DOCUMENT
  String _documentTypeLabel(String? type) {
    switch (type) {
      case 'carte_identite':
        return 'Carte d’identité';
      case 'passeport':
        return 'Passeport';
      case 'permis_conduire':
        return 'Permis de conduire';
      default:
        return type ?? 'Document d’identité';
    }
  }


  // COTE
  String _sideLabel(String? cote) {
    switch (cote) {
      case 'recto':
        return 'RECTO';
      case 'verso':
        return 'VERSO';
      default:
        return 'DOCUMENT';
    }
  }

  // STATUT DOCUMENT
  String _documentStatusLabel(String? statut) {
    switch (statut) {
      case 'en_attente':
        return 'En attente';
      case 'en_verification':
        return 'En vérification';
      case 'valide':
      case 'validee':
      case 'verifie':
        return 'Validé';
      case 'refuse':
      case 'refusee':
        return 'Refusé';
      case 'expire':
        return 'Expiré';
      default:
        return statut ?? 'Inconnu';
    }
  }

  Color _documentStatusColor(String? statut) {
    switch (statut) {
      case 'valide':
      case 'validee':
      case 'verifie':
        return Colors.green;
      case 'refuse':
      case 'refusee':
        return Colors.red;
      case 'expire':
        return Colors.orange;
      case 'en_verification':
        return Colors.blue;
      case 'en_attente':
        return const Color(0xFFFFC107);
      default:
        return Colors.grey;
    }
  }

  // APERÇU DOCUMENT
  Future<void> _showDocumentPreview(Map<String, dynamic> document) async {
    final chemin = document['chemin_fichier']?.toString();

    if (chemin == null || chemin.trim().isEmpty) {
      _safeShowSnackBar('Fichier introuvable', Colors.red, Icons.error_outline);
      return;
    }

    final mimeType = document['mime_type']?.toString().toLowerCase() ?? '';

    if (!mimeType.startsWith('image/')) {
      _showNonImageDocumentDialog(document);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFFC107)),
      ),
    );

    Uint8List? bytes;

    try {
      bytes = await _dbService.supabase.storage
          .from('documents')
          .download(chemin);
      debugPrint('Download OK : ${bytes.length} octets');
    } catch (e) {
      debugPrint('download() échoué : $e');
    }

    if (mounted) Navigator.of(context, rootNavigator: true).pop();

    if (!mounted) return;

    if (bytes == null || bytes.isEmpty) {
      _safeShowSnackBar(
        'Aucun contenu disponible.',
        Colors.red,
        Icons.error_outline,
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.82),
      builder: (_) {
        return Dialog(
          backgroundColor: const Color(0xFF111622),
          insetPadding: EdgeInsets.all(20.w),
          child: Container(
            constraints: BoxConstraints(maxWidth: 900.w, maxHeight: 0.9.sh),
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_documentTypeLabel(document['type_document'])} • '
                            '${_sideLabel(document['cote_document'])}',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: Image.memory(bytes!, fit: BoxFit.contain),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNonImageDocumentDialog(Map<String, dynamic> document) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111622),
          title: Text(
            _documentTypeLabel(document['type_document']),
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDialogInfo('Côté', _sideLabel(document['cote_document'])),
              _buildDialogInfo(
                'Fichier',
                document['nom_fichier']?.toString() ?? 'Non disponible',
              ),
              _buildDialogInfo(
                'Type',
                document['mime_type']?.toString() ?? 'Non disponible',
              ),
              _buildDialogInfo(
                'Taille',
                _formatFileSize(document['taille_fichier']),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Fermer',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFFFC107),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String _formatFileSize(dynamic size) {
    final value = int.tryParse(size?.toString() ?? '');
    if (value == null) return 'Inconnue';
    if (value < 1024) return '$value octets';
    if (value < 1024 * 1024) {
      return '${(value / 1024).toStringAsFixed(1)} Ko';
    }
    return '${(value / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  Widget _buildDialogInfo(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90.w,
            child: Text(
              '$label :',
              style: GoogleFonts.manrope(
                color: Colors.white38,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }


  // VALIDER DOCUMENT
  Future<Map<String, dynamic>?> _validateDocument(
      Map<String, dynamic> document,
      ) async {
    final documentId = document['id']?.toString();
    if (documentId == null || documentId.isEmpty) return null;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text(
          'Valider le document ?',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '${_documentTypeLabel(document['type_document'])} • '
              '${_sideLabel(document['cote_document'])}',
          style: GoogleFonts.manrope(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Annuler',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Valider'),
          ),
        ],
      ),
    );

    if (confirmed != true) return null;

    try {
      await _dbService.supabase.rpc(
        'valider_document',
        params: {'p_document_id': documentId},
      );

      if (!mounted) return null;

      _safeShowSnackBar(
        'Document validé avec succès',
        Colors.green,
        Icons.check_circle,
      );

      return {
        ...document,
        'statut': 'valide',
        'date_verification': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Validation document : $e');
      if (!mounted) return null;
      _safeShowSnackBar(
        'Erreur lors de la validation : $e',
        Colors.red,
        Icons.error_outline,
      );
      return null;
    }
  }


  // REFUSER DOCUMENT
  Future<Map<String, dynamic>?> _refuseDocument(
      Map<String, dynamic> document,
      ) async {
    final motifController = TextEditingController();

    final motif = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        title: Text(
          'Refuser le document',
          style: GoogleFonts.manrope(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_documentTypeLabel(document['type_document'])} • '
                  '${_sideLabel(document['cote_document'])}',
              style: GoogleFonts.manrope(color: Colors.white70),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: motifController,
              minLines: 3,
              maxLines: 6,
              style: GoogleFonts.manrope(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Motif du refus *',
                labelStyle: GoogleFonts.manrope(color: Colors.white54),
                hintText: 'Ex. document flou, pièce expirée...',
                hintStyle: GoogleFonts.manrope(color: Colors.white30),
                filled: true,
                fillColor: const Color(0xFF0A0F1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final value = motifController.text.trim();
              if (value.isEmpty) return;
              Navigator.pop(context, value);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    motifController.dispose();

    if (motif == null || motif.trim().isEmpty) return null;

    final documentId = document['id']?.toString();
    if (documentId == null || documentId.isEmpty) return null;

    try {
      await _dbService.supabase.rpc(
        'refuser_document',
        params: {
          'p_document_id': documentId,
          'p_motif': motif.trim(),
        },
      );

      if (!mounted) return null;

      _safeShowSnackBar(
        'Document refusé',
        Colors.orange,
        Icons.cancel,
      );

      return {
        ...document,
        'statut': 'refuse',
        'motif_refus': motif.trim(),
        'date_verification': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      debugPrint('Refus document : $e');
      if (!mounted) return null;
      _safeShowSnackBar(
        'Erreur lors du refus : $e',
        Colors.red,
        Icons.error_outline,
      );
      return null;
    }
  }

  // SECTION DOCUMENTS (PROFIL IDENTITÉ)
  Widget _buildIdentityDocumentsSection(
      Map<String, dynamic> locataire,
      List<Map<String, dynamic>> documents,
      void Function(String documentId) onProcessingStart,
      void Function(String documentId, Map<String, dynamic>? updated)
      onProcessingEnd,
      ) {
    // Documents personnels (sans residence_id)
    final personalDocs = documents.where((doc) {
      final residenceId = doc['residence_id']?.toString();
      return residenceId == null || residenceId.isEmpty;
    }).toList();

    //VÉRIFIER LE PROFIL
    final missingFields = _getMissingProfileFields(locataire);
    final profileComplete = missingFields.isEmpty;

    //VÉRIFIER LA PIÈCE D'IDENTITÉ
    final def = _requiredDocuments.first;

    final allMatchingDocs = personalDocs.where((doc) {
      final type = doc['type_document']?.toString().toLowerCase() ?? '';
      final cat = doc['categorie']?.toString().toLowerCase() ?? '';

      return cat == 'identite' &&
          (type.contains('carte') ||
              type.contains('cni') ||
              type.contains('passeport') ||
              type.contains('permis') ||
              type.contains('identite'));
    }).toList();

    allMatchingDocs.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    // Garder le dernier document par côté
    final Map<String, Map<String, dynamic>> latestBySide = {};

    for (final doc in allMatchingDocs) {
      final cote = doc['cote_document']?.toString() ?? 'unique';
      if (!latestBySide.containsKey(cote)) {
        latestBySide[cote] = doc;
      }
    }

    final matchingDocs = latestBySide.values.toList();

    matchingDocs.sort((a, b) {
      final dateA = a['created_at']?.toString() ?? '';
      final dateB = b['created_at']?.toString() ?? '';
      return dateB.compareTo(dateA);
    });

    final identityValidated = matchingDocs.isNotEmpty &&
        matchingDocs.every((d) {
          final s = d['statut']?.toString() ?? '';
          return s == 'valide' || s == 'validee' || s == 'verifie';
        });

    //DÉCISION FINALE : PROFIL + IDENTITÉ
    const totalSteps = 2;
    int completedSteps = 0;
    if (profileComplete) completedSteps++;
    if (identityValidated) completedSteps++;

    final allComplete = completedSteps == totalSteps;

    // Récupérer les infos du locataire pour le bouton
    final locataireId = locataire['id']?.toString();
    final estCertifie = locataire['est_certifie'] == true;

    //CONSTRUIRE LES CARTES
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // BANDEAU DE PROGRESSION
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: allComplete
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : const Color(0xFFFFC107).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: allComplete
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : const Color(0xFFFFC107).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                allComplete
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
                color: allComplete
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFC107),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      allComplete
                          ? 'Certification prête'
                          : 'Certification en cours',
                      style: GoogleFonts.manrope(
                        color: allComplete
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFFC107),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$completedSteps / $totalSteps condition(s) remplie(s)',
                      style: GoogleFonts.manrope(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              //BOUTON DE CERTIFICATION
              if (allComplete && !estCertifie && locataireId != null)
                Padding(
                  padding: EdgeInsets.only(left: 8.w),
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF111622),
                          title: Text(
                            'Certifier ce compte ?',
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          content: Text(
                            'Le profil est complet et l\'identité est validée. '
                                'Voulez-vous certifier le compte de ce locataire ?',
                            style: GoogleFonts.manrope(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Annuler',
                                style: GoogleFonts.manrope(
                                  color: Colors.white54,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Certifier'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        final success = await _certifierLocataire(locataireId);
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    icon: const Icon(Icons.verified_rounded, size: 18),
                    label: const Text('Certifier'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),


        // CARTE PROFIL COMPLET
        _buildProfileCompletionCard(
          locataire: locataire,
          profileComplete: profileComplete,
          missingFields: missingFields,
        ),

        SizedBox(height: 14.h),

        // CARTE PIÈCE D'IDENTITÉ
        _buildIdentityCard(
          def: def,
          documents: matchingDocs,
          onProcessingStart: onProcessingStart,
          onProcessingEnd: onProcessingEnd,
        ),
      ],
    );
  }

  // CARTE PROFIL COMPLET
  Widget _buildProfileCompletionCard({
    required Map<String, dynamic> locataire,
    required bool profileComplete,
    required List<String> missingFields,
  }) {
    final borderColor = profileComplete
        ? const Color(0xFF10B981).withValues(alpha: 0.4)
        : const Color(0xFFFFC107).withValues(alpha: 0.4);

    final bgColor = profileComplete
        ? const Color(0xFF10B981).withValues(alpha: 0.05)
        : const Color(0xFFFFC107).withValues(alpha: 0.05);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline,
                color: profileComplete
                    ? const Color(0xFF10B981)
                    : const Color(0xFFFFC107),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  'Profil complet',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (profileComplete)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFF10B981).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: const Color(0xFF10B981),
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'COMPLET',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFF10B981),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: const Color(0xFFFFC107).withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: const Color(0xFFFFC107),
                        size: 13.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'INCOMPLET',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFC107),
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          if (profileComplete)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: const Color(0xFF10B981),
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Tous les champs obligatoires sont remplis.',
                      style: GoogleFonts.manrope(
                        color: Colors.white70,
                        fontSize: 12.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: const Color(0xFFFFC107).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: const Color(0xFFFFC107),
                        size: 20.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '${missingFields.length} champ(s) manquant(s)',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFFFC107),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: missingFields.map((field) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFFFC107)
                                .withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          field,
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFFFC107),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
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
    );
  }

  // ============================================================
  // CARTE PIÈCE D'IDENTITÉ
  // ============================================================

  Widget _buildIdentityCard({
    required _AdminDocumentDef def,
    required List<Map<String, dynamic>> documents,
    required void Function(String documentId) onProcessingStart,
    required void Function(String documentId, Map<String, dynamic>? updated)
    onProcessingEnd,
  }) {
    final recto = documents.firstWhere(
          (d) => d['cote_document'] == 'recto',
      orElse: () => <String, dynamic>{},
    );

    final verso = documents.firstWhere(
          (d) => d['cote_document'] == 'verso',
      orElse: () => <String, dynamic>{},
    );

    final passport = documents.firstWhere(
          (d) =>
      d['cote_document'] == null &&
          (d['type_document']?.toString().toLowerCase().contains('passeport') ??
              false),
      orElse: () => <String, dynamic>{},
    );

    final hasRecto = recto.isNotEmpty;
    final hasVerso = verso.isNotEmpty;
    final hasPassport = passport.isNotEmpty;
    final isMissing = !hasRecto && !hasVerso && !hasPassport;

    final borderColor = isMissing
        ? const Color(0xFFEF4444).withValues(alpha: 0.5)
        : Colors.white.withValues(alpha: 0.06);

    final bgColor = isMissing
        ? const Color(0xFFEF4444).withValues(alpha: 0.05)
        : const Color(0xFF111622);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: isMissing ? 1.5 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                def.icon,
                color: isMissing
                    ? const Color(0xFFEF4444)
                    : const Color(0xFFFFC107),
                size: 22.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  def.label,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isMissing)
                _buildMissingBadge()
              else
                _buildStatusBadge(documents),
            ],
          ),
          SizedBox(height: 12.h),
          if (isMissing)
            _buildMissingMessage(
              'Aucune pièce d\'identité soumise',
              'Le locataire doit envoyer sa carte d\'identité (recto + verso), '
                  'son permis ou son passeport.',
            )
          else if (hasPassport)
            _buildDocumentCardWrapper(
              passport,
              onProcessingStart,
              onProcessingEnd,
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasRecto)
                  Expanded(
                    child: _buildDocumentCardWrapper(
                      recto,
                      onProcessingStart,
                      onProcessingEnd,
                    ),
                  )
                else
                  Expanded(child: _buildMissingSmallCard('RECTO')),
                SizedBox(width: 12.w),
                if (hasVerso)
                  Expanded(
                    child: _buildDocumentCardWrapper(
                      verso,
                      onProcessingStart,
                      onProcessingEnd,
                    ),
                  )
                else
                  Expanded(child: _buildMissingSmallCard('VERSO')),
              ],
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BADGES
  // ============================================================

  Widget _buildMissingBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444),
            size: 13.sp,
          ),
          SizedBox(width: 4.w),
          Text(
            'MANQUANT',
            style: GoogleFonts.manrope(
              color: const Color(0xFFEF4444),
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(List<Map<String, dynamic>> docs) {
    if (docs.isEmpty) return const SizedBox.shrink();

    final statuses =
    docs.map((d) => d['statut']?.toString() ?? '').toSet();

    Color color;
    String label;
    IconData icon;

    if (statuses.contains('refuse')) {
      color = const Color(0xFFEF4444);
      label = 'REFUSÉ';
      icon = Icons.cancel_outlined;
    } else if (statuses.every((s) =>
    s == 'valide' || s == 'validee' || s == 'verifie')) {
      color = const Color(0xFF10B981);
      label = 'VALIDÉ';
      icon = Icons.check_circle_outline;
    } else if (statuses.contains('expire')) {
      color = const Color(0xFFF59E0B);
      label = 'EXPIRÉ';
      icon = Icons.warning_amber_rounded;
    } else {
      color = const Color(0xFFFFC107);
      label = 'EN ATTENTE';
      icon = Icons.access_time;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: color,
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingMessage(String title, String description) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: const Color(0xFFEF4444),
            size: 20.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFEF4444),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: GoogleFonts.manrope(
                    color: Colors.white70,
                    fontSize: 11.5.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingSmallCard(String side) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: const Color(0xFFEF4444).withValues(alpha: 0.7),
            size: 28.sp,
          ),
          SizedBox(height: 6.h),
          Text(
            '$side MANQUANT',
            style: GoogleFonts.manrope(
              color: const Color(0xFFEF4444),
              fontSize: 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }


  // WRAPPER CARTE DOCUMENT
  Widget _buildDocumentCardWrapper(
      Map<String, dynamic> document,
      void Function(String documentId) onProcessingStart,
      void Function(String documentId, Map<String, dynamic>? updated)
      onProcessingEnd,
      ) {
    return _DocumentCardWrapper(
      key: ValueKey(document['id']),
      document: document,
      onValidate: _validateDocument,
      onRefuse: _refuseDocument,
      onProcessingStart: onProcessingStart,
      onProcessingEnd: onProcessingEnd,
      onPreview: _showDocumentPreview,
      sideLabel: _sideLabel,
      statusLabel: _documentStatusLabel,
      statusColor: _documentStatusColor,
      typeLabel: _documentTypeLabel,
      formatDate: _formatDate,
      formatFileSize: _formatFileSize,
    );
  }


  // INFO ROW
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: Colors.white38),
          SizedBox(width: 14.w),
          SizedBox(
            width: 125.w,
            child: Text(
              '$label:',
              style: GoogleFonts.manrope(
                color: Colors.white54,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 14.sp,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }


  // STATUT LOCATAIRE
  Future<void> _updateLocataireStatus(
      String userId,
      String newStatus,
      ) async {
    try {
      await _dbService.supabase
          .from('users')
          .update({'statut': newStatus})
          .eq('id', userId);

      _safeShowSnackBar(
        'Statut mis à jour avec succès',
        Colors.green,
        Icons.check_circle,
      );

      await _fetchLocataires();
    } catch (e) {
      debugPrint('Erreur statut locataire : $e');

      _safeShowSnackBar(
        'Erreur : $e',
        Colors.red,
        Icons.error,
      );
    }
  }


  // MODAL DÉTAILS
  void _showLocataireDetails(
      Map<String, dynamic> locataire, {
        String? highlightedDocumentId,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _LocataireDetailsDialog(
          locataire: locataire,
          fetchDocuments: _fetchIdentityDocuments,
          buildDocumentSection: (locataire, documents, onStart, onEnd) {
            return _buildIdentityDocumentsSection(
              locataire,
              documents,
              onStart,
              onEnd,
            );
          },
          buildInfoRow: _buildInfoRow,
          formatDate: _formatDate,
          formatDateNaissance: _formatDateNaissance,
          fullName: _fullName,
          initials: _initials,
          getStatusColor: _getLocataireStatusColor,
          onUpdateStatus: _updateLocataireStatus,
          onRefresh: _fetchLocataires,
          highlightedDocumentId: highlightedDocumentId,
        );
      },
    );
  }

  // RECHERCHE
  void _showSearchDialog() {
    final controller = TextEditingController(text: searchQuery);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Rechercher un locataire',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nom, prénom, email, téléphone, ville...',
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              _rebuildFilteredList();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
                _rebuildFilteredList();
              });
              Navigator.pop(context);
            },
            child: Text(
              'Réinitialiser',
              style: GoogleFonts.manrope(color: const Color(0xFFFFC107)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  // FILTER CHIPS
  Widget _buildFilterChipsLayout() {
    final stats = _getStats();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((filter) {
          final count = stats[filter] ?? 0;
          final isSelected = selectedFilter == filter;

          Color activeColor;
          if (filter == 'Tous') {
            activeColor = const Color(0xFFFFC107);
          } else if (filter == 'Actifs') {
            activeColor = const Color(0xFF10B981);
          } else if (filter == 'Inactifs') {
            activeColor = const Color(0xFFEF4444);
          } else {
            activeColor = const Color(0xFFF59E0B);
          }

          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: ChoiceChip(
              label: Text(
                '$filter ($count)',
                style: GoogleFonts.manrope(
                  color: isSelected
                      ? const Color(0xFF090D16)
                      : Colors.white70,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  // TABLEAU PRINCIPAL
  Widget _buildMainContentTable() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${filteredLocataires.length} locataires trouvés',
                style: GoogleFonts.manrope(
                  color: Colors.white60,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (searchQuery.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC107).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Recherche: "$searchQuery"',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFC107),
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            searchQuery = '';
                            _rebuildFilteredList();
                          });
                        },
                        child: Icon(
                          Icons.close,
                          size: 16.sp,
                          color: const Color(0xFFFFC107),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 20.h),
          if (isFetching)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                ),
              ),
            )
          else if (filteredLocataires.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.people_outline,
                      size: 64.w,
                      color: Colors.white24,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Aucun locataire disponible',
                      style: GoogleFonts.manrope(
                        color: Colors.white38,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredLocataires.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final locataire = filteredLocataires[index];
                final statut = locataire['statut'] ?? 'actif';
                final isActive = statut == 'actif';
                final statusColor =
                _getLocataireStatusColor(statut.toString());
                final certified = locataire['est_certifie'] == true;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _LocataireAvatar(
                              userId: locataire['id'].toString(),
                              initials: _initials(locataire),
                              isActive: isActive,
                              radius: 28.r,
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Flexible(
                                              child: Text(
                                                _fullName(locataire),
                                                style: GoogleFonts.manrope(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (certified) ...[
                                              SizedBox(width: 6.w),
                                              const Icon(
                                                Icons.verified_rounded,
                                                color: Color(0xFFFFC107),
                                                size: 18,
                                              ),
                                            ] else ...[
                                              SizedBox(width: 6.w),
                                              const Icon(
                                                Icons.cancel_rounded,
                                                color: Color(0xFFEF4444),
                                                size: 18,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 3.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                          statusColor.withValues(alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                        child: Text(
                                          statut.toString().toUpperCase(),
                                          style: GoogleFonts.manrope(
                                            color: statusColor,
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  if (locataire['email'] != null)
                                    Text(
                                      locataire['email'].toString(),
                                      style: GoogleFonts.manrope(
                                        color: Colors.white54,
                                        fontSize: 14.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Row(
                                    children: [
                                      if (locataire['telephone'] != null)
                                        Text(
                                          locataire['telephone'].toString(),
                                          style: GoogleFonts.manrope(
                                            color: Colors.white38,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      if (locataire['telephone'] != null &&
                                          locataire['ville'] != null)
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.w),
                                          child: Container(
                                            width: 3,
                                            height: 3,
                                            decoration: const BoxDecoration(
                                              color: Colors.white38,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                      if (locataire['ville'] != null)
                                        Expanded(
                                          child: Text(
                                            locataire['ville'].toString(),
                                            style: GoogleFonts.manrope(
                                              color: Colors.white38,
                                              fontSize: 14.sp,
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
                      ),
                      SizedBox(width: 16.w),
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: TextButton.icon(
                              onPressed: () =>
                                  _showLocataireDetails(locataire),
                              icon: const Icon(
                                Icons.visibility,
                                color: Color(0xFFFFC107),
                                size: 17,
                              ),
                              label: Text(
                                'Voir',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFFFC107),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          PopupMenuButton<String>(
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.white60,
                            ),
                            color: const Color(0xFF111622),
                            onSelected: (value) {
                              if (value == 'detail') {
                                _showLocataireDetails(locataire);
                              }
                              if (value == 'toggle_status') {
                                _updateLocataireStatus(
                                  locataire['id'].toString(),
                                  isActive ? 'inactif' : 'actif',
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Détails',
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'toggle_status',
                                child: Row(
                                  children: [
                                    Icon(
                                      isActive
                                          ? Icons.block
                                          : Icons.check_circle,
                                      color: isActive
                                          ? Colors.orange
                                          : Colors.green,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      isActive ? 'Désactiver' : 'Activer',
                                      style: GoogleFonts.manrope(
                                        color: isActive
                                            ? Colors.orange
                                            : Colors.green,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      title: 'Locataires',
      actions: [
        IconButton(
          icon: const Icon(
            Icons.refresh,
            color: Color(0xFFFFC107),
            size: 20,
          ),
          onPressed: isFetching ? null : () => _fetchLocataires(),
        ),
        IconButton(
          icon: const Icon(
            Icons.search,
            color: Colors.white54,
            size: 20,
          ),
          onPressed: _showSearchDialog,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFilterChipsLayout(),
          SizedBox(height: 24.h),
          if (errorMessage != null)
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: GoogleFonts.manrope(
                        color: Colors.white70,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            _buildMainContentTable(),
        ],
      ),
    );
  }
}

// ============================================================
// DIALOG DÉTAIL LOCATAIRE
// ============================================================

class _LocataireDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> locataire;
  final String? highlightedDocumentId;

  final Future<List<Map<String, dynamic>>> Function(String userId)
  fetchDocuments;

  final Widget Function(
      Map<String, dynamic> locataire,
      List<Map<String, dynamic>> documents,
      void Function(String documentId) onProcessingStart,
      void Function(String documentId, Map<String, dynamic>? updated)
      onProcessingEnd,
      ) buildDocumentSection;

  final Widget Function(IconData icon, String label, String value)
  buildInfoRow;

  final String Function(dynamic date) formatDate;
  final String Function(dynamic date) formatDateNaissance;

  final String Function(Map<String, dynamic> locataire) fullName;
  final String Function(Map<String, dynamic> locataire) initials;

  final Color Function(String? statut) getStatusColor;

  final Future<void> Function(String userId, String newStatus) onUpdateStatus;

  final Future<void> Function() onRefresh;

  const _LocataireDetailsDialog({
    required this.locataire,
    required this.fetchDocuments,
    required this.buildDocumentSection,
    required this.buildInfoRow,
    required this.formatDate,
    required this.formatDateNaissance,
    required this.fullName,
    required this.initials,
    required this.getStatusColor,
    required this.onUpdateStatus,
    required this.onRefresh,
    this.highlightedDocumentId,
  });

  @override
  State<_LocataireDetailsDialog> createState() =>
      _LocataireDetailsDialogState();
}

class _LocataireDetailsDialogState extends State<_LocataireDetailsDialog> {
  List<Map<String, dynamic>> documents = [];

  bool documentsLoading = true;
  bool statusUpdating = false;

  Map<String, dynamic>? highlightedDocument;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      documentsLoading = true;
      highlightedDocument = null;
    });

    try {
      final userId = widget.locataire['id'].toString();
      final result = await widget.fetchDocuments(userId);

      if (!mounted) return;

      Map<String, dynamic>? matchedDocument;
      final highlightedId = widget.highlightedDocumentId?.trim();

      if (highlightedId != null && highlightedId.isNotEmpty) {
        for (final document in result) {
          if (document['id']?.toString() == highlightedId) {
            matchedDocument = document;
            break;
          }
        }
      }

      setState(() {
        documents = result;
        highlightedDocument = matchedDocument;
        documentsLoading = false;
      });
    } catch (e) {
      debugPrint('Chargement documents locataire : $e');

      if (!mounted) return;

      setState(() {
        documents = [];
        highlightedDocument = null;
        documentsLoading = false;
      });
    }
  }

  void _handleProcessingEnd(
      String documentId,
      Map<String, dynamic>? updated,
      ) {
    if (!mounted || updated == null) return;

    setState(() {
      final idx =
      documents.indexWhere((d) => d['id']?.toString() == documentId);

      if (idx != -1) {
        documents[idx] = updated;
      }

      if (highlightedDocument != null &&
          highlightedDocument!['id']?.toString() == documentId) {
        highlightedDocument = updated;
      }
    });
  }

  Widget _buildHighlightedDocumentNotice() {
    final document = highlightedDocument;
    if (document == null) return const SizedBox.shrink();

    final type = document['type_document']?.toString();
    final cote = document['cote_document']?.toString();
    final fileName = document['nom_fichier']?.toString() ?? 'Document';
    final side = cote == null || cote.isEmpty ? 'DOCUMENT' : cote.toUpperCase();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC107).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFFFC107).withValues(alpha: 0.45),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC107).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Color(0xFFFFC107),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Document concerné par la notification',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFC107),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${type ?? 'Document d’identité'} • $side',
                  style: GoogleFonts.manrope(
                    color: Colors.white54,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statut = widget.locataire['statut']?.toString() ?? 'actif';
    final statusColor = widget.getStatusColor(statut);

    final fullName = widget.fullName(widget.locataire);
    final initials = widget.initials(widget.locataire);
    final certified = widget.locataire['est_certifie'] == true;

    return Dialog(
      backgroundColor: const Color(0xFF111622),
      insetPadding: EdgeInsets.all(24.w),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 1000.w,
          maxHeight: 0.9.sh,
        ),
        child: Column(
          children: [

            // HEADER
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  _LocataireAvatar(
                    userId: widget.locataire['id'].toString(),
                    initials: initials,
                    isActive: true,
                    radius: 28.r,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                fullName,
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (certified) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFFFFC107)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: const Color(0xFFFFC107),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'CERTIFIÉ',
                                      style: GoogleFonts.manrope(
                                        color: const Color(0xFFFFC107),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFFEF4444)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cancel_rounded,
                                      color: const Color(0xFFEF4444),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'NON CERTIFIÉ',
                                      style: GoogleFonts.manrope(
                                        color: const Color(0xFFEF4444),
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 5.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            statut.toUpperCase(),
                            style: GoogleFonts.manrope(
                              color: statusColor,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // INFORMATIONS PERSONNELLES
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Identité',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              widget.buildInfoRow(
                                Icons.person_outline,
                                'Nom complet',
                                fullName,
                              ),
                              widget.buildInfoRow(
                                Icons.email_outlined,
                                'Email',
                                widget.locataire['email']?.toString() ??
                                    'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.phone_outlined,
                                'Téléphone',
                                widget.locataire['telephone']?.toString() ??
                                    'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.cake_outlined,
                                'Date de naissance',
                                widget.formatDateNaissance(
                                    widget.locataire['date_naissance']),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          width: 1,
                          margin: EdgeInsets.symmetric(horizontal: 24.w),
                          color: Colors.white.withValues(alpha: 0.08),
                          constraints: BoxConstraints(minHeight: 250.h),
                        ),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Localisation & Contact',
                                style: GoogleFonts.manrope(
                                  color: Colors.white,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 12.h),
                              widget.buildInfoRow(
                                Icons.location_on_outlined,
                                'Ville',
                                widget.locataire['ville']?.toString() ??
                                    'Non renseignée',
                              ),
                              widget.buildInfoRow(
                                Icons.public,
                                'Pays',
                                widget.locataire['pays']?.toString() ??
                                    'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.home_outlined,
                                'Adresse',
                                widget.locataire['adresse']?.toString() ??
                                    'Non renseignée',
                              ),
                              widget.buildInfoRow(
                                Icons.phone_android,
                                'Urgence',
                                widget.locataire['urgencephone']
                                    ?.toString() ??
                                    'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.calendar_today,
                                'Inscrit le',
                                widget.formatDate(
                                    widget.locataire['created_at']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // DOCUMENTS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pièces justificatives',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser',
                          onPressed: documentsLoading ? null : _loadDocuments,
                          icon: const Icon(
                            Icons.refresh,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (documentsLoading)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(30.w),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      )
                    else ...[
                      _buildHighlightedDocumentNotice(),

                      widget.buildDocumentSection(
                        widget.locataire,
                        documents,
                            (docId) {},
                        _handleProcessingEnd,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Divider(height: 1, color: Colors.white.withValues(alpha: 0.06)),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Fermer',
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontWeight: FontWeight.w700,
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

// WRAPPER CARTE DOCUMENT
class _DocumentCardWrapper extends StatefulWidget {
  final Map<String, dynamic> document;

  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>)
  onValidate;
  final Future<Map<String, dynamic>?> Function(Map<String, dynamic>)
  onRefuse;

  final void Function(String documentId) onProcessingStart;
  final void Function(String documentId, Map<String, dynamic>? updated)
  onProcessingEnd;

  final Future<void> Function(Map<String, dynamic>) onPreview;
  final String Function(String?) sideLabel;
  final String Function(String?) statusLabel;
  final Color Function(String?) statusColor;
  final String Function(String) typeLabel;
  final String Function(dynamic) formatDate;
  final String Function(dynamic) formatFileSize;

  const _DocumentCardWrapper({
    super.key,
    required this.document,
    required this.onValidate,
    required this.onRefuse,
    required this.onProcessingStart,
    required this.onProcessingEnd,
    required this.onPreview,
    required this.sideLabel,
    required this.statusLabel,
    required this.statusColor,
    required this.typeLabel,
    required this.formatDate,
    required this.formatFileSize,
  });

  @override
  State<_DocumentCardWrapper> createState() => _DocumentCardWrapperState();
}

class _DocumentCardWrapperState extends State<_DocumentCardWrapper> {
  bool _isProcessing = false;

  Future<void> _handleValidate() async {
    final id = widget.document['id']?.toString();
    if (id == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    widget.onProcessingStart(id);

    final updated = await widget.onValidate(widget.document);

    if (!mounted) return;

    setState(() => _isProcessing = false);
    widget.onProcessingEnd(id, updated);
  }

  Future<void> _handleRefuse() async {
    final id = widget.document['id']?.toString();
    if (id == null || _isProcessing) return;

    setState(() => _isProcessing = true);
    widget.onProcessingStart(id);

    final updated = await widget.onRefuse(widget.document);

    if (!mounted) return;

    setState(() => _isProcessing = false);
    widget.onProcessingEnd(id, updated);
  }

  @override
  Widget build(BuildContext context) {
    final document = widget.document;
    final statut = document['statut']?.toString();
    final statusColor = widget.statusColor(statut);
    final mimeType = document['mime_type']?.toString().toLowerCase() ?? '';
    final isImage = mimeType.startsWith('image/');
    final fileName = document['nom_fichier']?.toString() ?? 'Document';

    final isPending =
        statut == 'en_attente' || statut == 'en_verification';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0F1E),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isProcessing
              ? const Color(0xFFFFC107).withValues(alpha: 0.6)
              : statusColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 58.w,
                height: 58.w,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: _isProcessing
                    ? Padding(
                  padding: EdgeInsets.all(16.w),
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFFFC107),
                  ),
                )
                    : Icon(
                  isImage
                      ? Icons.image_outlined
                      : Icons.picture_as_pdf_outlined,
                  color: statusColor,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.sideLabel(document['cote_document']),
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFC107),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding:
                      EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        widget.statusLabel(statut),
                        style: GoogleFonts.manrope(
                          color: statusColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Voir',
                onPressed: _isProcessing
                    ? null
                    : () => widget.onPreview(document),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: Color(0xFFFFC107),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          if (document['numero_document'] != null)
            _buildSmallInfo(
              Icons.badge_outlined,
              'N°',
              document['numero_document'].toString(),
            ),

          if (document['pays_emission'] != null)
            _buildSmallInfo(
              Icons.public,
              'Pays',
              document['pays_emission'].toString(),
            ),

          if (document['date_expiration'] != null)
            _buildSmallInfo(
              Icons.event_outlined,
              'Expiration',
              widget.formatDate(document['date_expiration']),
            ),

          if (document['motif_refus'] != null &&
              document['motif_refus'].toString().trim().isNotEmpty)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 8.h),
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8.r),
                border:
                Border.all(color: Colors.red.withValues(alpha: 0.18)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      document['motif_refus'].toString(),
                      style: GoogleFonts.manrope(
                        color: Colors.red.shade100,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (isPending) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing ? null : _handleRefuse,
                    icon: const Icon(Icons.close, size: 17),
                    label: const Text('Refuser'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(
                        color: Colors.red
                            .withValues(alpha: _isProcessing ? 0.2 : 0.45),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _handleValidate,
                    icon: const Icon(Icons.check, size: 17),
                    label: const Text('Valider'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      Colors.green.withValues(alpha: 0.25),
                      padding: EdgeInsets.symmetric(vertical: 11.h),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallInfo(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Row(
        children: [
          Icon(icon, color: Colors.white30, size: 15.sp),
          SizedBox(width: 7.w),
          Text(
            '$label : ',
            style: GoogleFonts.manrope(
              color: Colors.white38,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// AVATAR LOCATAIRE
// ============================================================

class _LocataireAvatar extends StatefulWidget {
  final String userId;
  final String initials;
  final bool isActive;
  final double radius;

  const _LocataireAvatar({
    required this.userId,
    required this.initials,
    required this.isActive,
    required this.radius,
  });

  @override
  State<_LocataireAvatar> createState() => _LocataireAvatarState();
}

class _LocataireAvatarState extends State<_LocataireAvatar> {
  final DatabaseService _dbService = ServiceLocator.database;

  String? _avatarUrl;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    if (!mounted) return;

    setState(() => _loading = true);

    try {
      final url = await _dbService.getUserAvatarUrl(widget.userId);

      if (!mounted) return;

      setState(() {
        _avatarUrl = url;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Erreur chargement avatar ${widget.userId} : $e');

      if (!mounted) return;

      setState(() {
        _avatarUrl = null;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = widget.isActive
        ? const Color(0xFFFFC107)
        : Colors.grey;

    final textColor =
    widget.isActive ? const Color(0xFF090D16) : Colors.white;

    if (_loading) {
      return CircleAvatar(
        radius: widget.radius,
        backgroundColor: backgroundColor.withValues(alpha: 0.5),
        child: SizedBox(
          width: widget.radius * 0.6,
          height: widget.radius * 0.6,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white70,
          ),
        ),
      );
    }

    if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      return Container(
        width: widget.radius * 2,
        height: widget.radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color:
            widget.isActive ? const Color(0xFFFFC107) : Colors.grey,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Image.network(
            _avatarUrl!,
            fit: BoxFit.cover,
            width: widget.radius * 2,
            height: widget.radius * 2,
            errorBuilder: (context, error, stackTrace) {
              debugPrint('⚠️ Erreur affichage avatar : $error');
              return _buildInitialsAvatar(backgroundColor, textColor);
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                color: backgroundColor.withValues(alpha: 0.3),
                child: Center(
                  child: SizedBox(
                    width: widget.radius * 0.6,
                    height: widget.radius * 0.6,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white70,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
    }

    return _buildInitialsAvatar(backgroundColor, textColor);
  }

  Widget _buildInitialsAvatar(Color bg, Color text) {
    return CircleAvatar(
      radius: widget.radius,
      backgroundColor: bg,
      child: Text(
        widget.initials.isEmpty ? '?' : widget.initials.toUpperCase(),
        style: GoogleFonts.manrope(
          color: text,
          fontSize: widget.radius * 0.7,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}