import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;

  final double? fontSize;
  final IconData? icon;
  final double? width;
  final double? height;

  /// Widget placé avant le texte.
  final Widget? leading;

  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final Color shadowColor;

  final bool enabled;

  const AnimatedGradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.fontSize,
    this.icon,
    this.width,
    this.height,
    this.leading,
    this.backgroundColor = const Color(0xFF2563EB),
    this.textColor = Colors.white,
    this.borderColor = const Color(0xFFE2E8F0),
    this.shadowColor = const Color(0x802466FF),
    this.enabled = true,
  });

  @override
  State<AnimatedGradientButton> createState() =>
      _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState
    extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (!widget.enabled) return;

    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (!widget.enabled) return;

    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    if (!widget.enabled) return;

    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool disabled = !widget.enabled;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: disabled ? null : _onTapDown,
      onTapUp: disabled ? null : _onTapUp,
      onTapCancel: disabled ? null : _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: disabled ? 0.55 : 1.0,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: EdgeInsets.symmetric(
              horizontal: 22.w,
            ),
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(40.r),
              border: Border.all(
                color: widget.borderColor,
                width: 1,
              ),
              boxShadow: widget.shadowColor == Colors.transparent
                  ? null
                  : [
                BoxShadow(
                  color: widget.shadowColor.withValues(
                    alpha: 0.30,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.leading != null) ...[
                  widget.leading!,
                  if (widget.label.isNotEmpty)
                    SizedBox(width: 10.w),
                ],

                if (widget.label.isNotEmpty)
                  Flexible(
                    child: Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        color: widget.textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: (widget.fontSize ?? 17).sp,
                      ),
                    ),
                  ),

                if (widget.icon != null) ...[
                  SizedBox(width: 8.w),
                  Icon(
                    widget.icon,
                    color: widget.textColor,
                    size: 18.sp,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}