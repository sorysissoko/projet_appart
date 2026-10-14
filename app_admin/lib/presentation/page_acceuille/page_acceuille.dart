import 'package:admin/presentation/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screens/auth/register_screen.dart';

class Home1Page extends StatelessWidget {
  const Home1Page({super.key});

  //CONSTANTES DE THÈME DASHBOARD
  static const Color _backgroundColor = Color(0xFF090D16);
  static const Color _surfaceColor = Color(0xFF111622);
  static const Color _primaryColor = Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 520.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: _surfaceColor,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(4.w),
                    decoration: BoxDecoration(
                      color: _primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: _primaryColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: Image.asset(
                        'assets/images/mali.png',
                        width: 140.w,
                        height: 140.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 140.w,
                            height: 140.w,
                            decoration: BoxDecoration(
                              color: _primaryColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.apartment_rounded,
                              color: _primaryColor,
                              size: 50.w,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ─── TITRES ───
                  Text(
                    "Bienvenue !",
                    style: GoogleFonts.sahitya(
                      fontSize: 40.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),

                  Text(
                    "Panel de l'admin",
                    style: GoogleFonts.sahitya(
                      fontSize: 26.sp,
                      color: _primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 36.h),

                  //BOUTON SE CONNECTER
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          ConnexionWidget.routeName,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor,
                        foregroundColor: _backgroundColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Se connecter',
                        style: GoogleFonts.manrope(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Text(
                    "si vous avez déjà un compte",
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      color: Colors.white38,
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // ─── SÉPARATEUR OU ───
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          color: Colors.white10,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          "Ou",
                          style: GoogleFonts.manrope(
                            fontSize: 13.sp,
                            color: Colors.white38,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          color: Colors.white10,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),

                  // ─── BOUTON CRÉER UN COMPTE ───
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          RegisterWidget.routeName,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        "Créer un compte",
                        style: GoogleFonts.manrope(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),

                  Text(
                    "si vous n'avez pas encore de compte",
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}