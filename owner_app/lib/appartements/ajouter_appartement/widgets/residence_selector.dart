import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

class ResidenceSelector extends StatelessWidget {
  final List<Map<String, dynamic>> residences;
  final String? selectedId;
  final ValueChanged<String?>? onChanged;

  const ResidenceSelector({
    super.key,
    required this.residences,
    required this.selectedId,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (residences.isEmpty) return _buildEmptyState();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          dropdownColor: const Color(0xFFF8FAFC),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF64748B),
          ),
          hint: Text(
            'Sélectionner une résidence',
            style: GoogleFonts.nunito(
              color: const Color(0xFF8A94A6),
              fontSize: 14,
            ),
          ),
          items: residences.map(_buildItem).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildItem(Map<String, dynamic> residence) {
    final String id = residence['id']?.toString() ?? '';
    final String nom = residence['nom']?.toString().trim() ?? '';
    final String ville = residence['ville']?.toString().trim() ?? '';
    final String status = residence['status']?.toString() ?? 'en_attente';

    final String titre = nom.isNotEmpty ? nom : 'Résidence sans nom';

    // 👇 UNE SEULE LIGNE
    return DropdownMenuItem<String>(
      value: id,
      child: Text(
        '$titre • $ville • ${formatResidenceStatus(status)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.inputText,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: Color(0xFFD97706),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Vous n\'avez encore aucune résidence. '
                  'Ajoutez votre première résidence pour pouvoir '
                  'y rattacher cet appartement.',
              style: GoogleFonts.nunito(
                fontSize: 13,
                color: const Color(0xFF92400E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String formatResidenceStatus(String status) {
  switch (status) {
    case 'validee':
      return 'Validée';
    case 'en_verification':
      return 'En vérification';
    case 'refusee':
      return 'Refusée';
    case 'supprimee':
      return 'Supprimée';
    case 'en_attente':
    default:
      return 'En attente';
  }
}