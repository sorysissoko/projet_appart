import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/database_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../widgets/main_layout.dart';
import 'package:service/service_locator.dart';
import 'property_list_screen.dart';

class OwnerListScreen extends StatefulWidget {
  final String? initialUserId;
  final String? initialDocumentId;

  const OwnerListScreen({
    super.key,
    this.initialUserId,
    this.initialDocumentId,
  });

  @override
  State<OwnerListScreen> createState() => _OwnerListScreenState();
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

class _OwnerListScreenState extends State<OwnerListScreen> {
  List<Map<String, dynamic>> proprietaire = [];
  List<Map<String, dynamic>> filteredProprietaires = [];
  String selectedFilter = 'Tous';
  bool isFetching = true;
  String searchQuery = '';
  String? errorMessage;

  bool _initialNotificationHandled = false;

  final List<String> filterOptions = ['Tous', 'Actifs', 'Inactifs', 'Suspendus'];

  final DatabaseService _dbService = ServiceLocator.database;


  // DÉFINITIONS DES DOCUMENTS REQUIS

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
    _AdminDocumentDef(
      key: 'rib',
      label: "RIB bancaire",
      sub: "Pour recevoir vos paiements",
      icon: Icons.account_balance_outlined,
      typeDocument: "RIB bancaire",
      categorie: "administratif",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fetchProprietaires();
  }


