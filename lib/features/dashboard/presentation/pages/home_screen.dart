import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart' as di;
import '../../data/models/dashboard_live_match_response.dart';
import '../../../scoring/presentation/pages/match_details_screen.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onCreateMatch;
  final VoidCallback onLogout;
  final ValueChanged<int> onNavigate;

  const HomeScreen({
    super.key,
    required this.onCreateMatch,
    required this.onLogout,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<DashboardBloc>()..add(LoadLiveMatchesEvent()),
      child: Builder(
        builder: (context) {
          return SafeArea(
            bottom: false,
            child: BlocBuilder<DashboardBloc, DashboardState>(
              builder: (context, state) {
                final liveMatches =
                    state is DashboardLoaded
                        ? state.liveMatches
                        : <LiveMatchData>[];
                final completedMatches =
                    state is DashboardLoaded
                        ? state.recentMatches
                        : <CompletedMatchData>[];

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
                      child: _buildHeader(context, liveMatches.length),
                    ),
                    SizedBox(height: 24.h),
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primary,
                        onRefresh: () async {
                          context.read<DashboardBloc>().add(
                            LoadLiveMatchesEvent(),
                          );
                          await Future<void>.delayed(
                            const Duration(milliseconds: 800),
                          );
                        },
                        child: ListView(
                          key: const PageStorageKey('dashboard_home'),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 150.h),
                          children: [
                            _SectionHeader(
                              title: 'All Matches',
                              subtitle:
                                  liveMatches.isEmpty
                                      ? 'Live scorecards will appear here as soon as scoring starts.'
                                      : 'Every active scorecard is listed here first for quick access.',
                              actionLabel:
                                  liveMatches.isEmpty ? null : 'Matches tab',
                              onTap:
                                  liveMatches.isEmpty
                                      ? null
                                      : () => onNavigate(1),
                            ),
                            SizedBox(height: 14.h),
                            _buildAllMatches(context, state, liveMatches),
                            SizedBox(height: 28.h),
                            _SectionHeader(
                              title: 'Completed Matches',
                              subtitle:
                                  'Recent results and finished match summaries sit below the live desk.',
                              actionLabel:
                                  completedMatches.isEmpty
                                      ? null
                                      : 'Latest first',
                              onTap: completedMatches.isEmpty ? null : () {},
                            ),
                            SizedBox(height: 14.h),
                            _buildCompletedMatches(
                              context,
                              state,
                              completedMatches,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int liveCount) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0F172A), Color(0xFF166534)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            Icons.sports_cricket_rounded,
            color: Colors.white,
            size: 26.r,
          ),
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TurfScore',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                liveCount == 0
                    ? 'Track live scorecards and completed results in one place.'
                    : '$liveCount active match${liveCount == 1 ? '' : 'es'} on your scorer desk.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        PopupMenuButton<_HeaderAction>(
          onSelected: (action) {
            switch (action) {
              case _HeaderAction.profile:
                onNavigate(3);
                break;
              case _HeaderAction.logout:
                onLogout();
                break;
            }
          },
          itemBuilder:
              (context) => const [
                PopupMenuItem(
                  value: _HeaderAction.profile,
                  child: Text('Open Profile'),
                ),
                PopupMenuItem(
                  value: _HeaderAction.logout,
                  child: Text('Sign Out'),
                ),
              ],
          child: Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              Icons.more_horiz_rounded,
              color: const Color(0xFF0F172A),
              size: 24.r,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 260.ms).slideY(begin: 0.04, end: 0);
  }

  Widget _buildAllMatches(
    BuildContext context,
    DashboardState state,
    List<LiveMatchData> liveMatches,
  ) {
    if (state is DashboardLoading || state is DashboardInitial) {
      return SizedBox(
        height: 320.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 2,
          separatorBuilder: (_, _) => SizedBox(width: 14.w),
          itemBuilder:
              (_, __) =>
                  SizedBox(width: 326.w, child: const _LiveMatchSkeleton()),
        ),
      );
    }

    if (state is DashboardError) {
      return _StatusCard(
        title: 'Unable to load current matches',
        subtitle: state.message,
        icon: Icons.wifi_off_rounded,
        actionLabel: 'Refresh',
        onTap: () => context.read<DashboardBloc>().add(LoadLiveMatchesEvent()),
      );
    }

    if (liveMatches.isEmpty) {
      return _StatusCard(
        title: 'No matches are live right now',
        subtitle:
            'Create a new match and it will appear here as the first scorecard on the dashboard.',
        icon: Icons.sports_cricket_rounded,
        actionLabel: 'Create Match',
        onTap: onCreateMatch,
      );
    }

    return SizedBox(
      height: 320.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: liveMatches.length,
        separatorBuilder: (_, _) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final match = liveMatches[index];
          return SizedBox(
            width: 326.w,
            child: _LiveMatchCard(
                  match: match,
                  scoreLabel: '${match.totalRuns}/${match.totalWickets}',
                  oversLabel: '${match.currentOvers}/${match.overs} ov',
                  runRateLabel:
                      'CRR ${_currentRunRate(match).toStringAsFixed(2)}',
                  phaseLabel: _phaseLabel(match),
                  oversLeftLabel: _oversLeftLabel(match),
                  progress: _inningsProgress(match),
                  teamCode: _teamCode,
                  onTap: () => _openMatch(context, match),
                )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 80 * index))
                .slideX(begin: 0.06, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildCompletedMatches(
    BuildContext context,
    DashboardState state,
    List<CompletedMatchData> completedMatches,
  ) {
    if (state is DashboardLoading || state is DashboardInitial) {
      return Column(
        children: List.generate(
          2,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: const _LiveMatchSkeleton(),
          ),
        ),
      );
    }

    if (state is DashboardError) {
      return _StatusCard(
        title: 'Unable to load completed matches',
        subtitle: state.message,
        icon: Icons.history_toggle_off_rounded,
        actionLabel: 'Refresh',
        onTap: () => context.read<DashboardBloc>().add(LoadLiveMatchesEvent()),
      );
    }

    if (completedMatches.isEmpty) {
      return _StatusCard(
        title: 'No completed matches yet',
        subtitle:
            'Finished scorecards will appear here once a match reaches its result.',
        icon: Icons.emoji_events_outlined,
        actionLabel: 'Create Match',
        onTap: onCreateMatch,
      );
    }

    return Column(
      children:
          completedMatches
              .asMap()
              .entries
              .map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _CompletedMatchCard(
                        match: entry.value,
                        onTap: () => _openCompletedMatch(context, entry.value),
                      )
                      .animate()
                      .fadeIn(delay: Duration(milliseconds: 100 * entry.key))
                      .slideY(begin: 0.05, end: 0),
                ),
              )
              .toList(),
    );
  }

  void _openMatch(BuildContext context, LiveMatchData match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MatchDetailsScreen(
              match.matchId,
              createdByUserId: match.createdByUserId,
            ),
      ),
    );
  }

  void _openCompletedMatch(BuildContext context, CompletedMatchData match) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => MatchDetailsScreen(
              match.matchId,
              createdByUserId: match.createdByUserId,
            ),
      ),
    );
  }

  double _currentRunRate(LiveMatchData match) {
    final balls = _oversToBalls(match.currentOvers);
    if (balls == 0) {
      return 0;
    }
    return (match.totalRuns * 6) / balls;
  }

  double _inningsProgress(LiveMatchData match) {
    final totalBalls = match.overs <= 0 ? 0 : match.overs * 6;
    final currentBalls = _oversToBalls(match.currentOvers);
    if (totalBalls == 0) {
      return 0;
    }

    final value = currentBalls / totalBalls;
    if (value < 0) {
      return 0;
    }
    if (value > 1) {
      return 1;
    }
    return value;
  }

  String _phaseLabel(LiveMatchData match) {
    final currentBalls = _oversToBalls(match.currentOvers);
    final totalBalls = match.overs <= 0 ? 0 : match.overs * 6;
    if (currentBalls == 0) {
      return 'Ready to start';
    }
    if (currentBalls <= 36) {
      return 'Powerplay';
    }
    if (totalBalls > 0 && (totalBalls - currentBalls) <= 18) {
      return 'Death overs';
    }
    return 'Middle overs';
  }

  String _oversLeftLabel(LiveMatchData match) {
    final totalBalls = match.overs <= 0 ? 0 : match.overs * 6;
    if (totalBalls == 0) {
      return 'Flexible format';
    }

    final leftBalls = totalBalls - _oversToBalls(match.currentOvers);
    if (leftBalls <= 0) {
      return 'Final over pressure';
    }

    return '${_formatOvers(leftBalls)} left';
  }

  int _oversToBalls(String overs) {
    final parts = overs.split('.');
    final completedOvers = int.tryParse(parts.first) ?? 0;
    final balls = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    final safeBalls = balls.clamp(0, 5);
    return (completedOvers * 6) + safeBalls;
  }

  String _formatOvers(int balls) {
    final safeBalls = balls < 0 ? 0 : balls;
    return '${safeBalls ~/ 6}.${safeBalls % 6}';
  }

  String _teamCode(String teamName) {
    final words =
        teamName
            .trim()
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();

    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }

    if (words.isEmpty) {
      return 'TM';
    }

    final cleaned = words.first.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    if (cleaned.isEmpty) {
      return 'TM';
    }
    if (cleaned.length >= 3) {
      return cleaned.substring(0, 3).toUpperCase();
    }
    return cleaned.toUpperCase();
  }
}

