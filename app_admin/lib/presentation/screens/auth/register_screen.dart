import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service/service_locator.dart';
import 'package:service/snackbar_service.dart';

// ============================================================
// HARMONISATION AVEC LE DASHBOARD
// ============================================================

const Color appBackgroundColor = Color(0xFF090D16);
const Color appSurfaceColor = Color(0xFF111622);
const Color appPrimary = Color(0xFFFFC107);

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// ============================================================
// REGISTER WIDGET
// ============================================================

class RegisterWidget extends StatefulWidget {
  const RegisterWidget({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterWidget> createState() => _RegisterWidgetState();
}

class _RegisterWidgetState extends State<RegisterWidget> {
  // ============================================================
  // FORMULAIRE
  // ============================================================

  final _formKey = GlobalKey<FormState>();

  String? checkboxError;

  // ============================================================
  // CONTROLEURS
  // ============================================================

  final nomController = TextEditingController();
  final prenomController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // ============================================================
  // TELEPHONE
  // ============================================================

  String? completePhoneNumber;

  // ============================================================
  // ETAT
  // ============================================================

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;
  bool checkboxValue = false;
  bool isLoading = false;

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showAppSnackBar({
    required String message,
    required SnackBarType type,
    Duration duration = const Duration(seconds: 4),
  }) {
    final snackbar = SnackBarService();

    switch (type) {
      case SnackBarType.success:
        snackbar.showSuccess(
          message,
          duration: duration,
        );
        break;

      case SnackBarType.error:
        snackbar.showError(
          message,
          duration: duration,
        );
        break;

      case SnackBarType.warning:
        snackbar.showWarning(
          message,
          duration: duration,
        );
        break;

      case SnackBarType.info:
        snackbar.showInfo(
          message,
          duration: duration,
        );
        break;
    }
  }

  // ============================================================
  // VALIDATION MOT DE PASSE ADMIN
  // ============================================================

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }

    if (value.length < 12) {
      return '12 caractères minimum';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Doit contenir une majuscule';
    }

    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Doit contenir une minuscule';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Doit contenir un chiffre';
    }

    if (!RegExp(
      r'''[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\/'`;~]''',
    ).hasMatch(value)) {
      return 'Doit contenir un caractère spécial';
    }

