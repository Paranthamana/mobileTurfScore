import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/scoring_bloc.dart';
import '../bloc/scoring_event.dart';
import '../bloc/scoring_state.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/brand_backdrop.dart';
import 'admin_scoring_screen.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  int _currentStep = 0;
  // Form Controllers
  final _matchNameController = TextEditingController();
  final _teamAController = TextEditingController();
  final _teamBController = TextEditingController();
  final _oversController = TextEditingController();
  final _wicketsController = TextEditingController();
  final _strikerController = TextEditingController();
  final _nonStrikerController = TextEditingController();
  final _bowlerController = TextEditingController();
  final _pageController = PageController();

  bool _isFlipping = false;
  bool _isHeads = true;
  int? _tossWinnerIndex;
  String? _electedTo;
  bool _isSubmittingMatch = false;

  @override
  void initState() {
    super.initState();
    _matchNameController.addListener(_onFormUpdate);
    _teamAController.addListener(_onFormUpdate);
    _teamBController.addListener(_onFormUpdate);
    _oversController.addListener(_onFormUpdate);
    _wicketsController.addListener(_onFormUpdate);
    _strikerController.addListener(_onFormUpdate);
    _nonStrikerController.addListener(_onFormUpdate);
    _bowlerController.addListener(_onFormUpdate);
  }

  @override
  void dispose() {
    _matchNameController.dispose();
    _teamAController.dispose();
    _teamBController.dispose();
    _oversController.dispose();
    _wicketsController.dispose();
    _strikerController.dispose();
    _nonStrikerController.dispose();
    _bowlerController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onFormUpdate() {
    setState(() {});
  }

  bool _isStepValid() {
    if (_currentStep == 0) {
      return _matchNameController.text.trim().isNotEmpty &&
          _teamAController.text.trim().isNotEmpty &&
          _teamBController.text.trim().isNotEmpty &&
          int.tryParse(_oversController.text) != null &&
          int.tryParse(_wicketsController.text) != null;
    } else if (_currentStep == 1) {
      return _tossWinnerIndex != null && _electedTo != null;
    } else if (_currentStep == 2) {
      return _strikerController.text.trim().isNotEmpty &&
          _nonStrikerController.text.trim().isNotEmpty &&
          _bowlerController.text.trim().isNotEmpty;
    }
    return false;
  }

  void _flipCoin() async {
    if (_isFlipping) return;
    setState(() => _isFlipping = true);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isFlipping = false;
        _isHeads = (DateTime.now().millisecondsSinceEpoch % 2) == 0;
      });
    }
  }

  void _dispatchCreateMatch() {
    if (_isSubmittingMatch) return;
    final body = {
      "match_name": _matchNameController.text.trim(),
      "overs": int.tryParse(_oversController.text) ?? 0,
      "wickets": int.tryParse(_wicketsController.text) ?? 0,
      "host_team_name": _teamAController.text.trim(),
      "visitor_team_name": _teamBController.text.trim(),
      "toss": {
        "won_by": _tossWinnerIndex == 0 ? "host" : "visitor",
        "decision": _electedTo?.toLowerCase() ?? "bat",
      },
      "opening_players": {
        "striker": _strikerController.text.trim(),
        "non_striker": _nonStrikerController.text.trim(),
        "bowler": _bowlerController.text.trim(),
      },
    };

    setState(() => _isSubmittingMatch = true);
    context.read<ScoringBloc>().add(CreateMatchSubmitted(body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ScoringBloc, ScoringState>(
      listener: (context, state) {
        if (state is MatchCreatedSuccess) {
          if (mounted) setState(() => _isSubmittingMatch = false);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (_) =>
                      AdminScoringScreen(matchId: state.response.data.matchId),
            ),
          );
        } else if (state is ScoringError) {
          if (mounted) setState(() => _isSubmittingMatch = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Stack(
        children: [
          const Positioned.fill(child: BrandBackdrop()),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              foregroundColor: Colors.white,
              title: const Text('Create Match'),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.brandHeroGradient,
                ),
              ),
            ),
            body: Column(
              children: [
                _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged:
                        (index) => setState(() => _currentStep = index),
                    children: [
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: _buildStageCard(_buildTeamsForm()),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: _buildStageCard(_buildTossSection()),
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.all(16.w),
                        child: _buildStageCard(_buildOpenersSection()),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: BlocBuilder<ScoringBloc, ScoringState>(
                  builder: (context, state) {
                    final isLoading = state is ScoringLoading;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        backgroundColor: AppColors.brandField,
                        foregroundColor: Colors.white,
                      ),
                      onPressed:
                          _isStepValid() && !isLoading && !_isSubmittingMatch
                              ? () {
                                if (_currentStep < 2) {
                                  _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  );
                                } else {
                                  _dispatchCreateMatch();
                                }
                              }
                              : null,
                      child:
                          isLoading
                              ? SizedBox(
                                height: 20.h,
                                width: 20.h,
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _currentStep == 2 ? 'START MATCH' : 'CONTINUE',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStageCard(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(28.r),
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.9)),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandInk.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: EdgeInsets.all(18.w),
      child: child,
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65)),
      ),
      child: Row(
        children: [
          _buildStepCircle(0, 'Teams'),
          _buildStepLine(0),
          _buildStepCircle(1, 'Toss'),
          _buildStepLine(1),
          _buildStepCircle(2, 'Openers'),
        ],
      ),
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isCompleted = _currentStep > step;
    bool isActive = _currentStep == step;

    return Column(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isCompleted || isActive
                    ? AppColors.brandField
                    : AppColors.surfaceMuted,
          ),
          child: Center(
            child:
                isCompleted
                    ? Icon(Icons.check, color: Colors.white, size: 16.r)
                    : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color:
                            isCompleted || isActive
                                ? Colors.white
                                : AppColors.textSecondaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color:
                isCompleted || isActive
                    ? AppColors.brandField
                    : AppColors.textSecondaryLight,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.only(bottom: 20.h),
        color: isCompleted ? AppColors.primary : AppColors.outline,
      ),
    );
  }

  Widget _buildTeamsForm() {
    return Column(
      children: [
        TextFormField(
          controller: _teamAController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Host Team Name',
            prefixIcon: Icon(Icons.shield_outlined),
          ),
        ).animate().fadeIn(delay: 100.ms).slideX(),
        SizedBox(height: 16.h),
        const Text(
          'VS',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _teamBController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Visitor Team Name',
            prefixIcon: Icon(Icons.shield_outlined),
          ),
        ).animate().fadeIn(delay: 200.ms).slideX(),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child:
                  TextFormField(
                    controller: _oversController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Overs',
                      prefixIcon: Icon(Icons.timer_outlined),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideX(),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child:
                  TextFormField(
                    controller: _wicketsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Wickets',
                      prefixIcon: Icon(Icons.sports_cricket_outlined),
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideX(),
            ),
          ],
        ),

        SizedBox(height: 16.h),
        TextFormField(
          controller: _matchNameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Match Name',
            hintText: 'Eg: T20 , Weekend Match, 5 Over Match',
            prefixIcon: Icon(Icons.edit_outlined),
          ),
        ).animate().fadeIn(delay: 50.ms).slideX(),
      ],
    );
  }

  Widget _buildTossSection() {
    final theme = Theme.of(context);
    return Column(
      children: [
        GestureDetector(
          onTap: _flipCoin,
          child: Container(
            height: 220.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _isFlipping
                    ? Image.asset(
                          'assets/images/head.png',
                          width: 120.r,
                          height: 120.r,
                        )
                        .animate(onPlay: (controller) => controller.repeat())
                        .flipV(duration: 300.ms)
                    : Image.asset(
                      _isHeads
                          ? 'assets/images/head.png'
                          : 'assets/images/tail.png',
                      width: 120.r,
                      height: 120.r,
                    ).animate().scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 400.ms,
                      curve: Curves.easeOutBack,
                    ),
                SizedBox(height: 24.h),
                Text(
                  _isFlipping ? 'Flipping...' : 'Tap to Flip Coin',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 32.h),
        Text(
          'Who won the toss?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSelectionButton(
                title:
                    _teamAController.text.isEmpty
                        ? 'Team A'
                        : _teamAController.text,
                isSelected: _tossWinnerIndex == 0,
                onTap: () {
                  setState(() => _tossWinnerIndex = 0);
                  _onFormUpdate();
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildSelectionButton(
                title:
                    _teamBController.text.isEmpty
                        ? 'Team B'
                        : _teamBController.text,
                isSelected: _tossWinnerIndex == 1,
                onTap: () {
                  setState(() => _tossWinnerIndex = 1);
                  _onFormUpdate();
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Text(
          'Elected to?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildSelectionButton(
                title: 'BAT',
                isSelected: _electedTo == 'BAT',
                onTap: () {
                  setState(() => _electedTo = 'BAT');
                  _onFormUpdate();
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildSelectionButton(
                title: 'BOWL',
                isSelected: _electedTo == 'BOWL',
                onTap: () {
                  setState(() => _electedTo = 'BOWL');
                  _onFormUpdate();
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn();
  }

  Widget _buildSelectionButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.brandField : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? AppColors.brandField : AppColors.outline,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildOpenersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Striker (Batsman)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _strikerController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter Player Name'),
        ),
        SizedBox(height: 16.h),
        const Text(
          'Non-Striker (Batsman)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _nonStrikerController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter Player Name'),
        ),
        SizedBox(height: 24.h),
        const Text(
          'Opening Bowler',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: _bowlerController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter Player Name'),
        ),
      ],
    ).animate().fadeIn();
  }
}