enum _HeaderAction { profile, logout }

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        if (actionLabel != null)
          TextButton(
            onPressed: onTap,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _LiveMatchCard extends StatelessWidget {
  final LiveMatchData match;
  final String scoreLabel;
  final String oversLabel;
  final String runRateLabel;
  final String phaseLabel;
  final String oversLeftLabel;
  final double progress;
  final String Function(String) teamCode;
  final VoidCallback onTap;

  const _LiveMatchCard({
    required this.match,
    required this.scoreLabel,
    required this.oversLabel,
    required this.runRateLabel,
    required this.phaseLabel,
    required this.oversLeftLabel,
    required this.progress,
    required this.teamCode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8.r,
                          height: 8.r,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'LIVE',
                          style: TextStyle(
                            color: const Color(0xFFB91C1C),
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      match.matchName,
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _TeamLine(
                          code: teamCode(match.hostTeam),
                          name: match.hostTeam,
                        ),
                        SizedBox(height: 12.h),
                        _TeamLine(
                          code: teamCode(match.visitorTeam),
                          name: match.visitorTeam,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF166534)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          scoreLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          oversLabel,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          runRateLabel,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _MiniInfoChip(label: phaseLabel, icon: Icons.flag_rounded),
                  _MiniInfoChip(
                    label: oversLeftLabel,
                    icon: Icons.av_timer_rounded,
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  backgroundColor: AppColors.accent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Text(
                    'Open full scorecard',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamLine extends StatelessWidget {
  final String code;
  final String name;

  const _TeamLine({required this.code, required this.name});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF7F0),
            borderRadius: BorderRadius.circular(14.r),
          ),
          alignment: Alignment.center,
          child: Text(
            code,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF166534),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _MiniInfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _MiniInfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 16.r),
          SizedBox(width: 6.w),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedMatchCard extends StatelessWidget {
  final CompletedMatchData match;
  final VoidCallback onTap;

  const _CompletedMatchCard({required this.match, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(26.r),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      'COMPLETED',
                      style: TextStyle(
                        color: const Color(0xFF166534),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _timingLabel(match.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                match.matchName,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 14.h),
              _CompletedScoreLine(team: match.hostTeam, score: match.hostScore),
              SizedBox(height: 10.h),
              _CompletedScoreLine(
                team: match.visitorTeam,
                score: match.visitorScore,
              ),
              SizedBox(height: 14.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  match.result,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timingLabel(String value) {
    final createdAt = DateTime.tryParse(value)?.toLocal();
    if (createdAt == null) {
      return 'Recently';
    }

    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays >= 7) {
      return '${difference.inDays ~/ 7}w ago';
    }
    if (difference.inDays >= 1) {
      return '${difference.inDays}d ago';
    }
    if (difference.inHours >= 1) {
      return '${difference.inHours}h ago';
    }
    if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m ago';
    }
    return 'Just now';
  }
}

class _CompletedScoreLine extends StatelessWidget {
  final String team;
  final String score;

  const _CompletedScoreLine({required this.team, required this.score});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            team,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          score,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String actionLabel;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(22.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(26.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54.r,
            height: 54.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26.r),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.45,
            ),
          ),
          SizedBox(height: 18.h),
          ElevatedButton(onPressed: onTap, child: Text(actionLabel)),
        ],
      ),
    );
  }
}

class _LiveMatchSkeleton extends StatelessWidget {
  const _LiveMatchSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              const Spacer(),
              Container(
                width: 110.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: List.generate(
                    2,
                    (index) => Padding(
                      padding: EdgeInsets.only(bottom: index == 0 ? 12.h : 0),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Container(
                              height: 16.h,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Container(
                width: 112.w,
                height: 100.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(22.r),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
        ],
      ),
    );
  }
}
