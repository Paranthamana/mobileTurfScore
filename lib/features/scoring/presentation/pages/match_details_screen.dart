import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:turfscore/features/dashboard/data/models/dashboard_live_match_response.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/storage/session_manager.dart';
import '../../../../injection_container.dart';
import 'admin_scoring_screen.dart';

class MatchDetailsScreen extends StatelessWidget {
  final int matchId;
  final int? createdByUserId;
  final LiveMatchData match;

  const MatchDetailsScreen(
    this.matchId, {
    super.key,
    this.createdByUserId,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'IND vs AUS',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: 20.w),
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: 'Info'),
              Tab(text: 'Live'),
              Tab(text: 'Scorecard'),
              Tab(text: 'Overs'),
              Tab(text: 'Highlights'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildInfoTab(context, theme),
            _buildLiveTab(theme),
            _buildScorecardTab(theme),
            _buildOversTab(theme),
            _buildHighlightsTab(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTab(BuildContext context, ThemeData theme) {
    final currentUserId = sl<SessionManager>().userId;
    final canResumeScoring =
        createdByUserId != null &&
        currentUserId != null &&
        createdByUserId == currentUserId;

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildInfoRow(
                  Icons.sports_cricket,
                  'Match',
                  '${match.hostTeam} vs ${match.visitorTeam}',
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.emoji_events,
                  'Match Name',
                  match.matchName,
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.calendar_today,
                  'Date',
                  match.hostTeam,
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.access_time,
                  'Time',
                  '07:30 PM LOCAL',
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.monetization_on,
                  'Toss',
                  'India won the toss and elected to bat',
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(
                  Icons.stadium,
                  'Venue',
                  'Wankhede Stadium',
                  theme,
                ),
                const Divider(height: 24),
                _buildInfoRow(Icons.location_city, 'City', 'Mumbai', theme),
                if (canResumeScoring) ...[
                  SizedBox(height: 20.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => AdminScoringScreen(matchId: matchId),
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
        ),
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

  Widget _buildLiveTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              Text(
                'IND',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '185',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 48.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '/4',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '(18.2)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 18.sp,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                'CRR: 10.15  •  Target: 210',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                ),
                const Divider(height: 16),
                _buildPlayerScoreRow(
                  'V Kohli',
                  '45',
                  '32',
                  '4',
                  '1',
                  '140.6',
                  theme,
                ),
                SizedBox(height: 8.h),
                _buildPlayerScoreRow(
                  'H Pandya',
                  '12',
                  '8',
                  '1',
                  '0',
                  '150.0',
                  theme,
                ),
                SizedBox(height: 16.h),
                Row(
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
                ),
                const Divider(height: 16),
                _buildBowlerScoreRow(
                  'P Cummins',
                  '3.4',
                  '0',
                  '24',
                  '1',
                  '6.5',
                  theme,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 20.r,
              color: AppColors.primary,
            ),
            SizedBox(width: 8.w),
            Text(
              'Commentary',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildCommentaryItem(
          '18.2',
          'Cummins to Pandya, FOUR! Smashed down the ground.',
          theme,
        ),
        _buildCommentaryItem(
          '18.1',
          'Cummins to Pandya, 1 run, guided to third man.',
          theme,
        ),
        _buildCommentaryItem(
          '18.0',
          'P Cummins is back into the attack.',
          theme,
        ),
      ],
    );
  }

  Widget _buildCommentaryItem(String over, String comment, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40.w,
            child: Text(
              over,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(child: Text(comment, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildScorecardTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Card(
          margin: EdgeInsets.only(bottom: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ExpansionTile(
            shape: const Border(),
            title: Text(
              'India Innings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '185/4 (18.2 Overs)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            initiallyExpanded: true,
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Batting',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildPlayerScoreRow(
                      'V Kohli',
                      '45',
                      '32',
                      '4',
                      '1',
                      '140.6',
                      theme,
                    ),
                    _buildPlayerScoreRow(
                      'H Pandya',
                      '12',
                      '8',
                      '1',
                      '0',
                      '150.0',
                      theme,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Bowling',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildBowlerScoreRow(
                      'P Cummins',
                      '3.4',
                      '0',
                      '24',
                      '1',
                      '6.5',
                      theme,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: ExpansionTile(
            shape: const Border(),
            title: Text(
              'Australia Innings',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Yet to bat',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            children: [
              Padding(
                padding: EdgeInsets.all(16.w),
                child: const Text('Innings has not started yet.'),
              ),
            ],
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

  Widget _buildOversTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        _buildOverSummary(
          'Over 18',
          '14 Runs',
          '1 Wicket',
          '1 4 0 W 4 5wd',
          theme,
        ),
        _buildOverSummary(
          'Over 17',
          '6 Runs',
          '0 Wickets',
          '1 1 2 0 1 1',
          theme,
        ),
        _buildOverSummary(
          'Over 16',
          '12 Runs',
          '0 Wickets',
          '4 2 1 1 4 0',
          theme,
        ),
      ],
    );
  }

  Widget _buildOverSummary(
    String over,
    String runs,
    String wickets,
    String balls,
    ThemeData theme,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  over,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '$runs • $wickets',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children:
                  balls.split(' ').map((ball) {
                    bool isWicket = ball.contains('W');
                    bool isBoundary = ball.contains('4') || ball.contains('6');
                    Color bgColor = Colors.grey.withValues(alpha: 0.1);
                    Color textColor = AppColors.textLight;
                    if (isWicket) {
                      bgColor = AppColors.error;
                      textColor = Colors.white;
                    } else if (isBoundary) {
                      bgColor = AppColors.primary;
                      textColor = Colors.white;
                    }
                    return Container(
                      width: 32.r,
                      height: 32.r,
                      margin: EdgeInsets.only(right: 8.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        ball,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightsTab(ThemeData theme) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.primary, size: 24.r),
            SizedBox(width: 8.w),
            Text(
              'Innings 1 Highlights',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        _buildHighlightItem(
          '18.2',
          'W',
          'Cummins to Kohli, OUT! Caught at mid-on.',
          true,
          theme,
        ),
        _buildHighlightItem(
          '17.4',
          '4',
          'Starc to Pandya, FOUR! Driven through covers.',
          false,
          theme,
        ),
        _buildHighlightItem(
          '15.1',
          '6',
          'Zampa to Kohli, SIX! Massive hit over long-on.',
          false,
          theme,
        ),
        _buildHighlightItem(
          '12.5',
          'W',
          'Zampa to Rahul, OUT! Bowled him.',
          true,
          theme,
        ),
      ],
    );
  }

  Widget _buildHighlightItem(
    String over,
    String event,
    String comment,
    bool isWicket,
    ThemeData theme,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color:
                      isWicket
                          ? AppColors.error.withValues(alpha: 0.1)
                          : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  event,
                  style: TextStyle(
                    color: isWicket ? AppColors.error : AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Over $over',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondaryLight,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  comment,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
