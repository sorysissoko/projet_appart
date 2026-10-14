import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';

import 'conversation_model.dart';

// ============================================================
// DONNÉES DE TEST
// ============================================================

final List<Conversation> conversationsData = [
  const Conversation(
    id: 1,
    name: 'Sophie Martin',
    apt: 'Studio Oberkampf',
    last: 'Bonjour, est-ce que le parking est inclus ?',
    time: '10:24',
    unread: 2,
    avatar: 'SM',
    online: true,
  ),
  const Conversation(
    id: 2,
    name: 'Lucas Bernard',
    apt: 'T2 Bastille',
    last: 'Merci pour la confirmation !',
    time: 'Hier',
    unread: 0,
    avatar: 'LB',
    online: false,
  ),
  const Conversation(
    id: 3,
    name: 'Emma Dubois',
    apt: 'Loft République',
    last: "J'arrive vers 15h, c'est possible ?",
    time: 'Hier',
    unread: 1,
    avatar: 'ED',
    online: true,
  ),
  const Conversation(
    id: 4,
    name: 'Antoine Leroy',
    apt: 'Studio Oberkampf',
    last: 'Pouvez-vous me confirmer le code wifi ?',
    time: 'Lun.',
    unread: 0,
    avatar: 'AL',
    online: false,
  ),
  const Conversation(
    id: 5,
    name: 'Marie Petit',
    apt: 'Appartement Nation',
    last: 'Tout était parfait, merci beaucoup !',
    time: 'Dim.',
    unread: 0,
    avatar: 'MP',
    online: false,
  ),
  const Conversation(
    id: 6,
    name: 'Thomas Girard',
    apt: 'Chambre Marais',
    last: 'Bonsoir, est-ce que le lit est en 160 ?',
    time: 'Sam.',
    unread: 3,
    avatar: 'TG',
    online: true,
  ),
];

// ============================================================
// SKELETON CONVERSATION CARD
// ============================================================

class _SkeletonConversationCard extends StatefulWidget {
  const _SkeletonConversationCard();

  @override
  State<_SkeletonConversationCard> createState() => _SkeletonConversationCardState();
}

class _SkeletonConversationCardState extends State<_SkeletonConversationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller.drive(
        CurveTween(curve: Curves.easeInOut),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB6B6B6).withValues(alpha: 0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar skeleton
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFEDF2F7),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // Contenu skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 14,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 11,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FA),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 100,
                      height: 11,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FA),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FA),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PAGE MESSAGES
// ============================================================

class MessagesPage extends StatefulWidget {
  final void Function(Conversation conversation)? onOpenConversation;

