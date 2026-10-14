import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/profil/Documents/documentpage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:owner_app/messages/messages_page.dart';
import 'package:owner_app/messages/conversation.dart';

import '../../appartements/ajouter_appartement/ajouter_appartement_page.dart';
import '../../appartements/details_appartement_page.dart';
import '../../appartements/gestion_photos_page.dart';
import '../../appartements/mes_appartements_page.dart';
import '../../appartements/modifier_appartement_page.dart';
import '../../dashboard/owner_dashboard.dart';
import '../../messages/conversation_model.dart';
import '../../profil/profil_page.dart';
import '../../reservations/reservations_page.dart';
import '../../revenus/revenus_page.dart';
import '../theme/app_theme.dart';

import '../../notifications/notifications_page.dart';
import '../../notifications/notification_service.dart';

enum AppPage {
  dashboard,
  mesAppartements,
  ajouterAppartement,
  modifierAppartement,
  gestionPhotos,
  details,
  reservations,
  revenus,
  messages,
  conversation,
  profile,
  notifications,
  documents,
}

typedef NavigateCallback = void Function(
    AppPage page, {
    String? appartementId,
    });

class MainWrapper extends StatefulWidget {
  const MainWrapper({
    super.key,
  });

  @override
  State<MainWrapper> createState() =>
      _MainWrapperState();
}

