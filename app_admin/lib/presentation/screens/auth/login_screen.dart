import 'package:admin/presentation/screens/auth/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/logger.dart';
import 'package:service/session_timeout_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const Color appBackgroundColor = Color(0xFF090D16);
const Color appSurfaceColor = Color(0xFF111622);
const Color appPrimary = Color(0xFFFFC107);

class ConnexionWidget extends StatefulWidget {
  const ConnexionWidget({super.key});
  static const String routeName = '/connexion';

  @override
  State<ConnexionWidget> createState() => _ConnexionWidgetState();
}

class _ConnexionWidgetState extends State<ConnexionWidget> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        backgroundColor: backgroundColor,
        duration: duration,
        content: Row(
          children: [
            Icon(
              icon ?? Icons.info,
              color: Colors.white,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = 'L\'email est requis';
      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(value)) {
        _emailError = 'Veuillez entrer un email valide';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = 'Le mot de passe est requis';
      } else if (value.length < 8) {
        _passwordError = 'Minimum 8 caractères';
      } else {
        _passwordError = null;
      }
    });
  }

  Future<void> loginWithMailPassword() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(
        message: 'Veuillez corriger les erreurs dans le formulaire',
        backgroundColor: const Color(0xFFF59E0B),
        icon: Icons.warning_amber_rounded,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      logger.i("Tentative de connexion pour: $email");

      //TENTATIVE DE CONNEXION
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Délai de connexion dépassé. Vérifiez votre connexion internet.');
        },
      );

      final session = Supabase.instance.client.auth.currentSession;
      if (session == null) {
        throw Exception('Session non créée');
      }

      logger.i("Authentification réussie pour: $email");

      //VÉRIFICATION DU RÔLE
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non trouvé');
      }

      final res = await Supabase.instance.client
          .from('users')
          .select('role')
          .eq('id', currentUser.id)
          .maybeSingle();

      final role = res?['role'] as String?;
      logger.i("Rôle de l'utilisateur: $role");

      await SessionTimeoutService().resetAfterLogin();

      //VÉRIFICATION SI C'EST UN ADMIN
      if (role == 'admin' || role == 'super_admin') {
        await SessionTimeoutService().resetAfterLogin();

        _showSnackBar(
          message: 'Connexion réussie !',
          backgroundColor: const Color(0xFF10B981),
          icon: Icons.check_circle_outline,
          duration: const Duration(seconds: 2),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (mounted) {
          Navigator.pushReplacementNamed(
            context,
            '/admin-dashboard',
          );
        }
      } else {
        logger.w(
          "⛔ Accès refusé: $email n'est pas admin (rôle: $role)",
        );

        await Supabase.instance.client.auth.signOut();

        _showSnackBar(
          message: 'Accès refusé : vous n\'êtes pas administrateur.',
          backgroundColor: const Color(0xFFEF4444),
          icon: Icons.block,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      final errorMessage = _getUserFriendlyErrorMessage(e);
      logger.e("❌ Erreur de connexion: $e");

      _showSnackBar(
        message: errorMessage,
        backgroundColor: const Color(0xFFEF4444),
        icon: Icons.error_outline,
        duration: const Duration(seconds: 4),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('invalid login credentials') ||
        errorStr.contains('invalid credentials') ||
        errorStr.contains('wrong password') ||
        errorStr.contains('incorrect password') ||
        errorStr.contains('password incorrect') ||
        errorStr.contains('email not found') ||
        errorStr.contains('user not found') ||
        errorStr.contains('no user found')) {
      return 'Email ou mot de passe incorrect. Veuillez réessayer.';
    }

    if (errorStr.contains('email') &&
        (errorStr.contains('not found') ||
            errorStr.contains('invalid') ||
            errorStr.contains('incorrect') ||
            errorStr.contains('does not exist'))) {
      return 'Cet email n\'existe pas. Veuillez vérifier votre email.';
    }

    if (errorStr.contains('password') &&
        (errorStr.contains('invalid') ||
            errorStr.contains('incorrect') ||
            errorStr.contains('wrong') ||
            errorStr.contains('mismatch'))) {
      return 'Mot de passe incorrect. Veuillez réessayer.';
    }

    if (errorStr.contains('network') ||
        errorStr.contains('connection') ||
        errorStr.contains('timeout') ||
        errorStr.contains('internet') ||
        errorStr.contains('socket') ||
        errorStr.contains('failed to connect') ||
        errorStr.contains('unable to connect') ||
        errorStr.contains('host not found')) {
      return 'Problème de connexion internet. Vérifiez votre réseau.';
    }

    if (errorStr.contains('server') ||
        errorStr.contains('500') ||
        errorStr.contains('503') ||
        errorStr.contains('502') ||
        errorStr.contains('internal server') ||
        errorStr.contains('bad gateway')) {
      return 'Le serveur est temporairement indisponible. Réessayez plus tard.';
    }

    if (errorStr.contains('session') ||
        errorStr.contains('token') ||
        errorStr.contains('expired') ||
        errorStr.contains('jwt') ||
        errorStr.contains('refresh')) {
      return 'Votre session a expiré. Veuillez vous reconnecter.';
    }

    if (errorStr.contains('permission') ||
        errorStr.contains('authorization') ||
        errorStr.contains('access') ||
        errorStr.contains('forbidden') ||
        errorStr.contains('unauthorized')) {
      return 'Vous n\'avez pas les permissions nécessaires.';
    }

    if (errorStr.contains('verify') ||
        errorStr.contains('confirmation') ||
        errorStr.contains('unconfirmed') ||
        errorStr.contains('not confirmed') ||
        errorStr.contains('email not verified')) {
      return 'Veuillez vérifier votre email avant de vous connecter.';
    }

    if (errorStr.contains('too many') ||
        errorStr.contains('rate limit') ||
        errorStr.contains('try again later')) {
      return 'Trop de tentatives. Veuillez réessayer dans quelques minutes.';
    }

    return 'Une erreur est survenue. Veuillez réessayer.';
  }

  InputDecoration _inputDecoration(
      String label,
      IconData icon, {
        String? errorText,
      }) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
        color: Colors.white54,
        fontSize: 14,
      ),
      prefixIcon: Icon(icon, color: appPrimary, size: 20),
      errorText: errorText,
      errorStyle: GoogleFonts.manrope(
        fontSize: 12,
        color: Color(0xFFF87171),
      ),
      filled: true,
      fillColor: appBackgroundColor,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: appPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: appBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 550.w,
              ),
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: appSurfaceColor,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: appPrimary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: appPrimary.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/log.png',
                        width: 90.w,
                        height: 90.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.admin_panel_settings_rounded,
                            color: appPrimary,
                            size: 36.w,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Text(
                      'Connexion',
                      style: GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Espace d\'administration',
                      style: GoogleFonts.manrope(
                        fontSize: 15,
                        color: appPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),


                    SizedBox(height: 28.h),

                    // Email
                    TextFormField(
                      controller: emailController,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: _validateEmail,
                      decoration: _inputDecoration(
                        "Email",
                        Icons.email_outlined,
                        errorText: _emailError,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez un email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Entrez un email valide';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Mot de passe
                    TextFormField(
                      controller: passwordController,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                      obscureText: !passwordVisible,
                      textInputAction: TextInputAction.done,
                      onChanged: _validatePassword,
                      decoration: _inputDecoration(
                        "Mot de passe",
                        Icons.lock_outline,
                        errorText: _passwordError,
                      ).copyWith(
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white38,
                          ),
                          onPressed: () => setState(
                                () => passwordVisible = !passwordVisible,
                          ),
                        ),
                      ),
                      onFieldSubmitted: (_) => loginWithMailPassword(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Entrez votre mot de passe';
                        }
                        if (value.length < 8) {
                          return 'Mot de passe trop court (min 8 caractères)';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          _showSnackBar(
                            message: 'Fonctionnalité bientôt disponible',
                            backgroundColor: appPrimary,
                            icon: Icons.info_outline,
                            duration: const Duration(seconds: 2),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Mot de passe oublié ?',
                          style: GoogleFonts.manrope(
                            color: appPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Bouton Se connecter
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : loginWithMailPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: appPrimary,
                          foregroundColor: appBackgroundColor,
                          disabledBackgroundColor:
                          appPrimary.withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            color: appBackgroundColor,
                            strokeWidth: 2,
                          ),
                        )
                            : Text(
                          'Se connecter',
                          style: GoogleFonts.manrope(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Inscription
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Vous n'avez pas de compte ? ",
                          style: GoogleFonts.manrope(
                            fontSize: 13,
                            color: Colors.white54,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacementNamed(
                              context,
                              RegisterWidget.routeName,
                            );
                          },
                          child: Text(
                            'Inscrivez-vous',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: appPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}