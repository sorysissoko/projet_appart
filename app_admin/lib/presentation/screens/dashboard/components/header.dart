import 'package:admin/presentation/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/color_constants.dart';


class Header extends StatelessWidget {
  final String title;

  const Header({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menuController = context.watch<MenuAppController>();

    return Row(
      children: [
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              //Ouvre le drawer
              menuController.scaffoldKey.currentState?.openDrawer();
            },
          ),
        if (!Responsive.isMobile(context))
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        if (!Responsive.isMobile(context))
          const Spacer(flex: 2),
        const Expanded(child: SearchField()),
        const ProfileCard(),
      ],
    );
  }
}

class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key}) : super(key: key);

  @override
  State<ProfileCard> createState() => _ProfileCardState();
}

class _ProfileCardState extends State<ProfileCard> {
  late Future<Map<String, dynamic>?> _profileFuture;

  Future<Map<String, dynamic>?> fetchUserProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      if (user == null) {
        debugPrint("Utilisateur non connecté.");
        return null;
      }

      final response = await supabase
          .from('users')
          .select('prenom, nom')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) {
        debugPrint("Aucun profil trouvé pour ${user.id}");
        return null;
      }

      return response;
    } catch (e) {
      debugPrint("Erreur Supabase : $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _profileFuture = fetchUserProfile();
  }

  Future<void> _logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();

    if (!mounted) return;

    // Rediriger vers la page de connexion
    Navigator.pushReplacementNamed(context, '/connexion');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: defaultPadding),
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding / 2,
      ),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          FutureBuilder<Map<String, dynamic>?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Row(
                  children: [
                    Image.asset(
                      "assets/images/profile_pic.png",
                      height: 38,
                    ),
                    const SizedBox(width: 8),
                    const CircularProgressIndicator(
                      color: Color(0xFFFFC107),
                      strokeWidth: 2,
                    ),
                  ],
                );
              }

              if (!snapshot.hasData || snapshot.data == null) {
                return Row(
                  children: [
                    Image.asset(
                      "assets/images/profile_pic.png",
                      height: 38,
                    ),
                    const SizedBox(width: 8),
                    const Text("Nom Prénom"),
                  ],
                );
              }

              final data = snapshot.data!;
              final fullName = "${data['prenom']} ${data['nom']}";

              return Row(
                children: [
                  Image.asset(
                    "assets/images/profile_pic.png",
                    height: 38,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fullName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              );
            },
          ),
          //Menu déroulant (Paramètres & Déconnexion)
          PopupMenuButton<String>(
            icon: const Icon(Icons.keyboard_arrow_down),
            color: secondaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (value) {
              if (value == 'settings') {
                Navigator.pushNamed(context, '/parametres');
              } else if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings, color: Colors.white70, size: 20),
                    SizedBox(width: 10),
                    Text("Paramètres", style: GoogleFonts.manrope(color: Colors.white)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: Colors.redAccent, size: 20),
                    SizedBox(width: 10),
                    Text("Déconnexion", style: GoogleFonts.manrope(color: Colors.redAccent)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  const SearchField({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: "Search",
        fillColor: secondaryColor,
        filled: true,
        border: const OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        suffixIcon: InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(defaultPadding * 0.75),
            margin: EdgeInsets.symmetric(horizontal: defaultPadding / 2),
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: SvgPicture.asset("assets/icons/Search.svg"),
          ),
        ),
      ),
    );
  }
}
