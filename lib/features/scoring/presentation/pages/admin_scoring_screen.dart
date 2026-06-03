import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
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

class _AdminScoringScreenState extends State<AdminScoringScreen> {
  late final ScoringBloc _scoringBloc;

  @override
  void initState() {
    super.initState();
    _scoringBloc =
        sl<ScoringBloc>()..add(ResumeScoringRequested(widget.matchId));
  }

  @override
  void dispose() {
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
          padding: EdgeInsets.all(8.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 16.w,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildScoreHeader(theme, data),
                _buildMatchStats(theme, data),
                _buildScorecardSection(theme, data),
                _buildThisOverSection(theme, thisOver),
                _buildAdvancedControls(),
                SizedBox(height: 2.h),
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                battingTeamName,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _inningsLabel(inningsNumber),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$totalRuns',
                    style: theme.textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 48.sp,
                    ),
                  ),
                  Text(
                    '/$wickets',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    '($overs) - ($totalMatchOvers)',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontSize: 20.sp,
                    ),
                  ),
                ],
              )
              .animate(key: ValueKey('$totalRuns-$wickets'))
              .scale(begin: const Offset(0.9, 0.9), duration: 200.ms),
          SizedBox(height: 8.h),
          Text(
            'CRR: $currentRunRate',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
              fontSize: 12.sp,
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatColumn('Target', target > 0 ? '$target' : '-', theme),
            Container(
              width: 1,
              height: 24.h,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            _buildStatColumn(
              'Req RR',
              target > 0 ? requiredRunRate : '-',
              theme,
            ),
            Container(
              width: 1,
              height: 24.h,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            _buildStatColumn(
              'Partnership',
              '$partnershipRuns ($partnershipBalls)',
              theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.sp),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
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
            SizedBox(height: 4.h),
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
            SizedBox(height: 8.h),
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
                const Icon(Icons.star, color: AppColors.primary, size: 14),
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
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
        child: Row(
          children: [
            Text(
              'This Over',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(6, (index) {
                    String value =
                        index < thisOver.length ? thisOver[index] : '';
                    bool isWicket = value == 'W';
                    bool isBoundary = value == '4' || value == '6';

                    Color bgColor = Colors.grey.withValues(alpha: 0.1);
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
                      width: 32.r,
                      height: 32.r,
                      margin: EdgeInsets.only(right: 6.w),
                      decoration: BoxDecoration(
                        color: bgColor,
                        shape: BoxShape.circle,
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
                          fontSize: 14.sp,
                        ),
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
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildActionButton(Icons.undo, 'Undo', Colors.orange),
            _buildActionButton(Icons.swap_horiz, 'Swap', Colors.blue),
            _buildActionButton(Icons.person_add, 'Batsman', Colors.purple),
            _buildActionButton(Icons.sports_baseball, 'Bowler', Colors.teal),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {},
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.1),
            radius: 20.r,
            child: Icon(icon, color: color, size: 20.r),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _matchDataFromState(ScoringState state) {
    if (state is BallUpdateSuccess) return state.matchData;
    if (state is BallUpdateLoading) return state.matchData;
    if (state is ScoringLoaded) return state.matchData;
    return {
      "battingTeamName": "-",
      "bowlingTeamName": "-",
      "inningsNumber": 1,
      "totalRuns": 0,
      "wickets": 0,
      "overs": "0.0",
      "currentRunRate": "0.0",
      "target": 0,
      "requiredRunRate": "0",
      "partnershipRuns": 0,
      "partnershipBalls": 0,
      "runsNeeded": 0,
      "ballsRemaining": 0,
      "thisOver": <String>[],
      "strikerName": "-",
      "strikerRuns": 0,
      "strikerBalls": 0,
      "strikerFours": 0,
      "strikerSixes": 0,
      "strikerStrikeRate": "0.0",
      "strikerIsCurrent": true,
      "nonStrikerName": "-",
      "nonStrikerRuns": 0,
      "nonStrikerBalls": 0,
      "nonStrikerFours": 0,
      "nonStrikerSixes": 0,
      "nonStrikerStrikeRate": "0.0",
      "nonStrikerIsCurrent": false,
      "bowlerName": "-",
      "bowlerOvers": "0.0",
      "bowlerMaidens": 0,
      "bowlerRuns": 0,
      "bowlerWickets": 0,
      "bowlerEconomy": "0.0",
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

  Widget _buildScoringKeyboard() {
    return BlocBuilder<ScoringBloc, ScoringState>(
      bloc: _scoringBloc,
      builder: (context, state) {
        final isBusy = state is BallUpdateLoading || state is ScoringLoading;
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunButton('0', enabled: !isBusy),
                    _buildRunButton('1', enabled: !isBusy),
                    _buildRunButton('2', enabled: !isBusy),
                    _buildRunButton('3', enabled: !isBusy),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRunButton('4', color: Colors.blue, enabled: !isBusy),
                    _buildRunButton('5', enabled: !isBusy),
                    _buildRunButton(
                      '6',
                      color: Colors.deepPurple,
                      enabled: !isBusy,
                    ),
                    _buildExtraButton(
                      'W',
                      color: AppColors.error,
                      enabled: !isBusy,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
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
                    _submitBall(
                      runs: int.parse(run),
                      isWicket: false,
                      extraType: null,
                      extraRuns: 0,
                    );
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
          child: Text(
            run,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
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
                          runs: 1,
                          isWicket: false,
                          extraType: 'no_ball',
                          extraRuns: 1,
                        );
                        return;
                      case 'B':
                        _submitBall(
                          runs: 2,
                          isWicket: false,
                          extraType: 'bye',
                          extraRuns: 0,
                        );
                        return;
                      case 'Lb':
                        _submitBall(
                          runs: 1,
                          isWicket: false,
                          extraType: 'leg_bye',
                          extraRuns: 0,
                        );
                        return;
                    }
                  },
          style: OutlinedButton.styleFrom(
            foregroundColor: color ?? AppColors.textLight,
            side: BorderSide(
              color: color ?? Colors.grey.withValues(alpha: 0.5),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            padding: EdgeInsets.symmetric(vertical: 16.h),
          ),
          child: Text(
            extra,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
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
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Live Scoring'),
            actions: [
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
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
