import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/constants.dart';

class PropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onViewPhotos;

  const PropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onViewPhotos,
  });

  // ─── HELPERS ───
  String _getTitle() => property['titre'] ?? property['title'] ?? 'Titre manquant';
  String _getCity() => property['ville'] ?? property['city'] ?? 'Ville inconnue';
  String _getType() => property['type'] ?? 'Type inconnu';
  String _getPrice() {
    final prix = property['prix'] ?? property['price'] ?? 0;
    return _formatPrice(prix);
  }

  String _formatPrice(dynamic prix) {
    final number = prix is int ? prix : int.tryParse(prix.toString()) ?? 0;
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M FCFA';
    }
    return '${number.toString()} FCFA';
  }

  String _getStatus() {
    final status = property['status'] ?? 'inconnu';
    switch (status) {
      case 'en_attente':
        return 'En attente';
      case 'publie':
        return 'Publié';
      case 'refuse':
        return 'Refusé';
      default:
        return status.toString();
    }
  }

  Color _getStatusColor() {
    final status = property['status'] ?? 'inconnu';
    switch (status) {
      case 'en_attente':
        return AppColors.statusPending;
      case 'publie':
        return AppColors.statusConfirmed;
      case 'refuse':
        return AppColors.statusCancelled;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ─── Image ───
              _buildImage(),
              const SizedBox(width: 16),

              // ─── Informations ───
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getTitle(),
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getCity(),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.hotel,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getType(),
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.bed,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          property['nbre_sejour']?.toString() ?? '0',
                          style: GoogleFonts.manrope(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ─── Prix et actions ───
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _getPrice(),
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        color: AppColors.info,
                        onPressed: onEdit,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.delete, size: 18),
                        color: AppColors.error,
                        onPressed: onDelete,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final photoUrl = property['main_photo'] ?? property['photo_url'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: AppColors.primary.withValues(alpha: 0x1A),
        child: photoUrl != null && photoUrl.toString().isNotEmpty
            ? Image.network(
          photoUrl.toString(),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: const CircularProgressIndicator(
                  color: Color(0xFFFFC107),
                  strokeWidth: 2,
                ),
              ),
            );
          },
        )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: Icon(
        Icons.house,
        size: 30,
        color: AppColors.primary,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0x1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getStatus(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          color: _getStatusColor(),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}