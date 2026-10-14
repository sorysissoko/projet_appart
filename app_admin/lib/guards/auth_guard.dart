import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:service/security_service.dart';
import 'package:service/service_locator.dart';

class AuthGuard extends StatelessWidget {
  final Widget child;
  final bool requireAdmin;

  const AuthGuard({
    super.key,
    required this.child,
    this.requireAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAccess(),
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFFC107),
              ),
            ),
          );
        }

        if (snapshot.hasError) {
          return const _UnauthorizedPage(
            message:
            'Erreur lors de la vérification des accès.',
          );
        }

        if (snapshot.data != true) {
          return const _UnauthorizedPage(
            message: 'Accès non autorisé.',
          );
        }

        return child;
      },
    );
  }

  Future<bool> _checkAccess() async {
    final auth = ServiceLocator.authWrapper;


    //SESSION
    final sessionValid = await auth.checkSession();

    if (!sessionValid) {
      return false;
    }

    //AUTHENTIFICATION SIMPLE
    if (!requireAdmin) {
      return true;
    }

    // ADMIN
    final role = await auth.getUserRole();

    return SecurityService.canAccessAdmin(role);
  }
}

  // PAGE NON AUTORISÉE
class _UnauthorizedPage extends StatelessWidget {
  final String message;

  const _UnauthorizedPage({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 70,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: Colors.red,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}