  const MessagesPage({
    super.key,
    this.onOpenConversation,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  static const Color textMuted = Color(0xFF8A94A6);

  final TextEditingController _searchController =
  TextEditingController();

  String _search = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _search = _searchController.text.toLowerCase().trim();
      });
    });

    // Simuler un chargement
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Conversation> get _filteredConversations {
    if (_search.isEmpty) {
      return conversationsData;
    }

    return conversationsData.where((conversation) {
      return conversation.name.toLowerCase().contains(_search) ||
          conversation.apt.toLowerCase().contains(_search) ||
          conversation.last.toLowerCase().contains(_search);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalUnread = conversationsData.fold<int>(
      0,
          (sum, conversation) => sum + conversation.unread,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Column(
        children: [

          // ======================================================
          // HEADER
          // ======================================================

          Container(
            color: AppColors.foreground,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  18,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // =================================================
                    // TITRE + NOUVEAU
                    // =================================================

                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [

                              Text(
                                'Messages',
                                style: GoogleFonts.nunito(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                '$totalUnread messages non lus',
                                style: GoogleFonts.nunito(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // BOUTON NOUVEAU
                        Container(
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.5),
                            borderRadius:
                            BorderRadius.circular(9),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              // TODO:
                              // ouvrir création nouvelle conversation
                            },
                            icon: const Icon(
                              Icons.edit_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                            label: Text(
                              'Nouveau',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize:
                              MaterialTapTargetSize
                                  .shrinkWrap,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // =================================================
                    // BARRE DE RECHERCHE
                    // =================================================

                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius:
                        BorderRadius.circular(10),
                      ),
                      padding:
                      const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Row(
                        children: [

                          Icon(
                            Icons.search_rounded,
                            size: 23,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),

                          const SizedBox(width: 8),

                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              decoration:
                              InputDecoration(
                                hintText:
                                'Rechercher une conversation...',
                                hintStyle: GoogleFonts.nunito(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding:
                                EdgeInsets.zero,
                              ),
                            ),
                          ),

                          if (_search.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                              },
                              child: Icon(
                                Icons.close_rounded,
                                size: 18,
                                color: Colors.white.withValues(alpha: 0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ======================================================
          // LISTE DES CONVERSATIONS
          // ======================================================

          Expanded(
            child: Container(
              color: const Color(0xFFF4F6FB),
              child: _isLoading
                  ? _buildLoadingState()
                  : _filteredConversations.isEmpty
                  ? Center(
                child: Text(
                  'Aucune conversation trouvée',
                  style: GoogleFonts.nunito(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
              )
                  : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: _filteredConversations.length,
                itemBuilder: (context, index) {
                  final conversation = _filteredConversations[index];

                  return _ConversationCard(
                    conversation: conversation,
                    onTap: () {
                      widget.onOpenConversation?.call(conversation);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOADING STATE AVEC SKELETONS
  // ============================================================

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: 6,
      itemBuilder: (context, index) => const _SkeletonConversationCard(),
    );
  }
}

// ============================================================
// CARTE CONVERSATION
// ============================================================

class _ConversationCard extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const _ConversationCard({
    required this.conversation,
    required this.onTap,
  });

  static const Color darkBg = Color(0xFF0F1B2D);
  static const Color goldAccent = Color(0xFFC9913A);
  static const Color onlineGreen = Color(0xFF10B981);
  static const Color textMuted = Color(0xFF8A94A6);

  @override
  Widget build(BuildContext context) {
    final bool unread = conversation.unread > 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB6B6B6).withValues(alpha: 0.15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // ==================================================
              // AVATAR
              // ==================================================

              Stack(
                clipBehavior: Clip.none,
                children: [

                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                    const Color(0xFFEDF2F7),
                    child: Text(
                      conversation.avatar,
                      style: GoogleFonts.nunito(
                        color: darkBg,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),

                  if (conversation.online)
                    Positioned(
                      right: -1,
                      bottom: -1,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration:
                        BoxDecoration(
                          color: onlineGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(width: 12),

              // ==================================================
              // CONTENU
              // ==================================================

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    // ------------------------------------------------
                    // NOM + HEURE
                    // ------------------------------------------------

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            conversation.name,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight:
                              FontWeight.bold,
                              color: darkBg,
                            ),
                          ),
                        ),

                        const SizedBox(width: 8),

                        Text(
                          conversation.time,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            color: unread
                                ? goldAccent
                                : textMuted,
                            fontWeight: unread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    // ------------------------------------------------
                    // APPARTEMENT
                    // ------------------------------------------------

                    Text(
                      conversation.apt,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        fontSize: 11,
                        color: textMuted,
                      ),
                    ),

                    const SizedBox(height: 6),

                    // ------------------------------------------------
                    // DERNIER MESSAGE + BADGE
                    // ------------------------------------------------

                    Row(
                      children: [

                        Expanded(
                          child: Text(
                            conversation.last,
                            maxLines: 1,
                            overflow:
                            TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(
                              fontSize: 12,
                              color: unread
                                  ? darkBg
                                  : textMuted,
                              fontWeight: unread
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),

                        if (unread)
                          Container(
                            margin:
                            const EdgeInsets.only(
                              left: 6,
                            ),
                            width: 18,
                            height: 18,
                            decoration:
                            const BoxDecoration(
                              color: darkBg,
                              shape: BoxShape.circle,
                            ),
                            alignment:
                            Alignment.center,
                            child: Text(
                              '${conversation.unread}',
                              style: GoogleFonts.nunito(
                                fontSize: 10,
                                fontWeight:
                                FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}