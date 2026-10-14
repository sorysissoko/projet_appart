import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../widgets/animated_gradient_button.dart';
import '../widgets/primary_action_button.dart';

// Définition de la classe Slide si elle n'est pas déjà dans un fichier externe
class OnboardingSlide {
  final String title;
  final String description;
  final String subtitle;
  final String imageAsset;
  final IconData icon;

  OnboardingSlide({
    required this.title,
    required this.description,
    required this.subtitle,
    required this.imageAsset,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int current = 0;
  final PageController _pageController = PageController();

  final List<OnboardingSlide> slides = [
    OnboardingSlide(
      imageAsset: 'assets/images/animations/publie.gif',
      icon: LucideIcons.home,
      title: 'Publiez',
      subtitle: 'Vos biens en quelques clics',
      description:
      'Mettez vos logements en valeur avec des photos, des descriptions '
          'et toutes les informations nécessaires pour attirer vos futurs locataires.',
    ),

    OnboardingSlide(
      imageAsset: 'assets/images/animations/choisir.gif',
      icon: LucideIcons.users,
      title: 'Trouvez',
      subtitle: 'De nouveaux locataires',
      description:
      'Augmentez la visibilité de vos biens et connectez-vous facilement '
          'avec des personnes à la recherche d’un logement au Mali.',
    ),

    OnboardingSlide(
      imageAsset: 'assets/images/animations/gere.gif',
      icon: LucideIcons.barChart3,
      title: 'Développez',
      subtitle: 'Votre activité immobilière',
      description:
      'Centralisez vos locations, suivez vos réservations et développez '
          'vos revenus grâce à une gestion simple et efficace.',
    ),
  ];


  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void next() {
    if (current < slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void goBack() {
    if (current > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = slides[current];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header avec Ignorer à gauche et indicateurs au centre
            Padding(
              padding: const EdgeInsets.only(left: 24, right: 24, top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/home2');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Ignorer',
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      slides.length,
                          (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == current ? 24 : 8,
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: i == current
                              ? const Color(0xFF0000FF)
                              : const Color(0x1D0000FF),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            // Zone image
            Expanded(
              flex: 2,
              child: Center(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      current = index;
                    });
                  },
                  children: slides.map((s) {
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final imageSize =
                        (constraints.maxHeight * 0.65).clamp(160.0, 280.0);

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: imageSize,
                              height: imageSize,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.asset(
                                  s.imageAsset,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(
                                      s.icon,
                                      size: 80,
                                      color: const Color(0xFF0000FF).withValues(alpha: 0.5),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0x1D0000FF),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    s.icon,
                                    size: 16,
                                    color: const Color(0xFF0000FF),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    s.subtitle,
                                    style: GoogleFonts.nunito(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2563EB),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ),

            // Zone texte et boutons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 1200),

                    layoutBuilder: (currentChild, previousChildren) {
                      return ClipRect(
                        child: currentChild ??
                            const SizedBox.shrink(),
                      );
                    },

                    transitionBuilder: (child, animation) {
                      final slide = Tween<Offset>(
                        begin: const Offset(0, 0.35),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        ),
                      );

                      return ClipRect(
                        child: FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: slide,
                            child: child,
                          ),
                        ),
                      );
                    },

                    child: Column(
                      key: ValueKey(current),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          slide.title,
                          style: GoogleFonts.nunito(
                            fontSize: 35,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          slide.description,
                          style: GoogleFonts.nunito(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            height: 1.7,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Zone des boutons animée
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: current == slides.length - 1
                    //DERNIÈRE PAGE BOUTON COMMENCER
                        ? Center(
                      key: const ValueKey("start_button"),
                        child: PrimaryActionButton(
                          label: "Commencer",
                          icon: LucideIcons.play,
                          onTap: () {
                            Navigator.pushReplacementNamed(context, "/home2");
                          },
                        )
                    )
                    //AUTRES PAGES BOUTON SUIVANT RETOUR
                        : Row(
                      key: const ValueKey("navigation"),
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (current > 0)
                          TextButton(
                            onPressed: goBack,
                            child: Text(
                              "Retour",
                              style: GoogleFonts.nunito(
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 60),

                        AnimatedGradientButton(
                          height: 65,
                          label: "Suivant",
                          icon: LucideIcons.arrowRight,
                          onPressed: next,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

