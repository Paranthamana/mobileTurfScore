import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/storage/session_manager.dart';
import '../../../../core/theme/colors.dart';
import '../../../../injection_container.dart';
import '../../data/models/match_details_response.dart';
import '../bloc/match_details_bloc.dart';
import '../bloc/match_details_event.dart';
import '../bloc/match_details_state.dart';
import 'admin_scoring_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  final int matchId;
  final int? createdByUserId;

  const MatchDetailsScreen(this.matchId, {super.key, this.createdByUserId});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  late final MatchDetailsBloc _matchDetailsBloc;

  @override
  void initState() {
    super.initState();
    _matchDetailsBloc =
        sl<MatchDetailsBloc>()
          ..add(LoadMatchDetailsEvent(matchId: widget.matchId));
  }

  @override
  void dispose() {
    _matchDetailsBloc.close();
    super.dispose();
  }

  Future<void> _refreshMatchDetails() async {
    _matchDetailsBloc.add(LoadMatchDetailsEvent(matchId: widget.matchId));
    await _matchDetailsBloc.stream.firstWhere(
      (state) => state is MatchDetailsLoaded || state is MatchDetailsError,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _matchDetailsBloc,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return BlocBuilder<MatchDetailsBloc, MatchDetailsState>(
            builder: (context, state) {
              final details =
                  state is MatchDetailsLoaded ? state.matchDetails : null;

              return DefaultTabController(
                length: 5,
                child: Scaffold(
                  backgroundColor: AppColors.backgroundLight,
                  appBar: AppBar(
                    toolbarHeight: 84.h,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.brandHeroGradient,
                      ),
                    ),
                    titleSpacing: 18.w,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          details?.title ?? 'Match Details',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          details == null
                              ? 'Live summary, scorecard and over-by-over view'
                              : '${details.statusLabel} | ${_fallback(details.overview.matchName)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.white.withValues(alpha: 0.74),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.read<MatchDetailsBloc>().add(
                            LoadMatchDetailsEvent(matchId: widget.matchId),
                          );
                        },
                        icon: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    bottom: PreferredSize(
                      preferredSize: Size.fromHeight(58.h),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
                        child: Container(
                          height: 42.h,
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.10),
                            ),
                          ),
                          child: TabBar(
                            isScrollable: false,
                            dividerColor: Colors.transparent,
                            labelPadding: EdgeInsets.zero,
                            indicator: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            indicatorSize: TabBarIndicatorSize.tab,
                            labelColor: AppColors.brandInk,
                            unselectedLabelColor: Colors.white,
                            labelStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                            ),
                            unselectedLabelStyle: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                            ),
                            splashBorderRadius: BorderRadius.circular(999.r),
                            tabs: const [
                              Tab(text: 'Info'),
                              Tab(text: 'Live'),
                              Tab(text: 'Score'),
                              Tab(text: 'Overs'),
                              Tab(text: 'Hlts'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      _buildStateAwareTab(
                        context,
                        state,
                        (data) => _buildInfoTab(context, theme, data),
                      ),
                      _buildStateAwareTab(
                        context,
                        state,
                        (data) => _buildLiveTab(theme, data),
                      ),
                      _buildStateAwareTab(
                        context,
                        state,
                        (data) => _buildScorecardTab(theme, data),
                      ),
                      _buildStateAwareTab(
                        context,
                        state,
                        (data) => _buildOversTab(theme, data),
                      ),
                      _buildStateAwareTab(
                        context,
                        state,
                        (data) => _buildHighlightsTab(theme, data),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStateAwareTab(
    BuildContext context,
    MatchDetailsState state,
    Widget Function(MatchDetailsData details) builder,
  ) {
    if (state is MatchDetailsLoading || state is MatchDetailsInitial) {
      return _buildCenteredState(
        icon: Icons.sports_cricket_rounded,
        title: 'Loading match desk',
        subtitle:
            'Pulling together live summary, innings cards, and ball-by-ball data.',
        child: const CircularProgressIndicator(),
      );
    }

    if (state is MatchDetailsError) {
      return _buildCenteredState(
        icon: Icons.error_outline_rounded,
        title: 'Unable to load this match',
        subtitle: state.message,
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<MatchDetailsBloc>().add(
              LoadMatchDetailsEvent(matchId: widget.matchId),
            );
          },
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Retry'),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshMatchDetails,
      child: builder((state as MatchDetailsLoaded).matchDetails),
    );
  }

  Widget _buildInfoTab(
    BuildContext context,
    ThemeData theme,
    MatchDetailsData details,
  ) {
    final currentUserId = sl<SessionManager>().userId;
    final matchOwnerId = details.overview.createdBy ?? widget.createdByUserId;
    final canResumeScoring =
        !details.overview.isCompleted &&
        matchOwnerId != null &&
        currentUserId != null &&
        matchOwnerId == currentUserId;
    final latestInnings =
        details.inningsSummaries.isNotEmpty
            ? details.inningsSummaries.last
            : null;

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        Container(
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
                  _buildStatusBadge(details.statusLabel),
                  const Spacer(),
                  if (details.overview.isSuperOver)
                    _buildTagPill(
                      'Super Over',
                      AppColors.goldDeep,
                      AppColors.goldSoft,
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              Text(
                _fallback(details.overview.matchName),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDashboardTeamLine(
                          label: 'HOST',
                          teamName: details.hostTeamName,
                        ),
                        SizedBox(height: 12.h),
                        _buildDashboardTeamLine(
                          label: 'VISITOR',
                          teamName: details.visitorTeamName,
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
                      gradient: AppColors.brandHeroGradient,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          latestInnings == null
                              ? details.statusLabel.toUpperCase()
                              : '${latestInnings.totalRuns}/${latestInnings.totalWickets}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          latestInnings == null
                              ? 'Match Desk'
                              : '${latestInnings.overs} ov',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          details.statusLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  _matchResult(details),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.brandField,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildDashboardInfoChip(
                    'Overs ${details.overview.overs}',
                    Icons.av_timer_rounded,
                  ),
                  _buildDashboardInfoChip(
                    'Wickets ${details.overview.wickets}',
                    Icons.sports_baseball_rounded,
                  ),
                  _buildDashboardInfoChip(
                    latestInnings == null
                        ? 'No innings yet'
                        : 'Last ${latestInnings.overs} ov',
                    Icons.flag_rounded,
                  ),
                ],
              ),
              if (canResumeScoring) ...[
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      backgroundColor: AppColors.accent,
                      foregroundColor: AppColors.brandInk,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) =>
                                  AdminScoringScreen(matchId: widget.matchId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      'Resume Scoring',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: 18.h),
        _buildSectionTitle(
          theme,
          'Match Overview',
          'Quick facts and match timeline',
          icon: Icons.dashboard_customize_rounded,
        ),
        SizedBox(height: 12.h),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.emoji_events_outlined,
                  'Match Name',
                  _fallback(details.overview.matchName),
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  'Created',
                  _formatDateTime(details.overview.createdAt),
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.update_rounded,
                  'Updated',
                  _formatDateTime(details.overview.updatedAt),
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.bolt_rounded,
                  'Super Over',
                  details.overview.isSuperOver ? 'Yes' : 'No',
                  theme,
                ),
              ],
            ),
          ),
        ),
        if (details.inningsSummaries.isNotEmpty) ...[
          SizedBox(height: 18.h),
          _buildSectionTitle(
            theme,
            'Innings Tracker',
            'How each innings progressed',
            icon: Icons.layers_rounded,
          ),
          SizedBox(height: 12.h),
          ...details.inningsSummaries.map(
            (innings) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildInningsSummaryCard(theme, details, innings),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiveTab(ThemeData theme, MatchDetailsData details) {
    final live = details.liveSummary;
    if (live == null) {
      return _buildEmptyState('Live summary not available.');
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTagPill(
                    'Innings ${live.inningsNumber}',
                    AppColors.errorDeep,
                    AppColors.liveSoft,
                  ),
                  SizedBox(width: 8.w),
                  _buildTagPill(
                    live.target > 0 ? 'CHASE' : 'SETUP',
                    AppColors.successDeep,
                    AppColors.successSoft,
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      _fallback(live.battingTeamName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildDashboardTeamLine(
                          label: 'BATTING',
                          teamName: live.battingTeamName,
                        ),
                        SizedBox(height: 12.h),
                        _buildDashboardTeamLine(
                          label: 'BOWLING',
                          teamName: live.bowlingTeamName,
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
                      gradient: AppColors.brandHeroGradient,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'LIVE SCORE',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '${live.totalRuns}/${live.totalWickets}',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28.sp,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${live.overs} ov',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'CRR ${live.currentRunRate}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      live.target > 0
                          ? 'CRR ${live.currentRunRate} | Target ${live.target} | RRR ${live.requiredRunRate}'
                          : 'CRR ${live.currentRunRate} | Partnership ${live.partnershipRuns} (${live.partnershipBalls})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.brandInk,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      live.target > 0
                          ? 'Need ${live.runsNeeded} runs in ${live.ballsRemaining} balls to finish the chase.'
                          : 'Batting first and setting the pace over ${live.totalMatchOvers} overs.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  _buildLiveMetricChip('Score', live.score),
                  _buildLiveMetricChip('Overs', live.overs),
                  _buildLiveMetricChip(
                    'Partnership',
                    '${live.partnershipRuns} (${live.partnershipBalls})',
                  ),
                  _buildLiveMetricChip(
                    'Balls Left',
                    live.ballsRemaining.toString(),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        _buildSectionTitle(
          theme,
          'Players In Focus',
          'Current batters and bowler snapshot',
          icon: Icons.insights_rounded,
        ),
        SizedBox(height: 12.h),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22.r),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Batting Now',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    _buildCompactScorePill(
                      '${live.partnershipRuns} in ${live.partnershipBalls}',
                      AppColors.successSoft,
                      AppColors.successDeep,
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                _buildBattingHeader(theme),
                const Divider(height: 16),
                if (details.striker != null)
                  _buildPlayerScoreRow(
                    details.striker!.playerName,
                    details.striker!.runs.toString(),
                    details.striker!.balls.toString(),
                    details.striker!.fours.toString(),
                    details.striker!.sixes.toString(),
                    details.striker!.strikeRate,
                    theme,
                    isOnStrike: details.striker!.isCurrentStriker,
                  ),
                if (details.nonStriker != null)
                  _buildPlayerScoreRow(
                    details.nonStriker!.playerName,
                    details.nonStriker!.runs.toString(),
                    details.nonStriker!.balls.toString(),
                    details.nonStriker!.fours.toString(),
                    details.nonStriker!.sixes.toString(),
                    details.nonStriker!.strikeRate,
                    theme,
                    isOnStrike: details.nonStriker!.isCurrentStriker,
                  ),
                SizedBox(height: 16.h),
                Text(
                  'Current Bowler',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 10.h),
                if (details.bowler != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                details.bowler!.playerName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            _buildCompactScorePill(
                              '${details.bowler!.overs} ov',
                              AppColors.infoSoft,
                              AppColors.infoDeep,
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _buildLiveMetricChip(
                                'Runs',
                                details.bowler!.runs.toString(),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildLiveMetricChip(
                                'Wkts',
                                details.bowler!.wickets.toString(),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: _buildLiveMetricChip(
                                'Econ',
                                details.bowler!.economy,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    'Bowler details are not available right now.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 18.h),
        _buildSectionTitle(
          theme,
          'Commentary',
          'Latest ball-by-ball notes',
          icon: Icons.chat_bubble_outline_rounded,
        ),
        SizedBox(height: 12.h),
        if (details.commentary.isEmpty)
          _buildEmptyState('Commentary not available.')
        else
          ...details.commentary
              .take(6)
              .map((item) => _buildCommentaryItem(item, theme)),
      ],
    );
  }

  Widget _buildScorecardTab(ThemeData theme, MatchDetailsData details) {
    if (details.scorecards.isEmpty) {
      return _buildEmptyState('Scorecard not available.');
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children:
          details.scorecards.map((innings) {
            return Container(
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ExpansionTile(
                initiallyExpanded:
                    innings.inningsNumber ==
                    details.scorecards.first.inningsNumber,
                tilePadding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                  vertical: 10.h,
                ),
                childrenPadding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
                shape: const Border(),
                collapsedShape: const Border(),
                title: Text(
                  innings.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: [
                      _buildCompactScorePill(
                        '${innings.totalRuns}/${innings.totalWickets}',
                        AppColors.successSoft,
                        AppColors.successDeep,
                      ),
                      _buildCompactScorePill(
                        '${innings.overs} ov',
                        AppColors.infoSoft,
                        AppColors.infoDeep,
                      ),
                      if (innings.target > 0)
                        _buildCompactScorePill(
                          'Target ${innings.target}',
                          AppColors.goldSoft,
                          AppColors.goldDeep,
                        ),
                    ],
                  ),
                ),
                children: [
                  _buildScoreSectionTitle(theme, 'Batting Card'),
                  SizedBox(height: 10.h),
                  _buildScorecardHeader(theme),
                  SizedBox(height: 8.h),
                  if (innings.batting.isEmpty)
                    _buildCompactEmptyLine('No batting data available.')
                  else
                    ...innings.batting.map(
                      (entry) => _buildScorecardBattingRow(entry, theme),
                    ),
                  SizedBox(height: 18.h),
                  _buildScoreSectionTitle(theme, 'Bowling Card'),
                  SizedBox(height: 10.h),
                  _buildBowlingHeader(theme),
                  SizedBox(height: 8.h),
                  if (innings.bowling.isEmpty)
                    _buildCompactEmptyLine('No bowling data available.')
                  else
                    ...innings.bowling.map(
                      (entry) => _buildBowlerScoreRow(
                        entry.playerName,
                        entry.overs,
                        '-',
                        entry.runs.toString(),
                        entry.wickets.toString(),
                        entry.economy,
                        theme,
                      ),
                    ),
                  if (innings.fallOfWickets.isNotEmpty) ...[
                    SizedBox(height: 18.h),
                    _buildScoreSectionTitle(theme, 'Fall Of Wickets'),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children:
                          innings.fallOfWickets.map((entry) {
                            return Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 10.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLight,
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Text(
                                '${entry.playerName}  ${entry.score} (${entry.overs})',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildOversTab(ThemeData theme, MatchDetailsData details) {
    if (details.overs.isEmpty) {
      return _buildEmptyState('Over summary not available.');
    }

    final inningsOvers = _splitOversByInnings(details);

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        ...inningsOvers.entries.map((entry) {
          return Padding(
            padding: EdgeInsets.only(bottom: 22.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(
                  theme,
                  'Innings ${entry.key}',
                  'Over-by-over flow for this innings',
                  icon: Icons.view_timeline_rounded,
                ),
                SizedBox(height: 12.h),
                ...entry.value.reversed.map((over) {
                  final runs = _overRuns(over.ballValues);
                  final wickets = _overWickets(over.ballValues);
                  return _buildModernOverSummary(
                    over.overLabel,
                    '$runs Runs',
                    '$wickets ${wickets == 1 ? 'Wicket' : 'Wickets'}',
                    over.ballValues.join(' '),
                    theme,
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHighlightsTab(ThemeData theme, MatchDetailsData details) {
    final highlights = _buildImprovedHighlights(details);
    if (highlights.isEmpty) {
      return _buildEmptyState('Highlights not available.');
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      children: [
        _buildSectionTitle(
          theme,
          'Match Highlights',
          'Big moments from the innings timeline',
          icon: Icons.auto_awesome_rounded,
        ),
        SizedBox(height: 20.h),
        ...highlights.map((item) {
          final event = _highlightEventLabel(item);
          return _buildHighlightItem(
            item.over,
            event,
            item.commentaryText,
            item.isWicket,
            theme,
          );
        }),
      ],
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20.r, color: AppColors.primary),
        SizedBox(width: 12.w),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenteredState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 24.h),
          children: [
            SizedBox(height: constraints.maxHeight * 0.16),
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 68.r,
                    height: 68.r,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE2FBE8), Color(0xFFDCEBFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 34.r, color: AppColors.primary),
                  ),
                  SizedBox(height: 18.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  child,
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(
    ThemeData theme,
    String title,
    String subtitle, {
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: AppColors.brandField, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondaryLight,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardTeamLine({
    required String label,
    required String teamName,
  }) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(14.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.brandField,
              fontSize: 9.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            _fallback(teamName),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardInfoChip(String label, IconData icon) {
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
            style: TextStyle(
              color: AppColors.textLight,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScorePill(
    String label,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildScoreSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w800,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildCompactEmptyLine(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: AppColors.textSecondaryLight,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildScorecardHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text('Batter', style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            'R',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'B',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'Boundaries',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'SR',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildScorecardBattingRow(
    ScorecardBattingEntry entry,
    ThemeData theme,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: entry.isOut ? Colors.white : AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.playerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  entry.isOut ? 'out' : 'not out',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondaryLight,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              entry.runs.toString(),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              entry.balls.toString(),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildBoundaryStatBadge('4', entry.fours, AppColors.infoDeep),
                  SizedBox(width: 6.w),
                  _buildBoundaryStatBadge('6', entry.sixes, AppColors.goldDeep),
                ],
              ),
            ),
          ),
          Expanded(
            child: Text(
              entry.strikeRate,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoundaryStatBadge(String label, int value, Color color) {
    final badge = Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: value > 0 ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: value > 0 ? 0.22 : 0.10),
        ),
      ),
      child: Text(
        '$label:$value',
        style: TextStyle(
          color: value > 0 ? color : AppColors.textSecondaryLight,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    if (value <= 0) {
      return badge;
    }

    return badge
        .animate(key: ValueKey('$label-$value'))
        .scale(
          begin: const Offset(0.88, 0.88),
          end: const Offset(1, 1),
          duration: 320.ms,
          curve: Curves.easeOutBack,
        )
        .shimmer(duration: 700.ms, color: color.withValues(alpha: 0.20));
  }

  Widget _buildStatusBadge(String label) {
    Color backgroundColor;
    Color textColor;

    switch (label.toLowerCase()) {
      case 'completed':
        backgroundColor = AppColors.successSoft;
        textColor = AppColors.successDeep;
        break;
      case 'live':
        backgroundColor = const Color(0xFFFFE3E3);
        textColor = const Color(0xFFB42318);
        break;
      default:
        backgroundColor = AppColors.infoSoft;
        textColor = AppColors.infoDeep;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildTagPill(String text, Color textColor, Color backgroundColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInningsSummaryCard(
    ThemeData theme,
    MatchDetailsData details,
    InningsSummary innings,
  ) {
    final battingTeam = _teamNameById(details.teams, innings.battingTeamId);
    final bowlingTeam = _teamNameById(details.teams, innings.bowlingTeamId);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
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
              _buildTagPill(
                'Innings ${innings.inningsNumber}',
                AppColors.brandInk,
                AppColors.surfaceMuted,
              ),
              const Spacer(),
              _buildTagPill(
                innings.isCompleted ? 'Closed' : 'In Progress',
                innings.isCompleted
                    ? AppColors.successDeep
                    : AppColors.goldDeep,
                innings.isCompleted
                    ? AppColors.successSoft
                    : AppColors.goldSoft,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            battingTeam,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            '${innings.totalRuns}/${innings.totalWickets} in ${innings.overs} overs',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bowling: $bowlingTeam',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                if (innings.target > 0) ...[
                  SizedBox(height: 6.h),
                  Text(
                    'Target: ${innings.target}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveMetricChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondaryLight,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              color: const Color(0xFF0F172A),
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBattingHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text('Batter', style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            'R',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'B',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '4s',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            '6s',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'SR',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildBowlingHeader(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text('Bowler', style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Text(
            'O',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'M',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'R',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          child: Text(
            'W',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'ER',
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerScoreRow(
    String name,
    String r,
    String b,
    String fours,
    String sixes,
    String sr,
    ThemeData theme, {
    bool isOnStrike = false,
    String suffix = '',
  }) {
    final displayName =
        isOnStrike
            ? '$name *'
            : suffix.isEmpty
            ? name
            : '$name ($suffix)';

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(displayName, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              r,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              b,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              fours,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              sixes,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              sr,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBowlerScoreRow(
    String name,
    String o,
    String m,
    String r,
    String w,
    String er,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(name, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              o,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              m,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              r,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              w,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              er,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentaryItem(CommentaryItem item, ThemeData theme) {
    final isWicket = item.isWicket;
    final isBigHit = item.runs == 4 || item.runs == 6;
    final accentColor =
        isWicket
            ? AppColors.error
            : isBigHit
            ? AppColors.primary
            : AppColors.brandInk;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            alignment: Alignment.center,
            child: Text(
              item.over,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: accentColor,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.commentaryText,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF0F172A),
                    height: 1.35,
                  ),
                ),
                if (item.extraType.trim().isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    item.extraType.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernOverSummary(
    String over,
    String runs,
    String wickets,
    String balls,
    ThemeData theme,
  ) {
    final ballItems =
        balls.split(' ').where((ball) => ball.isNotEmpty).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  over,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '$runs | $wickets',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            '${ballItems.length} ball events',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children:
                ballItems.map((ball) {
                  final normalized = ball.toUpperCase();
                  final isWicket = normalized.contains('W');
                  final isBoundary =
                      normalized.contains('4') || normalized.contains('6');
                  final isExtra =
                      normalized.startsWith('WD') ||
                      normalized.startsWith('NB') ||
                      normalized.startsWith('LB') ||
                      normalized.startsWith('B');

                  Color bgColor = AppColors.surfaceMuted;
                  Color textColor = AppColors.brandInk;

                  if (isWicket) {
                    bgColor = AppColors.error;
                    textColor = Colors.white;
                  } else if (isBoundary) {
                    bgColor = AppColors.primary;
                    textColor = Colors.white;
                  } else if (isExtra) {
                    bgColor = AppColors.goldSoft;
                    textColor = AppColors.goldDeep;
                  }

                  return Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ball,
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 12.sp,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightItem(
    String over,
    String event,
    String comment,
    bool isWicket,
    ThemeData theme,
  ) {
    final normalizedEvent = event.trim().toUpperCase();
    final accentColor =
        isWicket
            ? AppColors.error
            : normalizedEvent == '6'
            ? AppColors.goldDeep
            : normalizedEvent == '4'
            ? AppColors.infoDeep
            : normalizedEvent == 'WD' ||
                normalizedEvent == 'NB' ||
                normalizedEvent == 'LB' ||
                normalizedEvent == 'B'
            ? AppColors.goldDeep
            : AppColors.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50.r,
            height: 50.r,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              event,
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w900,
                fontSize: 16.sp,
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Over $over',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  comment,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    height: 1.35,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60.r,
            height: 60.r,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(18.r),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.inbox_rounded,
              size: 28.r,
              color: AppColors.textSecondaryLight,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Not available';
    final local = dateTime.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$day/$month/${local.year} $hour:$minute $period';
  }

  String _matchResult(MatchDetailsData details) {
    if (details.overview.isTie) return 'Match tied';
    if (details.overview.winnerTeamId == null) return 'Not decided';
    for (final team in details.teams) {
      if (team.teamId == details.overview.winnerTeamId) {
        return '${team.teamName} won';
      }
    }
    return 'Not decided';
  }

  List<CommentaryItem> _buildImprovedHighlights(MatchDetailsData details) {
    final highlights =
        details.commentary.where((item) {
          final text = item.commentaryText.toUpperCase();
          return item.isWicket ||
              item.runs >= 4 ||
              item.extraType.trim().isNotEmpty ||
              text.contains('FOUR') ||
              text.contains('SIX') ||
              text.contains('OUT');
        }).toList();

    if (highlights.isNotEmpty) {
      return highlights.take(12).toList();
    }

    return details.highlights.take(12).toList();
  }

  String _highlightEventLabel(CommentaryItem item) {
    if (item.isWicket) {
      return 'W';
    }

    final extra = item.extraType.trim().toLowerCase();
    if (extra.isNotEmpty) {
      switch (extra) {
        case 'wide':
        case 'wd':
          return 'WD';
        case 'no_ball':
        case 'nb':
          return 'NB';
        case 'bye':
        case 'b':
          return 'B';
        case 'leg_bye':
        case 'lb':
          return 'LB';
        default:
          return extra.toUpperCase();
      }
    }

    if (item.runs == 4 || item.runs == 6) {
      return item.runs.toString();
    }

    if (item.runs > 0) {
      return item.runs.toString();
    }

    return 'DOT';
  }

  String _fallback(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? 'Not available' : trimmed;
  }

  String _teamNameById(List<TeamInfo> teams, int teamId) {
    for (final team in teams) {
      if (team.teamId == teamId) {
        return _fallback(team.teamName);
      }
    }
    return 'Team $teamId';
  }

  Map<int, List<OverByBall>> _splitOversByInnings(MatchDetailsData details) {
    if (details.overs.isEmpty) {
      return <int, List<OverByBall>>{};
    }

    final summaries = [
      ...details.inningsSummaries,
    ]..sort((left, right) => left.inningsNumber.compareTo(right.inningsNumber));
    final result = <int, List<OverByBall>>{};

    if (summaries.isEmpty) {
      result[1] = [...details.overs];
      return result;
    }

    var cursor = 0;
    for (var index = 0; index < summaries.length; index++) {
      if (cursor >= details.overs.length) {
        break;
      }

      final summary = summaries[index];
      final remaining = details.overs.length - cursor;
      final rawExpectedCount = _oversSummaryCount(summary.overs);
      final expectedCount =
          index == summaries.length - 1
              ? remaining
              : rawExpectedCount < 0
              ? 0
              : rawExpectedCount > remaining
              ? remaining
              : rawExpectedCount;

      if (expectedCount <= 0) {
        continue;
      }

      result[summary.inningsNumber] =
          details.overs.sublist(cursor, cursor + expectedCount).toList();
      cursor += expectedCount;
    }

    if (cursor < details.overs.length) {
      final fallbackInnings =
          summaries.isNotEmpty ? summaries.last.inningsNumber : 1;
      result.putIfAbsent(fallbackInnings, () => <OverByBall>[]);
      result[fallbackInnings]!.addAll(details.overs.sublist(cursor));
    }

    return result;
  }

  int _oversSummaryCount(String overs) {
    final parts = overs.split('.');
    final completedOvers = int.tryParse(parts.first.trim()) ?? 0;
    final balls = parts.length > 1 ? int.tryParse(parts[1].trim()) ?? 0 : 0;
    return completedOvers + (balls > 0 ? 1 : 0);
  }

  int _overRuns(List<String> balls) {
    var total = 0;
    for (final ball in balls) {
      total += _ballRuns(ball);
    }
    return total;
  }

  int _overWickets(List<String> balls) {
    return balls.where((ball) => ball.trim().toUpperCase() == 'W').length;
  }

  int _ballRuns(String ball) {
    final normalized = ball.trim().toUpperCase();
    if (normalized == 'W') return 0;
    if (normalized == 'WD') return 1;
    if (normalized == 'NB') return 1;

    if (normalized.startsWith('WD+')) {
      final extra = int.tryParse(normalized.substring(3)) ?? 0;
      return 1 + extra;
    }
    if (normalized.startsWith('NB+')) {
      final extra = int.tryParse(normalized.substring(3)) ?? 0;
      return 1 + extra;
    }
    if (normalized.startsWith('B+')) {
      return int.tryParse(normalized.substring(2)) ?? 0;
    }
    if (normalized.startsWith('LB+')) {
      return int.tryParse(normalized.substring(3)) ?? 0;
    }

    return int.tryParse(normalized) ?? 0;
  }
}
