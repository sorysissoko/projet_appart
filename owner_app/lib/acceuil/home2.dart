import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/animated_gradient_button.dart';

class Home2Page extends StatelessWidget {
  const Home2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              children: [
                // ==========================================================
                // ESPACE HAUT
                // ==========================================================

                SizedBox(height: 70.h),

                // ==========================================================
                // IMAGE
                // ==========================================================

                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.asset(
                    'assets/images/home1.png',
                    width: 250.w,
                    height: 150.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 250.w,
                        height: 150.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 45.sp,
                          color: const Color(0xFF64748B),
                        ),
                      );
                    },
                  ),
                ),

                SizedBox(height: 25.h),

                // ==========================================================
                // DESCRIPTION
                // ==========================================================

                Text(
                  'Donnez plus de visibilité à vos biens immobiliers. '
                      'Publiez vos logements, trouvez de nouveaux locataires '
                      'et développez votre activité en toute simplicité.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                    color: const Color(0xFF1E3A5F),
                    letterSpacing: 0.5.sp,
                  ),
                ),

                // ==========================================================
                // ESPACE
                // ==========================================================

                SizedBox(height: 80.h),

                // ==========================================================
                // CONNEXION
                // ==========================================================

                AnimatedGradientButton(
                  label: 'Connectez-vous',
                  width: 300.w,
                  height: 48.h,
                  fontSize: 18.sp,
                  backgroundColor: Colors.white,
                  textColor: const Color(0xFF2563EB),
                  borderColor: const Color(0xFFE2E8F0),
                  shadowColor: Colors.transparent,
                  onPressed: () {
                    Navigator.pushNamed(context, '/connexion');
                  },
                ),

                SizedBox(height: 18.h),

                // ==========================================================
                // DEVENIR PROPRIÉTAIRE
                // ==========================================================

                AnimatedGradientButton(
                  label: 'Devenir propriétaire',
                  width: 300.w,
                  height: 52.h,
                  fontSize: 21.sp,
                  backgroundColor: const Color(0xFF2563EB),
                  textColor: Colors.white,
                  borderColor: const Color(0xFFE2E8F0),
                  shadowColor: const Color(0x802466FF),
                  onPressed: () {
                    Navigator.pushNamed(context, '/register');
                  },
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}