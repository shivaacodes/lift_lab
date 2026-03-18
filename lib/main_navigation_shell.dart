// The main navigation shell — only navigation logic and the bottom nav bar.
// Each tab is defined in its own file in lib/screens/.
import 'package:flutter/material.dart';
import 'package:lift_lab/models/user_model.dart';
import 'package:lift_lab/services/auth_service.dart';
import 'package:lift_lab/services/database_service.dart';
import 'package:lift_lab/services/haptics_service.dart';
import 'package:lift_lab/screens/home_tab.dart';
import 'package:lift_lab/screens/train_tab.dart';
import 'package:lift_lab/screens/nutrition_tab.dart';
import 'package:lift_lab/screens/history_tab.dart';
import 'package:lift_lab/screens/profile_tab.dart';
import 'package:lift_lab/widgets/app_widgets.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;
  final _auth = AuthService();
  final _db = DatabaseService();
  Stream<UserModel?>? _profileStream;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      _profileStream = _db.getUserProfileStream(user.uid);
    }
  }

  void _onItemTapped(int index) {
    HapticsService.selection();
    setState(() => _currentIndex = index);
  }

  Widget _buildNavItem({required int index, required IconData icon, required String label}) {
    final bool isActive = _currentIndex == index;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = navAccent(index, colors);
    
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.15 : 1.0,
              child: Icon(
                icon, 
                size: 26, 
                color: isActive ? accent : Colors.black26,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.5,
                color: isActive ? accent : Colors.black26,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              ),
              child: Text(label.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavItem(UserModel? profile) {
    final bool isActive = _currentIndex == 4;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final accent = navAccent(4, colors);
    final user = _auth.currentUser;
    final imageUrl = profile?.profileImageUrl;
    final name = profile?.name ?? (user?.email ?? 'user');
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isActive ? 1.15 : 1.0,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isActive ? accent : Colors.black12,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: CircleAvatar(
                  radius: 12,
                  backgroundColor: isActive ? accent.withValues(alpha: 0.1) : Colors.white,
                  backgroundImage: (imageUrl != null && imageUrl.isNotEmpty) ? NetworkImage(imageUrl) : null,
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Text(initial, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isActive ? accent : Colors.black26))
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.5,
                color: isActive ? accent : Colors.black26,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.w700,
              ),
              child: const Text('PROFILE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return StreamBuilder<UserModel?>(
      stream: _profileStream,
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data;

        final pages = [
          HomeTab(profile: profile, onOpenTrain: () => _onItemTapped(1), onOpenNutrition: () => _onItemTapped(2)),
          TrainTab(profile: profile),
          NutritionTab(profile: profile),
          HistoryTab(profile: profile),
          ProfileTab(profile: profile, onProfileUpdated: () async {}),
        ];

        return Scaffold(
          extendBody: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: IndexedStack(index: _currentIndex, children: pages),
          bottomNavigationBar: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  _buildNavItem(index: 0, icon: Icons.grid_view_rounded,      label: 'Home'),
                  _buildNavItem(index: 1, icon: Icons.fitness_center_rounded, label: 'Train'),
                  _buildNavItem(index: 2, icon: Icons.camera_alt_rounded,     label: 'Lab'),
                  _buildNavItem(index: 3, icon: Icons.bar_chart_rounded,      label: 'Logs'),
                  _buildProfileNavItem(profile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
