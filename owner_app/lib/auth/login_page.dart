import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';
import 'package:service/auth_service_wrapper.dart';
import 'package:service/logger.dart';
import 'package:service/snackbar_service.dart';

import '../widgets/animated_gradient_button.dart';

// TYPES DE SNACKBAR
enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// PAGE DE CONNEXION
class ConnexionWidget extends StatefulWidget {
  const ConnexionWidget({super.key});

  static const String routeName = '/connexion';

  @override
  State<ConnexionWidget> createState() => _ConnexionWidgetState();
}

class _ConnexionWidgetState extends State<ConnexionWidget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  bool _showPassword = false;
  bool isLoading = false;

  final Color _accentColor = const Color(0xFF2563EB);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // SNACKBAR
  void _showAppSnackBar({
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (type == SnackBarType.success) {
      final messenger = ScaffoldMessenger.maybeOf(context);

      if (messenger == null) return;

      messenger.removeCurrentSnackBar();

      messenger.showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          duration: duration,
        ),
      );

      return;
    }

    switch (type) {
      case SnackBarType.success:
        break;

      case SnackBarType.error:
        SnackBarService().showError(
          message,
          duration: duration,
        );
        break;

      case SnackBarType.warning:
        SnackBarService().showWarning(
          message,
          duration: duration,
        );
        break;

      case SnackBarType.info:
        SnackBarService().showInfo(
          message,
          duration: duration,
        );
        break;
    }
  }

  // ERREUR
  String _getGenericErrorMessage(dynamic e) {
    final String errorString = e.toString().toLowerCase();

    if (errorString.contains('invalid credentials') ||
        errorString.contains('wrong password') ||
        errorString.contains('invalid login') ||
        errorString.contains('password')) {
      return 'Email ou mot de passe incorrect.';
    }

    if (errorString.contains('user not found') ||
        errorString.contains('user-not-found')) {
      return 'Utilisateur non trouvé.';
    }

    if (errorString.contains('network') ||
        errorString.contains('timeout') ||
        errorString.contains('connection')) {
      return 'Problème de connexion réseau.';
    }

    if (errorString.contains('too many requests')) {
      return 'Trop de tentatives. Réessayez plus tard.';
    }

    if (errorString.contains('email not confirmed')) {
      return 'Veuillez confirmer votre adresse email.';
    }

    return 'Échec de connexion. Veuillez réessayer.';
  }

  // LOGIN
  Future<void> login() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text;

      logger.i('Tentative de connexion : $email');

      final auth = AuthServiceWrapper();

      final bool success = await auth.signIn(
        email,
        password,
      );

      if (!mounted) return;

      if (!success) {
        logger.w(
          'Échec de connexion : ${auth.errorMessage}',
        );

        _showAppSnackBar(
          message: auth.errorMessage ??
              'Échec de connexion. Vérifiez vos identifiants.',
          type: SnackBarType.error,
        );

        return;
      }

      logger.i('✅ AUTHENTIFICATION RÉUSSIE');

      if (!auth.isOwner) {
        logger.w(
          'Accès Owner refusé : ${auth.currentRole}',
        );

        _showAppSnackBar(
          message:
          'Accès Owner refusé. Ce compte n’est pas autorisé '
              'dans l’application propriétaire.',
          type: SnackBarType.error,
        );

        return;
      }

      //Récupérer le profil pour connaître la certification
      final bool estCertifie = await auth.isCertified();

      _showAppSnackBar(
        message: '👋 Ravi de vous revoir',
        type: SnackBarType.success,
        duration: const Duration(seconds: 2),
      );

      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/owner-dashboard',
            (route) => false,
        arguments: {
          'showCertificationWarning': !estCertifie,
        },
      );
    } catch (e) {
      if (!mounted) return;

      logger.e('Erreur de connexion : $e');

      _showAppSnackBar(
        message: _getGenericErrorMessage(e),
        type: SnackBarType.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isLargeScreen = constraints.maxWidth >= 700;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeScreen ? 32.w : 24.w,
                vertical: 16.h,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 520,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: isLargeScreen ? 35.h : 20.h),
                      _buildTitleSection(),
                      SizedBox(height: isLargeScreen ? 45.h : 32.h),
                      _buildForm(),
                      SizedBox(height: isLargeScreen ? 45.h : 35.h),
                      _buildGoogleButton(),
                      SizedBox(height: 20.h),
                      _buildRegisterLink(),
                      SizedBox(height: 30.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: isLoading
              ? null
              : () => Navigator.pop(context),
          child: Container(
            width: 42.w,
            height: 42.w,
            decoration: const BoxDecoration(
              color: Color(0xFFE0E7FF),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              size: 23.sp,
              color: _accentColor,
            ),
          ),
        ),
      ],
    );
  }

  // TITRE
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '👋 Bonjour !',
          style: GoogleFonts.nunito(
            fontSize: 28.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Ravi de vous revoir ! Connectez-vous.',
          style: GoogleFonts.nunito(
            fontSize: 15.sp,
            color: const Color(0xFF1E3A5F),
          ),
        ),
      ],
    );
  }

  // FORM
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEmailField(),
          SizedBox(height: 20.h),
          _buildPasswordField(),
          SizedBox(height: 12.h),
          _buildForgotPasswordLink(),
          SizedBox(height: 30.h),
          _buildLoginButton(),
          SizedBox(height: 40.h),
          _buildDivider(),
        ],
      ),
    );
  }

  // EMAIL
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('ADRESSE EMAIL'),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _emailController,
          enabled: !isLoading,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [
            AutofillHints.email,
          ],
          style: GoogleFonts.nunito(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hintText: 'votre@email.com',
            icon: Icons.email_outlined,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Veuillez entrer votre email';
            }

            final emailRegex = RegExp(
              r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
            );

            if (!emailRegex.hasMatch(value.trim())) {
              return 'Email invalide';
            }

            return null;
          },
        ),
      ],
    );
  }

  // PASSWORD
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel('MOT DE PASSE'),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _passwordController,
          enabled: !isLoading,
          obscureText: !_showPassword,
          textInputAction: TextInputAction.done,
          autofillHints: const [
            AutofillHints.password,
          ],
          onFieldSubmitted: (_) {
            if (!isLoading) {
              login();
            }
          },
          style: GoogleFonts.nunito(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF0F172A),
          ),
          decoration: _inputDecoration(
            hintText: '••••••••',
            icon: Icons.lock_outline,
            suffixIcon: IconButton(
              tooltip: _showPassword
                  ? 'Masquer le mot de passe'
                  : 'Afficher le mot de passe',
              icon: Icon(
                _showPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 19.sp,
                color: _accentColor,
              ),
              onPressed: isLoading
                  ? null
                  : () {
                setState(() {
                  _showPassword = !_showPassword;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Veuillez entrer votre mot de passe';
            }

            if (value.length < 6) {
              return 'Mot de passe trop court';
            }

            return null;
          },
        ),
      ],
    );
  }

  // LABEL
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  // DECORATION
  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 19.sp,
        color: _accentColor,
      ),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle: GoogleFonts.nunito(
        fontSize: 14.sp,
        color: const Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xB3FFFFFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(
          color: Color(0x350000FF),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: BorderSide(
          color: _accentColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16.r),
        borderSide: const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      errorStyle: GoogleFonts.nunito(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: Colors.redAccent,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 15.h,
      ),
    );
  }

  // FORGOT
  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: isLoading
            ? null
            : () {
          _showAppSnackBar(
            message: 'Fonctionnalité à venir',
            type: SnackBarType.info,
          );
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize:
          MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          'Mot de passe oublié ?',
          style: GoogleFonts.nunito(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: _accentColor,
          ),
        ),
      ),
    );
  }

  // DIVIDER
  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color(0xFFD3D6DD),
            thickness: 0.7,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
          ),
          child: Text(
            'ou',
            style: GoogleFonts.nunito(
              fontSize: 12,
              color: const Color(0xFFBCBFC8),
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color(0xFFD3D6DD),
            thickness: 0.7,
          ),
        ),
      ],
    );
  }

  // LOGIN BUTTON
  Widget _buildLoginButton() {
    return AnimatedGradientButton(
      label: isLoading ? '' : 'Se connecter',
      width: double.infinity,
      height: 50.h,
      fontSize: 20,
      backgroundColor: _accentColor,
      textColor: Colors.white,
      borderColor: Colors.transparent,
      shadowColor: _accentColor,
      leading: isLoading
          ? SizedBox(
        width: 24.w,
        height: 24.w,
        child: const CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : null,
      onPressed: isLoading ? () {} : login,
    );
  }

  // GOOGLE
  Widget _buildGoogleButton() {
    return AnimatedGradientButton(
      label: 'Continuer avec Google',
      width: double.infinity,
      height: 44.h,
      fontSize: 15,
      backgroundColor: Colors.white,
      textColor: _accentColor,
      borderColor: const Color(0xFFE2E8F0),
      shadowColor: Colors.transparent,
      leading: SizedBox(
        width: 20.w,
        height: 20.w,
        child: Image.asset(
          'assets/images/google_logo.svg.png',
          fit: BoxFit.contain,
          errorBuilder: (
              context,
              error,
              stackTrace,
              ) {
            return const Icon(
              Icons.g_mobiledata_rounded,
              color: Colors.red,
            );
          },
        ),
      ),
      onPressed: isLoading
          ? () {}
          : () {
        _showAppSnackBar(
          message: 'Fonctionnalité à venir',
          type: SnackBarType.info,
        );
      },
    );
  }

  // REGISTER
  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Pas encore de compte ? ',
            style: GoogleFonts.nunito(
              fontSize: 14.sp,
              color: const Color(0xFF1E3A5F),
            ),
          ),
        ),
        GestureDetector(
          onTap: isLoading
              ? null
              : () {
            Navigator.pushReplacementNamed(
              context,
              '/register',
            );
          },
          child: Text(
            'Inscrivez-vous',
            style: GoogleFonts.nunito(
              fontSize: 15.sp,
              fontWeight: FontWeight.w900,
              color: _accentColor,
            ),
          ),
        ),
      ],
    );
  }

}
