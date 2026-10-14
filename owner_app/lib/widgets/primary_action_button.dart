import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const PrimaryActionButton({super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  State<PrimaryActionButton> createState() => PrimaryActionButtonState();
}

class PrimaryActionButtonState extends State<PrimaryActionButton>
    with TickerProviderStateMixin {
  late AnimationController _pressController;
  late AnimationController _pulseController;
  late AnimationController _shimmerController;

  late Animation<double> _scalePressAnimation;
  late Animation<double> _glowPulseAnimation;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Animation au Clic (Pression)
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scalePressAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );

    // 2. Animation de Pulsation de l'ombre (Glow)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _glowPulseAnimation = Tween<double>(begin: 0.3, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 3. Animation du passage du reflet lumineux sur le texte
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _shimmerAnimation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    _pulseController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  // --- Gestionnaires de clics corrigés ---
  void _onTapDown(TapDownDetails details) => _pressController.forward();

  void _onTapUp(TapUpDetails details) {
    _pressController.reverse();
    widget.onTap();
  }

  void _onTapCancel() => _pressController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scalePressAnimation,
          _glowPulseAnimation,
          _shimmerAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scalePressAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(40),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xB22563EB)
                        .withValues(alpha: _glowPulseAnimation.value),
                    blurRadius: 2,
                    spreadRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 55,
                  vertical: 17,
                ),
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    final double val = _shimmerAnimation.value;
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: const [
                        Colors.white,
                        Colors.white,
                        Color(0xFFFFEEAA), // Éclat doré sur le texte
                        Colors.white,
                        Colors.white,
                      ],
                      stops: [
                        (val - 0.4).clamp(0.0, 1.0),
                        (val - 0.1).clamp(0.0, 1.0),
                        val.clamp(0.0, 1.0),
                        (val + 0.1).clamp(0.0, 1.0),
                        (val + 0.4).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcIn,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(widget.icon, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}