    return null;
  }

  // ============================================================
  // VALIDATION EMAIL
  // ============================================================

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Entrez un email';
    }

    final email = value.trim();

    final emailRegex = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Email invalide';
    }

    return null;
  }

  // ============================================================
  // VALIDATION NOM
  // ============================================================

  String? _validateName(
      String? value, {
        required String fieldName,
      }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName requis';
    }

    if (value.trim().length < 2) {
      return '$fieldName trop court';
    }

    if (value.trim().length > 100) {
      return '$fieldName trop long';
    }

    return null;
  }

  // ============================================================
  // EXTRAIRE LE MESSAGE D'ERREUR
  // ============================================================

  String _extractErrorMessage(Object error) {
    final raw = error.toString();

    final lower = raw.toLowerCase();

    // ----------------------------------------------------------
    // EMAIL DEJA UTILISE
    // ----------------------------------------------------------

    if (lower.contains('already') ||
        lower.contains('duplicate') ||
        lower.contains('already registered') ||
        lower.contains('déjà utilisé') ||
        lower.contains('deja utilise') ||
        lower.contains('email_exists')) {
      return 'Cet email est déjà utilisé.';
    }

    // ----------------------------------------------------------
    // MOT DE PASSE
    // ----------------------------------------------------------

    if (lower.contains('password') ||
        lower.contains('mot de passe')) {
      return 'Le mot de passe ne respecte pas les critères de sécurité.';
    }

    // ----------------------------------------------------------
    // AUTORISATION
    // ----------------------------------------------------------

    if (lower.contains('autorisation') ||
        lower.contains('authorization') ||
        lower.contains('forbidden') ||
        lower.contains('403')) {
      return 'Vous n’avez pas l’autorisation de créer un administrateur.';
    }

    // ----------------------------------------------------------
    // SESSION
    // ----------------------------------------------------------

    if (lower.contains('authentification') ||
        lower.contains('unauthorized') ||
        lower.contains('401') ||
        lower.contains('session')) {
      return 'Votre session administrateur est invalide. Veuillez vous reconnecter.';
    }

    // ----------------------------------------------------------
    // COMPTE INACTIF
    // ----------------------------------------------------------

    if (lower.contains('compte administrateur n\'est pas actif') ||
        lower.contains('not active')) {
      return 'Votre compte administrateur n’est pas actif.';
    }

    // ----------------------------------------------------------
    // RESEAU
    // ----------------------------------------------------------

    if (lower.contains('network') ||
        lower.contains('connection') ||
        lower.contains('timeout') ||
        lower.contains('socket')) {
      return 'Erreur réseau. Vérifiez votre connexion internet.';
    }

    // ----------------------------------------------------------
    // MESSAGE GENERIQUE
    // ----------------------------------------------------------

    return 'Impossible de créer l’administrateur. Veuillez réessayer.';
  }

  // ============================================================
  // CREATION ADMINISTRATEUR
  // ============================================================

  Future<void> _handleRegistration() async {
    // ----------------------------------------------------------
    // PROTECTION DOUBLE CLIC
    // ----------------------------------------------------------

    if (isLoading) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATION FORMULAIRE
    // ----------------------------------------------------------

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ----------------------------------------------------------
    // VALIDATION TELEPHONE
    // ----------------------------------------------------------

    if (completePhoneNumber == null ||
        completePhoneNumber!.trim().isEmpty) {
      if (mounted) {
        _showAppSnackBar(
          message: 'Veuillez entrer votre numéro de téléphone.',
          type: SnackBarType.error,
        );
      }

      return;
    }

    // ----------------------------------------------------------
    // CONDITIONS
    // ----------------------------------------------------------

    if (!checkboxValue) {
      setState(() {
        checkboxError =
        'Vous devez accepter les conditions';
      });

      return;
    }

    setState(() {
      isLoading = true;
      checkboxError = null;
    });

    try {
      // ========================================================
      // NETTOYAGE DES DONNEES
      // ========================================================

      final email = emailController.text
          .trim()
          .toLowerCase();

      final password =
          passwordController.text;

      final nom =
      nomController.text.trim();

      final prenom =
      prenomController.text.trim();

      final telephone =
      completePhoneNumber!
          .replaceAll(
        RegExp(r'[\s\-()]'),
        '',
      )
          .trim();

      // ========================================================
      // CONTROLE FINAL
      // ========================================================

      if (email.isEmpty ||
          password.isEmpty ||
          nom.isEmpty ||
          prenom.isEmpty ||
          telephone.isEmpty) {
        throw Exception(
          'Tous les champs sont obligatoires.',
        );
      }

      // ========================================================
      // AUTH SERVICE
      // ========================================================

      final authService =
          ServiceLocator.auth;

      // IMPORTANT :
      // Aucun "role: admin" n'est envoyé ici.
      //
      // La promotion en administrateur est effectuée
      // côté serveur par l'Edge Function create-admin.
      //
      await authService.createAdmin(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        telephone: telephone,
      );

      // ========================================================
      // SUCCES
      // ========================================================

      if (!mounted) {
        return;
      }

      FocusScope.of(context).unfocus();

      _showAppSnackBar(
        message:
        'Administrateur créé avec succès.',
        type: SnackBarType.success,
        duration:
        const Duration(seconds: 3),
      );

      // ========================================================
      // REDIRECTION
      // ========================================================

      await Future.delayed(
        const Duration(seconds: 3),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacementNamed(
        context,
        '/connexion',
      );
    } catch (e) {
      // ========================================================
      // ERREUR
      // ========================================================

      if (!mounted) {
        return;
      }

      debugPrint(
        'Erreur création administrateur : $e',
      );

      final errorMessage =
      _extractErrorMessage(e);

      _showAppSnackBar(
        message: errorMessage,
        type: SnackBarType.error,
        duration:
        const Duration(seconds: 5),
      );
    } finally {
      // ========================================================
      // FIN CHARGEMENT
      // ========================================================

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.manrope(
        color: Colors.white54,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        icon,
        color: appPrimary,
        size: 20,
      ),
      filled: true,
      fillColor: appBackgroundColor,
      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 18.h,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color:
          Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12.r),
        borderSide:
        const BorderSide(
          color: appPrimary,
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12.r),
        borderSide:
        const BorderSide(
          color: Color(0xFFEF4444),
          width: 1,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(12.r),
        borderSide:
        const BorderSide(
          color: Color(0xFFEF4444),
          width: 1.5,
        ),
      ),
      errorStyle:
      GoogleFonts.manrope(
        color: const Color(0xFFF87171),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor:
      appBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
            EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 24.h,
            ),
            child: Container(
              constraints:
              BoxConstraints(
                maxWidth: 920.w,
              ),
              padding:
              EdgeInsets.symmetric(
                horizontal: 28.w,
                vertical: 36.h,
              ),
              decoration:
              BoxDecoration(
                color: appSurfaceColor,
                borderRadius:
                BorderRadius.circular(
                  20.r,
                ),
                border: Border.all(
                  color: Colors.white
                      .withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset:
                    const Offset(0, 10),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    // ==================================================
                    // LOGO
                    // ==================================================

                    Container(
                      padding:
                      EdgeInsets.all(12.w),
                      decoration:
                      BoxDecoration(
                        color: appPrimary
                            .withValues(
                          alpha: 0.12,
                        ),
                        shape:
                        BoxShape.circle,
                        border: Border.all(
                          color: appPrimary
                              .withValues(
                            alpha: 0.25,
                          ),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/log.png',
                        width: 48.w,
                        height: 48.w,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (
                            context,
                            error,
                            stackTrace,
                            ) {
                          return Icon(
                            Icons
                                .apartment_rounded,
                            color:
                            appPrimary,
                            size: 32.w,
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // ==================================================
                    // TITRE
                    // ==================================================

                    Text(
                      'Créer un compte',
                      style:
                      GoogleFonts.manrope(
                        fontSize: 28,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Colors.white,
                      ),
                    ),

                    SizedBox(height: 4.h),

                    Text(
                      'Espace d’administration',
                      style:
                      GoogleFonts.manrope(
                        fontSize: 15,
                        color:
                        appPrimary,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    SizedBox(height: 28.h),

                    // ==================================================
                    // NOM / PRENOM
                    // ==================================================

                    _buildPairRow(
                      children: [
                        TextFormField(
                          controller:
                          nomController,
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          decoration:
                          _inputDecoration(
                            'Nom',
                            Icons
                                .person_outline,
                          ),
                          validator:
                              (value) =>
                              _validateName(
                                value,
                                fieldName:
                                'Nom',
                              ),
                        ),

                        TextFormField(
                          controller:
                          prenomController,
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          decoration:
                          _inputDecoration(
                            'Prénom',
                            Icons
                                .person_outline,
                          ),
                          validator:
                              (value) =>
                              _validateName(
                                value,
                                fieldName:
                                'Prénom',
                              ),
                        ),
                      ],
                    ),

                    SizedBox(height: 14.h),

                    // ==================================================
                    // EMAIL / TELEPHONE
                    // ==================================================

                    _buildPairRow(
                      children: [
                        TextFormField(
                          controller:
                          emailController,
                          keyboardType:
                          TextInputType
                              .emailAddress,
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          decoration:
                          _inputDecoration(
                            'Email',
                            Icons
                                .email_outlined,
                          ),
                          validator:
                          _validateEmail,
                        ),

                        IntlPhoneField(
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          dropdownTextStyle:
                          GoogleFonts.manrope(
                            color:
                            Colors.white70,
                          ),
                          pickerDialogStyle:
                          PickerDialogStyle(
                            backgroundColor:
                            appSurfaceColor,
                            countryCodeStyle:
                            GoogleFonts
                                .manrope(
                              color:
                              Colors.white,
                            ),
                            countryNameStyle:
                            GoogleFonts
                                .manrope(
                              color:
                              Colors.white,
                            ),
                          ),
                          decoration:
                          _inputDecoration(
                            'Téléphone',
                            Icons
                                .phone_outlined,
                          ),
                          initialCountryCode:
                          'ML',
                          onChanged:
                              (phone) {
                            if (phone
                                .completeNumber
                                .isNotEmpty) {
                              completePhoneNumber =
                                  phone
                                      .completeNumber;
                            } else if (phone
                                .number
                                .isNotEmpty) {
                              completePhoneNumber =
                                  phone.number;
                            }
                          },
                          validator:
                              (phone) {
                            if (phone ==
                                null ||
                                phone.number
                                    .isEmpty) {
                              return 'Entrez votre téléphone';
                            }

                            final cleanNumber =
                            phone.number
                                .replaceAll(
                              RegExp(
                                r'[\s\-()]',
                              ),
                              '',
                            );

                            if (cleanNumber
                                .length <
                                8) {
                              return 'Numéro invalide';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 10.h),

                    // ==================================================
                    // MOT DE PASSE
                    // ==================================================

                    _buildPairRow(
                      children: [
                        TextFormField(
                          controller:
                          passwordController,
                          obscureText:
                          !passwordVisible,
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          decoration:
                          _inputDecoration(
                            'Mot de passe',
                            Icons
                                .lock_outline,
                          ).copyWith(
                            suffixIcon:
                            IconButton(
                              icon: Icon(
                                passwordVisible
                                    ? Icons
                                    .visibility
                                    : Icons
                                    .visibility_off,
                                color:
                                Colors.white38,
                              ),
                              onPressed: () {
                                setState(() {
                                  passwordVisible =
                                  !passwordVisible;
                                });
                              },
                            ),
                          ),
                          validator:
                          _validatePassword,
                        ),

                        TextFormField(
                          controller:
                          confirmPasswordController,
                          obscureText:
                          !confirmPasswordVisible,
                          style:
                          GoogleFonts.manrope(
                            color:
                            Colors.white,
                            fontSize: 15,
                          ),
                          decoration:
                          _inputDecoration(
                            'Confirmer',
                            Icons
                                .lock_outline,
                          ).copyWith(
                            suffixIcon:
                            IconButton(
                              icon: Icon(
                                confirmPasswordVisible
                                    ? Icons
                                    .visibility
                                    : Icons
                                    .visibility_off,
                                color:
                                Colors.white38,
                              ),
                              onPressed: () {
                                setState(() {
                                  confirmPasswordVisible =
                                  !confirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                          validator:
                              (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Confirmation requise';
                            }

                            if (value !=
                                passwordController
                                    .text) {
                              return 'Ne correspond pas';
                            }

                            return null;
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: 30.h),

                    // ==================================================
                    // CONDITIONS
                    // ==================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                      children: [
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child:
                          Checkbox(
                            value:
                            checkboxValue,
                            onChanged:
                            isLoading
                                ? null
                                : (value) {
                              setState(() {
                                checkboxValue =
                                    value ??
                                        false;
                                checkboxError =
                                null;
                              });
                            },
                            activeColor:
                            appPrimary,
                            checkColor:
                            appBackgroundColor,
                            side:
                            const BorderSide(
                              color:
                              Colors.white38,
                              width: 1.5,
                            ),
                            shape:
                            RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius
                                  .circular(
                                4.r,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 10.w),

                        Expanded(
                          child: Text(
                            "J'accepte les conditions d'utilisation et la politique de confidentialité.",
                            style:
                            GoogleFonts
                                .manrope(
                              fontSize:
                              15.sp,
                              color:
                              Colors.white60,
                              letterSpacing:
                              0.6,
                            ),
                          ),
                        ),
                      ],
                    ),

                    if (checkboxError !=
                        null)
                      Align(
                        alignment:
                        Alignment.centerLeft,
                        child: Padding(
                          padding:
                          EdgeInsets.only(
                            left: 34.w,
                            top: 4.h,
                          ),
                          child: Text(
                            checkboxError!,
                            style:
                            GoogleFonts
                                .manrope(
                              color:
                              const Color(
                                0xFFF87171,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 24.h),

                    // ==================================================
                    // BOUTON
                    // ==================================================

                    SizedBox(
                      width:
                      double.infinity,
                      height: 54.h,
                      child:
                      ElevatedButton(
                        onPressed:
                        isLoading
                            ? null
                            : _handleRegistration,
                        style:
                        ElevatedButton
                            .styleFrom(
                          backgroundColor:
                          appPrimary,
                          foregroundColor:
                          appBackgroundColor,
                          disabledBackgroundColor:
                          appPrimary
                              .withValues(
                            alpha: 0.3,
                          ),
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius
                                .circular(
                              12.r,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child:
                          const CircularProgressIndicator(
                            color:
                            appBackgroundColor,
                            strokeWidth:
                            2,
                          ),
                        )
                            : Text(
                          "Créer l’administrateur",
                          style:
                          GoogleFonts
                              .manrope(
                            fontSize:
                            18,
                            fontWeight:
                            FontWeight
                                .w800,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ==================================================
                    // CONNEXION
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                      children: [
                        Text(
                          'Vous avez déjà un compte ? ',
                          style:
                          GoogleFonts
                              .manrope(
                            fontSize: 13,
                            color:
                            Colors.white54,
                          ),
                        ),

                        GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                            Navigator
                                .pushReplacementNamed(
                              context,
                              '/connexion',
                            );
                          },
                          child: Text(
                            'Connectez-vous',
                            style:
                            GoogleFonts
                                .manrope(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.bold,
                              color:
                              appPrimary,
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

  // ============================================================
  // LIGNE DE CHAMPS COTE A COTE
  // ============================================================

  Widget _buildPairRow({
    required List<Widget> children,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: children
          .map(
            (child) => Expanded(
          child: Padding(
            padding:
            EdgeInsets.symmetric(
              horizontal: 6.w,
            ),
            child: child,
          ),
        ),
      )
          .toList(),
    );
  }
}