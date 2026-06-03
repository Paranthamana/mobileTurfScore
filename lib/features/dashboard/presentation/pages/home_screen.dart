import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:turfscore/core/utils/util_method.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/storage/session_manager.dart';
import '../../../../injection_container.dart' as di;
import '../../../scoring/presentation/pages/match_details_screen.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create: (_) => di.sl<DashboardBloc>()..add(LoadLiveMatchesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.sports_cricket, color: AppColors.primary, size: 28.r),
              SizedBox(width: 8.w),
              Text(
                'TurfScore',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: () {},
            ),
            IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await di.sl<SessionManager>().clear();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
          ],
        ),
        body: Builder(
          builder: (context) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(LoadLiveMatchesEvent());
                await Future.delayed(const Duration(seconds: 1));
              },
              color: AppColors.primary,
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildSectionHeader(
                    context,
                    'Live Matches',
                    showSeeAll: true,
                  ),
                  SizedBox(height: 16.h),
                  _buildLiveMatchesHorizontalList(),
                  SizedBox(height: 24.h),
                  _buildSectionHeader(
                    context,
                    'Recent Matches',
                    showSeeAll: true,
                  ),
                  SizedBox(height: 16.h),
                  _buildRecentMatchesList(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title, {
    bool showSeeAll = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (showSeeAll)
          TextButton(
            onPressed: () {},
            child: const Text(
              'See All',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveMatchesHorizontalList() {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading || state is DashboardInitial) {
          return SizedBox(
            height: 200.h,
            child: const Center(child: CircularProgressIndicator()),
          );
        } else if (state is DashboardError) {
          return SizedBox(
            height: 200.h,
            child: Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (state is DashboardLoaded) {
          final matches = state.liveMatches.reversed.toList();
          if (matches.isEmpty) {
            return SizedBox(
              height: 200.h,
              child: const Center(child: Text('No live matches available.')),
            );
          }

          return SizedBox(
            height: 210.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: matches.length,
              padding: EdgeInsets.zero,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Container(
                      width: 320.w,
                      margin: EdgeInsets.only(right: 16.w),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 4,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16.r),
                          onTap: () {
                            UtilMethod.debugLog(
                              "creat by user id : ${match.createdByUserId}",
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MatchDetailsScreen(
                                      match.matchId,
                                      createdByUserId: match.createdByUserId,
                                      match: matches[index],
                                    ),
                              ),
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              gradient: AppColors.darkCardGradient,
                            ),
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          8.r,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                                width: 8.r,
                                                height: 8.r,
                                                decoration: const BoxDecoration(
                                                  color: Colors.red,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                              .animate(
                                                onPlay:
                                                    (controller) =>
                                                        controller.repeat(),
                                              )
                                              .fadeIn(duration: 500.ms)
                                              .then()
                                              .fadeOut(duration: 500.ms),
                                          SizedBox(width: 6.w),
                                          const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        match.matchName,
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12.sp,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        match.hostTeam,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 16.w),
                                    Expanded(
                                      child: Text(
                                        match.visitorTeam,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${match.totalRuns}/${match.totalWickets}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 22.sp,
                                            ),
                                          ),
                                          Text(
                                            '${match.currentOvers} ov',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Center(
                                        child: Text(
                                          'VS',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'Yet to bat',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '-',
                                            style: TextStyle(
                                              color: Colors.transparent,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Toss: ${match.hostTeam} opted to bat',
                                      style: TextStyle(
                                        color: Colors.white60,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    Text(
                                      'Overs: ${match.overs}',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: index * 100))
                    .slideX(begin: 0.1, end: 0);
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecentMatchesList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12.r),
                onTap: () {
                  /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>  MatchDetailsScreen(1, match: ),
                    ),
                  ); */
                },
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'League Match • Yesterday',
                        style: TextStyle(
                          color: AppColors.textSecondaryLight,
                          fontSize: 12.sp,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Super Kings',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '165/8 (20)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Royal Strikers',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                            ),
                          ),
                          Text(
                            '166/4 (18.4)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Royal Strikers won by 6 wickets',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 200 + (index * 100)))
            .slideY(begin: 0.1, end: 0);
      },
    );
  }
}
