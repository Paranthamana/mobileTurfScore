import 'dart:async';
import 'dart:math' as math;

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../theme/colors.dart';

class OfflineConnectionGate extends StatefulWidget {
  const OfflineConnectionGate({super.key, required this.child});

  final Widget child;

  @override
  State<OfflineConnectionGate> createState() => _OfflineConnectionGateState();
}

class _OfflineConnectionGateState extends State<OfflineConnectionGate>
    with WidgetsBindingObserver {
  final Connectivity _connectivity = Connectivity();
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 2),
      receiveTimeout: const Duration(seconds: 2),
    ),
  );
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  Timer? _connectionTimer;
  final List<Timer> _restoreRetryTimers = [];
  bool _hasConnection = true;
  bool _isCheckingConnection = false;
  bool _shouldCheckAgain = false;
  int _connectionCheckId = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkConnection();
    _connectionTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _checkConnection(),
    );
    _subscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChanged,
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnection();
    }
  }

  Future<void> _checkConnection() async {
    if (_isCheckingConnection) {
      _shouldCheckAgain = true;
      return;
    }

    _isCheckingConnection = true;
    final checkId = ++_connectionCheckId;

    try {
      final result = await _connectivity.checkConnectivity();
      final hasConnection = await _hasConnectionForResults(result);
      if (checkId == _connectionCheckId) {
        _setConnectionStatus(hasConnection);
      }
    } catch (_) {
      _setConnectionStatus(false);
    } finally {
      _isCheckingConnection = false;
      if (_shouldCheckAgain) {
        _shouldCheckAgain = false;
        unawaited(_checkConnection());
      }
    }
  }

  void _handleConnectivityChanged(List<ConnectivityResult> results) {
    final hasNetwork = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasNetwork) {
      _cancelRestoreRetryTimers();
      _setConnectionStatus(false);
      return;
    }

    unawaited(_checkConnection());
    _scheduleRestoreRetryChecks();
  }

  Future<bool> _hasConnectionForResults(
    List<ConnectivityResult> results,
  ) async {
    final hasNetwork = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasNetwork) return false;

    return _hasInternetAccess();
  }

  Future<bool> _hasInternetAccess() async {
    if (kIsWeb) return true;

    const urls = [
      'https://www.google.com/generate_204',
      'https://connectivitycheck.gstatic.com/generate_204',
      'https://www.gstatic.com/generate_204',
      'https://one.one.one.one/cdn-cgi/trace',
    ];

    final probes = urls.map(_canReachUrl).toList();
    await for (final canReach in Stream.fromFutures(probes)) {
      if (canReach) return true;
    }

    return false;
  }

  Future<bool> _canReachUrl(String url) async {
    try {
      final response = await _dio.getUri<void>(
        Uri.parse(url),
        options: Options(
          followRedirects: false,
          receiveDataWhenStatusError: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      return response.statusCode != null && response.statusCode! < 500;
    } catch (_) {
      return false;
    }
  }

  void _scheduleRestoreRetryChecks() {
    _cancelRestoreRetryTimers();

    for (final delay in const [
      Duration(milliseconds: 700),
      Duration(seconds: 2),
      Duration(seconds: 5),
    ]) {
      _restoreRetryTimers.add(Timer(delay, _checkConnection));
    }
  }

  void _cancelRestoreRetryTimers() {
    for (final timer in _restoreRetryTimers) {
      timer.cancel();
    }
    _restoreRetryTimers.clear();
  }

  void _setConnectionStatus(bool hasConnection) {
    if (!mounted || hasConnection == _hasConnection) return;

    setState(() {
      _hasConnection = hasConnection;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectionTimer?.cancel();
    _cancelRestoreRetryTimers();
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _hasConnection,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              opacity: _hasConnection ? 0 : 1,
              child:
                  _hasConnection
                      ? const SizedBox.shrink()
                      : const _OfflineConnectionScreen(),
            ),
          ),
        ),
      ],
    );
  }
}

class _OfflineConnectionScreen extends StatelessWidget {
  const _OfflineConnectionScreen();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      key: const ValueKey('offline_connection_screen'),
      color: AppColors.backgroundDark,
      child: PopScope(
        canPop: false,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF052E1B), Color(0xFF0A1710)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Column(
                children: [
                  const Spacer(),
                  const _OfflineCricketIllustration(),
                  const SizedBox(height: 36),
                  Text(
                    'Internet not available',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Please check your Wi-Fi or mobile data. We will bring you back to the match as soon as the network is restored.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.74),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.16),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryLight,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Waiting for connection...',
                          style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineCricketIllustration extends StatelessWidget {
  const _OfflineCricketIllustration();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.16,
      child: CustomPaint(painter: _OfflineCricketPainter()),
    );
  }
}

class _OfflineCricketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    final center = Offset(width / 2, height / 2);

    final glowPaint =
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.28),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: center, radius: math.min(width, height)),
          );

    canvas.drawCircle(center, math.min(width, height) * 0.48, glowPaint);

    final fieldPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(width * 0.5, height * 0.76),
        width: width * 0.82,
        height: height * 0.28,
      ),
      math.pi,
      math.pi,
      false,
      fieldPaint,
    );

    final stumpPaint =
        Paint()
          ..color = const Color(0xFFF7F0D0)
          ..strokeWidth = width * 0.018
          ..strokeCap = StrokeCap.round;

    for (final x in [0.43, 0.5, 0.57]) {
      canvas.drawLine(
        Offset(width * x, height * 0.44),
        Offset(width * x, height * 0.72),
        stumpPaint,
      );
    }

    canvas.drawLine(
      Offset(width * 0.39, height * 0.42),
      Offset(width * 0.61, height * 0.42),
      stumpPaint,
    );

    final batPaint =
        Paint()
          ..color = const Color(0xFFE7B968)
          ..strokeWidth = width * 0.045
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(width * 0.68, height * 0.33),
      Offset(width * 0.45, height * 0.7),
      batPaint,
    );

    final handlePaint =
        Paint()
          ..color = const Color(0xFF9B612B)
          ..strokeWidth = width * 0.023
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(width * 0.73, height * 0.25),
      Offset(width * 0.66, height * 0.36),
      handlePaint,
    );

    final ballPaint =
        Paint()
          ..shader = const LinearGradient(
            colors: [Color(0xFFFF6B5A), Color(0xFFC92828)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(
            Rect.fromCircle(
              center: Offset(width * 0.29, height * 0.55),
              radius: width * 0.08,
            ),
          );

    canvas.drawCircle(
      Offset(width * 0.29, height * 0.55),
      width * 0.075,
      ballPaint,
    );

    final seamPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.68)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4;

    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(width * 0.29, height * 0.55),
        width: width * 0.09,
        height: width * 0.14,
      ),
      -math.pi / 2,
      math.pi,
      false,
      seamPaint,
    );

    final signalPaint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.82)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 4;

    final signalCenter = Offset(width * 0.5, height * 0.25);
    for (final radius in [0.08, 0.15, 0.22]) {
      canvas.drawArc(
        Rect.fromCircle(center: signalCenter, radius: width * radius),
        math.pi * 1.18,
        math.pi * 0.64,
        false,
        signalPaint,
      );
    }

    final slashPaint =
        Paint()
          ..color = AppColors.error
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(width * 0.36, height * 0.16),
      Offset(width * 0.64, height * 0.36),
      slashPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
