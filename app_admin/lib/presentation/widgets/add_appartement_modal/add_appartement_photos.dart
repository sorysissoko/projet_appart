import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'photo_picker_options.dart';

class AddAppartementPhotos extends StatefulWidget {
  final List<XFile> selectedImages;
  final VoidCallback onAddImages;
  final VoidCallback onClearAll;
  final Function(int) onRemoveImage;

  final void Function(int oldIndex, int newIndex) onReorder;

  const AddAppartementPhotos({
    super.key,
    required this.selectedImages,
    required this.onAddImages,
    required this.onClearAll,
    required this.onRemoveImage,
    required this.onReorder,
  });

  @override
  State<AddAppartementPhotos> createState() => _AddAppartementPhotosState();
}

class _AddAppartementPhotosState extends State<AddAppartementPhotos> {
  static const Color _amberColor = Color(0xFFFFC107);

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111622),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => PhotoPickerOptions(
        onGalleryTap: widget.onAddImages,
        onCameraTap: widget.onAddImages,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '📸 Photos (${widget.selectedImages.length})',
              style: GoogleFonts.manrope(
                fontSize: 22.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            Row(
              children: [
                if (widget.selectedImages.isNotEmpty)
                  TextButton.icon(
                    onPressed: widget.onClearAll,
                    icon: Icon(Icons.delete_sweep, color: Colors.red, size: 18.sp),
                    label: Text(
                      'Tout supprimer',
                      style: GoogleFonts.manrope(color: Colors.red, fontSize: 12.sp),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: _showImagePickerOptions,
                  icon: Icon(Icons.add_a_photo, size: 20.sp),
                  label: Text(
                    'Ajouter',
                    style: GoogleFonts.manrope(fontSize: 15.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _amberColor,
                    foregroundColor: const Color(0xFF090D16),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (widget.selectedImages.isEmpty)
          _buildEmptyState()
        else
          _buildImageList(),
        SizedBox(height: 8.h),
        if (widget.selectedImages.isNotEmpty)
          Text(
            'La première photo sera utilisée comme photo principale',
            style: GoogleFonts.manrope(
              color: Colors.white38,
              fontSize: 11.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 100.h,
      decoration: BoxDecoration(
        color: const Color(0xFF111622),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white10, style: BorderStyle.solid),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 32.sp,
              color: Colors.white38,
            ),
            SizedBox(height: 8.h),
            Text(
              'Ajoutez des photos de votre bien',
              style: GoogleFonts.manrope(
                color: Colors.white38,
                fontSize: 14.sp,
              ),
            ),
            Text(
              'Cliquez sur "Ajouter" pour sélectionner',
              style: GoogleFonts.manrope(
                color: Colors.white24,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageList() {
    return SizedBox(
      height: 120.h,
      child: ReorderableListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.selectedImages.length,

        onReorder: widget.onReorder,

        itemBuilder: (context, index) {
          final image = widget.selectedImages[index];

          return Container(
            key: ValueKey(image.path),

            margin: EdgeInsets.only(right: 10.w),
            width: 120.w,
            height: 120.h,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.white10),
            ),

            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: FutureBuilder<Uint8List>(
                    future: image.readAsBytes(),
                    builder: (context, snapshot) {

                      if (!snapshot.hasData) {
                        return const Center(
                          child: const CircularProgressIndicator(
                            color: Color(0xFFFFC107),
                            strokeWidth: 2,
                          ),
                        );
                      }

                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),

                Positioned(
                  top: 8.h,
                  left: 8.w,
                  child: Container(
                    padding: EdgeInsets.all(5.w),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 8.h,
                  right: 8.w,
                  child: InkWell(
                    onTap: () => widget.onRemoveImage(index),
                    child: CircleAvatar(
                      radius: 12.r,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        Icons.close,
                        size: 15.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                if(index == 0)
                  Positioned(
                    bottom: 8.h,
                    left: 8.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _amberColor,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        "Principale",
                        style: GoogleFonts.manrope(
                          color: Colors.black,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}