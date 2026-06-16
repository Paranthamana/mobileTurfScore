import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/storage/session_manager.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/brand_backdrop.dart';
import '../../../../injection_container.dart';
import '../../../scoring/presentation/bloc/scoring_bloc.dart';
import '../../../scoring/presentation/pages/create_match_screen.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final List<Widget> _screens;

  static const List<_DashboardNavItem> _navItems = [
    _DashboardNavItem(
      label: 'Home',
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
    ),
    _DashboardNavItem(
      label: 'Matches',
      icon: Icons.scoreboard_outlined,
      activeIcon: Icons.scoreboard_rounded,
    ),
    _DashboardNavItem(
      label: 'Series',
      icon: Icons.emoji_events_outlined,
      activeIcon: Icons.emoji_events_rounded,
    ),
    _DashboardNavItem(
      label: 'Profile',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(
        onCreateMatch: _openCreateSheet,
        onLogout: _logout,
        onNavigate: _onTabSelected,
      ),
      const _LiveTab(),
      _SeriesTab(onCreateTournament: _showTournamentSetupPreview),
      _ProfileTab(onLogout: _logout, onOpenAppearance: _openAppearance),
    ];
  }

  void _onTabSelected(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _openCreateSheet() {
    _showCreateMatchBottomSheet(context);
  }

  Future<void> _openAppearance() async {
    await Navigator.pushNamed(context, '/appearance');
  }

  void _showTournamentSetupPreview() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Series setup tools are coming soon.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _logout() async {
    await sl<SessionManager>().clear();
    if (!mounted) {
      return;
    }

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BrandBackdrop(),
          IndexedStack(index: _currentIndex, children: _screens),
        ],
      ),
      floatingActionButton: _buildCreateButton(theme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNavigationBar(theme),
    );
  }

  Widget _buildCreateButton(ThemeData theme) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.brandField.withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SizedBox(
        width: 70.r,
        height: 70.r,
        child: FloatingActionButton(
          onPressed: _openCreateSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
        ),
      ),
    ).animate().scale(
      delay: 250.ms,
      duration: 450.ms,
      curve: Curves.easeOutBack,
    );
  }

  Widget _buildBottomNavigationBar(ThemeData theme) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 18.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              height: 76.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(26.r),
                border: Border.all(
                  color: AppColors.outline.withValues(alpha: 0.8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.brandInk.withValues(alpha: 0.12),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(child: _buildNavItem(_navItems[0], 0)),
                  Expanded(child: _buildNavItem(_navItems[1], 1)),
                  SizedBox(width: 84.w),
                  Expanded(child: _buildNavItem(_navItems[2], 2)),
                  Expanded(child: _buildNavItem(_navItems[3], 3)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(_DashboardNavItem item, int index) {
    final isSelected = _currentIndex == index;
    final color =
        isSelected ? AppColors.brandInk : AppColors.textSecondaryLight;

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () => _onTabSelected(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        width: 48.r,
        height: 48.r,
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Center(
          child: AnimatedScale(
            duration: const Duration(milliseconds: 220),
            scale: isSelected ? 1.05 : 1,
            child: Icon(
              isSelected ? item.activeIcon : item.icon,
              color: color,
              size: 24.r,
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateMatchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          ),
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 28.h),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48.w,
                    height: 5.h,
                    decoration: BoxDecoration(
                      color: AppColors.textSecondaryLight.withValues(
                        alpha: 0.24,
                      ),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                  ),
                ),
                SizedBox(height: 22.h),
                Text(
                  'Create something new',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Jump into a fresh match or set up a tournament hub for your crew.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 22.h),
                _ActionSheetTile(
                  icon: Icons.sports_cricket_rounded,
                  title: 'Create Match',
                  subtitle: 'Start scoring right away with a quick setup.',
                  color: AppColors.primary,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => BlocProvider(
                              create: (_) => sl<ScoringBloc>(),
                              child: const CreateMatchScreen(),
                            ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 14.h),
                _ActionSheetTile(
                  icon: Icons.emoji_events_rounded,
                  title: 'Open Series Desk',
                  subtitle: 'Manage leagues, cups, and upcoming fixtures.',
                  color: AppColors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
              ],
            ),
          ),
        ).animate().slideY(
          begin: 0.2,
          end: 0,
          duration: 260.ms,
          curve: Curves.easeOutCubic,
        );
      },
    );
  }
}

class _DashboardNavItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _DashboardNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _SeriesTab extends StatelessWidget {
  final VoidCallback onCreateTournament;

