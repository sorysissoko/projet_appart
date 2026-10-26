import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:service/auth_service_wrapper.dart';
import 'package:service/logger.dart';
import 'package:service/snackbar_service.dart';

import '../widgets/animated_gradient_button.dart';

// ============================================================
// TYPES DE SNACKBAR
// ============================================================

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

// ============================================================
// CONFIGURATION CHAMPS
// ============================================================

class FieldConfig {
  final String id;
  final String label;
  final String placeholder;
  final IconData icon;

  const FieldConfig({
    required this.id,
    required this.label,
    required this.placeholder,
    required this.icon,
  });
}

// ============================================================
// REGISTER
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  static const String routeName = '/register';

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _step1FormKey =
  GlobalKey<FormState>();

  final GlobalKey<FormState> _step2FormKey =
  GlobalKey<FormState>();

  final GlobalKey<FormState> _step3FormKey =
  GlobalKey<FormState>();

  final TextEditingController nomController =
  TextEditingController();

  final TextEditingController prenomController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController villeController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  // ============================================================
  // COULEURS
  // ============================================================

  static const Color accentColor =
  Color(0xFF2563EB);

  static const Color backgroundColor =
  Color(0xFFF8FAFF);

  static const Color textColor =
  Color(0xFF0F172A);

  static const Color secondaryTextColor =
  Color(0xFF1E3A5F);

  static const Color borderColor =
  Color(0x350000FF);

  // ============================================================
  // ETAT
  // ============================================================

  DateTime? selectedDate;

  String? completePhoneNumber;
  String? countryCode;

  bool passwordVisible = false;
  bool confirmPasswordVisible = false;

  bool checkboxValue = false;
  String? checkboxError;

  bool isLoading = false;

  int currentStep = 0;

  static const int totalSteps = 3;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    villeController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _pageController.dispose();

    super.dispose();
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showAppSnackBar({
    required String message,
    required SnackBarType type,
    Duration duration =
    const Duration(seconds: 4),
  }) {
    switch (type) {
      case SnackBarType.success:
        SnackBarService().showSuccess(
          message,
          duration: duration,
        );
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

  // ============================================================
  // AGE
  // ============================================================

  bool _isAtLeast19YearsOld(
      DateTime birthDate,
      ) {
    final DateTime now = DateTime.now();

    int age =
        now.year - birthDate.year;

    final bool birthdayNotReached =
        now.month < birthDate.month ||
            (now.month == birthDate.month &&
                now.day < birthDate.day);

    if (birthdayNotReached) {
      age--;
    }

    return age >= 19;
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate(
      BuildContext context,
      ) async {
    final DateTime now = DateTime.now();

    final DateTime maximumDate = DateTime(
      now.year - 19,
      now.month,
      now.day,
    );

    final DateTime initialDate = DateTime(
      now.year - 25,
      now.month,
      now.day,
    );

    final DateTime? picked =
    await showDatePicker(
      context: context,
      locale: const Locale('fr', 'FR'),
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: maximumDate,
      helpText: 'DATE DE NAISSANCE',
      cancelText: 'ANNULER',
      confirmText: 'VALIDER',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme:
            const ColorScheme.light(
              primary: accentColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: textColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    if (!_isAtLeast19YearsOld(picked)) {
      _showAppSnackBar(
        message:
        '⚠️ Vous devez avoir au moins 19 ans.',
        type: SnackBarType.warning,
      );
      return;
    }

    setState(() {
      selectedDate = picked;
    });
  }

  // ============================================================
  // VALIDATION
  // ============================================================

  bool _validateCurrentStep() {
    switch (currentStep) {
      case 0:
        return _step1FormKey.currentState
            ?.validate() ??
            false;

      case 1:
        final bool valid =
            _step2FormKey.currentState
                ?.validate() ??
                false;

        if (!valid) return false;

        if (selectedDate == null) {
          _showAppSnackBar(
            message:
            '📅 Veuillez sélectionner votre date de naissance.',
            type: SnackBarType.error,
          );
          return false;
        }

        if (!_isAtLeast19YearsOld(
          selectedDate!,
        )) {
          _showAppSnackBar(
            message:
            '⚠️ Vous devez avoir au moins 19 ans.',
            type: SnackBarType.warning,
          );
          return false;
        }

        if (completePhoneNumber ==
            null ||
            completePhoneNumber!
                .trim()
                .isEmpty) {
          _showAppSnackBar(
            message:
            '📱 Veuillez entrer votre numéro.',
            type: SnackBarType.error,
          );
          return false;
        }

        return true;

      case 2:
        final bool valid =
            _step3FormKey.currentState
                ?.validate() ??
                false;

        if (!valid) return false;

        if (!checkboxValue) {
          setState(() {
            checkboxError =
            'Vous devez accepter les conditions.';
          });

          _showAppSnackBar(
            message:
            'Veuillez accepter les conditions.',
            type: SnackBarType.warning,
          );

          return false;
        }

        return true;

      default:
        return false;
    }
  }

  // ============================================================
  // NEXT
  // ============================================================

  Future<void> _goToNextStep() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    if (currentStep ==
        totalSteps - 1) {
      await _register();
      return;
    }

    setState(() {
      currentStep++;
    });

    await _pageController.nextPage(
      duration:
      const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // PREVIOUS
  // ============================================================

  Future<void> _goToPreviousStep() async {
    if (isLoading || currentStep == 0) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      currentStep--;
    });

    await _pageController.previousPage(
      duration:
      const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    if (!_validateCurrentStep()) {
      return;
    }

    setState(() {
      isLoading = true;
      checkboxError = null;
    });

    try {
      final String nom =
      nomController.text.trim();

      final String prenom =
      prenomController.text.trim();

      final String email =
      emailController.text.trim();

      final String password =
          passwordController.text;

      final String ville =
      villeController.text.trim();

      final String dateNaissance =
          selectedDate!
              .toIso8601String()
              .split('T')
              .first;

      logger.i(
        '🚀 DÉBUT INSCRIPTION',
      );

      final auth =
      AuthServiceWrapper();

      final bool success =
      await auth.signUpOwner(
        email: email,
        password: password,
        nom: nom,
        prenom: prenom,
        telephone:
        completePhoneNumber!,
        adresse: '',
        ville: ville,
        dateNaissance:
        dateNaissance,
      );

      if (!mounted) return;

      if (success) {
        _showAppSnackBar(
          message: '🎉 Bienvenue $prenom $nom !',
          type: SnackBarType.success,
          duration: const Duration(seconds: 5),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (!mounted) return;

        // 🔴 NOUVEAU : Nouveau compte = jamais certifié → warning garanti
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/owner-dashboard',
              (route) => false,
          arguments: {
            'showCertificationWarning': true,
          },
        );
      } else {
        _showAppSnackBar(
          message:
          auth.errorMessage ??
              'Une erreur est survenue.',
          type: SnackBarType.error,
        );
      }
    } catch (e) {
      if (!mounted) return;

      logger.e(
        '❌ Erreur inscription : $e',
      );

      _showAppSnackBar(
        message:
        '❌ Une erreur est survenue.',
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      backgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (
              context,
              constraints,
              ) {
            final bool isLargeScreen =
                constraints.maxWidth >= 700;

            return SingleChildScrollView(
              physics:
              const BouncingScrollPhysics(),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior
                  .onDrag,
              padding: EdgeInsets.symmetric(
                horizontal:
                isLargeScreen
                    ? 32.w
                    : 24.w,
                vertical: 16.h,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints:
                  const BoxConstraints(
                    maxWidth: 550,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      SizedBox(
                        height:
                        isLargeScreen
                            ? 30.h
                            : 18.h,
                      ),

                      _buildTitleSection(),

                      SizedBox(
                        height:
                        isLargeScreen
                            ? 25.h
                            : 18.h,
                      ),

                      _buildStepIndicator(),

                      SizedBox(
                        height: 12.h,
                      ),

                      _buildProgressBar(),

                      SizedBox(
                        height: 20.h,
                      ),

                      _buildCurrentStep(),

                      SizedBox(
                        height: 18.h,
                      ),

                      _buildNavigationButtons(),

                      SizedBox(
                        height: 24.h,
                      ),

                      if (currentStep == 0 ||
                          currentStep == 2) ...[
                        _buildGoogleButton(),
                        SizedBox(height: 24.h),
                      ],

                      _buildLoginLink(),

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

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius:
            BorderRadius.circular(50.r),
            onTap: isLoading
                ? null
                : () =>
                Navigator.pop(context),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration:
              const BoxDecoration(
                color:
                Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                size: 23.sp,
                color: accentColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TITRE
  // ============================================================

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          '🎉 Rejoignez-nous !',
          style: GoogleFonts.nunito(
            fontSize: 28.sp,
            fontWeight:
            FontWeight.w900,
            color: textColor,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'Créez votre compte en quelques étapes',
          style: GoogleFonts.nunito(
            fontSize: 15.sp,
            fontWeight:
            FontWeight.w500,
            color:
            secondaryTextColor,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INDICATEUR
  // ============================================================

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepCircle(
          number: 1,
          title: 'Profil',
          active: currentStep >= 0,
        ),
        Expanded(
          child: _buildStepLine(
            active: currentStep >= 1,
          ),
        ),
        _buildStepCircle(
          number: 2,
          title: 'Détails',
          active: currentStep >= 1,
        ),
        Expanded(
          child: _buildStepLine(
            active: currentStep >= 2,
          ),
        ),
        _buildStepCircle(
          number: 3,
          title: 'Sécurité',
          active: currentStep >= 2,
        ),
      ],
    );
  }

  Widget _buildStepCircle({
    required int number,
    required String title,
    required bool active,
  }) {
    return Column(
      children: [
        AnimatedContainer(
          duration:
          const Duration(milliseconds: 250),
          width: 32.w,
          height: 32.w,
          decoration:
          BoxDecoration(
            shape: BoxShape.circle,
            color: active
                ? accentColor
                : const Color(
              0xFFE2E8F0,
            ),
          ),
          child: Center(
            child: Text(
              '$number',
              style: GoogleFonts.nunito(
                color: active
                    ? Colors.white
                    : const Color(
                  0xFF64748B,
                ),
                fontSize: 13.sp,
                fontWeight:
                FontWeight.w900,
              ),
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          title,
          style: GoogleFonts.nunito(
            fontSize: 10.sp,
            fontWeight: active
                ? FontWeight.w800
                : FontWeight.w500,
            color: active
                ? accentColor
                : const Color(
              0xFF94A3B8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine({
    required bool active,
  }) {
    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 250),
      height: 2,
      margin: EdgeInsets.only(
        bottom: 17.h,
        left: 5.w,
        right: 5.w,
      ),
      color: active
          ? accentColor
          : const Color(
        0xFFE2E8F0,
      ),
    );
  }

  // ============================================================
  // PROGRESS
  // ============================================================

  Widget _buildProgressBar() {
    final double progress =
        currentStep /
            (totalSteps - 1);

    return ClipRRect(
      borderRadius:
      BorderRadius.circular(10.r),
      child:
      LinearProgressIndicator(
        value:
        progress == 0
            ? 0.02
            : progress,
        minHeight: 7.h,
        backgroundColor:
        const Color(
            0xFFE2E8F0),
        valueColor:
        const AlwaysStoppedAnimation<
            Color>(
          accentColor,
        ),
      ),
    );
  }

  // ============================================================
  // ETAPE ACTUELLE
  // ============================================================

  Widget _buildCurrentStep() {
    switch (currentStep) {
      case 0:
        return _buildStep1();

      case 1:
        return _buildStep2();

      case 2:
        return _buildStep3();

      default:
        return const SizedBox.shrink();
    }
  }

  // ============================================================
  // ETAPE 1
  // ============================================================

  Widget _buildStep1() {
    return Form(
      key: _step1FormKey,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildFormField(
            const FieldConfig(
              id: 'nom',
              label: 'NOM',
              placeholder:
              'Votre nom',
              icon:
              Icons.person_outline,
            ),
            nomController,
          ),
          _buildFormField(
            const FieldConfig(
              id: 'prenom',
              label: 'PRÉNOM',
              placeholder:
              'Votre prénom',
              icon:
              Icons.person_outline,
            ),
            prenomController,
          ),
          _buildFormField(
            const FieldConfig(
              id: 'email',
              label: 'EMAIL',
              placeholder:
              'votre@email.com',
              icon:
              Icons.email_outlined,
            ),
            emailController,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ETAPE 2
  // ============================================================

  Widget _buildStep2() {
    return Form(
      key: _step2FormKey,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildDateField(),
          _buildFormField(
            const FieldConfig(
              id: 'ville',
              label: 'VILLE',
              placeholder:
              'Votre ville',
              icon:
              Icons.location_city_outlined,
            ),
            villeController,
          ),
          _buildPhoneField(),
        ],
      ),
    );
  }

  // ============================================================
  // ETAPE 3
  // ============================================================

  Widget _buildStep3() {
    return Form(
      key: _step3FormKey,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          _buildPasswordField(),
          _buildConfirmPasswordField(),
          SizedBox(height: 4.h),
          _buildTermsCheckbox(),
        ],
      ),
    );
  }

  // ============================================================
  // CHAMP
  // ============================================================

  Widget _buildFormField(
      FieldConfig field,
      TextEditingController controller,
      ) {
    return Padding(
      padding:
      EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
          SizedBox(height: 5.h),
          TextFormField(
            controller: controller,
            enabled: !isLoading,
            textCapitalization:
            field.id == 'email'
                ? TextCapitalization.none
                : TextCapitalization
                .words,
            keyboardType:
            field.id == 'email'
                ? TextInputType
                .emailAddress
                : TextInputType.text,
            style:
            GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w600,
              color: textColor,
            ),
            decoration:
            _inputDecoration(
              hintText:
              field.placeholder,
              icon: field.icon,
            ),
            validator: (value) {
              final text =
                  value?.trim() ?? '';

              if (text.isEmpty) {
                return 'Ce champ est requis';
              }

              if (field.id ==
                  'email') {
                final regex =
                RegExp(
                  r'^[\w\-.]+@([\w\-]+\.)+[\w\-]{2,}$',
                );

                if (!regex
                    .hasMatch(text)) {
                  return 'Email invalide';
                }
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 19.sp,
        color: accentColor,
      ),
      suffixIcon: suffixIcon,
      hintText: hintText,
      hintStyle:
      GoogleFonts.nunito(
        fontSize: 14.sp,
        color:
        const Color(0xFF64748B),
        fontWeight:
        FontWeight.w500,
      ),
      filled: true,
      fillColor:
      const Color(0xB3FFFFFF),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: accentColor,
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      errorStyle:
      GoogleFonts.nunito(
        fontSize: 11.sp,
        fontWeight:
        FontWeight.w600,
        color:
        Colors.redAccent,
      ),
      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 14.h,
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateField() {
    final bool hasDate =
        selectedDate != null;

    return Padding(
      padding:
      EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'DATE DE NAISSANCE',
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
          SizedBox(height: 6.h),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius:
              BorderRadius.circular(
                  16.r),
              onTap: isLoading
                  ? null
                  : () =>
                  _selectDate(
                      context),
              child: Container(
                padding:
                EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
                decoration:
                BoxDecoration(
                  color: const Color(
                      0xB3FFFFFF),
                  borderRadius:
                  BorderRadius
                      .circular(
                      16.r),
                  border:
                  Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons
                          .calendar_month_outlined,
                      size: 19.sp,
                      color:
                      accentColor,
                    ),
                    SizedBox(
                        width: 14.w),
                    Expanded(
                      child: Text(
                        hasDate
                            ? '${selectedDate!.day.toString().padLeft(2, '0')}/'
                            '${selectedDate!.month.toString().padLeft(2, '0')}/'
                            '${selectedDate!.year}'
                            : 'JJ/MM/AAAA',
                        style:
                        GoogleFonts
                            .nunito(
                          fontSize:
                          16.sp,
                          fontWeight:
                          FontWeight
                              .w600,
                          color: hasDate
                              ? textColor
                              : const Color(
                              0xFF64748B),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.cake_outlined,
                      size: 19.sp,
                      color:
                      accentColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TELEPHONE
  // ============================================================

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          'TÉLÉPHONE',
          style: GoogleFonts.nunito(
            fontSize: 12.sp,
            fontWeight:
            FontWeight.w700,
            letterSpacing: 1,
            color: textColor,
          ),
        ),
        SizedBox(height: 6.h),
        IntlPhoneField(
          initialCountryCode: 'ML',
          disableLengthCheck: false,
          style: GoogleFonts.nunito(
            fontSize: 16.sp,
            fontWeight:
            FontWeight.w600,
            color: textColor,
          ),
          dropdownTextStyle:
          GoogleFonts.nunito(
            fontSize: 14.sp,
            fontWeight:
            FontWeight.w700,
            color: textColor,
          ),
          decoration:
          _phoneInputDecoration(),
          onChanged: (phone) {
            completePhoneNumber =
                phone.completeNumber;

            countryCode =
                phone.countryCode;
          },
          onCountryChanged:
              (country) {
            countryCode =
                country.dialCode;
          },
          validator: (phone) {
            if (phone == null ||
                phone.number
                    .trim()
                    .isEmpty) {
              return 'Entrez votre téléphone';
            }

            if (phone.number.length <
                8) {
              return 'Numéro invalide';
            }

            return null;
          },
        ),
      ],
    );
  }

  InputDecoration
  _phoneInputDecoration() {
    return InputDecoration(
      hintText: 'XX XX XX XX',
      hintStyle:
      GoogleFonts.nunito(
        fontSize: 14.sp,
        color:
        const Color(0xFF64748B),
      ),
      filled: true,
      fillColor:
      const Color(0xB3FFFFFF),
      border:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        BorderSide.none,
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: accentColor,
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(
            16.r),
        borderSide:
        const BorderSide(
          color: Colors.redAccent,
          width: 1.5,
        ),
      ),
      contentPadding:
      EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 14.h,
      ),
    );
  }

  // ============================================================
  // PASSWORD
  // ============================================================

  Widget _buildPasswordField() {
    return Padding(
      padding:
      EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'MOT DE PASSE',
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller:
            passwordController,
            enabled: !isLoading,
            obscureText:
            !passwordVisible,
            style:
            GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w600,
              color: textColor,
            ),
            decoration:
            _inputDecoration(
              hintText: '••••••••',
              icon:
              Icons.lock_outline,
              suffixIcon:
              IconButton(
                onPressed:
                isLoading
                    ? null
                    : () {
                  setState(() {
                    passwordVisible =
                    !passwordVisible;
                  });
                },
                icon: Icon(
                  passwordVisible
                      ? Icons
                      .visibility_outlined
                      : Icons
                      .visibility_off_outlined,
                  size: 19.sp,
                  color:
                  accentColor,
                ),
              ),
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Le mot de passe est requis';
              }

              if (value.length <
                  8) {
                return 'Minimum 8 caractères';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONFIRMATION
  // ============================================================

  Widget _buildConfirmPasswordField() {
    return Padding(
      padding:
      EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'CONFIRMATION DU MOT DE PASSE',
            style: GoogleFonts.nunito(
              fontSize: 12.sp,
              fontWeight:
              FontWeight.w700,
              letterSpacing: 1,
              color: textColor,
            ),
          ),
          SizedBox(height: 6.h),
          TextFormField(
            controller:
            confirmPasswordController,
            enabled: !isLoading,
            obscureText:
            !confirmPasswordVisible,
            style:
            GoogleFonts.nunito(
              fontSize: 16.sp,
              fontWeight:
              FontWeight.w600,
              color: textColor,
            ),
            decoration:
            _inputDecoration(
              hintText: '••••••••',
              icon:
              Icons.lock_outline,
              suffixIcon:
              IconButton(
                onPressed:
                isLoading
                    ? null
                    : () {
                  setState(() {
                    confirmPasswordVisible =
                    !confirmPasswordVisible;
                  });
                },
                icon: Icon(
                  confirmPasswordVisible
                      ? Icons
                      .visibility_outlined
                      : Icons
                      .visibility_off_outlined,
                  size: 19.sp,
                  color:
                  accentColor,
                ),
              ),
            ),
            validator: (value) {
              if (value == null ||
                  value.isEmpty) {
                return 'Veuillez confirmer votre mot de passe';
              }

              if (value !=
                  passwordController
                      .text) {
                return 'Les mots de passe ne correspondent pas';
              }

              return null;
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONDITIONS
  // ============================================================

  Widget _buildTermsCheckbox() {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Material(
              color:
              Colors.transparent,
              child: InkWell(
                borderRadius:
                BorderRadius.circular(
                    8.r),
                onTap: isLoading
                    ? null
                    : () {
                  setState(() {
                    checkboxValue =
                    !checkboxValue;

                    if (checkboxValue) {
                      checkboxError =
                      null;
                    }
                  });
                },
                child: Padding(
                  padding:
                  EdgeInsets.all(
                      2.w),
                  child:
                  AnimatedContainer(
                    duration:
                    const Duration(
                        milliseconds:
                        200),
                    width: 24.w,
                    height: 24.w,
                    decoration:
                    BoxDecoration(
                      color:
                      checkboxValue
                          ? accentColor
                          : Colors
                          .transparent,
                      borderRadius:
                      BorderRadius
                          .circular(
                          6.r),
                      border:
                      Border.all(
                        color:
                        checkboxValue
                            ? accentColor
                            : const Color(
                            0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child:
                    checkboxValue
                        ? Icon(
                      Icons
                          .check_rounded,
                      size: 17.sp,
                      color:
                      Colors.white,
                    )
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(width: 9.w),
            Expanded(
              child: Wrap(
                children: [
                  Text(
                    "J'accepte les ",
                    style:
                    GoogleFonts.nunito(
                      fontSize: 11.sp,
                      color:
                      secondaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator
                          .pushNamed(
                        context,
                        '/conditions',
                      );
                    },
                    child: Text(
                      "Conditions d'utilisation",
                      style:
                      GoogleFonts.nunito(
                        fontSize:
                        11.sp,
                        fontWeight:
                        FontWeight
                            .w800,
                        color:
                        accentColor,
                        decoration:
                        TextDecoration
                            .underline,
                      ),
                    ),
                  ),
                  Text(
                    " et la ",
                    style:
                    GoogleFonts.nunito(
                      fontSize: 11.sp,
                      color:
                      secondaryTextColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator
                          .pushNamed(
                        context,
                        '/conditions',
                      );
                    },
                    child: Text(
                      "Politique de confidentialité",
                      style:
                      GoogleFonts.nunito(
                        fontSize:
                        11.sp,
                        fontWeight:
                        FontWeight
                            .w800,
                        color:
                        accentColor,
                        decoration:
                        TextDecoration
                            .underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (checkboxError != null)
          Padding(
            padding:
            EdgeInsets.only(
              top: 6.h,
              left: 35.w,
            ),
            child: Text(
              checkboxError!,
              style:
              GoogleFonts.nunito(
                color:
                Colors.redAccent,
                fontSize: 11.sp,
                fontWeight:
                FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // GOOGLE
  // ============================================================

  Widget _buildGoogleButton() {
    return AnimatedGradientButton(
      label:
      "S'inscrire avec Google",
      width: double.infinity,
      height: 44.h,
      fontSize: 14,
      backgroundColor:
      Colors.white,
      textColor:
      accentColor,
      borderColor:
      const Color(0xFFE2E8F0),
      shadowColor:
      Colors.transparent,
      leading: SizedBox(
        width: 22.w,
        height: 22.w,
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
          ? null
          : () {
        _showAppSnackBar(
          message:
          '🔜 Connexion Google bientôt disponible.',
          type:
          SnackBarType.info,
        );
      },
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Widget _buildNavigationButtons() {
    final bool isLastStep =
        currentStep ==
            totalSteps - 1;

    return Row(
      children: [
        if (currentStep > 0) ...[
          Expanded(
            child:
            AnimatedGradientButton(
              label: 'Précédent',
              width:
              double.infinity,
              height: 45.h,
              fontSize: 15,
              backgroundColor:
              Colors.white,
              textColor:
              textColor,
              borderColor:
              const Color(
                  0xFFE2E8F0),
              shadowColor:
              Colors.transparent,
              enabled:
              !isLoading,
              onPressed:
              _goToPreviousStep,
            ),
          ),
          SizedBox(width: 12.w),
        ],
        Expanded(
          child:
          AnimatedGradientButton(
            label: isLastStep
                ? (isLoading
                ? 'Inscription...'
                : "S'inscrire")
                : 'Suivant',
            width:
            double.infinity,
            height: 45.h,
            fontSize:
            isLastStep
                ? 16
                : 17,
            backgroundColor:
            accentColor,
            textColor:
            Colors.white,
            borderColor:
            Colors.transparent,
            shadowColor:
            const Color(
                0x602563EB),
            enabled:
            !isLoading,
            leading:
            isLoading &&
                isLastStep
                ? SizedBox(
              width: 19.w,
              height: 19.w,
              child:
              const CircularProgressIndicator(
                color:
                Colors.white,
                strokeWidth:
                2,
              ),
            )
                : null,
            onPressed:
            _goToNextStep,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(
            'Déjà un compte ? ',
            style:
            GoogleFonts.nunito(
              fontSize: 14.sp,
              color:
              secondaryTextColor,
            ),
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
            GoogleFonts.nunito(
              fontSize: 14.sp,
              fontWeight:
              FontWeight.w900,
              color:
              accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
