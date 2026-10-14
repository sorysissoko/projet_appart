import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

/// Section de sélection de photos.
///
/// Ne connaît PAS le controller : elle reçoit la liste et des callbacks.
class PhotoPickerSection extends StatelessWidget {
  final List<XFile> images;
  final bool isSaving;
  final VoidCallback onPick;
  final ValueChanged<int> onRemove;
  final VoidCallback onClear;

  const PhotoPickerSection({
    super.key,
    required this.images,
    required this.isSaving,
    required this.onPick,
    required this.onRemove,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Photos du bien',
          style: GoogleFonts.nunito(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F1B2D),
          ),
        ),
        const SizedBox(height: 8),
        if (images.isEmpty) _buildEmptyState() else _buildSelectedPhotos(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Aucune photo sélectionnée',
            style: GoogleFonts.nunito(
              color: Colors.grey[600],
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: isSaving ? null : onPick,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Sélectionner des photos'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B3A6B),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: images.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: FileImage(File(images[index].path)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => onRemove(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onPick,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Ajouter'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isSaving ? null : onClear,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Tout supprimer'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFEF4444)),
                  foregroundColor: const Color(0xFFEF4444),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${images.length} photo(s) sélectionnée(s)',
          style: GoogleFonts.nunito(
            fontSize: 12,
            color: const Color(0xFF8A94A6),
          ),
        ),
      ],
    );
  }
}