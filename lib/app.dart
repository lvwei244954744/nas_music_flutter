import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/router/app_router.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/player/mini_player_bar.dart';
import 'features/player/player_provider.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      context.read<AuthState>().init();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();

    return MaterialApp(
      title: 'loml.nas.music',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      onGenerateRoute: AppRouter.generateRoute,
      home: auth.isConnected ? _MainShell() : const LoginScreen(),
    );
  }
}

class _MainShell extends StatefulWidget {
  @override
  State<_MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<_MainShell> {
  int _currentTab = 0;

  final _screens = const [
    HomeScreen(),
    LibraryScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerState>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _screens[_currentTab]),
          if (player.hasCurrent)
            const MiniPlayerBar(),
          _BottomNav(
            currentIndex: _currentTab,
            onTap: (i) => setState(() => _currentTab = i),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '首页',
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.library_music_outlined,
                activeIcon: Icons.library_music_rounded,
                label: '曲库',
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings_rounded,
                label: '设置',
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 24,
              color: isActive ? AppColors.primary : AppColors.textDarkMuted,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primary : AppColors.textDarkMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