class _MainWrapperState
    extends State<MainWrapper> {
  SupabaseClient get _supabase {
    return Supabase.instance.client;
  }

  final NotificationService
  _notificationService =
      NotificationService.instance;

  StreamSubscription<
      NotificationRealtimeEvent>?
  _notificationSubscription;

  AppPage _currentPage =
      AppPage.dashboard;

  String? _selectedAppartementId;

  Conversation?
  _selectedConversation;

  String _userNom = '';
  String _userPrenom = '';
  String _userEmail = '';


  String _userPhotoUrl = '';

  int _unreadNotificationCount = 0;

  // USER
  String get _nom {
    return _userNom.trim();
  }

  String get _prenom {
    return _userPrenom.trim();
  }

  String get _fullName {
    final prenom = _prenom;
    final nom = _nom;

    final fullName =
    '$prenom $nom'.trim();

    if (fullName.isEmpty) {
      return 'Utilisateur';
    }

    return fullName;
  }

  String get _initials {
    final prenom = _prenom;
    final nom = _nom;

    String first = '';
    String last = '';

    if (prenom.isNotEmpty) {
      first = prenom[0];
    }

    if (nom.isNotEmpty) {
      last = nom[0];
    }

    final initials =
    '$first$last'.trim();

    if (initials.isEmpty) {
      return 'U';
    }

    return initials.toUpperCase();
  }

  // INIT
  @override
  void initState() {
    super.initState();

    _initializeUserImmediately();

    _loadCurrentUser();

    _initializeNotifications();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      final args =
          ModalRoute.of(context)
              ?.settings
              .arguments;

      if (args is Map<String, dynamic>) {
        final message =
        args['successMessage'];

        if (message is String &&
            message.isNotEmpty) {
          _showSuccessSnackBar(
            message: message,
          );
        }
      }
    });
  }

  // NOTIFICATIONS INIT
  Future<void>
  _initializeNotifications() async {
    try {
      final count =
      await _notificationService
          .getUnreadCount();

      if (mounted) {
        setState(() {
          _unreadNotificationCount =
              count;
        });
      }

      await _notificationService
          .startRealtime();

      _notificationSubscription =
          _notificationService
              .realtimeEvents
              .listen(
            _handleNotificationRealtime,
          );
    } catch (e) {
      debugPrint(
        'Initialisation notifications : $e',
      );
    }
  }

  // REALTIME NOTIFICATIONS
  void _handleNotificationRealtime(
      NotificationRealtimeEvent event,
      ) {
    if (!mounted) return;

    switch (event.type) {
      case NotificationRealtimeEventType
          .inserted:

        final notification =
            event.notification;

        if (notification == null) {
          return;
        }

        if (!notification.isRead) {
          setState(() {
            _unreadNotificationCount++;
          });
        }

        break;

      case NotificationRealtimeEventType
          .updated:

        final oldIsRead =
            event.oldIsRead ?? false;

        final newIsRead =
            event.newIsRead ?? false;

        if (oldIsRead == false &&
            newIsRead == true) {
          setState(() {
            if (_unreadNotificationCount >
                0) {
              _unreadNotificationCount--;
            }
          });
        } else if (oldIsRead == true &&
            newIsRead == false) {
          setState(() {
            _unreadNotificationCount++;
          });
        }

        break;

      case NotificationRealtimeEventType
          .deleted:

        final oldIsRead =
            event.oldIsRead ?? false;

        if (!oldIsRead) {
          setState(() {
            if (_unreadNotificationCount >
                0) {
              _unreadNotificationCount--;
            }
          });
        }

        break;
    }
  }

  // USER INITIAL
  void _initializeUserImmediately() {
    try {
      final user =
          _supabase.auth.currentUser;

      if (user == null) {
        debugPrint(
          'Aucun utilisateur connecté.',
        );
        return;
      }

      _userEmail =
          user.email ?? '';

      final metadata =
          user.userMetadata;

      if (metadata != null) {
        final prenom =
            metadata['prenom'] ??
                metadata['first_name'] ??
                metadata['firstName'] ??
                '';

        final nom =
            metadata['nom'] ??
                metadata['last_name'] ??
                metadata['lastName'] ??
                '';

        _userPrenom =
            prenom.toString().trim();

        _userNom =
            nom.toString().trim();

      }

      debugPrint(
        '⚡ Utilisateur disponible immédiatement : '
            '$_fullName',
      );
    } catch (e) {
      debugPrint(
        'Initialisation utilisateur : $e',
      );
    }
  }

  //CHARGER L'URL SIGNÉE DE LA PHOTO DE PROFIL
  Future<void> _loadUserPhotoUrl(String photoPath) async {
    // Pas de photo
    if (photoPath.trim().isEmpty) {
      if (mounted) {
        setState(() => _userPhotoUrl = '');
      }
      return;
    }

    // Déjà une URL complète
    if (photoPath.startsWith('http://') ||
        photoPath.startsWith('https://')) {
      if (mounted) {
        setState(() => _userPhotoUrl = photoPath);
      }
      return;
    }

    // Chemin invalide
    if (photoPath.contains('://')) {
      debugPrint('Chemin photo invalide : $photoPath');
      if (mounted) {
        setState(() => _userPhotoUrl = '');
      }
      return;
    }

    // Générer l'URL signée via Supabase Storage
    try {
      final signedUrl = await _supabase.storage
          .from('avatars')
          .createSignedUrl(photoPath, 3600);

      if (!mounted) return;

      setState(() {
        _userPhotoUrl = signedUrl;
      });

      debugPrint('Photo de profil signée avec succès');
    } catch (e) {
      debugPrint('Impossible de signer la photo : $e');

      if (mounted) {
        setState(() => _userPhotoUrl = '');
      }
    }
  }

  // USER SUPABASE
  Future<void> _loadCurrentUser() async {
    try {
      final user =
          _supabase.auth.currentUser;

      if (user == null) {
        debugPrint(
          'Aucun utilisateur connecté.',
        );
        return;
      }

      final authEmail =
          user.email ?? '';

      if (_userEmail.isEmpty) {
        _userEmail = authEmail;
      }

      final response =
      await _supabase
          .from('users')
          .select('''
                id,
                nom,
                prenom,
                email,
                photo_profil
              ''')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint(
          'Profil users introuvable '
              'pour ${user.id}',
        );

        if (mounted) {
          setState(() {});
        }

        return;
      }

      final data =
      Map<String, dynamic>.from(
        response,
      );

      final nom =
          data['nom']
              ?.toString()
              .trim() ??
              '';

      final prenom =
          data['prenom']
              ?.toString()
              .trim() ??
              '';

      final photo =
          data['photo_profil']
              ?.toString()
              .trim() ??
              '';

      final email =
          data['email']
              ?.toString()
              .trim() ??
              authEmail;

      if (!mounted) return;

      setState(() {
        _userNom = nom;
        _userPrenom = prenom;
        _userEmail =
        email.isNotEmpty
            ? email
            : authEmail;
      });

      //AJOUT : Charger l'URL signée de la photo
      await _loadUserPhotoUrl(photo);

      debugPrint(
        'Profil Supabase chargé : '
            '$_fullName',
      );
    } catch (e, stackTrace) {
      debugPrint(
        'MainWrapper._loadCurrentUser: $e',
      );

      debugPrint(
        '$stackTrace',
      );
    }
  }

  // SUCCESS
  void _showSuccessSnackBar({
    required String message,
  }) {
    final messenger =
    ScaffoldMessenger.maybeOf(
      context,
    );

    if (messenger == null) {
      debugPrint(
        'ScaffoldMessenger introuvable.',
      );
      return;
    }

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(
                  alpha: 0.18,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style:
                GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        backgroundColor:
        const Color(0xFF10B981),
        behavior:
        SnackBarBehavior.floating,
        margin:
        const EdgeInsets.fromLTRB(
          16,
          0,
          16,
          16,
        ),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        elevation: 6,
        shape:
        RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(16),
        ),
        duration:
        const Duration(seconds: 3),
      ),
    );
  }


  // NAVIGATION
  void _navigateTo(
      AppPage page, {
        String? appartementId,
      }) {
    setState(() {
      _currentPage = page;
      _selectedAppartementId =
          appartementId;
    });
  }

  // CURRENT INDEX
  int get _currentIndex {
    switch (_currentPage) {
      case AppPage.dashboard:
      case AppPage.profile:
      case AppPage.notifications:
      case AppPage.documents:
        return 0;

      case AppPage.mesAppartements:
      case AppPage.ajouterAppartement:
      case AppPage.modifierAppartement:
      case AppPage.gestionPhotos:
      case AppPage.details:
        return 1;

      case AppPage.reservations:
        return 2;

      case AppPage.revenus:
        return 3;

      case AppPage.messages:
      case AppPage.conversation:
        return 4;
    }
  }

  // BODY
  Widget _buildBody() {
    switch (_currentPage) {
      case AppPage.dashboard:
        return DashboardPage(
          onNavigate: _navigateTo,
        );

      case AppPage.mesAppartements:
        return MesAppartementsPage(
          onNavigate: _navigateTo,
        );

      case AppPage.ajouterAppartement:
        return AjouterAppartementPage(
          onNavigate: _navigateTo,
        );

      case AppPage.modifierAppartement:
        return ModifierAppartementPage(
          onNavigate: _navigateTo,
          appartementId:
          _selectedAppartementId,
        );

      case AppPage.gestionPhotos:
        return GestionPhotosPage(
          onNavigate: _navigateTo,
          appartementId:
          _selectedAppartementId,
        );

      case AppPage.details:
        return DetailsAppartementPage(
          onNavigate: _navigateTo,
          appartementId:
          _selectedAppartementId,
        );

      case AppPage.reservations:
        return ReservationsPage(
          onNavigate: _navigateTo,
        );

      case AppPage.revenus:
        return RevenusPage(
          onNavigate: _navigateTo,
        );

      case AppPage.messages:
        return MessagesPage(
          onOpenConversation:
              (conversation) {
            setState(() {
              _selectedConversation =
                  conversation;

              _currentPage =
                  AppPage.conversation;
            });
          },
        );

      case AppPage.conversation:
        if (_selectedConversation ==
            null) {
          return MessagesPage(
            onOpenConversation:
                (conversation) {
              setState(() {
                _selectedConversation =
                    conversation;

                _currentPage =
                    AppPage.conversation;
              });
            },
          );
        }

        return ConversationPage(
          conversation:
          _selectedConversation!,
          onBack: () {
            _navigateTo(
              AppPage.messages,
            );
          },
        );

      case AppPage.profile:
        return ProfilePage(
          onNavigate: _navigateTo,
        );

      case AppPage.notifications:
        return NotificationsPage(
          onNavigate: _navigateTo,
        );

      case AppPage.documents:
        return DocumentsPage(
          onBack: () => _navigateTo(AppPage.profile),
        );
    }
  }

  // NAV ITEM
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final bool isSelected =
        _currentIndex == index;

    return Expanded(
      child: GestureDetector(
        behavior:
        HitTestBehavior.opaque,
        onTap: () {
          switch (index) {
            case 0:
              _navigateTo(
                AppPage.dashboard,
              );
              break;

            case 1:
              _navigateTo(
                AppPage.mesAppartements,
              );
              break;

            case 2:
              _navigateTo(
                AppPage.reservations,
              );
              break;

            case 3:
              _navigateTo(
                AppPage.revenus,
              );
              break;

            case 4:
              _navigateTo(
                AppPage.messages,
              );
              break;
          }
        },
        child: AnimatedContainer(
          duration:
          const Duration(
            milliseconds: 300,
          ),
          curve:
          Curves.easeOutCubic,
          padding:
          const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Stack(
            alignment:
            Alignment.bottomCenter,
            children: [
              Column(
                mainAxisAlignment:
                MainAxisAlignment.center,
                children: [
                  AnimatedScale(
                    scale:
                    isSelected
                        ? 1.44
                        : 1.0,
                    duration:
                    const Duration(
                      milliseconds: 300,
                    ),
                    curve:
                    Curves.easeOutBack,
                    child: Icon(
                      icon,
                      size: 25,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(
                        0xFF8A94A6,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  AnimatedDefaultTextStyle(
                    duration:
                    const Duration(
                      milliseconds: 250,
                    ),
                    curve:
                    Curves.easeOut,
                    style:
                    GoogleFonts.nunito(
                      fontSize:
                      isSelected
                          ? 10
                          : 9,
                      fontWeight:
                      isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : const Color(
                        0xFF94A3B8,
                      ),
                    ),
                    child:
                    Text(label),
                  ),
                ],
              ),
              Positioned(
                bottom: 0,
                child:
                AnimatedContainer(
                  duration:
                  const Duration(
                    milliseconds: 300,
                  ),
                  curve:
                  Curves.easeOutCubic,
                  width:
                  isSelected
                      ? 32
                      : 0,
                  height: 3,
                  decoration:
                  BoxDecoration(
                    color:
                    AppColors.primary,
                    borderRadius:
                    BorderRadius
                        .circular(
                      10,
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

  // HEADER TITLE
  Widget _buildHeaderTitle() {
    switch (_currentPage) {
      case AppPage.mesAppartements:
        return Text(
          'Mes Appartements',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.reservations:
        return Text(
          'Réservations',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.revenus:
        return Text(
          'Mes Revenus',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.ajouterAppartement:
        return Text(
          'Ajouter un bien',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.modifierAppartement:
        return Text(
          'Modifier le bien',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.gestionPhotos:
        return Text(
          'Gestion des photos',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.details:
        return Text(
          "Détails de l'appartement",
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.notifications:
        return Text(
          'Notifications',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.documents:
        return Text(
          'Documents',
          style:
          GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 22,
            fontWeight:
            FontWeight.bold,
          ),
        );

      case AppPage.dashboard:
        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          mainAxisSize:
          MainAxisSize.min,
          children: [
            Text(
              'Bonjour,',
              style:
              GoogleFonts.nunito(
                color:
                const Color(
                  0xFF94A3B8,
                ),
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 2,
            ),
            AnimatedSwitcher(
              duration:
              const Duration(
                milliseconds: 180,
              ),
              switchInCurve:
              Curves.easeOut,
              switchOutCurve:
              Curves.easeIn,
              transitionBuilder:
                  (
                  child,
                  animation,
                  ) {
                return FadeTransition(
                  opacity:
                  animation,
                  child: child,
                );
              },
              child: Text(
                _fullName,
                key:
                ValueKey(
                  _fullName,
                ),
                maxLines: 1,
                overflow:
                TextOverflow
                    .ellipsis,
                style:
                GoogleFonts.nunito(
                  color:
                  Colors.white,
                  fontSize: 19,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        );

      case AppPage.messages:
      case AppPage.conversation:
      case AppPage.profile:
        return const SizedBox.shrink();
    }
  }

  //PROFILE AVATAR
  Widget _buildProfileAvatar() {

    final bool hasValidPhoto =
        _userPhotoUrl.trim().isNotEmpty;

    return GestureDetector(
      onTap: () {
        _navigateTo(
          AppPage.profile,
        );
      },
      child: CircleAvatar(
        radius: 22,
        backgroundColor:
        const Color(0xFFFF8836),


        backgroundImage: hasValidPhoto
            ? NetworkImage(_userPhotoUrl)
            : null,

        child: hasValidPhoto
            ? null
            : Text(
          _initials,
          style:
          GoogleFonts.nunito(
            color:
            Colors.white,
            fontWeight:
            FontWeight.w800,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // NOTIFICATION BUTTON
  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () {
        _navigateTo(
          AppPage.notifications,
        );
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white
              .withValues(
            alpha: 0.10,
          ),
          borderRadius:
          BorderRadius.circular(
            14,
          ),
        ),
        child: Stack(
          clipBehavior:
          Clip.none,
          alignment:
          Alignment.center,
          children: [
            const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
              size: 25,
            ),

            if (_unreadNotificationCount >
                0)
              Positioned(
                right: 4,
                top: 3,
                child: Container(
                  constraints:
                  const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  padding:
                  const EdgeInsets
                      .symmetric(
                    horizontal: 4,
                  ),
                  decoration:
                  const BoxDecoration(
                    color: Colors.red,
                    shape:
                    BoxShape.circle,
                  ),
                  child: Text(
                    _unreadNotificationCount >
                        99
                        ? '99+'
                        : '$_unreadNotificationCount',
                    textAlign:
                    TextAlign.center,
                    style:
                    GoogleFonts.nunito(
                      fontSize: 8,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // HEADER FIXE
  Widget _buildFixedHeader() {
    return Container(
      color: AppColors.primary,
      padding:
      const EdgeInsets.fromLTRB(
        20,
        12,
        20,
        16,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child:
              _buildHeaderTitle(),
            ),

            const SizedBox(
              width: 10,
            ),

            _buildNotificationButton(),

            const SizedBox(
              width: 10,
            ),

            _buildProfileAvatar(),
          ],
        ),
      ),
    );
  }

  // BOTTOM NAVIGATION
  Widget _buildBottomNavigation() {
    return Container(
      decoration:
      const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color:
            Color(0xFFF1F5F9),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment:
            MainAxisAlignment
                .spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon:
                Icons.home_rounded,
                label: 'Accueil',
              ),
              _buildNavItem(
                index: 1,
                icon:
                Icons.grid_view_rounded,
                label: 'Biens',
              ),
              _buildNavItem(
                index: 2,
                icon:
                Icons.calendar_today_rounded,
                label: 'Réservations',
              ),
              _buildNavItem(
                index: 3,
                icon:
                Icons.attach_money_rounded,
                label: 'Revenus',
              ),
              _buildNavItem(
                index: 4,
                icon:
                Icons.chat_bubble_outline_rounded,
                label: 'Messages',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // DISPOSE
  @override
  void dispose() {
    _notificationSubscription
        ?.cancel();

    super.dispose();
  }

  // BUILD
  @override
  Widget build(
      BuildContext context,
      ) {
    final bool isMessages =
        _currentPage ==
            AppPage.messages;

    final bool isConversation =
        _currentPage ==
            AppPage.conversation;

    final bool isProfile =
        _currentPage ==
            AppPage.profile;

    final bool isNotifications =
        _currentPage ==
            AppPage.notifications;

    final bool isDocuments =
        _currentPage ==
            AppPage.documents;

    final bool hideMainHeader =
        isMessages ||
            isConversation ||
            isProfile ||
            isNotifications ||
            isDocuments;

    return AnnotatedRegion<
        SystemUiOverlayStyle>(
      value:
      const SystemUiOverlayStyle(
        statusBarColor:
        Colors.transparent,
        statusBarIconBrightness:
        Brightness.light,
        statusBarBrightness:
        Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor:
        const Color(0xFF0F1B2D),
        body: Column(
          children: [
            if (!hideMainHeader)
              _buildFixedHeader(),

            Expanded(
              child: Container(
                color:
                const Color(
                  0xFFF4F6FB,
                ),
                child:
                _buildBody(),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
        isProfile
            ? null
            : _buildBottomNavigation(),
      ),
    );
  }
}