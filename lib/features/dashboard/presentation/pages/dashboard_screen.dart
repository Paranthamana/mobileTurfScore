import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/colors.dart';
import '../../../scoring/presentation/pages/create_match_screen.dart';
import '../../../../injection_container.dart';
import '../../../scoring/presentation/bloc/scoring_bloc.dart';
import 'home_screen.dart';
// import '../../tournament/presentation/pages/tournament_screen.dart';
// import '../../history/presentation/pages/history_screen.dart';
// import '../../more/presentation/pages/more_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Center(child: Text('Tournament Screen')), // Placeholder
    const Center(child: Text('History Screen')), // Placeholder
    const Center(child: Text('More Screen')), // Placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateMatchBottomSheet(context);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ).animate().scale(
        delay: 400.ms,
        duration: 400.ms,
        curve: Curves.easeOutBack,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Home', 0),
              _buildNavItem(
                Icons.emoji_events_outlined,
                Icons.emoji_events,
                'Tournament',
                1,
              ),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(
                Icons.history_outlined,
                Icons.history,
                'History',
                2,
              ),
              _buildNavItem(Icons.menu_outlined, Icons.menu, 'More', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentIndex == index;
    final color = isSelected ? AppColors.primary : AppColors.textSecondaryLight;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? selectedIcon : unselectedIcon, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          )
          .animate(target: isSelected ? 1 : 0)
          .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.1, 1.1),
            duration: 200.ms,
          ),
    );
  }

  void _showCreateMatchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.sports_cricket,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Create Match',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Start a new quick match'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => BlocProvider(
                              create: (_) => sl<ScoringBloc>(),
                              child: const CreateMatchScreen(),
                            ),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.info.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.emoji_events,
                      color: AppColors.info,
                    ),
                  ),
                  title: const Text(
                    'Create Tournament',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text('Start a new league or cup'),
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to create tournament
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
