import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../responsive.dart';
import '../providers/user_provider.dart';
import 'navigation/side_menu.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const MainLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  final ValueNotifier<bool> _isMenuCollapsed = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  //Ajoutez cette méthode pour la navigation
  void _navigateTo(String route) {
    print('Navigation depuis MainLayout vers: $route');
    // Utiliser le contexte pour naviguer
    Navigator.pushNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    context.watch<UserProvider>();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFF090D16),
      drawer: !isDesktop
          ? SideMenu(
        isCollapsed: false,
        onNavigate: _navigateTo,
      )
          : null,
      body: SafeArea(
        child: ValueListenableBuilder<bool>(
          valueListenable: _isMenuCollapsed,
          builder: (context, isCollapsed, child) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDesktop)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: isCollapsed ? 80.w : 290.w,
                    child: SideMenu(
                      isCollapsed: isCollapsed,
                      onNavigate: _navigateTo,
                    ),
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _buildAppBar(
                        isDesktop: isDesktop,
                        isCollapsed: isCollapsed,
                        onToggleMenu: () {
                          _isMenuCollapsed.value = !_isMenuCollapsed.value;
                        },
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isDesktop ? 24.w : 16.w,
                            vertical: 16.h,
                          ),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar({
    required bool isDesktop,
    required bool isCollapsed,
    required VoidCallback onToggleMenu,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF090D16),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white, size: 22),
            onPressed: isDesktop
                ? onToggleMenu
                : () => _scaffoldKey.currentState?.openDrawer(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              widget.title,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (widget.actions != null) ...[
            ...widget.actions!,
          ],
        ],
      ),
    );
  }
}