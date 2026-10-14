import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _navigationTimer = Timer(const Duration(seconds: 60), () {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, '/onboarding');
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _goToOnboarding() {
    if (!mounted) return;

    Navigator.pushReplacementNamed(context, '/onboarding');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _goToOnboarding,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0C51EC),
                Color(0xFF5775F3),
                Color(0xFF0C51EC),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              // ==========================================================
              // CERCLE HAUT DROITE
              // ==========================================================

              Positioned(
                top: -120.h,
                right: -120.w,
                child: Container(
                  width: 320.w,
                  height: 320.w,
                  decoration: const BoxDecoration(
                    color: Color(0x2F8FADFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // CERCLE BAS GAUCHE
              Positioned(
                bottom: -160.h,
                left: -160.w,
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: const BoxDecoration(
                    color: Color(0x2F8FADFF),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // CONTENU PRINCIPAL
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // GIF
                      Container(
                        padding: EdgeInsets.all(20.r),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final screenWidth =
                                MediaQuery.of(context).size.width;

                            final imageSize = (screenWidth * 0.82)
                                .clamp(220.0, 350.0);

                            return Image.asset(
                              'assets/images/animations/proprietaire.gif',
                              width: imageSize.w,
                              height: imageSize.w,
                              fit: BoxFit.contain,
                            );
                          },
                        ),
                      ),

                      // TITRE
                      Transform.translate(
                        offset: Offset(0, -100.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // LOGO TEXTE
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'DS',
                                    style: GoogleFonts.carterOne(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'APPARTS',
                                    style: GoogleFonts.righteous(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFFFE0A3),
                                      letterSpacing: 2,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 5.h),

                            // ------------------------------------------------
                            // SOUS-TITRE
                            // ------------------------------------------------

                            Text(
                              'Publiez vos biens',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.white70,
                                fontSize: 16.sp,
                                letterSpacing: 2.w,
                              ),
                            ),

                            SizedBox(height: 15.h),

                            // ------------------------------------------------
                            // SLOGAN
                            // ------------------------------------------------

                            Text(
                              'Gérez. Louez. Développez.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            SizedBox(height: 45.h),

                            // ------------------------------------------------
                            // DOTS
                            // ------------------------------------------------

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                3,
                                    (i) {
                                  return AnimatedBuilder(
                                    animation: _controller,
                                    builder: (context, child) {
                                      double opacity =
                                          (i + 1) * 0.3 -
                                              _controller.value;

                                      opacity = opacity.clamp(0.2, 1.0);

                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                        ),
                                        width: 8.w,
                                        height: 8.w,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: opacity,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ==========================================================
              // TEXTE BAS
              // ==========================================================

              Positioned(
                bottom: 35.h,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Touchez pour continuer',
                    style: GoogleFonts.nunito(
                      color: const Color(0x80FFFFFF),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}