import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/core/theme/app_theme.dart';
import 'conversation_model.dart';

class ConversationPage extends StatefulWidget {
  final Conversation conversation;
  final VoidCallback onBack;

  const ConversationPage({
    super.key,
    required this.conversation,
    required this.onBack,
  });

  @override
  State<ConversationPage> createState() =>
      _ConversationPageState();
}

class _ConversationPageState
    extends State<ConversationPage> {

  final TextEditingController _messageController =
  TextEditingController();

  final ScrollController _scrollController =
  ScrollController();

  final List<_Message> _messages = [
    const _Message(
      text:
      'Bonjour ! Je viens de réserver le studio pour le 14 août.',
      time: '10:10',
      isMine: false,
    ),

    const _Message(
      text:
      'Bonjour Sophie ! Bienvenue, votre réservation est bien confirmée 😊',
      time: '10:13',
      isMine: true,
    ),

    const _Message(
      text:
      'Super merci ! Est-ce que le parking est inclus dans le prix ?',
      time: '10:24',
      isMine: false,
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ============================================================
  // ENVOYER
  // ============================================================

  void _sendMessage() {
    final text =
    _messageController.text.trim();

    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        _Message(
          text: text,
          time: _currentTime(),
          isMine: true,
        ),
      );
    });

    _messageController.clear();

    Future.delayed(
      const Duration(milliseconds: 100),
          () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration:
            const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  // ============================================================
  // HEURE
  // ============================================================

  String _currentTime() {
    final now = TimeOfDay.now();

    final hour =
    now.hour.toString().padLeft(2, '0');

    final minute =
    now.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // ========================================================
        // HEADER CONVERSATION
        // ========================================================

        Container(
          color: AppColors.foreground,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Row(
                children: [

                  // =================================================
                  // RETOUR
                  // =================================================

                  IconButton(
                    onPressed: widget.onBack,
                    style:
                    IconButton.styleFrom(
                      backgroundColor:
                      Colors.white
                          .withValues(alpha: 0.10),
                      minimumSize:
                      const Size(40, 40),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons
                          .arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // =================================================
                  // AVATAR
                  // =================================================

                  Stack(
                    children: [

                      CircleAvatar(
                        radius: 19,
                        backgroundColor:
                        const Color(0xFFC9913A),
                        child: Text(
                          widget
                              .conversation.avatar,
                          style:
                          GoogleFonts.nunito(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      if (widget
                          .conversation.online)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration:
                            BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.success,width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(width: 10),

                  // =================================================
                  // NOM
                  // =================================================

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [

                        Text(
                          widget
                              .conversation.name,
                          maxLines: 1,
                          overflow:
                          TextOverflow.ellipsis,
                          style:
                          GoogleFonts.nunito(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 2),

                        Row(
                          children: [

                            Flexible(
                              child: Text(
                                widget
                                    .conversation
                                    .apt,
                                maxLines: 1,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                                style:
                                GoogleFonts.nunito(
                                  color:
                                  Color(
                                    0xFF94A3B8,
                                  ),
                                  fontSize: 10,
                                ),
                              ),
                            ),

                            if (widget
                                .conversation
                                .online) ...[
                                  Text(
                                ' · ',
                                style:
                                GoogleFonts.nunito(
                                  color:
                                  Color(
                                    0xFF64748B,
                                  ),
                                  fontSize: 10,
                                ),
                              ),

                              Text(
                                'En ligne',
                                style:
                                GoogleFonts.nunito(
                                  color:
                                  Color(
                                    0xFF94A3B8,
                                  ),
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // TELEPHONE
                  // =================================================

                  IconButton(
                    onPressed: () {},
                    style:
                    IconButton.styleFrom(
                      backgroundColor:
                      Colors.white
                          .withValues(alpha:0.10),
                      minimumSize:
                      const Size(40, 40),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          11,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.phone_outlined,
                      color: Colors.white,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ========================================================
        // ZONE CONVERSATION
        // ========================================================

        Expanded(
          child: Container(
            color: AppColors.background,
            child: Column(
              children: [

                // ==================================================
                // DATE
                // ==================================================

                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 14,
                  ),
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration:
                    BoxDecoration(
                      color:
                      const Color(
                        0xFFE2E8F0,
                      ),
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Text(
                      "Aujourd'hui",
                      style: GoogleFonts.nunito(
                        color:
                        Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ==================================================
                // MESSAGES
                // ==================================================

                Expanded(
                  child: ListView.builder(
                    controller:
                    _scrollController,
                    padding:
                    const EdgeInsets.fromLTRB(
                      12,
                      6,
                      12,
                      12,
                    ),
                    itemCount:
                    _messages.length + 1,
                    itemBuilder:
                        (context, index) {

                      // --------------------------------------------
                      // INDICATEUR DE FRAPPE
                      // --------------------------------------------

                      if (index ==
                          _messages.length) {
                        return Align(
                          alignment:
                          Alignment.centerLeft,
                          child: Container(
                            margin:
                            const EdgeInsets
                                .only(
                              top: 5,
                            ),
                            padding:
                            const EdgeInsets
                                .symmetric(
                              horizontal: 14,
                              vertical: 9,
                            ),
                            decoration:
                            BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius
                                  .circular(
                                16,
                              ),
                            ),
                            child: Row(
                              mainAxisSize:
                              MainAxisSize.min,
                              children: [
                                _dot(),
                                const SizedBox(
                                  width: 3,
                                ),
                                _dot(),
                                const SizedBox(
                                  width: 3,
                                ),
                                _dot(),
                              ],
                            ),
                          ),
                        );
                      }

                      final message =
                      _messages[index];

                      return _MessageBubble(
                        message: message,
                      );
                    },
                  ),
                ),

                // ==================================================
                // CHAMP MESSAGE
                // ==================================================

                Container(
                  padding:
                  const EdgeInsets.fromLTRB(
                    12,
                    8,
                    12,
                    10,
                  ),
                  decoration:
                  const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(
                        color:
                        Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [

                      // --------------------------------------------
                      // INPUT
                      // --------------------------------------------

                      Expanded(
                        child: Container(
                          height: 43,
                          padding:
                          const EdgeInsets
                              .symmetric(
                            horizontal: 14,
                          ),
                          decoration:
                          BoxDecoration(
                            color:
                            const Color(
                              0xFFF1F5F9,
                            ),
                            borderRadius:
                            BorderRadius
                                .circular(
                              22,
                            ),
                            border: Border.all(
                              color:
                              const Color(
                                0xFFE2E8F0,
                              ),
                            ),
                          ),
                          child: TextField(
                            controller:
                            _messageController,
                            textInputAction:
                            TextInputAction
                                .send,
                            onSubmitted:
                                (_) =>
                                _sendMessage(),
                            decoration:
                            InputDecoration(
                              hintText:
                              'Écrire un message...',
                              hintStyle:
                              GoogleFonts.nunito(
                                color:
                                Color(
                                  0xFF94A3B8,
                                ),
                                fontSize: 13,
                              ),
                              border:
                              InputBorder.none,
                              contentPadding:
                              EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // --------------------------------------------
                      // BOUTON ENVOYER
                      // --------------------------------------------

                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          width: 43,
                          height: 43,
                          decoration:
                          const BoxDecoration(
                            color:
                            Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.send_rounded,
                            color:
                            Color(0xFF94A3B8),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot() {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: Color(0xFF94A3B8),
        shape: BoxShape.circle,
      ),
    );
  }
}

// ============================================================
// MODÈLE MESSAGE
// ============================================================

class _Message {
  final String text;
  final String time;
  final bool isMine;

  const _Message({
    required this.text,
    required this.time,
    required this.isMine,
  });
}

// ============================================================
// BULLE MESSAGE
// ============================================================

class _MessageBubble extends StatelessWidget {
  final _Message message;

  const _MessageBubble({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment:
        message.isMine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [

          Align(
            alignment:
            message.isMine
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              constraints:
              BoxConstraints(
                maxWidth:
                MediaQuery.of(context)
                    .size
                    .width *
                    0.72,
              ),
              padding:
              const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 11,
              ),
              decoration:
              BoxDecoration(
                color: message.isMine
                    ? const Color(
                  0xFF23467D,
                )
                    : Colors.white,
                borderRadius:
                BorderRadius.only(
                  topLeft:
                  const Radius.circular(
                    16,
                  ),
                  topRight:
                  const Radius.circular(
                    16,
                  ),
                  bottomLeft:
                  Radius.circular(
                    message.isMine
                        ? 16
                        : 4,
                  ),
                  bottomRight:
                  Radius.circular(
                    message.isMine
                        ? 4
                        : 16,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                    Colors.black
                        .withValues(alpha:
                      0.04,
                    ),
                    blurRadius: 5,
                    offset:
                    const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: GoogleFonts.nunito(
                  color: message.isMine
                      ? Colors.white
                      : const Color(
                    0xFF0F1B2D,
                  ),
                  fontSize: 13,
                  height: 1.35,
                  fontWeight:
                  message.isMine
                      ? FontWeight.w500
                      : FontWeight.w400,
                ),
              ),
            ),
          ),

          const SizedBox(height: 3),

          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Text(
              message.time,
              style: GoogleFonts.nunito(
                color:
                Color(0xFF94A3B8),
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }
}