import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'package:service/database_service.dart';

import '../../core/theme/app_theme.dart';

// ════════════════════════════════════════════════════════════
// SKELETON SYSTEM
// ════════════════════════════════════════════════════════════

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double radius;
  final Color? color;
  final BoxShape shape;

  const SkeletonBox({
    super.key,
    this.width,
    this.height,
    this.radius = 8,
    this.color,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? const Color(0xFFE2E8F0),
        borderRadius:
        shape == BoxShape.circle ? null : BorderRadius.circular(radius.r),
        shape: shape,
      ),
    );
  }
}

class ShimmerLoading extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerLoading({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF1F5F9),
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

// ════════════════════════════════════════════════════════════
// ENUMS & MODELS
// ════════════════════════════════════════════════════════════

enum DocStatus {
  verified,
  pending,
  rejected,
  expired,
  missing,
}

class DocumentDefinition {
  final String key;
  final String label;
  final String sub;
  final IconData icon;
  final String typeDocument;
  final String categorie;
  final bool identity;
  final bool identitySideRequired;

  const DocumentDefinition({
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

class OwnerDocument {
  final DocumentDefinition definition;
  final List<Map<String, dynamic>> records;

  const OwnerDocument({
    required this.definition,
    required this.records,
  });

  bool get isMissing => records.isEmpty;

  Map<String, dynamic>? get latestRecord {
    if (records.isEmpty) {
      return null;
    }
    return records.first;
  }

  String? get filename {
    if (records.isEmpty) {
      return null;
    }
    if (records.length == 1) {
      return records.first['nom_fichier']?.toString();
    }
    return '${records.length} fichiers';
  }

  String? get date {
    if (records.isEmpty) {
      return null;
    }
    final value = records.first['created_at'];
    if (value == null) {
      return null;
    }
    return _formatDate(value.toString());
  }

  String? get rejectionReason {
    for (final record in records) {
      final reason = record['motif_refus']?.toString();
      if (reason != null && reason.trim().isNotEmpty) {
        return reason;
      }
    }
    return null;
  }

  DocStatus get status {
    if (records.isEmpty) {
      return DocStatus.missing;
    }

    final statuses = records
        .map((record) => record['statut']?.toString().trim())
        .whereType<String>()
        .toSet();

    // ============================================================
    // IDENTITÉ : RECTO + VERSO
    // ============================================================

    if (definition.identity && definition.identitySideRequired) {
      final recto = records.any(
            (record) => record['cote_document'] == 'recto',
      );

      final verso = records.any(
            (record) => record['cote_document'] == 'verso',
      );

      final rectoValide = records.any(
            (record) =>
        record['cote_document'] == 'recto' &&
            record['statut'] == 'valide',
      );

      final versoValide = records.any(
            (record) =>
        record['cote_document'] == 'verso' &&
            record['statut'] == 'valide',
      );

      if (recto && verso && rectoValide && versoValide) {
        return DocStatus.verified;
      }

      if (statuses.contains('refuse')) {
        return DocStatus.rejected;
      }

      if (statuses.contains('expire')) {
        return DocStatus.expired;
      }

      if (statuses.contains('en_attente') ||
          statuses.contains('en_verification')) {
        return DocStatus.pending;
      }

      if (recto || verso) {
        return DocStatus.pending;
      }

      return DocStatus.pending;
    }

    // ============================================================
    // DOCUMENT SIMPLE
    // ============================================================

    if (statuses.contains('valide')) {
      return DocStatus.verified;
    }

    if (statuses.contains('refuse')) {
      return DocStatus.rejected;
    }

    if (statuses.contains('expire')) {
      return DocStatus.expired;
    }

    if (statuses.contains('en_verification') ||
        statuses.contains('en_attente')) {
      return DocStatus.pending;
    }

    return DocStatus.pending;
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;

  const _StatusConfig({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });
}

// ════════════════════════════════════════════════════════════
// PAGE
// ════════════════════════════════════════════════════════════

class DocumentsPage extends StatefulWidget {
  final VoidCallback? onBack;

  const DocumentsPage({
    super.key,
    this.onBack,
  });

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final DatabaseService _databaseService = DatabaseService();

  final ImagePicker _imagePicker = ImagePicker();

  List<Map<String, dynamic>> _records = [];

  OwnerDocument? _selectedDocument;

  bool _loading = true;
  bool _uploading = false;

  List<Map<String, dynamic>> _residences = [];

  bool _loadingResidences = false;

  String? _selectedResidenceId;

  bool _personalExpanded = false;
  final Set<String> _expandedResidences = {};

  // DOCUMENT EN PRÉPARATION
  String? _identityType;

  Uint8List? _rectoBytes;
  String? _rectoFilename;
  String? _rectoMimeType;

  Uint8List? _versoBytes;
  String? _versoFilename;
  String? _versoMimeType;

  Uint8List? _singleDocumentBytes;
  String? _singleDocumentFilename;
  String? _singleDocumentMimeType;

  // DÉFINITIONS
  static const List<DocumentDefinition> _definitions = [
    DocumentDefinition(
      key: 'identite',
      label: "Pièce d'identité",
      sub: "CNI, permis ou passeport en cours de validité",
      icon: PhosphorIconsBold.identificationCard,
      typeDocument: "Carte d'identité",
      categorie: "identite",
      identity: true,
      identitySideRequired: true,
    ),
    DocumentDefinition(
      key: 'rib',
      label: "RIB bancaire",
      sub: "Pour recevoir vos paiements",
      icon: PhosphorIconsBold.bank,
      typeDocument: "RIB bancaire",
      categorie: "administratif",
    ),
    DocumentDefinition(
      key: 'assurance',
      label: "Attestation assurance",
      sub: "Assurance propriétaire non-occupant",
      icon: PhosphorIconsBold.shieldCheck,
      typeDocument: "Attestation assurance",
      categorie: "administratif",
    ),
    DocumentDefinition(
      key: 'propriete',
      label: "Justificatif de propriété",
      sub: "Acte notarié, titre de propriété ou attestation de droit d'usage",
      icon: PhosphorIconsBold.fileDoc,
      typeDocument: "justificatif_propriete",
      categorie: "propriete",
    ),
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadDocuments();
    _loadResidences();
  }

  // ============================================================
  // CHARGEMENT
  Future<void> _loadResidences() async {
    if (!mounted) return;

    setState(() {
      _loadingResidences = true;
    });

    try {
      final residences =
      await _databaseService.getMyResidences();

      if (!mounted) return;

      setState(() {
        _residences = residences;
      });
    } catch (e) {
      debugPrint(
        '❌ DocumentsPage._loadResidences: $e',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loadingResidences = false;
        });
      }
    }
  }


  Future<void> _loadDocuments() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
    });

    try {
      // ============================================================
      // 1. DOCUMENTS PERSONNELS
      // ============================================================

      final personalDocuments =
      await _databaseService.getCurrentUserDocuments();

      // ============================================================
      // 2. DOCUMENTS DES RÉSIDENCES
      // ============================================================

      final residenceDocuments =
      await _databaseService.getCurrentUserResidenceDocuments();

      // ============================================================
      // 3. FUSION
      // ============================================================

      final allDocuments = [
        ...personalDocuments,
        ...residenceDocuments,
      ];

      if (!mounted) return;

      setState(() {
        _records = allDocuments;
        _loading = false;
      });

      debugPrint(
        '✅ Documents chargés : '
            '${personalDocuments.length} personnels + '
            '${residenceDocuments.length} résidence(s)',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage(
        "Impossible de charger vos documents.",
        error: true,
      );

      debugPrint(
        '❌ DocumentsPage._loadDocuments: $e',
      );
    }
  }

  // ============================================================
  // DOCUMENTS PERSONNELS (sans residence_id)
  // ============================================================

  bool _isPersonalDefinition(DocumentDefinition definition) {
    return definition.identity ||
        definition.key == 'rib';
  }

  List<OwnerDocument> get _personalDocuments {
    return _definitions
        .where(_isPersonalDefinition)
        .map((definition) {
      final matchingRecords = _records.where((record) {
        // Un document personnel ne doit pas appartenir à une résidence.
        final residenceId = record['residence_id']?.toString();
        if (residenceId != null && residenceId.isNotEmpty) {
          return false;
        }

        return _matchesDefinition(definition, record);
      }).toList();

      matchingRecords.sort((a, b) {
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';
        return dateB.compareTo(dateA);
      });

      return OwnerDocument(
        definition: definition,
        records: matchingRecords,
      );
    }).toList();
  }

  // ============================================================
  // TOUS LES DOCUMENTS (personnels + résidences)
  // ============================================================

  List<OwnerDocument> get _allDocuments {
    final personal = _personalDocuments;

    final residential = <OwnerDocument>[];
    for (final residence in _residences) {
      final residenceId = residence['id']?.toString();
      if (residenceId == null || residenceId.isEmpty) {
        continue;
      }
      residential.addAll(_documentsForResidence(residenceId));
    }

    return [...personal, ...residential];
  }

  List<OwnerDocument> get _documents => _allDocuments;

  bool _isResidenceDefinition(DocumentDefinition definition) {
    return definition.key == 'assurance' ||
        definition.key == 'propriete';
  }

  List<OwnerDocument> _documentsForResidence(String residenceId) {
    return _definitions
        .where(_isResidenceDefinition)
        .map((definition) {
      final matchingRecords = _records.where((record) {
        final recordResidenceId =
        record['residence_id']?.toString();

        if (recordResidenceId != residenceId) {
          return false;
        }

        return _matchesDefinition(definition, record);
      }).toList();

      matchingRecords.sort((a, b) {
        final dateA = a['created_at']?.toString() ?? '';
        final dateB = b['created_at']?.toString() ?? '';

        return dateB.compareTo(dateA);
      });

      return OwnerDocument(
        definition: definition,
        records: matchingRecords,
      );
    }).toList();
  }


  bool _matchesDefinition(
      DocumentDefinition definition,
      Map<String, dynamic> record,
      ) {
    final type = _normalizeText(
      record['type_document']?.toString() ?? '',
    );

    final categorie = _normalizeText(
      record['categorie']?.toString() ?? '',
    );

    final targetType = _normalizeText(definition.typeDocument);

    // IDENTITÉ
    if (definition.identity) {
      if (categorie == 'identite') {
        final isIdentityType = type.contains('carteidentite') ||
            type.contains('cni') ||
            type.contains('passeport') ||
            type.contains('permis') ||
            type.contains('permisdeconduire') ||
            type.contains('pieceidentite') ||
            type.contains('identite');

        return isIdentityType;
      }
      return false;
    }

    // AUTRES
    if (type == targetType) {
      return true;
    }

    switch (definition.key) {
      case 'rib':
        return type.contains('rib');
      case 'assurance':
        return type.contains('assurance');
      case 'propriete':
        return type.contains('propriete') || type.contains('titre');
      default:
        return false;
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  _StatusConfig _statusConfig(DocStatus status) {
    switch (status) {
      case DocStatus.verified:
        return const _StatusConfig(
          label: "Vérifié",
          color: Color(0xFF10B981),
          bg: Color(0xFFECFDF5),
          icon: PhosphorIconsBold.check,
        );

      case DocStatus.pending:
        return const _StatusConfig(
          label: "En cours",
          color: Color(0xFFF97316),
          bg: Color(0xFFFFF7ED),
          icon: PhosphorIconsBold.clock,
        );

      case DocStatus.rejected:
        return const _StatusConfig(
          label: "Refusé",
          color: Color(0xFFEF4444),
          bg: Color(0xFFFEF2F2),
          icon: PhosphorIconsBold.xCircle,
        );

      case DocStatus.expired:
        return const _StatusConfig(
          label: "Expiré",
          color: Color(0xFFB45309),
          bg: Color(0xFFFFFBEB),
          icon: PhosphorIconsBold.warning,
        );

      case DocStatus.missing:
        return const _StatusConfig(
          label: "Manquant",
          color: Color(0xFFEF4444),
          bg: Color(0xFFFEF2F2),
          icon: PhosphorIconsBold.warning,
        );
    }
  }

  // ============================================================
  // COMPTEURS
  // ============================================================

  int get _verifiedCount {
    return _documents
        .where((document) => document.status == DocStatus.verified)
        .length;
  }

  int get _pendingCount {
    return _documents
        .where((document) => document.status == DocStatus.pending)
        .length;
  }

  int get _missingCount {
    return _documents
        .where((document) =>
    document.status == DocStatus.missing ||
        document.status == DocStatus.rejected ||
        document.status == DocStatus.expired)
        .length;
  }

  void _closeUploadModal() {
    if (!mounted) return;
    setState(() {
      _selectedDocument = null;
      _uploading = false;
    });
  }

  // ============================================================
  // CHOIX TYPE IDENTITÉ
  // ============================================================

  Future<String?> _chooseIdentityType() async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quel type de pièce ?',
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Le choix détermine si RECTO et VERSO sont requis.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 16.h),
                _buildIdentityTypeOption(
                  value: 'cni',
                  title: 'Carte nationale d\'identité',
                  subtitle: 'RECTO & VERSO',
                ),
                SizedBox(height: 10.h),
                _buildIdentityTypeOption(
                  value: 'permis',
                  title: 'Permis de conduire',
                  subtitle: 'RECTO & VERSO',
                ),
                SizedBox(height: 10.h),
                _buildIdentityTypeOption(
                  value: 'passeport',
                  title: 'Passeport',
                  subtitle: 'Une seule photo',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResidenceDocuments(
      Map<String, dynamic> residence,
      ) {
    final residenceId = residence['id']?.toString();

    if (residenceId == null || residenceId.isEmpty) {
      return const SizedBox.shrink();
    }

    final documents = _documentsForResidence(residenceId);
    final isExpanded = _expandedResidences.contains(residenceId);

    final nom =
        residence['nom']?.toString() ?? 'Résidence';

    final ville =
        residence['ville']?.toString() ?? '';

    final adresse =
        residence['adresse']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER CLIQUABLE =====
          InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedResidences.remove(residenceId);
                } else {
                  _expandedResidences.add(residenceId);
                }
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      PhosphorIconsBold.buildings,
                      color: const Color(0xFF2563EB),
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nom,
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),

                        if (ville.isNotEmpty || adresse.isNotEmpty)
                          Text(
                            [
                              if (ville.isNotEmpty) ville,
                              if (adresse.isNotEmpty) adresse,
                            ].join(' • '),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 11.sp,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PhosphorIconsBold.caretDown,
                      color: const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENU REPLIABLE =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: documents
                    .map((document) => _buildDocumentCard(
                  document,
                  residenceId: residenceId,
                ))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildAllResidenceDocuments() {
    if (_loadingResidences) {
      return Column(
        children: List.generate(
          2,
              (_) => _buildSkeletonCard(),
        ),
      );
    }

    if (_residences.isEmpty) {
      return _buildEmptyResidences();
    }

    return Column(
      children: _residences.map(
            (residence) => _buildResidenceDocuments(residence),
      ).toList(),
    );
  }

  Widget _buildPersonalDocuments() {
    final documents = _personalDocuments;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ===== HEADER CLIQUABLE =====
          InkWell(
            borderRadius: BorderRadius.circular(18.r),
            onTap: () {
              setState(() {
                _personalExpanded = !_personalExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      PhosphorIconsBold.userCircle,
                      color: const Color(0xFF2563EB),
                      size: 22.sp,
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Documents personnels',
                          style: GoogleFonts.outfit(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${documents.where((d) => d.records.isNotEmpty).length}/${documents.length} ajoutés',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  AnimatedRotation(
                    turns: _personalExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      PhosphorIconsBold.caretDown,
                      color: const Color(0xFF64748B),
                      size: 18.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ===== CONTENU REPLIABLE =====
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _personalExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Column(
                children: documents
                    .map((document) => _buildDocumentCard(document))
                    .toList(),
              ),
            ),
            secondChild: const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyResidences() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(
            PhosphorIconsBold.buildings,
            size: 40.sp,
            color: const Color(0xFF94A3B8),
          ),
          SizedBox(height: 10.h),
          Text(
            'Aucune résidence',
            style: GoogleFonts.outfit(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildIdentityTypeOption({
    required String value,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context, value);
      },
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE0E7FF)),
        ),
        child: Row(
          children: [
            Icon(
              PhosphorIconsBold.identificationCard,
              color: const Color(0xFF2563EB),
              size: 22.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 11.sp,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsBold.caretRight,
              color: const Color(0xFFCBD5E1),
              size: 17.sp,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CHOIX SOURCE
  // ============================================================

  Future<String?> _chooseSource({required String title}) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 16.h),
                _buildSourceOption(
                  icon: PhosphorIconsBold.camera,
                  title: 'Prendre une photo',
                  value: 'camera',
                ),
                SizedBox(height: 10.h),
                _buildSourceOption(
                  icon: PhosphorIconsBold.image,
                  title: 'Depuis la galerie',
                  value: 'gallery',
                ),
                SizedBox(height: 10.h),
                _buildSourceOption(
                  icon: PhosphorIconsBold.file,
                  title: 'Importer un fichier',
                  value: 'file',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      tileColor: const Color(0xFFF8FAFF),
      leading: Icon(icon, color: const Color(0xFF2563EB)),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
      ),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: () {
        Navigator.pop(context, value);
      },
    );
  }

  // ============================================================
  // DÉMARRAGE IDENTITÉ
  // ============================================================

  Future<void> _startIdentityUpload(DocumentDefinition definition) async {
    final identityType = await _chooseIdentityType();

    if (!mounted || identityType == null) {
      return;
    }

    _identityType = identityType;

    _rectoBytes = null;
    _versoBytes = null;
    _rectoFilename = null;
    _versoFilename = null;
    _rectoMimeType = null;
    _versoMimeType = null;

    await _openIdentitySource(definition, side: 'recto');
  }

  Future<void> _openIdentitySource(
      DocumentDefinition definition, {
        required String side,
      }) async {
    final source = await _chooseSource(
      title: side == 'recto' ? 'Ajouter le RECTO' : 'Ajouter le VERSO',
    );

    if (!mounted || source == null) {
      return;
    }

    switch (source) {
      case 'camera':
        await _captureIdentityPhoto(definition, side: side);
        break;
      case 'gallery':
        await _selectIdentityGallery(definition, side: side);
        break;
      case 'file':
        await _selectIdentityFile(definition, side: side);
        break;
    }
  }

  // ============================================================
  // PHOTO CAMÉRA IDENTITÉ
  // ============================================================

  Future<void> _captureIdentityPhoto(
      DocumentDefinition definition, {
        required String side,
      }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      var bytes = await image.readAsBytes();
      bytes = await _askAndMaybeCrop(bytes);

      _storeIdentityImage(
        bytes: bytes,
        filename: _fileNameFromXFile(image),
        mimeType: 'image/jpeg',
        side: side,
      );

      await _continueAfterIdentitySide(definition, side);
    } catch (e) {
      _showMessage("Impossible d'utiliser la caméra.", error: true);
      debugPrint('❌ Camera identity: $e');
    }
  }

  // ============================================================
  // GALERIE IDENTITÉ
  // ============================================================

  Future<void> _selectIdentityGallery(
      DocumentDefinition definition, {
        required String side,
      }) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      var bytes = await image.readAsBytes();
      bytes = await _askAndMaybeCrop(bytes);

      _storeIdentityImage(
        bytes: bytes,
        filename: _fileNameFromXFile(image),
        mimeType: _mimeTypeFromExtension(
          _extensionFromFilename(image.name),
        ),
        side: side,
      );

      await _continueAfterIdentitySide(definition, side);
    } catch (e) {
      _showMessage("Impossible d'ouvrir la galerie.", error: true);
      debugPrint('❌ Gallery identity: $e');
    }
  }

  // ============================================================
  // FICHIER IDENTITÉ
  // ============================================================

  Future<void> _selectIdentityFile(
      DocumentDefinition definition, {
        required String side,
      }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Impossible de lire le fichier.');
      }

      final extension = (file.extension ?? '').toLowerCase();

      if (extension == 'pdf') {
        _storeIdentityFile(
          bytes: bytes,
          filename: file.name,
          mimeType: 'application/pdf',
          side: side,
        );
      } else {
        var imageBytes = bytes;
        imageBytes = await _askAndMaybeCrop(imageBytes);

        _storeIdentityFile(
          bytes: imageBytes,
          filename: file.name,
          mimeType: _mimeTypeFromExtension(extension),
          side: side,
        );
      }

      await _continueAfterIdentitySide(definition, side);
    } catch (e) {
      _showMessage("Impossible d'importer le fichier.", error: true);
      debugPrint('❌ File identity: $e');
    }
  }

  // ============================================================
  // STOCKAGE TEMPORAIRE IDENTITÉ
  // ============================================================

  void _storeIdentityImage({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required String side,
  }) {
    if (side == 'recto') {
      _rectoBytes = bytes;
      _rectoFilename = filename;
      _rectoMimeType = mimeType;
    } else {
      _versoBytes = bytes;
      _versoFilename = filename;
      _versoMimeType = mimeType;
    }
  }

  void _storeIdentityFile({
    required Uint8List bytes,
    required String filename,
    required String mimeType,
    required String side,
  }) {
    _storeIdentityImage(
      bytes: bytes,
      filename: filename,
      mimeType: mimeType,
      side: side,
    );
  }

  // ============================================================
  // CONTINUER APRÈS RECTO / VERSO
  // ============================================================

  Future<void> _continueAfterIdentitySide(
      DocumentDefinition definition,
      String side,
      ) async {
    if (!mounted) return;

    if (side == 'recto' &&
        (_identityType == 'cni' || _identityType == 'permis')) {
      _showMessage(
        'RECTO enregistré. Veuillez maintenant ajouter le VERSO.',
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      await _openIdentitySource(definition, side: 'verso');
      return;
    }

    if (_identityType == 'passeport') {
      await _showReviewSheet(definition);
      return;
    }

    if (side == 'verso') {
      await _showReviewSheet(definition);
    }
  }

  // ============================================================
  // DOCUMENT SIMPLE
  // ============================================================

  Future<void> _startSimpleDocumentUpload(
      DocumentDefinition definition,
      ) async {
    final source = await _chooseSource(
      title: 'Ajouter ${definition.label}',
    );

    if (!mounted || source == null) {
      return;
    }

    switch (source) {
      case 'camera':
        await _captureSimpleDocument(definition);
        break;
      case 'gallery':
        await _selectSimpleGallery(definition);
        break;
      case 'file':
        await _selectSimpleFile(definition);
        break;
    }
  }

  Future<void> _captureSimpleDocument(DocumentDefinition definition) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 90,
      );

      if (image == null) return;

      var bytes = await image.readAsBytes();
      bytes = await _askAndMaybeCrop(bytes);

      _singleDocumentBytes = bytes;
      _singleDocumentFilename = _fileNameFromXFile(image);
      _singleDocumentMimeType = 'image/jpeg';

      await _showReviewSheet(definition);
    } catch (e) {
      _showMessage("Impossible d'utiliser la caméra.", error: true);
    }
  }

  Future<void> _selectSimpleGallery(DocumentDefinition definition) async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (image == null) return;

      var bytes = await image.readAsBytes();
      bytes = await _askAndMaybeCrop(bytes);

      _singleDocumentBytes = bytes;
      _singleDocumentFilename = _fileNameFromXFile(image);
      _singleDocumentMimeType = _mimeTypeFromExtension(
        _extensionFromFilename(image.name),
      );

      await _showReviewSheet(definition);
    } catch (e) {
      _showMessage("Impossible d'ouvrir la galerie.", error: true);
    }
  }

  Future<void> _selectSimpleFile(DocumentDefinition definition) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: false,
        withData: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'webp'],
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      final file = result.files.single;
      final bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        throw Exception('Impossible de lire le fichier.');
      }

      final extension = (file.extension ?? '').toLowerCase();

      if (extension == 'pdf') {
        _singleDocumentBytes = bytes;
        _singleDocumentFilename = file.name;
        _singleDocumentMimeType = 'application/pdf';
      } else {
        var imageBytes = bytes;
        imageBytes = await _askAndMaybeCrop(imageBytes);

        _singleDocumentBytes = imageBytes;
        _singleDocumentFilename = file.name;
        _singleDocumentMimeType = _mimeTypeFromExtension(extension);
      }

      await _showReviewSheet(definition);
    } catch (e) {
      _showMessage("Impossible d'importer le fichier.", error: true);
    }
  }

  // ============================================================
  // DEMANDER SI MODIFICATION
  // ============================================================

  Future<Uint8List> _askAndMaybeCrop(Uint8List bytes) async {
    if (!mounted) return bytes;

    final shouldEdit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            'Photo enregistrée',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Voulez-vous modifier ou rogner cette photo avant de continuer ?',
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Continuer',
                style: GoogleFonts.outfit(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                'Modifier',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (shouldEdit != true) {
      return bytes;
    }

    final cropped = await _cropImage(bytes);
    return cropped ?? bytes;
  }

  // ============================================================
  // CROP
  // ============================================================

  Future<Uint8List?> _cropImage(Uint8List bytes) async {
    try {
      final tempFile = await _writeTempImage(bytes);
      if (tempFile == null) {
        return bytes;
      }

      final croppedFile = await ImageCropper().cropImage(
        sourcePath: tempFile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 90,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Modifier la photo',
            toolbarColor: const Color(0xFF2563EB),
            toolbarWidgetColor: Colors.white,
            backgroundColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Modifier la photo'),
        ],
      );

      if (croppedFile == null) {
        return bytes;
      }

      return await croppedFile.readAsBytes();
    } catch (e) {
      debugPrint('❌ Crop image: $e');
      return bytes;
    }
  }

  Future<File?> _writeTempImage(Uint8List bytes) async {
    try {
      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/document_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      debugPrint('❌ Temp image: $e');
      return null;
    }
  }

  // ============================================================
  // REVIEW
  // ============================================================

  Future<void> _showReviewSheet(DocumentDefinition definition) async {
    if (!mounted) return;

    if (definition.identity) {
      if (_identityType == 'cni' || _identityType == 'permis') {
        if (_rectoBytes == null || _versoBytes == null) {
          _showMessage('RECTO et VERSO sont obligatoires.', error: true);
          return;
        }
      }

      if (_identityType == 'passeport' && _rectoBytes == null) {
        _showMessage(
          'La photo du passeport est obligatoire.',
          error: true,
        );
        return;
      }
    } else {
      if (_singleDocumentBytes == null) {
        return;
      }
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final hasVerso = definition.identity &&
                (_identityType == 'cni' || _identityType == 'permis');

            return Container(
              height: MediaQuery.of(context).size.height * 0.92,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 14.h, 12.w, 10.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  definition.identity
                                      ? 'Vérifiez vos photos'
                                      : 'Vérifiez votre document',
                                  style: GoogleFonts.outfit(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  'Vous pouvez encore modifier ou rogner avant l\'envoi.',
                                  style: GoogleFonts.inter(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20.w),
                        child: Column(
                          children: [
                            if (definition.identity && _rectoBytes != null)
                              _buildReviewImage(
                                title: 'RECTO',
                                bytes: _rectoBytes!,
                                mimeType: _rectoMimeType ?? 'image/jpeg',
                                onEdit: () async {
                                  await _editRecto(definition);
                                  setModalState(() {});
                                },
                                onReplace: () async {
                                  await _openIdentitySource(
                                    definition,
                                    side: 'recto',
                                  );
                                  setModalState(() {});
                                },
                              ),
                            if (hasVerso && _versoBytes != null) ...[
                              SizedBox(height: 18.h),
                              _buildReviewImage(
                                title: 'VERSO',
                                bytes: _versoBytes!,
                                mimeType: _versoMimeType ?? 'image/jpeg',
                                onEdit: () async {
                                  await _editVerso(definition);
                                  setModalState(() {});
                                },
                                onReplace: () async {
                                  await _openIdentitySource(
                                    definition,
                                    side: 'verso',
                                  );
                                  setModalState(() {});
                                },
                              ),
                            ],
                            if (!definition.identity)
                              _buildReviewImage(
                                title: 'DOCUMENT',
                                bytes: _singleDocumentBytes!,
                                mimeType: _singleDocumentMimeType ??
                                    'application/pdf',
                                onEdit: _isImageMime(_singleDocumentMimeType)
                                    ? () async {
                                  await _editSingleDocument(
                                    definition,
                                  );
                                  setModalState(() {});
                                }
                                    : null,
                                onReplace: () async {
                                  Navigator.pop(context);
                                  await _startSimpleDocumentUpload(
                                    definition,
                                  );
                                },
                              ),
                            SizedBox(height: 20.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: const Color(0xFFD1FAE5),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF059669),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Text(
                                      definition.identity && hasVerso
                                          ? 'RECTO et VERSO sont prêts. Ils seront envoyés lors de la validation.'
                                          : 'Le document est prêt. Il sera envoyé lors de la validation.',
                                      style: GoogleFonts.inter(
                                        fontSize: 12.sp,
                                        color: const Color(0xFF065F46),
                                        height: 1.45,
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
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 20.h),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52.h,
                        child: ElevatedButton(
                          onPressed: _uploading
                              ? null
                              : () async {
                            Navigator.pop(context);
                            await _sendPreparedDocuments(definition);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            definition.identity && hasVerso
                                ? 'Envoyer les 2 photos'
                                : 'Envoyer le document',
                            style: GoogleFonts.outfit(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w700,
                            ),
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
  // EDIT RECTO / VERSO / SIMPLE
  // ============================================================

  Future<void> _editRecto(DocumentDefinition definition) async {
    if (_rectoBytes == null) return;
    final cropped = await _cropImage(_rectoBytes!);
    if (cropped != null && mounted) {
      setState(() {
        _rectoBytes = cropped;
        _rectoMimeType = 'image/jpeg';
      });
    }
  }

  Future<void> _editVerso(DocumentDefinition definition) async {
    if (_versoBytes == null) return;
    final cropped = await _cropImage(_versoBytes!);
    if (cropped != null && mounted) {
      setState(() {
        _versoBytes = cropped;
        _versoMimeType = 'image/jpeg';
      });
    }
  }

  Future<void> _editSingleDocument(DocumentDefinition definition) async {
    if (_singleDocumentBytes == null) return;
    final cropped = await _cropImage(_singleDocumentBytes!);
    if (cropped != null && mounted) {
      setState(() {
        _singleDocumentBytes = cropped;
        _singleDocumentMimeType = 'image/jpeg';
      });
    }
  }

  // ============================================================
  // PREVIEW IMAGE
  // ============================================================

  Widget _buildReviewImage({
    required String title,
    required Uint8List bytes,
    required String mimeType,
    required VoidCallback? onEdit,
    required VoidCallback onReplace,
  }) {
    final isImage = _isImageMime(mimeType);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              if (onEdit != null)
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.crop_rounded, size: 16),
                  label: const Text('Modifier'),
                ),
              TextButton.icon(
                onPressed: onReplace,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Remplacer'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.memory(
                bytes,
                width: double.infinity,
                height: 220.h,
                fit: BoxFit.contain,
              ),
            )
          else
            _buildPdfPreview(),
        ],
      ),
    );
  }

  Widget _buildPdfPreview() {
    return Container(
      width: double.infinity,
      height: 180.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsBold.filePdf,
            size: 46.sp,
            color: const Color(0xFF2563EB),
          ),
          SizedBox(height: 10.h),
          Text(
            'Document PDF prêt',
            style: GoogleFonts.outfit(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }


  // ENVOI DES DOCUMENTS PRÉPARÉS
  Future<void> _sendPreparedDocuments(
      DocumentDefinition definition,
      ) async {
    if (!mounted) return;

    if (definition.identity) {
      if (_identityType == 'cni' || _identityType == 'permis') {
        if (_rectoBytes == null || _versoBytes == null) {
          _showMessage('RECTO et VERSO sont obligatoires.', error: true);
          return;
        }
      } else if (_identityType == 'passeport') {
        if (_rectoBytes == null) {
          _showMessage(
            'La photo du passeport est obligatoire.',
            error: true,
          );
          return;
        }
      }
    } else {
      if (_singleDocumentBytes == null) {
        _showMessage('Aucun document à envoyer.', error: true);
        return;
      }
    }

    if (definition.identity &&
        _identityType == 'cni' &&
        (_rectoBytes!.length > 10 * 1024 * 1024 ||
            _versoBytes!.length > 10 * 1024 * 1024)) {
      _showMessage(
        'Chaque photo doit faire moins de 10 Mo.',
        error: true,
      );
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      if (definition.identity) {
        final typeDocument = _identityType == 'permis'
            ? 'permis_conduire'
            : _identityType == 'passeport'
            ? 'passeport'
            : 'carte_identite';

        await _databaseService.uploadCurrentUserDocument(
          bytes: _rectoBytes!,
          typeDocument: typeDocument,
          nomFichier: _rectoFilename ?? 'recto.jpg',
          mimeType: _rectoMimeType ?? 'image/jpeg',
          categorie: definition.categorie,
          coteDocument: 'recto',
          obligatoire: true,
        );

        if (_identityType == 'cni' || _identityType == 'permis') {
          await _databaseService.uploadCurrentUserDocument(
            bytes: _versoBytes!,
            typeDocument: typeDocument,
            nomFichier: _versoFilename ?? 'verso.jpg',
            mimeType: _versoMimeType ?? 'image/jpeg',
            categorie: definition.categorie,
            coteDocument: 'verso',
            obligatoire: true,
          );
        }
      } else {
        await _databaseService.uploadCurrentUserDocument(
          bytes: _singleDocumentBytes!,
          typeDocument: definition.typeDocument,
          nomFichier: _singleDocumentFilename ?? 'document',
          mimeType: _singleDocumentMimeType ??
              'application/octet-stream',
          categorie: definition.categorie,
          residenceId: _selectedResidenceId,
          coteDocument: null,
          obligatoire: true,
        );
      }

      if (!mounted) return;

      _clearPreparedDocuments();

      _showMessage(
        definition.identity &&
            (_identityType == 'cni' || _identityType == 'permis')
            ? 'RECTO et VERSO envoyés pour vérification.'
            : 'Document envoyé pour vérification.',
      );

      await _loadDocuments();
    } catch (e) {
      if (!mounted) return;

      _showMessage(_extractErrorMessage(e), error: true);
      debugPrint('❌ Send prepared documents: $e');
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
        });
      }
    }
  }

  void _clearPreparedDocuments() {
    _identityType = null;

    _rectoBytes = null;
    _rectoFilename = null;
    _rectoMimeType = null;

    _versoBytes = null;
    _versoFilename = null;
    _versoMimeType = null;

    _singleDocumentBytes = null;
    _singleDocumentFilename = null;
    _singleDocumentMimeType = null;

    _selectedResidenceId = null;
  }

  // ============================================================
  // SUPPRESSION
  // ============================================================

  Future<void> _deleteDocument(OwnerDocument document) async {
    if (document.records.isEmpty) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Text(
            "Supprimer le document ?",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          content: Text(
            "Cette action supprimera le document de votre espace.",
            style: GoogleFonts.inter(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "Annuler",
                style: GoogleFonts.outfit(
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                "Supprimer",
                style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    try {
      if (document.records.length == 1) {
        final id = document.records.first['id']?.toString();

        if (id == null || id.isEmpty) {
          throw Exception("Identifiant du document introuvable.");
        }

        await _databaseService.deleteCurrentUserDocument(id);
      } else {
        final selectedId = await _chooseRecordToDelete(document.records);
        if (selectedId == null) {
          return;
        }
        await _databaseService.deleteCurrentUserDocument(selectedId);
      }

      _showMessage("Document supprimé.");
      await _loadDocuments();
    } catch (e) {
      _showMessage(_extractErrorMessage(e), error: true);
      debugPrint('❌ Delete document: $e');
    }
  }

  Future<String?> _chooseRecordToDelete(
      List<Map<String, dynamic>> records,
      ) async {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Quel fichier supprimer ?",
                  style: GoogleFonts.outfit(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16.h),
                ...records.map((record) {
                  final side = record['cote_document']?.toString();
                  final name = record['nom_fichier']?.toString() ?? 'Document';

                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      tileColor: const Color(0xFFF8FAFF),
                      leading: const Icon(
                        Icons.insert_drive_file,
                        color: Color(0xFF2563EB),
                      ),
                      title: Text(
                        side != null ? side.toUpperCase() : name,
                        style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                      ),
                      subtitle: side != null ? Text(name) : null,
                      onTap: () {
                        Navigator.pop(context, record['id']?.toString());
                      },
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // APERÇU DOCUMENT EXISTANT
  // ============================================================

  Future<void> _showPreviewDialog(OwnerDocument document) async {
    if (document.records.isEmpty) {
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          title: Row(
            children: [
              Icon(
                PhosphorIconsBold.file,
                color: const Color(0xFF2563EB),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  document.definition.label,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 360.w,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: document.records.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final record = document.records[index];
                return _buildPreviewRecord(record);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Fermer",
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2563EB),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreviewRecord(Map<String, dynamic> record) {
    final filename = record['nom_fichier']?.toString() ?? 'Document';
    final side = record['cote_document']?.toString();
    final mime = record['mime_type']?.toString().toLowerCase();
    final path = record['chemin_fichier']?.toString();

    return FutureBuilder<String?>(
      future: path == null || path.isEmpty
          ? null
          : _databaseService.getSignedUrl(
        bucketName: 'documents',
        filePath: path,
        expiresIn: 300,
      ),
      builder: (context, snapshot) {
        final url = snapshot.data;
        final isImage = mime?.startsWith('image/') == true;

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFF),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isImage ? PhosphorIconsBold.image : PhosphorIconsBold.file,
                    color: const Color(0xFF2563EB),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      side != null
                          ? "${side.toUpperCase()} — $filename"
                          : filename,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              if (snapshot.connectionState == ConnectionState.waiting)
                Container(
                  height: 180.h,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: Color(0xFF2563EB),
                  ),
                )
              else if (isImage && url != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    url,
                    width: double.infinity,
                    height: 200.h,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPreviewError();
                    },
                  ),
                )
              else
                _buildFilePreview(filename),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilePreview(String filename) {
    return Container(
      width: double.infinity,
      height: 130.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIconsBold.file,
            size: 40.sp,
            color: const Color(0xFF2563EB),
          ),
          SizedBox(height: 8.h),
          Text(
            filename,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12.sp,
              color: const Color(0xFF475569),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewError() {
    return Container(
      width: double.infinity,
      height: 130.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        "Aperçu indisponible",
        style: GoogleFonts.inter(
          fontSize: 12.sp,
          color: const Color(0xFFEF4444),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    // ============================================================
    // SKELETON LOADING
    // ============================================================
    if (_loading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            _buildSkeletonHeader(topPadding: topPadding),
            Expanded(
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                child: ShimmerLoading(
                  child: Column(
                    children: [
                      ...List.generate(6, (_) => _buildSkeletonCard()),
                      SizedBox(height: 10.h),
                      _buildSkeletonInfoBanner(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // ============================================================
    // CONTENU RÉEL
    // ============================================================
    final documents = _documents;
    final verified = _verifiedCount;
    final pending = _pendingCount;
    final missing = _missingCount;
    final total = documents.length;
    final progress = total == 0 ? 0.0 : verified / total;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Column(
            children: [
              _buildHeader(
                topPadding: topPadding,
                verified: verified,
                pending: pending,
                missing: missing,
                total: total,
                progress: progress,
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: _loadDocuments,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
                    child: Column(
                      children: [
                        _buildPersonalDocuments(),

                        SizedBox(height: 20.h),

                        Text(
                          'Documents des résidences',
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),

                        SizedBox(height: 12.h),

                        _buildAllResidenceDocuments(),
                        SizedBox(height: 10.h),
                        _buildInfoBanner(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (_selectedDocument != null)
            _buildUploadModal(_selectedDocument!),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SKELETON HEADER
  // ══════════════════════════════════════════════════════════

  Widget _buildSkeletonHeader({required double topPadding}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12.w,
        topPadding + 8.h,
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
      child: ShimmerLoading(
        baseColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SkeletonBox(
                  width: 36.w,
                  height: 36.w,
                  radius: 10,
                  color: Colors.white.withValues(alpha: 0.10),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(
                        width: 150.w,
                        height: 16.h,
                        radius: 6,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                      SizedBox(height: 6.h),
                      SkeletonBox(
                        width: 110.w,
                        height: 10.h,
                        radius: 5,
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SkeletonBox(
                        width: 130.w,
                        height: 12.h,
                        radius: 5,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      SkeletonBox(
                        width: 40.w,
                        height: 14.h,
                        radius: 5,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  SkeletonBox(
                    width: double.infinity,
                    height: 6.h,
                    radius: 3,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      _buildSkeletonHeaderStat(),
                      SizedBox(width: 16.w),
                      _buildSkeletonHeaderStat(),
                      SizedBox(width: 16.w),
                      _buildSkeletonHeaderStat(),
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

  Widget _buildSkeletonHeaderStat() {
    return Expanded(
      child: Row(
        children: [
          SkeletonBox(
            width: 8.w,
            height: 8.w,
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: SkeletonBox(
              width: double.infinity,
              height: 10.h,
              radius: 5,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SKELETON CARD DOCUMENT
  // ══════════════════════════════════════════════════════════

  Widget _buildSkeletonCard() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 46.w,
            height: 46.w,
            radius: 13,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 14.h,
                        radius: 5,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    SkeletonBox(
                      width: 60.w,
                      height: 18.h,
                      radius: 20,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                SkeletonBox(
                  width: 200.w,
                  height: 10.h,
                  radius: 5,
                ),
                SizedBox(height: 10.h),
                SkeletonBox(
                  width: double.infinity,
                  height: 22.h,
                  radius: 8,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: SkeletonBox(
                        width: double.infinity,
                        height: 36.h,
                        radius: 9,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    SkeletonBox(
                      width: 70.w,
                      height: 36.h,
                      radius: 9,
                    ),
                    SizedBox(width: 6.w),
                    SkeletonBox(
                      width: 40.w,
                      height: 36.h,
                      radius: 9,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SKELETON INFO BANNER
  // ══════════════════════════════════════════════════════════

  Widget _buildSkeletonInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 18.w,
            height: 18.w,
            radius: 4,
            color: const Color(0xFFBFDBFE),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(
                  width: double.infinity,
                  height: 10.h,
                  radius: 4,
                  color: const Color(0xFFBFDBFE),
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  width: 250.w,
                  height: 10.h,
                  radius: 4,
                  color: const Color(0xFFBFDBFE),
                ),
                SizedBox(height: 6.h),
                SkeletonBox(
                  width: 180.w,
                  height: 10.h,
                  radius: 4,
                  color: const Color(0xFFBFDBFE),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════

  Widget _buildHeader({
    required double topPadding,
    required int verified,
    required int pending,
    required int missing,
    required int total,
    required double progress,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        12.w,
        topPadding + 8.h,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => widget.onBack?.call(),
                      borderRadius: BorderRadius.circular(10.r),
                      child: Container(
                        width: 36.w,
                        height: 36.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          PhosphorIconsBold.caretLeft,
                          color: Colors.white,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Mes Documents",
                          style: GoogleFonts.outfit(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Gérez vos justificatifs",
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
              SizedBox(height: 20.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Profil documentaire",
                          style: GoogleFonts.outfit(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "$verified/$total",
                          style: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3.r),
                      child: Container(
                        height: 6.h,
                        color: Colors.white.withValues(alpha: 0.20),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF4ADE80),
                                  Color(0xFF22D3EE),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Row(
                      children: [
                        _buildHeaderStat(
                          count: verified,
                          label: "Vérifiés",
                          color: const Color(0xFF4ADE80),
                        ),
                        SizedBox(width: 16.w),
                        _buildHeaderStat(
                          count: pending,
                          label: "En cours",
                          color: const Color(0xFFFCD34D),
                        ),
                        SizedBox(width: 16.w),
                        _buildHeaderStat(
                          count: missing,
                          label: "À revoir",
                          color: const Color(0xFFF87171),
                        ),
                      ],
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

  Widget _buildHeaderStat({
    required int count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              "$count $label",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: Colors.white.withValues(alpha: 0.70),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CARD DOCUMENT
  // ══════════════════════════════════════════════════════════

  Widget _buildDocumentCard(
    OwnerDocument document, {
      String? residenceId,
    }) {
    final status = _statusConfig(document.status);

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: document.status == DocStatus.missing ||
              document.status == DocStatus.rejected ||
              document.status == DocStatus.expired
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFF1F5F9),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.w,
            height: 46.w,
            decoration: BoxDecoration(
              color: status.bg,
              borderRadius: BorderRadius.circular(13.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              document.definition.icon,
              size: 22.sp,
              color: status.color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        document.definition.label,
                        style: GoogleFonts.outfit(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: status.bg,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              status.icon,
                              color: status.color,
                              size: 11.sp,
                            ),
                            SizedBox(width: 3.w),
                            Flexible(
                              child: Text(
                                status.label,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.outfit(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: status.color,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  document.definition.sub,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
                if (document.definition.identity &&
                    document.records.isNotEmpty)
                  _buildIdentitySides(document),
                if (document.filename != null) ...[
                  SizedBox(height: 8.h),
                  _buildFileInfo(document),
                ],
                if (document.status == DocStatus.rejected &&
                    document.rejectionReason != null) ...[
                  SizedBox(height: 8.h),
                  _buildRefusalReason(document.rejectionReason!),
                ],
                SizedBox(height: 8.h),
                _buildDocumentActions(
                  document,
                  residenceId: residenceId,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdentitySides(OwnerDocument document) {
    final recto = document.records.any(
          (record) => record['cote_document'] == 'recto',
    );

    final verso = document.records.any(
          (record) => record['cote_document'] == 'verso',
    );

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: Row(
        children: [
          _buildSideChip(label: "RECTO", present: recto),
          SizedBox(width: 6.w),
          _buildSideChip(label: "VERSO", present: verso),
        ],
      ),
    );
  }

  Widget _buildSideChip({
    required String label,
    required bool present,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: present ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: present ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Text(
        present ? "✓ $label" : "$label manquant",
        style: GoogleFonts.inter(
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          color: present ? const Color(0xFF059669) : const Color(0xFF94A3B8),
        ),
      ),
    );
  }

  Widget _buildFileInfo(OwnerDocument document) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            PhosphorIconsBold.file,
            size: 13.sp,
            color: const Color(0xFF2563EB),
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              document.filename!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                color: const Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (document.date != null) ...[
            SizedBox(width: 6.w),
            Text(
              document.date!,
              style: GoogleFonts.inter(
                fontSize: 10.sp,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRefusalReason(String reason) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Text(
        "Motif : $reason",
        style: GoogleFonts.inter(
          fontSize: 10.5.sp,
          color: const Color(0xFF991B1B),
          height: 1.45,
        ),
      ),
    );
  }

  Widget _buildDocumentActions(
      OwnerDocument document, {
        String? residenceId,
      }) {
    final isMissing = document.status == DocStatus.missing;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36.h,
            child: ElevatedButton(
              onPressed: _uploading
                  ? null
                  : () async {
                if (document.definition.identity) {
                  await _startIdentityUpload(
                    document.definition,
                  );
                } else {
                  if (residenceId != null) {
                    _selectedResidenceId = residenceId;
                  } else {
                    _selectedResidenceId = null;
                  }

                  await _startSimpleDocumentUpload(
                    document.definition,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isMissing
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFEEF2FF),
                foregroundColor:
                isMissing ? Colors.white : const Color(0xFF2563EB),
                disabledBackgroundColor: const Color(0xFFE2E8F0),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              child: Text(
                isMissing
                    ? "+ Ajouter"
                    : document.status == DocStatus.rejected
                    ? "↑ Renvoyer"
                    : "↑ Remplacer",
                style: GoogleFonts.outfit(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        if (document.records.isNotEmpty) ...[
          SizedBox(width: 6.w),
          SizedBox(
            height: 36.h,
            child: OutlinedButton(
              onPressed: () => _showPreviewDialog(document),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFF),
                foregroundColor: const Color(0xFF64748B),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(PhosphorIconsBold.eye, size: 14.sp),
                  SizedBox(width: 4.w),
                  Text(
                    "Voir",
                    style: GoogleFonts.outfit(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6.w),
          SizedBox(
            width: 40.w,
            height: 36.h,
            child: IconButton(
              onPressed: () => _deleteDocument(document),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFFEF2F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9.r),
                ),
              ),
              icon: Icon(
                PhosphorIconsBold.trash,
                color: const Color(0xFFEF4444),
                size: 16.sp,
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // MODAL INITIAL UPLOAD
  // ══════════════════════════════════════════════════════════

  Widget _buildUploadModal(OwnerDocument document) {
    return Positioned.fill(
      child: Material(
        color: Colors.black.withValues(alpha: 0.50),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.90,
            ),
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Icon(
                          document.definition.icon,
                          size: 24.sp,
                          color: const Color(0xFF2563EB),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            document.definition.label,
                            style: GoogleFonts.outfit(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      document.definition.sub,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    if (document.definition.identity) ...[
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: const Color(0xFFDBEAFE)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              PhosphorIconsBold.info,
                              size: 18.sp,
                              color: const Color(0xFF2563EB),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                "CNI et permis : RECTO + VERSO. "
                                    "Passeport : une seule photo. "
                                    "Aucune photo n'est envoyée avant votre validation.",
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  color: const Color(0xFF1E3A5F),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton.icon(
                        onPressed: _uploading
                            ? null
                            : () async {
                          Navigator.pop(context);
                          if (document.definition.identity) {
                            await _startIdentityUpload(
                              document.definition,
                            );
                          } else {
                            await _startSimpleDocumentUpload(
                              document.definition,
                            );
                          }
                        },
                        icon: const Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 20,
                        ),
                        label: Text(
                          document.definition.identity
                              ? "Commencer"
                              : "Choisir le document",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _closeUploadModal,
                        child: Text(
                          "Annuler",
                          style: GoogleFonts.outfit(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // INFO
  // ══════════════════════════════════════════════════════════

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFDBEAFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            PhosphorIconsBold.info,
            size: 18.sp,
            color: const Color(0xFF2563EB),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              "Vos documents sont chiffrés et stockés "
                  "de manière sécurisée. Ils ne sont utilisés "
                  "que pour la vérification de votre identité.",
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                color: const Color(0xFF1E3A5F),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════

  bool _isImageMime(String? mime) {
    return mime != null && mime.toLowerCase().startsWith('image/');
  }

  String _extensionFromFilename(String filename) {
    final index = filename.lastIndexOf('.');
    if (index == -1) {
      return '';
    }
    return filename.substring(index + 1).toLowerCase();
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]'), '');
  }

  String _mimeTypeFromExtension(String extension) {
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }

  String _fileNameFromXFile(XFile file) {
    final name = file.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    return 'document_${DateTime.now().millisecondsSinceEpoch}.jpg';
  }

  String _extractErrorMessage(Object error) {
    final message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }
    return message;
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 12.sp),
        ),
        backgroundColor:
        error ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
// DATE FORMATTER
// ════════════════════════════════════════════════════════════

String _formatDate(String value) {
  try {
    final date = DateTime.parse(value).toLocal();

    const months = [
      'jan.',
      'fév.',
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
  } catch (_) {
    return value;
  }
}