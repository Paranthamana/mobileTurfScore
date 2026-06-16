import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/brand_backdrop.dart';
import '../../../../injection_container.dart';
import '../bloc/scoring_bloc.dart';
import '../bloc/scoring_event.dart';
import '../bloc/scoring_state.dart';

class AdminScoringScreen extends StatefulWidget {
  final int matchId;

  const AdminScoringScreen({super.key, required this.matchId});

  @override
  State<AdminScoringScreen> createState() => _AdminScoringScreenState();
}

class _AdminScoringScreenState extends State<AdminScoringScreen>
    with SingleTickerProviderStateMixin {
  late final ScoringBloc _scoringBloc;
  late final AnimationController _boundaryAnimationController;
  late final Animation<double> _boundaryAnimation;
  Timer? _keyboardCooldownTimer;
  bool _isKeyboardCooldown = false;
  bool _isBatsmanSheetOpen = false;
  bool _isBatsmanDialogQueued = false;
  bool _isBowlerSheetOpen = false;
  bool _isBowlerDialogQueued = false;
  bool _isResultDialogOpen = false;
  String _lastPendingBatsmanKey = '';
  String _lastPendingBowlerKey = '';
  String _lastResultDialogKey = '';
  String? _boundaryLabel;
  Color _boundaryColor = AppColors.info;

  @override
  void initState() {
    super.initState();
    _boundaryAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _boundaryAnimation = CurvedAnimation(
      parent: _boundaryAnimationController,
      curve: Curves.easeOutCubic,
    );
    _boundaryAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() {
          _boundaryLabel = null;
        });
        _boundaryAnimationController.reset();
      }
    });
    _scoringBloc =
        sl<ScoringBloc>()..add(ResumeScoringRequested(widget.matchId));
  }

  @override
  void dispose() {
    _keyboardCooldownTimer?.cancel();
    _boundaryAnimationController.dispose();
    _scoringBloc.close();
    super.dispose();
  }

  Widget _buildPortraitLayout(ThemeData theme, Map<String, dynamic> data) {
    final thisOver = List<String>.from(
      data['thisOver'] as List? ?? const <String>[],
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(6.w, 6.h, 6.w, 6.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 12.h,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildScoreHeader(theme, data),
                SizedBox(height: 6.h),
                _buildMatchStats(theme, data),
                SizedBox(height: 6.h),
                _buildScorecardSection(theme, data),
                SizedBox(height: 6.h),
                _buildThisOverSection(theme, thisOver),
                SizedBox(height: 6.h),
                _buildAdvancedControls(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLandscapeLayout(ThemeData theme, Map<String, dynamic> data) {
    final thisOver = List<String>.from(
      data['thisOver'] as List? ?? const <String>[],
    );
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: Column(
              children: [
                _buildScoreHeader(theme, data),
                SizedBox(height: 8.h),
                _buildMatchStats(theme, data),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8.w),
            child: Column(
              children: [
                _buildScorecardSection(theme, data),
                SizedBox(height: 8.h),
                _buildThisOverSection(theme, thisOver),
                SizedBox(height: 8.h),
                _buildAdvancedControls(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoreHeader(ThemeData theme, Map<String, dynamic> data) {
    final battingTeamName = data['battingTeamName']?.toString() ?? '-';
    final inningsNumber = (data['inningsNumber'] as int?) ?? 1;
    final totalRuns = (data['totalRuns'] as int?) ?? 0;
    final wickets = (data['wickets'] as int?) ?? 0;
    final overs = data['overs']?.toString() ?? '0.0';
    final currentRunRate = data['currentRunRate']?.toString() ?? '0.0';
    final totalMatchOvers = data['totalMatchOvers']?.toString() ?? '0';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.brandHeroGradient,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandField.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  battingTeamName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  _inningsLabel(inningsNumber),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$totalRuns',
                          style: theme.textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontSize: 40.sp,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                          child: Text(
                            '/$wickets',
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$overs / $totalMatchOvers ov',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              )
              .animate(key: ValueKey('$totalRuns-$wickets'))
              .scale(begin: const Offset(0.94, 0.94), duration: 220.ms),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Current Run Rate',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  currentRunRate,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchStats(ThemeData theme, Map<String, dynamic> data) {
    final target = (data['target'] as int?) ?? 0;
    final requiredRunRate = data['requiredRunRate']?.toString() ?? '0';
    final partnershipRuns = (data['partnershipRuns'] as int?) ?? 0;
    final partnershipBalls = (data['partnershipBalls'] as int?) ?? 0;
    final extrasTotal = (data['extrasTotal'] as int?) ?? 0;
    final wideRuns = (data['wideRuns'] as int?) ?? 0;
    final noBallRuns = (data['noBallRuns'] as int?) ?? 0;
    final byeRuns = (data['byeRuns'] as int?) ?? 0;
    final legByeRuns = (data['legByeRuns'] as int?) ?? 0;
    return Container(
      margin: EdgeInsets.only(top: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCompactStatTile(
                  theme: theme,
                  title: 'Target',
                  value: target > 0 ? '$target' : '-',
                  tint: AppColors.primary.withValues(alpha: 0.06),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: _buildCompactStatTile(
                  theme: theme,
                  title: 'Req RR',
                  value: target > 0 ? requiredRunRate : '-',
                  tint: AppColors.infoSoft,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28.r,
                        height: 28.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.link_rounded,
                          color: AppColors.primary,
                          size: 15.r,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Partnership',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10.sp,
                                color: AppColors.textSecondaryLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              '$partnershipRuns in $partnershipBalls balls',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: _buildExtraStatChip(
                  theme: theme,
                  label: 'Extras',
                  value: '$extrasTotal',
                  tint: AppColors.goldSoft,
                  textColor: AppColors.goldDeep,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildExtraStatChip(
                  theme: theme,
                  label: 'Wd',
                  value: '$wideRuns',
                  tint: AppColors.warningSoft,
                  textColor: AppColors.warningDeep,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildExtraStatChip(
                  theme: theme,
                  label: 'Nb',
                  value: '$noBallRuns',
                  tint: AppColors.errorSoft,
                  textColor: AppColors.errorDeep,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildExtraStatChip(
                  theme: theme,
                  label: 'B',
                  value: '$byeRuns',
                  tint: AppColors.infoSoft,
                  textColor: AppColors.infoDeep,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _buildExtraStatChip(
                  theme: theme,
                  label: 'Lb',
                  value: '$legByeRuns',
                  tint: AppColors.purpleSoft,
                  textColor: AppColors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatTile({
    required ThemeData theme,
    required String title,
    required String value,
    required Color tint,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 10.sp,
              color: AppColors.textSecondaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExtraStatChip({
    required ThemeData theme,
    required String label,
    required String value,
    required Color tint,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 9.sp,
              color: textColor.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorecardSection(ThemeData theme, Map<String, dynamic> data) {
    final strikerName = data['strikerName']?.toString() ?? '-';
    final strikerRuns = '${(data['strikerRuns'] as int?) ?? 0}';
    final strikerBalls = '${(data['strikerBalls'] as int?) ?? 0}';
    final strikerFours = '${(data['strikerFours'] as int?) ?? 0}';
    final strikerSixes = '${(data['strikerSixes'] as int?) ?? 0}';
    final strikerStrikeRate = data['strikerStrikeRate']?.toString() ?? '0.0';
    final strikerIsCurrent = (data['strikerIsCurrent'] as bool?) ?? true;
    final nonStrikerName = data['nonStrikerName']?.toString() ?? '-';
    final nonStrikerRuns = '${(data['nonStrikerRuns'] as int?) ?? 0}';
    final nonStrikerBalls = '${(data['nonStrikerBalls'] as int?) ?? 0}';
    final nonStrikerFours = '${(data['nonStrikerFours'] as int?) ?? 0}';
    final nonStrikerSixes = '${(data['nonStrikerSixes'] as int?) ?? 0}';
    final nonStrikerStrikeRate =
        data['nonStrikerStrikeRate']?.toString() ?? '0.0';
    final nonStrikerIsCurrent = (data['nonStrikerIsCurrent'] as bool?) ?? false;
    final bowlerName = data['bowlerName']?.toString() ?? '-';
    final bowlerOvers = data['bowlerOvers']?.toString() ?? '0.0';
    final bowlerMaidens = '${(data['bowlerMaidens'] as int?) ?? 0}';
    final bowlerRuns = '${(data['bowlerRuns'] as int?) ?? 0}';
    final bowlerWickets = '${(data['bowlerWickets'] as int?) ?? 0}';
    final bowlerEconomy = data['bowlerEconomy']?.toString() ?? '0.0';
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('Batsman', style: theme.textTheme.bodySmall),
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
            const Divider(height: 8),
            _buildPlayerRow(
              strikerName,
              strikerRuns,
              strikerBalls,
              strikerFours,
              strikerSixes,
              strikerStrikeRate,
              isStriker: strikerIsCurrent,
              theme: theme,
            ),
            SizedBox(height: 2.h),
            _buildPlayerRow(
              nonStrikerName,
              nonStrikerRuns,
              nonStrikerBalls,
              nonStrikerFours,
              nonStrikerSixes,
              nonStrikerStrikeRate,
              isStriker: nonStrikerIsCurrent,
              theme: theme,
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Current Bowler',
                    style: theme.textTheme.bodySmall,
                  ),
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
            const Divider(height: 8),
            _buildPlayerRow(
              bowlerName,
              bowlerOvers,
              bowlerMaidens,
              bowlerRuns,
              bowlerWickets,
              bowlerEconomy,
              isStriker: false,
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerRow(
    String name,
    String r,
    String b,
    String fours,
    String sixes,
    String sr, {
    required bool isStriker,
    required ThemeData theme,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Flexible(
                child: Text(
                  name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isStriker ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isStriker) ...[
                SizedBox(width: 4.w),
                Icon(Icons.star, color: AppColors.primary, size: 14),
              ],
            ],
          ),
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
    );
  }

  Widget _buildThisOverSection(ThemeData theme, List<String> thisOver) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 10.w),
        child: Row(
          children: [
            Text(
              'This Over',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(6, (index) {
                    String value =
                        index < thisOver.length ? thisOver[index] : '';
                    bool isWicket = value == 'W';
                    bool isBoundary = value == '4' || value == '6';
                    final normalizedValue = value.trim();
                    final isCompactCircle = normalizedValue.length <= 2;

                    Color bgColor = AppColors.surfaceMuted;
                    Color textColor = AppColors.textLight;

                    if (isWicket) {
                      bgColor = AppColors.error;
                      textColor = Colors.white;
                    } else if (isBoundary) {
                      bgColor = AppColors.primary;
                      textColor = Colors.white;
                    } else if (value.isNotEmpty) {
                      bgColor = AppColors.primary.withValues(alpha: 0.2);
                      textColor = AppColors.primary;
                    }

                    return Container(
                      constraints: BoxConstraints(
                        minWidth: 28.r,
                        minHeight: 28.r,
                      ),
                      height: 28.r,
                      padding: EdgeInsets.symmetric(
                        horizontal: isCompactCircle ? 0 : 8.w,
                      ),
                      margin: EdgeInsets.only(right: 5.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape:
                            isCompactCircle
                                ? BoxShape.circle
                                : BoxShape.rectangle,
                        borderRadius:
                            isCompactCircle
                                ? null
                                : BorderRadius.circular(999.r),
                        border: Border.all(
                          color:
                              value.isEmpty
                                  ? Colors.grey.withValues(alpha: 0.3)
                                  : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: isCompactCircle ? 12.sp : 10.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.visible,
                      ),
                    ).animate(target: value.isNotEmpty ? 1 : 0).scale();
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedControls() {
    final currentState = _scoringBloc.state;
    final currentData = _matchDataFromState(currentState);
    final isLoadingBusy =
        _isKeyboardCooldown ||
        currentState is BallUpdateLoading ||
        currentState is ScoringLoading;
    final awaitingNewBatsman =
        (currentData['awaitingNewBatsman'] as bool?) ?? false;
    final awaitingNewBowler =
        (currentData['awaitingNewBowler'] as bool?) ?? false;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            Expanded(
              child: _buildActionButton(
                Icons.undo,
                'Undo',
                AppColors.goldDeep,
                enabled: !isLoadingBusy,
                onTap: _undoLastBall,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildActionButton(
                Icons.swap_horiz,
                'Swap',
                AppColors.info,
                enabled: !isLoadingBusy,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildActionButton(
                Icons.person_add,
                'Batsman',
                AppColors.purple,
                enabled: awaitingNewBatsman && !isLoadingBusy,
                onTap: _showNewBatsmanBottomSheet,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildActionButton(
                Icons.sports_baseball,
                'Bowler',
                AppColors.brandField,
                enabled: awaitingNewBowler && !isLoadingBusy,
                onTap: _showNewBowlerBottomSheet,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color, {
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color:
              enabled
                  ? color.withValues(alpha: 0.06)
                  : Colors.grey.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              backgroundColor:
                  enabled
                      ? color.withValues(alpha: 0.12)
                      : Colors.grey.withValues(alpha: 0.15),
              radius: 16.r,
              child: Icon(
                icon,
                color: enabled ? color : Colors.grey,
                size: 17.r,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: enabled ? null : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _matchDataFromState(ScoringState state) {
    if (state is BallUpdateSuccess) return state.matchData;
    if (state is BallUpdateLoading) return state.matchData;
    if (state is ScoringLoaded) return state.matchData;
    if (state is ScoringError && state.matchData != null) {
      return state.matchData!;
    }
    return {
      "battingTeamName": "-",
      "bowlingTeamName": "-",
      "inningsNumber": 1,
      "matchCompleted": false,
      "isTie": false,
      "winnerTeamId": 0,
      "winnerTeamName": "",
      "totalMatchOvers": 0,
      "totalRuns": 0,
      "wickets": 0,
      "overs": "0.0",
      "currentRunRate": "0.0",
      "target": 0,
      "requiredRunRate": "0",
      "partnershipRuns": 0,
      "partnershipBalls": 0,
      "extrasTotal": 0,
      "wideRuns": 0,
      "noBallRuns": 0,
      "byeRuns": 0,
      "legByeRuns": 0,
      "runsNeeded": 0,
      "ballsRemaining": 0,
      "thisOver": <String>[],
      "strikerId": 0,
      "strikerName": "-",
      "strikerRuns": 0,
      "strikerBalls": 0,
      "strikerFours": 0,
      "strikerSixes": 0,
      "strikerStrikeRate": "0.0",
      "strikerIsCurrent": true,
      "nonStrikerId": 0,
      "nonStrikerName": "-",
      "nonStrikerRuns": 0,
      "nonStrikerBalls": 0,
      "nonStrikerFours": 0,
      "nonStrikerSixes": 0,
      "nonStrikerStrikeRate": "0.0",
      "nonStrikerIsCurrent": false,
      "bowlerId": 0,
      "bowlerName": "-",
      "bowlerOvers": "0.0",
      "bowlerMaidens": 0,
      "bowlerRuns": 0,
      "bowlerWickets": 0,
      "bowlerEconomy": "0.0",
      "awaitingNewBatsman": false,
      "awaitingNewBowler": false,
    };
  }

  void _submitBall({
    required int runs,
    required bool isWicket,
    required String? extraType,
    required int extraRuns,
  }) {
    if (widget.matchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid match id. Create match first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final currentState = _scoringBloc.state;
    final currentData = _matchDataFromState(currentState);
    final matchCompleted = (currentData['matchCompleted'] as bool?) ?? false;
    final awaitingNewBatsman =
        (currentData['awaitingNewBatsman'] as bool?) ?? false;
    final awaitingNewBowler =
        (currentData['awaitingNewBowler'] as bool?) ?? false;
    final isBusy =
        _isKeyboardCooldown ||
        currentState is BallUpdateLoading ||
        currentState is ScoringLoading;

    if (matchCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Match already completed. Scoring is locked.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (awaitingNewBowler) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Wait for the new bowler to finish updating.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (awaitingNewBatsman) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select the next batsman before scoring.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (isBusy) return;

    setState(() {
      _isKeyboardCooldown = true;
    });
    _keyboardCooldownTimer?.cancel();
    _keyboardCooldownTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isKeyboardCooldown = false;
      });
    });

    _scoringBloc.add(
      BallSubmitted(
        matchId: widget.matchId,
        runs: runs,
        isWicket: isWicket,
        extraType: extraType,
        extraRuns: extraRuns,
      ),
    );
  }

  void _undoLastBall() {
    if (widget.matchId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid match id. Create match first.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final currentState = _scoringBloc.state;
    final currentData = _matchDataFromState(currentState);
    final awaitingNewBatsman =
        (currentData['awaitingNewBatsman'] as bool?) ?? false;
    final awaitingNewBowler =
        (currentData['awaitingNewBowler'] as bool?) ?? false;
    final isBusy =
        _isKeyboardCooldown ||
        currentState is BallUpdateLoading ||
        currentState is ScoringLoading ||
        awaitingNewBatsman ||
        awaitingNewBowler;

    if (isBusy) return;

    _scoringBloc.add(UndoLastBallRequested(widget.matchId));
  }

  Future<void> _showNewBatsmanBottomSheet() async {
    final currentState = _scoringBloc.state;
    final isActionableScoringState =
        currentState is ScoringLoaded ||
        currentState is BallUpdateSuccess ||
        currentState is BallUpdateLoading;
    final currentData = _matchDataFromState(currentState);
    final awaitingNewBatsman =
        (currentData['awaitingNewBatsman'] as bool?) ?? false;

    if (!isActionableScoringState ||
        !awaitingNewBatsman ||
        _isBatsmanSheetOpen) {
      return;
    }

    String? errorText;
    _isBatsmanSheetOpen = true;
    String? playerName;
    var enteredName = '';

    try {
      playerName = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        isDismissible: false,
        enableDrag: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        builder: (bottomSheetContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 20.h,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add New Batsman',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter the batsman name to continue scoring.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      textCapitalization: TextCapitalization.words,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Batsman Name',
                        hintText: 'Enter batsman name',
                        errorText: errorText,
                      ),
                      onChanged: (value) {
                        enteredName = value;
                        if (errorText != null) {
                          setModalState(() {
                            errorText = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final value = enteredName.trim();
                          if (value.isEmpty) {
                            setModalState(() {
                              errorText = 'Batsman name is required';
                            });
                            return;
                          }

                          Navigator.of(bottomSheetContext).pop(value);
                        },
                        child: const Text('Update Batsman'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    } finally {
      _isBatsmanSheetOpen = false;
    }

    if (!mounted || playerName == null || playerName.isEmpty) {
      return;
    }

    _scoringBloc.add(
      NewBatsmanSubmitted(matchId: widget.matchId, playerName: playerName),
    );
  }

  Future<void> _showNewBowlerBottomSheet() async {
    final currentState = _scoringBloc.state;
    final isStableScoringState =
        currentState is ScoringLoaded || currentState is BallUpdateSuccess;
    final currentData = _matchDataFromState(currentState);
    final awaitingNewBowler =
        (currentData['awaitingNewBowler'] as bool?) ?? false;

    if (!isStableScoringState || !awaitingNewBowler || _isBowlerSheetOpen) {
      return;
    }

    String? errorText;
    _isBowlerSheetOpen = true;
    String? playerName;
    var enteredName = '';

    try {
      playerName = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setModalState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                title: Text(
                  'Add New Bowler',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                content: SizedBox(
                  width: 360.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current over is complete. Enter the next bowler name to continue scoring.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 16.h),
                      TextField(
                        textCapitalization: TextCapitalization.words,
                        autofocus: true,
                        cursorColor: AppColors.primary,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Bowler Name',
                          hintText: 'Enter bowler name',
                          errorText: errorText,
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        onChanged: (value) {
                          enteredName = value;
                          if (errorText != null) {
                            setModalState(() {
                              errorText = null;
                            });
                          }
                        },
                      ),
                      SizedBox(height: 20.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final value = enteredName.trim();
                            if (value.isEmpty) {
                              setModalState(() {
                                errorText = 'Bowler name is required';
                              });
                              return;
                            }

                            Navigator.of(dialogContext).pop(value);
                          },
                          child: const Text('Update Bowler'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    } finally {
      _isBowlerSheetOpen = false;
    }

    if (!mounted || playerName == null || playerName.isEmpty) {
      return;
    }

    _scoringBloc.add(
      NewBowlerSubmitted(matchId: widget.matchId, playerName: playerName),
    );
  }

  void _playBoundaryBurst(String run) {
    _boundaryAnimationController.stop();
    _boundaryAnimationController.reset();
    setState(() {
      _boundaryLabel = run == '4' ? 'FOUR' : 'SIX';
      _boundaryColor = run == '4' ? AppColors.infoDeep : AppColors.goldDeep;
    });
    _boundaryAnimationController.forward();
  }

  Widget _buildBoundaryOverlay() {
    final label = _boundaryLabel;
    if (label == null) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _boundaryAnimation,
        builder: (context, child) {
          final progress = _boundaryAnimation.value;
          final opacity = (1 - progress).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.15),
                  radius: 0.9,
                  colors: [
                    _boundaryColor.withValues(alpha: 0.14 * opacity),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Align(
                alignment: const Alignment(0, -0.15),
                child: Transform.scale(
                  scale: 0.78 + (progress * 0.38),
                  child: CustomPaint(
                    painter: _PaintBurstPainter(
                      progress: progress,
                      color: _boundaryColor,
                    ),
                    child: SizedBox(
                      width: 260.w,
                      height: 260.w,
                      child: Center(
                        child: Transform.translate(
                          offset: Offset(0, -10.h * (1 - progress)),
                          child: Transform.rotate(
                            angle: (1 - progress) * 0.06,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 28.w,
                                vertical: 14.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white,
                                    _boundaryColor.withValues(alpha: 0.14),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(999.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: _boundaryColor.withValues(
                                      alpha: 0.28,
                                    ),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                                border: Border.all(
                                  color: _boundaryColor.withValues(alpha: 0.22),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.sports_cricket,
                                    color: _boundaryColor,
                                    size: 24.r,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    label,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium?.copyWith(
                                      color: _boundaryColor,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScoringKeyboard() {
    return BlocBuilder<ScoringBloc, ScoringState>(
      bloc: _scoringBloc,
      builder: (context, state) {
        final currentData = _matchDataFromState(state);
        final matchCompleted =
            (currentData['matchCompleted'] as bool?) ?? false;
        final awaitingNewBatsman =
            (currentData['awaitingNewBatsman'] as bool?) ?? false;
        final awaitingNewBowler =
            (currentData['awaitingNewBowler'] as bool?) ?? false;
        final isBusy =
            _isKeyboardCooldown ||
            matchCompleted ||
            state is BallUpdateLoading ||
            state is ScoringLoading ||
            awaitingNewBatsman ||
            awaitingNewBowler;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(top: BorderSide(color: AppColors.outline)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child:
                      _isKeyboardCooldown
                          ? Padding(
                            key: const ValueKey('keyboard_shimmer'),
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: _buildKeyboardShimmer(),
                          )
                          : const SizedBox.shrink(
                            key: ValueKey('keyboard_idle'),
                          ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunButton('0', enabled: !isBusy),
                    _buildRunButton('1', enabled: !isBusy),
                    _buildRunButton('2', enabled: !isBusy),
                    _buildRunButton('3', enabled: !isBusy),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunButton(
                      '4',
                      color: AppColors.info,
                      enabled: !isBusy,
                    ),
                    _buildRunButton('5', enabled: !isBusy),
                    _buildRunButton(
                      '6',
                      color: AppColors.goldDeep,
                      enabled: !isBusy,
                    ),
                    _buildExtraButton(
                      'W',
                      color: AppColors.error,
                      enabled: !isBusy,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildExtraButton('Wd', enabled: !isBusy),
                    _buildExtraButton('Nb', enabled: !isBusy),
                    _buildExtraButton('B', enabled: !isBusy),
                    _buildExtraButton('Lb', enabled: !isBusy),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRunButton(String run, {Color? color, required bool enabled}) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: ElevatedButton(
          onPressed:
              !enabled
                  ? null
                  : () {
                    if (run == '4' || run == '6') {
                      _playBoundaryBurst(run);
                    }
                    _submitBall(
                      runs: int.parse(run),
                      isWicket: false,
                      extraType: null,
                      extraRuns: 0,
                    );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.brandField,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            minimumSize: Size(0, 44.h),
          ),
          child: Text(
            run,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildExtraButton(
    String extra, {
    Color? color,
    required bool enabled,
  }) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: OutlinedButton(
          onPressed:
              !enabled
                  ? null
                  : () {
                    switch (extra) {
                      case 'W':
                        _submitBall(
                          runs: 0,
                          isWicket: true,
                          extraType: null,
                          extraRuns: 0,
                        );
                        return;
                      case 'Wd':
                        _submitBall(
                          runs: 0,
                          isWicket: false,
                          extraType: 'wide',
                          extraRuns: 1,
                        );
                        return;
                      case 'Nb':
                        _submitBall(
                          runs: 0,
                          isWicket: false,
                          extraType: 'no_ball',
                          extraRuns: 1,
                        );
                        return;
                      case 'B':
                        _submitBall(
                          runs: 0,
                          isWicket: false,
                          extraType: 'bye',
                          extraRuns: 1,
                        );
                        return;
                      case 'Lb':
                        _submitBall(
                          runs: 0,
                          isWicket: false,
                          extraType: 'leg_bye',
                          extraRuns: 1,
                        );
                        return;
                    }
                  },
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? AppColors.brandInk,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: color ?? AppColors.brandInk.withValues(alpha: 0.18),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            minimumSize: Size(0, 44.h),
          ),
          child: Text(
            extra,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: AppColors.surfaceLight,
      child: Container(
        width: double.infinity,
        height: 12.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999.r),
        ),
      ),
    );
  }

  void _queuePendingPlayerSheets(ScoringState state) {
    final isActionableState =
        state is ScoringLoaded ||
        state is BallUpdateSuccess ||
        state is BallUpdateLoading;
    if (!isActionableState) {
      return;
    }

    final currentData = _matchDataFromState(state);
    final matchCompleted = (currentData['matchCompleted'] as bool?) ?? false;
    if (matchCompleted) {
      _lastPendingBatsmanKey = '';
      _lastPendingBowlerKey = '';
      return;
    }

    final awaitingNewBatsman =
        (currentData['awaitingNewBatsman'] as bool?) ?? false;
    final awaitingNewBowler =
        (currentData['awaitingNewBowler'] as bool?) ?? false;
    final strikerId = (currentData['strikerId'] as int?) ?? 0;
    final nonStrikerId = (currentData['nonStrikerId'] as int?) ?? 0;
    final inningsNumber = (currentData['inningsNumber'] as int?) ?? 0;
    final overs = currentData['overs']?.toString() ?? '0.0';
    final batsmanPendingKey =
        awaitingNewBatsman
            ? '$inningsNumber:$overs:$strikerId:$nonStrikerId'
            : '';
    final bowlerPendingKey = awaitingNewBowler ? '$inningsNumber:$overs' : '';
    final batsmanJustBecamePending =
        batsmanPendingKey.isNotEmpty &&
        batsmanPendingKey != _lastPendingBatsmanKey;
    final bowlerJustBecamePending =
        bowlerPendingKey.isNotEmpty &&
        bowlerPendingKey != _lastPendingBowlerKey;

    _lastPendingBatsmanKey = batsmanPendingKey;
    _lastPendingBowlerKey = bowlerPendingKey;

    if (batsmanJustBecamePending &&
        !_isBatsmanSheetOpen &&
        !_isBatsmanDialogQueued) {
      _isBatsmanDialogQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          if (mounted) {
            await _showNewBatsmanBottomSheet();
          }
        } finally {
          _isBatsmanDialogQueued = false;
        }
      });
      return;
    }

    final canOpenBowlerDialog =
        state is ScoringLoaded || state is BallUpdateSuccess;

    if (bowlerJustBecamePending &&
        canOpenBowlerDialog &&
        !awaitingNewBatsman &&
        !_isBowlerSheetOpen &&
        !_isBowlerDialogQueued) {
      _isBowlerDialogQueued = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          if (mounted) {
            await _showNewBowlerBottomSheet();
          }
        } finally {
          _isBowlerDialogQueued = false;
        }
      });
    }
  }

  void _queueMatchResultDialog(ScoringState state) {
    final isStableState = state is ScoringLoaded || state is BallUpdateSuccess;
    if (!isStableState || _isResultDialogOpen) {
      return;
    }

    final currentData = _matchDataFromState(state);
    final inningsNumber = (currentData['inningsNumber'] as int?) ?? 0;
    final matchCompleted = (currentData['matchCompleted'] as bool?) ?? false;
    if (!matchCompleted || inningsNumber != 2) {
      return;
    }

    final isTie = (currentData['isTie'] as bool?) ?? false;
    final winnerTeamName = currentData['winnerTeamName']?.toString() ?? '';
    final totalRuns = (currentData['totalRuns'] as int?) ?? 0;
    final wickets = (currentData['wickets'] as int?) ?? 0;
    final overs = currentData['overs']?.toString() ?? '0.0';
    final resultKey =
        '$inningsNumber:$isTie:$winnerTeamName:$totalRuns:$wickets:$overs';

    if (resultKey == _lastResultDialogKey) {
      return;
    }

    _lastResultDialogKey = resultKey;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      _isResultDialogOpen = true;
      try {
        await _showMatchResultDialog(currentData);
      } finally {
        _isResultDialogOpen = false;
      }
    });
  }

  Future<void> _showMatchResultDialog(Map<String, dynamic> data) async {
    final isTie = (data['isTie'] as bool?) ?? false;
    final winnerTeamName = data['winnerTeamName']?.toString().trim() ?? '';
    final score =
        '${(data['totalRuns'] as int?) ?? 0}/${(data['wickets'] as int?) ?? 0}';
    final overs = data['overs']?.toString() ?? '0.0';
    final title = isTie ? 'Match Tied' : 'Congratulations!';
    final headline =
        isTie
            ? 'What a finish. Both teams stayed level right to the end.'
            : '$winnerTeamName stole the show and sealed the win.';
    final accentColor = isTie ? AppColors.goldDeep : AppColors.successDeep;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          contentPadding: EdgeInsets.fromLTRB(22.w, 22.h, 22.w, 18.h),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 172.h,
                child: _ResultCelebration(
                  accentColor: accentColor,
                  isTie: isTie,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                headline,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      isTie ? 'Final Score' : winnerTeamName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accentColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      '$score in $overs overs',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: const Text('Back to Dashboard'),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted) {
      return;
    }

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/dashboard', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocProvider.value(
      value: _scoringBloc,
      child: BlocListener<ScoringBloc, ScoringState>(
        listener: (context, state) {
          if (state is ScoringError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
          _queueMatchResultDialog(state);
          _queuePendingPlayerSheets(state);
        },
        child: Stack(
          children: [
            const Positioned.fill(child: BrandBackdrop()),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                elevation: 0,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.brandHeroGradient,
                  ),
                ),
                title: const Text('Live Scoring'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {},
                  ),
                ],
              ),
              body: BlocBuilder<ScoringBloc, ScoringState>(
                builder: (context, state) {
                  if (state is ScoringInitial || state is ScoringLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = _matchDataFromState(state);

                  return isLandscape
                      ? _buildLandscapeLayout(theme, data)
                      : _buildPortraitLayout(theme, data);
                },
              ),
              bottomNavigationBar: _buildScoringKeyboard(),
            ),
            Positioned.fill(child: _buildBoundaryOverlay()),
          ],
        ),
      ),
    );
  }

  String _inningsLabel(int inningsNumber) {
    switch (inningsNumber) {
      case 1:
        return '1st Innings';
      case 2:
        return '2nd Innings';
      case 3:
        return '3rd Innings';
      default:
        return '${inningsNumber}th Innings';
    }
  }
}

class _PaintBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _PaintBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseRadius = size.width * (0.18 + (progress * 0.2));
    final basePaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.28 + ((1 - progress) * 0.24));

    canvas.drawCircle(center, baseRadius, basePaint);

    for (var index = 0; index < 12; index++) {
      final angle = (math.pi * 2 / 12) * index;
      final distance = 34 + (progress * 62) + ((index % 3) * 10);
      final dropletCenter = Offset(
        center.dx + math.cos(angle) * distance,
        center.dy + math.sin(angle) * distance,
      );
      final dropletRadius = 10 + ((index % 4) * 4) + ((1 - progress) * 7);
      canvas.drawCircle(
        dropletCenter,
        dropletRadius,
        Paint()..color = color.withValues(alpha: 0.2 + ((1 - progress) * 0.18)),
      );
    }

    for (var index = 0; index < 8; index++) {
      final angle = (math.pi * 2 / 8) * index + 0.25;
      final linePaint =
          Paint()
            ..color = color.withValues(alpha: 0.28 + ((1 - progress) * 0.2))
            ..strokeWidth = 7 - (progress * 2.5)
            ..strokeCap = StrokeCap.round;
      final start = Offset(
        center.dx + math.cos(angle) * (baseRadius + 10),
        center.dy + math.sin(angle) * (baseRadius + 10),
      );
      final end = Offset(
        center.dx + math.cos(angle) * (baseRadius + 36 + (progress * 34)),
        center.dy + math.sin(angle) * (baseRadius + 36 + (progress * 34)),
      );
      canvas.drawLine(start, end, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaintBurstPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

class _ResultCelebration extends StatefulWidget {
  final Color accentColor;
  final bool isTie;

  const _ResultCelebration({required this.accentColor, required this.isTie});

  @override
  State<_ResultCelebration> createState() => _ResultCelebrationState();
}

class _ResultCelebrationState extends State<_ResultCelebration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ResultCelebrationPainter(
            progress: _controller.value,
            accentColor: widget.accentColor,
            isTie: widget.isTie,
          ),
          child: Container(
            alignment: Alignment.center,
            child: Container(
              width: 76.r,
              height: 76.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    widget.accentColor.withValues(alpha: 0.16),
                    widget.accentColor.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.18),
                    blurRadius: 24,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                widget.isTie
                    ? Icons.handshake_rounded
                    : Icons.emoji_events_rounded,
                color: widget.accentColor,
                size: 38.r,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ResultCelebrationPainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final bool isTie;

  _ResultCelebrationPainter({
    required this.progress,
    required this.accentColor,
    required this.isTie,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.48);
    final baseY = size.height * 0.9;
    final softPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [accentColor.withValues(alpha: 0.16), Colors.transparent],
          ).createShader(
            Rect.fromCircle(center: center, radius: size.width * 0.42),
          );
    canvas.drawCircle(center, size.width * 0.36, softPaint);

    _drawBurst(
      canvas,
      Offset(size.width * 0.22, size.height * 0.28),
      (progress + 0.08) % 1,
      Color.lerp(accentColor, Colors.amber, 0.45) ?? accentColor,
      10,
    );
    _drawBurst(
      canvas,
      Offset(size.width * 0.78, size.height * 0.24),
      (progress + 0.42) % 1,
      Color.lerp(accentColor, Colors.cyanAccent, 0.4) ?? accentColor,
      11,
    );

    _drawFlowerPot(
      canvas,
      size,
      baseY,
      Color.lerp(accentColor, Colors.orange, 0.3) ?? accentColor,
    );
    _drawFountain(canvas, size, progress, baseY, accentColor);
    if (!isTie) {
      _drawConfetti(canvas, size);
    }
  }

  void _drawBurst(
    Canvas canvas,
    Offset center,
    double phase,
    Color color,
    int rays,
  ) {
    final linePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final glowPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.2);

    final radius = 12 + (phase * 34);
    canvas.drawCircle(center, radius * 0.7, glowPaint);

    for (var i = 0; i < rays; i++) {
      final angle = ((math.pi * 2) / rays) * i + (phase * 0.3);
      final start = Offset(
        center.dx + math.cos(angle) * (8 + (phase * 6)),
        center.dy + math.sin(angle) * (8 + (phase * 6)),
      );
      final end = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      linePaint
        ..color = color.withValues(alpha: 0.9 - (phase * 0.45))
        ..strokeWidth = 3.4 - (phase * 1.6);
      canvas.drawLine(start, end, linePaint);
      canvas.drawCircle(
        end,
        1.8 + ((1 - phase) * 2.8),
        Paint()..color = Colors.white.withValues(alpha: 0.85 - (phase * 0.35)),
      );
    }
  }

  void _drawFlowerPot(Canvas canvas, Size size, double baseY, Color color) {
    final potPath =
        Path()
          ..moveTo(size.width * 0.43, baseY - 8)
          ..lineTo(size.width * 0.57, baseY - 8)
          ..lineTo(size.width * 0.53, baseY + 22)
          ..lineTo(size.width * 0.47, baseY + 22)
          ..close();

    final potPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [
              color.withValues(alpha: 0.95),
              color.withValues(alpha: 0.68),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromLTWH(size.width * 0.43, baseY - 8, size.width * 0.14, 30),
          );
    canvas.drawPath(potPath, potPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.425, baseY - 12, size.width * 0.15, 8),
        const Radius.circular(6),
      ),
      Paint()..color = color.withValues(alpha: 0.86),
    );
  }

  void _drawFountain(
    Canvas canvas,
    Size size,
    double phase,
    double baseY,
    Color color,
  ) {
    final sparkPaint =
        Paint()
          ..style = PaintingStyle.fill
          ..strokeCap = StrokeCap.round;
    final plumeBase = Offset(size.width / 2, baseY - 8);

    for (var i = 0; i < 24; i++) {
      final t = ((phase + (i * 0.041)) % 1);
      final spread = (i % 2 == 0 ? -1 : 1) * (10 + ((i % 6) * 4.0));
      final height = 22 + (((i * 17) % 70).toDouble());
      final sway = math.sin((t * math.pi) + (i * 0.35)) * spread;
      final x = plumeBase.dx + sway * t;
      final y = plumeBase.dy - (height * math.sin(t * math.pi));
      final radius = 1.8 + ((1 - t) * 2.8);
      sparkPaint.color =
          Color.lerp(
            Colors.amberAccent,
            color,
            t * 0.7,
          )?.withValues(alpha: 0.85 - (t * 0.28)) ??
          color;
      canvas.drawCircle(Offset(x, y), radius, sparkPaint);
    }
  }

  void _drawConfetti(Canvas canvas, Size size) {
    for (var i = 0; i < 18; i++) {
      final t = ((progress + (i * 0.07)) % 1);
      final x = ((i * 37.0) % size.width);
      final y = size.height * 0.14 + (t * size.height * 0.42);
      final dx = math.sin((t * math.pi * 2) + i) * 8;
      final rect = Rect.fromCenter(
        center: Offset(x + dx, y),
        width: 6 + (i % 3),
        height: 9,
      );
      final confettiColor =
          i.isEven
              ? Color.lerp(accentColor, Colors.amber, 0.4) ?? accentColor
              : Color.lerp(accentColor, Colors.white, 0.28) ?? accentColor;
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate((t * 2.6) + (i * 0.4));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: rect.width,
            height: rect.height,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = confettiColor.withValues(alpha: 0.78),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ResultCelebrationPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isTie != isTie;
  }
}
