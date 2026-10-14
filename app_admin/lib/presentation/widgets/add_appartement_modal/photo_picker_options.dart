import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PhotoPickerOptions extends StatelessWidget {
  final VoidCallback onGalleryTap;
  final VoidCallback onCameraTap;

  const PhotoPickerOptions({
    Key? key,
    required this.onGalleryTap,
    required this.onCameraTap,
  }) : super(key: key);

  static const Color _amberColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajouter des photos',
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildPhotoOption(
                  icon: Icons.photo_library,
                  label: 'Galerie',
                  onTap: () {
                    Navigator.pop(context);
                    onGalleryTap();
                  },
                ),
                _buildPhotoOption(
                  icon: Icons.camera_alt,
                  label: 'Appareil photo',
                  onTap: () {
                    Navigator.pop(context);
                    onCameraTap();
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: _amberColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _amberColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: _amberColor, size: 32.sp),
            SizedBox(height: 8.h),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}