  const _SeriesTab({required this.onCreateTournament});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_tournaments'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 140.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                gradient: AppColors.darkCardGradient,
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.14),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'Series Desk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Plan series, leagues, and match schedules with less friction.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Give captains a proper tournament view with fixtures, tables, and knockout flow in one place.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 22.h),
                  ElevatedButton.icon(
                    onPressed: onCreateTournament,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Set Up Series'),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
            SizedBox(height: 24.h),
            Text(
              'Formats you can run',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Knockout',
                    subtitle: 'Fast, high-stakes elimination rounds.',
                    icon: Icons.local_fire_department_rounded,
                    tint: AppColors.goldSoft,
                    iconColor: AppColors.goldDeep,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _InfoCard(
                    title: 'Round Robin',
                    subtitle: 'Fair tables with every team getting a shot.',
                    icon: Icons.grid_view_rounded,
                    tint: AppColors.accent,
                    iconColor: AppColors.brandField,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _InfoCard(
                    title: 'Points Table',
                    subtitle: 'Track momentum, NRR, and standings cleanly.',
                    icon: Icons.leaderboard_rounded,
                    tint: AppColors.infoSoft,
                    iconColor: AppColors.infoDeep,
                  ),
                ),
                SizedBox(width: 14),
                Expanded(
                  child: _InfoCard(
                    title: 'Fixtures',
                    subtitle: 'Keep upcoming clashes visible for everyone.',
                    icon: Icons.calendar_month_rounded,
                    tint: AppColors.purpleSoft,
                    iconColor: AppColors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What this desk supports',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  const _FeatureBullet(
                    text: 'Create group stages with flexible team counts.',
                  ),
                  const _FeatureBullet(
                    text: 'Publish branded fixtures for captains and fans.',
                  ),
                  const _FeatureBullet(
                    text: 'Move winning teams into knockout brackets quickly.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveTab extends StatelessWidget {
  const _LiveTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_activity'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 140.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(28.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'Matches Desk',
                      style: TextStyle(
                        color: AppColors.brandField,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Keep live and recently scored matches easy to open.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Use this space to jump into running scorecards, stay close to the current over, and keep your match flow organised.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.08, end: 0),
            SizedBox(height: 24.h),
            Text(
              'Match flow',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14.h),
            _ActivityCard(
              icon: Icons.sports_cricket_rounded,
              title: 'Open current matches',
              subtitle:
                  'Move from the dashboard into the right live scorecard quickly.',
              detail: 'Step 1',
              tint: AppColors.accent,
              iconColor: AppColors.brandField,
            ),
            SizedBox(height: 12.h),
            const _ActivityCard(
              icon: Icons.speed_rounded,
              title: 'Track match pace',
              subtitle: 'Stay close to run rate, overs remaining, and wickets.',
              detail: 'Step 2',
              tint: AppColors.infoSoft,
              iconColor: AppColors.infoDeep,
            ),
            SizedBox(height: 12.h),
            const _ActivityCard(
              icon: Icons.flash_on_rounded,
              title: 'Resume scoring fast',
              subtitle:
                  'Keep the scorer flow clean when the next ball matters most.',
              detail: 'Step 3',
              tint: AppColors.goldSoft,
              iconColor: AppColors.goldDeep,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTab extends StatelessWidget {
  final VoidCallback onLogout;
  final VoidCallback onOpenAppearance;

  const _ProfileTab({required this.onLogout, required this.onOpenAppearance});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        key: const PageStorageKey('dashboard_profile'),
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 140.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: AppColors.brandHeroGradient,
                borderRadius: BorderRadius.circular(28.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 30.r,
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Match Organizer',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Keep your scoring, leagues, and team actions in one place.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: const [
                      Expanded(
                        child: _ProfileStatChip(label: 'Matches', value: '24'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _ProfileStatChip(label: 'Teams', value: '08'),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _ProfileStatChip(label: 'Trophies', value: '03'),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 320.ms).slideY(begin: 0.08, end: 0),
            SizedBox(height: 24.h),
            Text(
              'Workspace',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 14.h),
            const _SettingsTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Score alerts and match reminders',
            ),
            SizedBox(height: 12.h),
            _SettingsTile(
              icon: Icons.palette_outlined,
              title: 'Appearance',
              subtitle: 'Theme and visual preferences',
              onTap: onOpenAppearance,
            ),
            SizedBox(height: 12.h),
            const _SettingsTile(
              icon: Icons.security_outlined,
              title: 'Privacy',
              subtitle: 'Session and account controls',
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.22),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionSheetTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionSheetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(icon, color: color, size: 24.r),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color tint;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.tint,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: iconColor, size: 22.r),
          ),
          SizedBox(height: 14.h),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final String text;

  const _FeatureBullet({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.r,
            height: 22.r,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: AppColors.primary,
              size: 14.r,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String detail;
  final Color tint;
  final Color iconColor;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.detail,
    required this.tint,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.r),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            detail,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatChip extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileStatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.r,
                color: AppColors.textSecondaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