  // CHARGEMENT DES PROPRIÉTAIRES
  Future<void> _fetchProprietaires() async {
    setState(() {
      isFetching = true;
      errorMessage = null;
    });

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
            identite_verifiee,
            date_certification,
            date_verification_identite
          ''')
          .eq('role', 'proprietaire')
          .order('created_at', ascending: false);

      debugPrint('${response.length} propriétaires chargés');

      final proprietaires = response.cast<Map<String, dynamic>>();

      if (!mounted) return;

      setState(() {
        proprietaire = proprietaires;
        _filterProprietaires();
        isFetching = false;
      });

      if (!_initialNotificationHandled &&
          widget.initialUserId != null &&
          widget.initialUserId!.isNotEmpty) {
        _initialNotificationHandled = true;

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          final index = proprietaires.indexWhere(
                (owner) => owner['id']?.toString() == widget.initialUserId,
          );

          if (index == -1) {
            _safeShowSnackBar(
              'Le propriétaire concerné par cette notification est introuvable.',
              Colors.orange,
              Icons.warning_amber_rounded,
            );
            return;
          }

          _showProprietairesDetails(
            proprietaires[index],
            highlightedDocumentId: widget.initialDocumentId,
          );
        });
      }
    } catch (e) {
      debugPrint('Erreur chargement propriétaires : $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Erreur lors du chargement : $e';
        proprietaire = [];
        filteredProprietaires = [];
        isFetching = false;
      });

      _safeShowSnackBar('Erreur: $e', Colors.red, Icons.error);
    }
  }


  // CERTIFIER UN UTILISATEUR
  Future<bool> _certifierUtilisateur(String userId) async {
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

      // Rafraîchir la liste pour voir le badge jaune
      await _fetchProprietaires();

      return true;
    } catch (e) {
      debugPrint('Erreur certification : $e');
      _safeShowSnackBar(
        'Erreur lors de la certification : $e',
        Colors.red,
        Icons.error_outline,
      );
      return false;
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
      debugPrint('Erreur documents propriétaire $userId : $e');
      return [];
    }
  }


  // FETCH RÉSIDENCES DU PROPRIÉTAIRE
  Future<List<Map<String, dynamic>>> _fetchOwnerResidences(
      String userId,
      ) async {
    try {
      final response = await _dbService.supabase
          .from('residences')
          .select('''
          id,
          nom,
          ville,
          adresse,
          localisation,
          status,
          created_at,
          validated_at,
          refusal_reason,
          appartements (id)
        ''')
          .eq('proprietaire_id', userId)
          .neq('status', 'supprimee')
          .order('created_at', ascending: false);

      final list = List<Map<String, dynamic>>.from(response);

      for (final item in list) {
        final apts = item['appartements'];
        item['appartements_count'] = (apts is List) ? apts.length : 0;
      }

      return list;
    } catch (e) {
      debugPrint('Erreur résidences propriétaire $userId : $e');
      return [];
    }
  }


  // LABELS
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

  String _documentTypeLabel(String type) {
    switch (type) {
      case 'carte_identite':
        return 'Carte d’identité';
      case 'passeport':
        return 'Passeport';
      case 'permis_conduire':
        return 'Permis de conduire';
      case 'rib':
      case 'RIB bancaire':
        return 'RIB bancaire';
      case 'assurance':
      case 'Attestation assurance':
        return 'Attestation assurance';
      case 'justificatif_propriete':
      case 'propriete':
        return 'Justificatif de propriété';
      default:
        return type;
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
      debugPrint('✅ Download OK : ${bytes.length} octets');
    } catch (e) {
      debugPrint('❌ download() échoué : $e');
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


  // VALIDER / REFUSER DOCUMENT
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
      debugPrint('❌ Validation document : $e');
      if (!mounted) return null;
      _safeShowSnackBar(
        'Erreur lors de la validation : $e',
        Colors.red,
        Icons.error_outline,
      );
      return null;
    }
  }

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
      debugPrint('❌ Refus document : $e');
      if (!mounted) return null;
      _safeShowSnackBar(
        'Erreur lors du refus : $e',
        Colors.red,
        Icons.error_outline,
      );
      return null;
    }
  }

  // HELPERS DOCUMENT
  Map<String, dynamic>? _getDocumentForSide(
      List<Map<String, dynamic>> documents,
      String type,
      String side,
      ) {
    for (final document in documents) {
      if (document['type_document']?.toString() == type &&
          document['cote_document']?.toString() == side) {
        return document;
      }
    }
    return null;
  }


  // FILTRES
  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
      _filterProprietaires();
    });
  }

  void _filterProprietaires() {
    var filtered = List<Map<String, dynamic>>.from(proprietaire);

    if (selectedFilter == 'Actifs') {
      filtered = filtered.where((l) => l['statut'] == 'actif').toList();
    } else if (selectedFilter == 'Inactifs') {
      filtered = filtered.where((l) => l['statut'] == 'inactif').toList();
    } else if (selectedFilter == 'Suspendus') {
      filtered = filtered.where((l) => l['statut'] == 'suspendu').toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((l) {
        final nom = l['nom']?.toString().toLowerCase() ?? '';
        final prenom = l['prenom']?.toString().toLowerCase() ?? '';
        final email = l['email']?.toString().toLowerCase() ?? '';
        final telephone = l['telephone']?.toString() ?? '';
        final ville = l['ville']?.toString().toLowerCase() ?? '';
        return nom.contains(query) ||
            prenom.contains(query) ||
            email.contains(query) ||
            telephone.contains(query) ||
            ville.contains(query);
      }).toList();
    }

    filteredProprietaires = filtered;
  }

  Map<String, int> _getStats() {
    return {
      'Tous': proprietaire.length,
      'Actifs': proprietaire.where((l) => l['statut'] == 'actif').length,
      'Inactifs': proprietaire.where((l) => l['statut'] == 'inactif').length,
      'Suspendus': proprietaire.where((l) => l['statut'] == 'suspendu').length,
    };
  }

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

  String _formatDate(dynamic date) {
    if (date == null) return 'Non disponible';
    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (e) {
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
    } catch (e) {
      return date.toString();
    }
  }

  Future<void> _updateProprietaireStatus(
      String userId,
      String newStatus,
      ) async {
    try {
      await _dbService.supabase
          .from('users')
          .update({'statut': newStatus})
          .eq('id', userId);

      if (!mounted) return;

      setState(() {
        final idx =
        proprietaire.indexWhere((u) => u['id']?.toString() == userId);

        if (idx != -1) {
          proprietaire[idx] = {
            ...proprietaire[idx],
            'statut': newStatus,
          };
        }

        _filterProprietaires();
      });

      _safeShowSnackBar(
        'Statut mis à jour avec succès',
        Colors.green,
        Icons.check_circle,
      );
    } catch (e) {
      _safeShowSnackBar('Erreur: $e', Colors.red, Icons.error);
    }
  }


  // MODAL DÉTAILS
  void _showProprietairesDetails(
      Map<String, dynamic> proprietaire, {
        String? highlightedDocumentId,
      }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return _OwnerDetailsDialog(
          proprietaire: proprietaire,
          highlightedDocumentId: highlightedDocumentId,
          fetchDocuments: _fetchIdentityDocuments,
          fetchResidences: _fetchOwnerResidences,
          buildDocumentSection: (proprietaire, documents, onStart, onEnd) {
            return _buildIdentityDocumentsSection(
              documents,
              onStart,
              onEnd,
              proprietaire: proprietaire,
            );
          },
          buildInfoRow: _buildInfoRow,
          formatDate: _formatDate,
          formatDateNaissance: _formatDateNaissance,
          onUpdateStatus: _updateProprietaireStatus,
          onCertify: _certifierUtilisateur,
          onOpenResidence: (residence) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PropertyListScreen(
                  city: residence['ville']?.toString() ?? '',
                  propertyType: 'Appart',
                  title: residence['nom']?.toString() ?? 'Résidence',
                  focusResidenceId: residence['id']?.toString(),
                ),
              ),
            );
          },
        );
      },
    );
  }


  // SECTION PIÈCES D'IDENTITÉ
  Widget _buildIdentityDocumentsSection(
      List<Map<String, dynamic>> documents,
      void Function(String documentId) onProcessingStart,
      void Function(String documentId, Map<String, dynamic>? updated)
      onProcessingEnd, {
        Map<String, dynamic>? proprietaire,
      }) {
    final personalDocs = documents.where((doc) {
      final residenceId = doc['residence_id']?.toString();
      return residenceId == null || residenceId.isEmpty;
    }).toList();

    int validatedCount = 0;
    int totalCount = _requiredDocuments.length;

    final List<Widget> cards = [];

    for (final def in _requiredDocuments) {
      final allMatchingDocs = personalDocs.where((doc) {
        final type = doc['type_document']?.toString().toLowerCase() ?? '';
        final cat = doc['categorie']?.toString().toLowerCase() ?? '';

        if (def.identity) {
          return cat == 'identite' &&
              (type.contains('carte') ||
                  type.contains('cni') ||
                  type.contains('passeport') ||
                  type.contains('permis') ||
                  type.contains('identite'));
        }

        if (def.key == 'rib') {
          return type.contains('rib') || type.contains('bancaire');
        }

        return false;
      }).toList();

      allMatchingDocs.sort((a, b) {
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

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

      final allValidated = matchingDocs.isNotEmpty &&
          matchingDocs.every((d) {
            final s = d['statut']?.toString() ?? '';
            return s == 'valide' || s == 'validee' || s == 'verifie';
          });

      if (allValidated) validatedCount++;

      if (def.identity) {
        cards.add(_buildIdentityCard(
          def: def,
          documents: matchingDocs,
          onProcessingStart: onProcessingStart,
          onProcessingEnd: onProcessingEnd,
        ));
      } else {
        cards.add(_buildSimpleDocumentCard(
          def: def,
          documents: matchingDocs,
          onProcessingStart: onProcessingStart,
          onProcessingEnd: onProcessingEnd,
        ));
      }
    }

    final proprietaireId = proprietaire?['id']?.toString();
    final estCertifie = proprietaire?['est_certifie'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          margin: EdgeInsets.only(bottom: 14.h),
          decoration: BoxDecoration(
            color: validatedCount == totalCount
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : const Color(0xFFFFC107).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: validatedCount == totalCount
                  ? const Color(0xFF10B981).withValues(alpha: 0.4)
                  : const Color(0xFFFFC107).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              Icon(
                validatedCount == totalCount
                    ? Icons.verified_rounded
                    : Icons.pending_actions_rounded,
                color: validatedCount == totalCount
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
                      validatedCount == totalCount
                          ? 'Certification prête'
                          : 'Certification en cours',
                      style: GoogleFonts.manrope(
                        color: validatedCount == totalCount
                            ? const Color(0xFF10B981)
                            : const Color(0xFFFFC107),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$validatedCount / $totalCount document(s) validé(s)',
                      style: GoogleFonts.manrope(
                        color: Colors.white70,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              //BOUTON DE CERTIFICATION
              if (validatedCount == totalCount &&
                  !estCertifie &&
                  proprietaireId != null)
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
                            'Tous les documents sont validés. '
                                'Voulez-vous certifier le compte de ce propriétaire ?',
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
                        final success =
                        await _certifierUtilisateur(proprietaireId);
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
        ...cards,
      ],
    );
  }


  // CARTE PIÈCE D'IDENTITÉ
  Widget _buildIdentityCard({
    required _AdminDocumentDef def,
    required List<Map<String, dynamic>> documents,
    required void Function(String documentId) onProcessingStart,
    required void Function(String documentId, Map<String, dynamic>? updated)
    onProcessingEnd,
  }) {
    final typeDocuments = documents;

    final recto = _getDocumentForSide(typeDocuments, 'carte_identite', 'recto') ??
        _getDocumentForSide(typeDocuments, 'permis_conduire', 'recto') ??
        _getDocumentForSide(typeDocuments, 'passeport', 'recto') ??
        typeDocuments.firstWhere(
              (d) =>
          d['cote_document'] == 'recto' ||
              (d['cote_document'] == null &&
                  d['type_document']?.toString().contains('passeport') == true),
          orElse: () => <String, dynamic>{},
        );

    final verso = _getDocumentForSide(typeDocuments, 'carte_identite', 'verso') ??
        _getDocumentForSide(typeDocuments, 'permis_conduire', 'verso') ??
        typeDocuments.firstWhere(
              (d) => d['cote_document'] == 'verso',
          orElse: () => <String, dynamic>{},
        );

    final hasRecto = recto.isNotEmpty;
    final hasVerso = verso.isNotEmpty;
    final isMissing = !hasRecto && !hasVerso;

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
                _buildStatusBadge(typeDocuments),
            ],
          ),
          SizedBox(height: 12.h),
          if (isMissing)
            _buildMissingMessage(
              'Aucune pièce d\'identité soumise',
              'Le propriétaire doit envoyer sa carte d\'identité (recto + verso), '
                  'son permis ou son passeport.',
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
                else if (_isIdentityWithTwoSides(typeDocuments))
                  Expanded(child: _buildMissingSmallCard('VERSO')),
              ],
            ),
        ],
      ),
    );
  }

  bool _isIdentityWithTwoSides(List<Map<String, dynamic>> docs) {
    return docs.any((d) => d['cote_document'] == 'recto') ||
        docs.any((d) => d['cote_document'] == 'verso');
  }


  // CARTE DOCUMENT SIMPLE (RIB)
  Widget _buildSimpleDocumentCard({
    required _AdminDocumentDef def,
    required List<Map<String, dynamic>> documents,
    required void Function(String documentId) onProcessingStart,
    required void Function(String documentId, Map<String, dynamic>? updated)
    onProcessingEnd,
  }) {
    final isMissing = documents.isEmpty;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      def.label,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      def.sub,
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
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
              'Document non fourni',
              'Le propriétaire n\'a pas encore envoyé ce document.',
            )
          else
            _buildDocumentCardWrapper(
              documents.first,
              onProcessingStart,
              onProcessingEnd,
            ),
        ],
      ),
    );
  }


  // BADGES / MESSAGES MANQUANTS
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

    final statuses = docs
        .map((d) => d['statut']?.toString() ?? '')
        .toSet();

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
          style: BorderStyle.solid,
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


  // WRAPPER DE CARTE
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Icon(icon, size: 18.sp, color: Colors.white38),
          SizedBox(width: 14.w),
          SizedBox(
            width: 110.w,
            child: Text(
              '$label:',
              style: GoogleFonts.manrope(
                color: Colors.white54,
                fontSize: 17.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.4,
              ),
            ),
          ),
          SizedBox(width: 40.w),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 18.sp,
                letterSpacing: 0.5,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }


  // DIALOGUE RECHERCHE
  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF111622),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        title: Text(
          'Rechercher un propriétaire',
          style: GoogleFonts.manrope(color: Colors.white),
        ),
        content: TextField(
          style: GoogleFonts.manrope(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Nom, prénom, email, téléphone, ville...',
            hintStyle: GoogleFonts.manrope(color: Colors.white38),
            prefixIcon: const Icon(Icons.search, color: Colors.white38),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide:
              BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: Color(0xFFFFC107)),
            ),
          ),
          onChanged: (value) {
            setState(() {
              searchQuery = value;
              _filterProprietaires();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: GoogleFonts.manrope(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                searchQuery = '';
                _filterProprietaires();
              });
              Navigator.pop(context);
            },
            child: Text(
              'Réinitialiser',
              style: GoogleFonts.manrope(color: const Color(0xFFFFC107)),
            ),
          ),
        ],
      ),
    );
  }


  // FILTRES CHIPS
  Widget _buildFilterChipsLayout() {
    final stats = _getStats();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filterOptions.map((filter) {
          final count = stats[filter] ?? 0;
          final isSelected = selectedFilter == filter;

          Color activeColor = filter == 'Tous'
              ? const Color(0xFFFFC107)
              : filter == 'Actifs'
              ? const Color(0xFF10B981)
              : filter == 'Inactifs'
              ? const Color(0xFFEF4444)
              : const Color(0xFFF59E0B);

          return Container(
            margin: EdgeInsets.only(right: 12.w),
            child: ChoiceChip(
              label: Text(
                "$filter ($count)",
                style: GoogleFonts.manrope(
                  color:
                  isSelected ? const Color(0xFF090D16) : Colors.white70,
                  fontSize: 18.sp,
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
                '${filteredProprietaires.length} propriétaires trouvés',
                style: GoogleFonts.manrope(
                  color: Colors.white60,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (searchQuery.isNotEmpty)
                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
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
                            _filterProprietaires();
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
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            )
          else if (filteredProprietaires.isEmpty)
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
                      "Aucun propriétaire disponible",
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
              itemCount: filteredProprietaires.length,
              separatorBuilder: (_, __) => Divider(
                color: Colors.white.withValues(alpha: 0.05),
                height: 1,
              ),
              itemBuilder: (context, index) {
                final proprietaire = filteredProprietaires[index];
                final statut = proprietaire['statut'] ?? 'actif';
                final isActive = statut == 'actif';
                Color statutColor = isActive ? Colors.green : Colors.red;

                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            _OwnerAvatar(
                              userId: proprietaire['id'].toString(),
                              initials: '${proprietaire['prenom']?[0] ?? ''}${proprietaire['nom']?[0] ?? ''}',
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
                                                '${proprietaire['prenom'] ?? ''} ${proprietaire['nom'] ?? ''}',
                                                style: GoogleFonts.manrope(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 20.sp,
                                                  letterSpacing: 0.5,
                                                ),
                                                overflow:
                                                TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (proprietaire['est_certifie'] ==
                                                true) ...[
                                              SizedBox(width: 6.w),
                                              Icon(
                                                Icons.verified_rounded,
                                                color:
                                                const Color(0xFFFFC107),
                                                size: 18.sp,
                                              ),
                                            ] else if (proprietaire[
                                            'identite_verifiee'] ==
                                                true) ...[
                                              SizedBox(width: 6.w),
                                              Icon(
                                                Icons.verified_user_rounded,
                                                color:
                                                const Color(0xFF10B981),
                                                size: 16.sp,
                                              ),
                                            ] else ...[
                                              SizedBox(width: 6.w),
                                              Icon(
                                                Icons.cancel_rounded,
                                                color:
                                                const Color(0xFFEF4444),
                                                size: 18.sp,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 8.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statutColor.withValues(
                                              alpha: 0.15),
                                          borderRadius:
                                          BorderRadius.circular(10.r),
                                        ),
                                        child: Text(
                                          statut.toString().toUpperCase(),
                                          style: GoogleFonts.manrope(
                                            color: statutColor,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  if (proprietaire['email'] != null)
                                    Text(
                                      proprietaire['email'],
                                      style: GoogleFonts.manrope(
                                        color: Colors.white54,
                                        fontSize: 18.sp,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Row(
                                    children: [
                                      if (proprietaire['telephone'] != null)
                                        Text(
                                          proprietaire['telephone'],
                                          style: GoogleFonts.manrope(
                                            color: Colors.white38,
                                            fontSize: 18.sp,
                                          ),
                                        ),
                                      if (proprietaire['telephone'] != null &&
                                          proprietaire['ville'] != null)
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
                                      if (proprietaire['ville'] != null)
                                        Expanded(
                                          child: Text(
                                            proprietaire['ville'],
                                            style: GoogleFonts.manrope(
                                              color: Colors.white38,
                                              fontSize: 18.sp,
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
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFC107)
                                  .withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: TextButton.icon(
                              onPressed: () {
                                _showProprietairesDetails(proprietaire);
                              },
                              icon: Icon(
                                Icons.visibility,
                                color: const Color(0xFFFFC107),
                                size: 16.sp,
                              ),
                              label: Text(
                                'Voir',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFFFFC107),
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8.w, vertical: 4.h),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert,
                                color: Colors.white60),
                            color: const Color(0xFF111622),
                            onSelected: (value) {
                              if (value == 'detail') {
                                _showProprietairesDetails(proprietaire);
                              } else if (value == 'toggle_status') {
                                _updateProprietaireStatus(
                                  proprietaire['id'].toString(),
                                  isActive ? 'inactif' : 'actif',
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              PopupMenuItem(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    Icon(Icons.info_outline,
                                        color: Colors.white, size: 20.sp),
                                    SizedBox(width: 12.w),
                                    Text(
                                      'Détails',
                                      style: GoogleFonts.manrope(
                                        color: Colors.white,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
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
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 12.w),
                                    Text(
                                      isActive ? 'Désactiver' : 'Activer',
                                      style: GoogleFonts.manrope(
                                        color: isActive
                                            ? Colors.orange
                                            : Colors.green,
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w800,
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
      title: 'Propriétaires',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh,
              color: Color(0xFFFFC107), size: 20),
          onPressed: () => _fetchProprietaires(),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white54, size: 20),
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
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
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


// DIALOG DÉTAILS PROPRIÉTAIRE
class _OwnerDetailsDialog extends StatefulWidget {
  final Map<String, dynamic> proprietaire;
  final String? highlightedDocumentId;

  final Future<List<Map<String, dynamic>>> Function(String userId)
  fetchDocuments;

  final Future<List<Map<String, dynamic>>> Function(String userId)
  fetchResidences;

  final Widget Function(
      Map<String, dynamic> proprietaire,
      List<Map<String, dynamic>> documents,
      void Function(String documentId) onProcessingStart,
      void Function(String documentId, Map<String, dynamic>? updated)
      onProcessingEnd,
      ) buildDocumentSection;

  final Widget Function(IconData icon, String label, String value)
  buildInfoRow;

  final String Function(dynamic date) formatDate;
  final String Function(dynamic date) formatDateNaissance;

  final Future<void> Function(String userId, String newStatus) onUpdateStatus;

  final Future<bool> Function(String userId) onCertify;

  final void Function(Map<String, dynamic> residence) onOpenResidence;

  const _OwnerDetailsDialog({
    required this.proprietaire,
    required this.fetchDocuments,
    required this.fetchResidences,
    required this.buildDocumentSection,
    required this.buildInfoRow,
    required this.formatDate,
    required this.formatDateNaissance,
    required this.onUpdateStatus,
    required this.onCertify,
    required this.onOpenResidence,
    this.highlightedDocumentId,
  });

  @override
  State<_OwnerDetailsDialog> createState() => _OwnerDetailsDialogState();
}

class _OwnerDetailsDialogState extends State<_OwnerDetailsDialog> {
  List<Map<String, dynamic>> documents = [];
  bool documentsLoading = true;
  Map<String, dynamic>? highlightedDocument;

  List<Map<String, dynamic>> residences = [];
  bool residencesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadResidences();
  }

  Future<void> _loadDocuments() async {
    if (!mounted) return;

    setState(() {
      documentsLoading = true;
      highlightedDocument = null;
    });

    try {
      final userId = widget.proprietaire['id'].toString();
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
      debugPrint('❌ Chargement documents : $e');

      if (!mounted) return;

      setState(() {
        documents = [];
        highlightedDocument = null;
        documentsLoading = false;
      });
    }
  }

  Future<void> _loadResidences() async {
    if (!mounted) return;

    setState(() {
      residencesLoading = true;
    });

    try {
      final userId = widget.proprietaire['id'].toString();
      final result = await widget.fetchResidences(userId);

      if (!mounted) return;

      setState(() {
        residences = result;
        residencesLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Chargement résidences : $e');

      if (!mounted) return;

      setState(() {
        residences = [];
        residencesLoading = false;
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
    final side =
    cote == null || cote.isEmpty ? 'DOCUMENT' : cote.toUpperCase();

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

  Widget _buildResidenceTile(Map<String, dynamic> residence) {
    final nom = residence['nom']?.toString() ?? 'Résidence';
    final ville = residence['ville']?.toString() ?? '';
    final adresse = residence['adresse']?.toString() ?? '';
    final status = residence['status']?.toString() ?? 'en_attente';
    final apartmentsCount = residence['appartements_count'] ?? 0;

    Color statusColor;
    String statusLabel;

    switch (status) {
      case 'validee':
        statusColor = const Color(0xFF10B981);
        statusLabel = 'Validée';
        break;
      case 'refusee':
        statusColor = const Color(0xFFEF4444);
        statusLabel = 'Refusée';
        break;
      default:
        statusColor = const Color(0xFFF59E0B);
        statusLabel = 'En attente';
    }

    return InkWell(
      onTap: () => widget.onOpenResidence(residence),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFF0A0F1E),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107).withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: const Icon(
                Icons.business_outlined,
                color: Color(0xFFFFC107),
                size: 22,
              ),
            ),
            SizedBox(width: 12.w),
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
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: const Color(0xFFFFC107)
                                .withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.meeting_room_outlined,
                              color: const Color(0xFFFFC107),
                              size: 11.sp,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '$apartmentsCount',
                              style: GoogleFonts.manrope(
                                color: const Color(0xFFFFC107),
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    [
                      if (ville.isNotEmpty) ville,
                      if (adresse.isNotEmpty) adresse,
                    ].join(' • '),
                    style: GoogleFonts.manrope(
                      color: Colors.white54,
                      fontSize: 13.sp,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.35),
                ),
              ),
              child: Text(
                statusLabel,
                style: GoogleFonts.manrope(
                  color: statusColor,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.4),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statut = widget.proprietaire['statut']?.toString() ?? 'actif';

    Color statusColor;
    switch (statut) {
      case 'actif':
        statusColor = Colors.green;
        break;
      case 'inactif':
        statusColor = Colors.red;
        break;
      case 'suspendu':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
    }

    final prenom = widget.proprietaire['prenom']?.toString().trim() ?? '';
    final nom = widget.proprietaire['nom']?.toString().trim() ?? '';
    final fullName =
    '$prenom $nom'.trim().isEmpty ? 'Propriétaire' : '$prenom $nom';
    final initials = '${prenom.isNotEmpty ? prenom[0] : ''}'
        '${nom.isNotEmpty ? nom[0] : ''}';

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
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Row(
                children: [
                  _OwnerAvatar(
                    userId: widget.proprietaire['id'].toString(),
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
                            if (widget.proprietaire['est_certifie'] ==
                                true) ...[
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
                            ] else if (widget
                                .proprietaire['identite_verifiee'] ==
                                true) ...[
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: const Color(0xFF10B981)
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_user_rounded,
                                      color: const Color(0xFF10B981),
                                      size: 12.sp,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'IDENTITÉ VÉRIFIÉE',
                                      style: GoogleFonts.manrope(
                                        color: const Color(0xFF10B981),
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
                                widget.proprietaire['email']?.toString() ?? 'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.phone_outlined,
                                'Téléphone',
                                widget.proprietaire['telephone']?.toString() ?? 'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.cake_outlined,
                                'Date de naissance',
                                widget.formatDateNaissance(
                                    widget.proprietaire['date_naissance']),
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
                                widget.proprietaire['ville']?.toString() ?? 'Non renseignée',
                              ),
                              widget.buildInfoRow(
                                Icons.public,
                                'Pays',
                                widget.proprietaire['pays']?.toString() ?? 'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.home_outlined,
                                'Adresse',
                                widget.proprietaire['adresse']?.toString() ?? 'Non renseignée',
                              ),
                              widget.buildInfoRow(
                                Icons.phone_android,
                                'Urgence',
                                widget.proprietaire['urgencephone']?.toString() ??
                                    'Non renseigné',
                              ),
                              widget.buildInfoRow(
                                Icons.calendar_today,
                                'Inscrit le',
                                widget.formatDate(widget.proprietaire['created_at']),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Résidences',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Actualiser',
                          onPressed:
                          residencesLoading ? null : _loadResidences,
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFFFFC107)),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    if (residencesLoading)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(30.w),
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFFFC107),
                          ),
                        ),
                      )
                    else if (residences.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A0F1E),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 40.sp,
                              color: Colors.white24,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              'Aucune résidence',
                              style: GoogleFonts.manrope(
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ...residences.map(_buildResidenceTile),

                    SizedBox(height: 24.h),

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
                          onPressed:
                          documentsLoading ? null : _loadDocuments,
                          icon: const Icon(Icons.refresh,
                              color: Color(0xFFFFC107)),
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
                        widget.proprietaire,
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


// WRAPPER DE CARTE DOCUMENT
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

    final isPending = statut == 'en_attente' || statut == 'en_verification';

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
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.w, vertical: 3.h),
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


// AVATAR PROPRIÉTAIRE
class _OwnerAvatar extends StatefulWidget {
  final String userId;
  final String initials;
  final bool isActive;
  final double radius;

  const _OwnerAvatar({
    required this.userId,
    required this.initials,
    required this.isActive,
    required this.radius,
  });

  @override
  State<_OwnerAvatar> createState() => _OwnerAvatarState();
}

class _OwnerAvatarState extends State<_OwnerAvatar> {
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
      debugPrint('❌ Erreur chargement avatar ${widget.userId} : $e');

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

    final textColor = widget.isActive
        ? const Color(0xFF090D16)
        : Colors.white;

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
            color: widget.isActive
                ? const Color(0xFFFFC107)
                : Colors.grey,
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