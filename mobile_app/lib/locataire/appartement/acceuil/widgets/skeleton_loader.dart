import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SkeletonLoader extends StatefulWidget {
  final double width;

  const SkeletonLoader({
    super.key,
    required this.width,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Opacity(
          opacity: _animation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //FILTRES (barres ville + recherche)
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                child: Row(
                  children: [
                    _buildSkeletonBox(width: 100.w, height: 40.h, radius: 20.r),
                    SizedBox(width: 10.w),
                    _buildSkeletonBox(width: 100.w, height: 40.h, radius: 20.r),
                    SizedBox(width: 10.w),
                    _buildSkeletonBox(width: 100.w, height: 40.h, radius: 20.r),
                  ],
                ),
              ),

              //SECTION NOUVEAUTÉS
              _buildSectionTitle(),
              SizedBox(height: 10.h),

              // Carrousel horizontal
              SizedBox(
                height: 260.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: _buildCardSkeleton(width: 220.w, height: 260.h),
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),

              //SECTION POPULAIRES
              _buildSectionTitle(),
              SizedBox(height: 10.h),

              SizedBox(
                height: 260.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: _buildCardSkeleton(width: 220.w, height: 260.h),
                    );
                  },
                ),
              ),

              SizedBox(height: 24.h),

              //SECTION RECOMMANDATIONS
              _buildSectionTitle(),
              SizedBox(height: 10.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: List.generate(
                    3,
                        (index) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildCardSkeleton(
                        width: double.infinity,
                        height: 120.h,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TITRE DE SECTION
  Widget _buildSectionTitle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: _buildSkeletonBox(
        width: 180.w,
        height: 24.h,
        radius: 8.r,
      ),
    );
  }

  // CARTE SKELETON
  Widget _buildCardSkeleton({
    required double width,
    required double height,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          _buildSkeletonBox(
            width: double.infinity,
            height: height * 0.55,
            radius: 15.r,
          ),

          Padding(
            padding: EdgeInsets.all(10.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                _buildSkeletonBox(
                  width: width * 0.7,
                  height: 14.h,
                  radius: 4.r,
                ),
                SizedBox(height: 8.h),

                // Lieu
                _buildSkeletonBox(
                  width: width * 0.5,
                  height: 12.h,
                  radius: 4.r,
                ),
                SizedBox(height: 12.h),

                // Prix
                _buildSkeletonBox(
                  width: width * 0.4,
                  height: 16.h,
                  radius: 4.r,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // BOÎTE GRISE DE BASE
  Widget _buildSkeletonBox({
    required double width,
    required double height,
    double? radius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE8D5C4),
        borderRadius: BorderRadius.circular(radius ?? 6.r),
      ),
    );
  }
}