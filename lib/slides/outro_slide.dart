import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class Slide43Thanks extends FlutterDeckSlideWidget {
  const Slide43Thanks({super.key})
    : super(
        configuration: const FlutterDeckSlideConfiguration(
          route: '/thanks',
          header: FlutterDeckHeaderConfiguration(title: 'ご清聴ありがとうございました！'),
          steps: 4, // Background → Title → Handle/QR → flutter_deck credit
        ),
      );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) {
        return FlutterDeckSlideStepsBuilder(
          builder: (context, stepNumber) =>
              _ClosingSlideContent(stepNumber: stepNumber),
        );
      },
    );
  }
}

class _ClosingSlideContent extends StatefulWidget {
  final int stepNumber;

  const _ClosingSlideContent({required this.stepNumber});

  @override
  State<_ClosingSlideContent> createState() => _ClosingSlideContentState();
}

class _ClosingSlideContentState extends State<_ClosingSlideContent>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _titleController;
  late AnimationController _bottomController;
  late AnimationController _creditController;

  late Animation<double> _backgroundFadeAnimation;
  late Animation<double> _titleZoomAnimation;
  late Animation<Offset> _handleSlideAnimation;
  late Animation<Offset> _qrSlideAnimation;
  late Animation<double> _creditFadeAnimation;
  late Animation<double> _creditShimmerAnimation;

  // Dash Rive animation
  late final FileLoader _dashFileLoader;
  bool _showDash = false;

  @override
  void initState() {
    super.initState();

    // Initialize Dash Rive file loader
    _dashFileLoader = FileLoader.fromAsset(
      'assets/dash.riv',
      riveFactory: Factory.rive,
    );

    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bottomController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _creditController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _backgroundFadeAnimation = CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    );

    _titleZoomAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _titleController, curve: Curves.easeOut));

    _handleSlideAnimation =
        Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bottomController,
            curve: Curves.easeOutCubic,
          ),
        );

    _qrSlideAnimation =
        Tween<Offset>(begin: const Offset(1.5, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _bottomController,
            curve: Curves.easeOutCubic,
          ),
        );

    _creditFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _creditController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _creditShimmerAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _creditController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
      ),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    if (widget.stepNumber >= 1) {
      _backgroundController.forward();
    }
    if (widget.stepNumber >= 2) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) {
        _titleController.forward();
        setState(() {
          _showDash = true;
        });
      }
    }
    if (widget.stepNumber >= 3) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) _bottomController.forward();
    }
    if (widget.stepNumber >= 4) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) _creditController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant _ClosingSlideContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stepNumber != oldWidget.stepNumber) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _dashFileLoader.dispose();
    _backgroundController.dispose();
    _titleController.dispose();
    _bottomController.dispose();
    _creditController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated background with stars
        AnimatedBuilder(
          animation: _backgroundFadeAnimation,
          builder: (context, child) {
            return Opacity(
              opacity: _backgroundFadeAnimation.value,
              child: Stack(
                children: [
                  // WWDC-style diagonal gradient on a dark canvas
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF14121F), // near-black, violet cast
                          Color(0xFF5B2A8C), // deep purple
                          Color(0xFFBF5AF2), // system purple
                          Color(0xFFFF375F), // system pink
                        ],
                        stops: [0.0, 0.34, 0.72, 1.0],
                      ),
                    ),
                  ),
                  // Subtle stars/dots pattern
                  CustomPaint(painter: _StarsPainter(), size: Size.infinite),
                ],
              ),
            );
          },
        ),
        // Conference watermark (top-right corner)
        if (widget.stepNumber >= 1)
          Positioned(
            top: 40,
            right: 48,
            child: FadeTransition(
              opacity: _backgroundFadeAnimation,
              child: Opacity(
                opacity: 0.35,
                child: Text(
                  'FLUTTERKAIGI 2026',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3.2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        // Main content
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dash Rive animation (appears with title)
              if (_showDash && widget.stepNumber >= 2)
                SizedBox(
                  width: 200,
                  height: 200,
                  child: RiveWidgetBuilder(
                    fileLoader: _dashFileLoader,
                    builder: (context, state) => switch (state) {
                      RiveLoading() => const SizedBox.shrink(),
                      RiveFailed() => const SizedBox.shrink(),
                      RiveLoaded() => RiveWidget(
                        controller: state.controller,
                        fit: Fit.contain,
                      ),
                    },
                  ),
                ),
              const SizedBox(height: 20),
              // Main title with zoom animation
              if (widget.stepNumber >= 2)
                AnimatedBuilder(
                  animation: _titleZoomAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _titleZoomAnimation.value,
                      child: FadeTransition(
                        opacity: _titleZoomAnimation,
                        child: Text(
                          'ご清聴ありがとうございました！',
                          textAlign: TextAlign.center,
                          style: FlutterDeckTheme.of(context).textTheme.display
                              .copyWith(
                                fontSize: 72,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 40),
              // Credit text with shimmer effect
              if (widget.stepNumber >= 4)
                AnimatedBuilder(
                  animation: _creditController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _creditFadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(_creditFadeAnimation),
                        child: ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Colors.white.withValues(alpha: 0.7),
                                Colors.white,
                                Colors.white.withValues(alpha: 0.7),
                              ],
                              stops: [0.0, _creditShimmerAnimation.value, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            'Slides made with flutter_deck',
                            style: FlutterDeckTheme.of(context)
                                .textTheme
                                .subtitle
                                .copyWith(
                                  fontSize: 18,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
        // Bottom section with handle and QR code
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Twitter handle (slides from left)
              if (widget.stepNumber >= 3)
                SlideTransition(
                  position: _handleSlideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 60),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.alternate_email,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'LucasGoldner',
                              style: FlutterDeckTheme.of(context)
                                  .textTheme
                                  .subtitle
                                  .copyWith(
                                    fontSize: 48,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'X (Twitter) で繋がりましょう',
                          style: FlutterDeckTheme.of(context).textTheme.subtitle
                              .copyWith(
                                fontSize: 32,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              // QR code (slides from right)
              if (widget.stepNumber >= 3)
                SlideTransition(
                  position: _qrSlideAnimation,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 60),
                    child: Column(
                      children: [
                        Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: PrettyQrView.data(
                              data: 'https://x.com/LucasGoldner',
                              decoration: const PrettyQrDecoration(
                                shape: PrettyQrSmoothSymbol(),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'スキャンして繋がる！',
                          style: FlutterDeckTheme.of(context).textTheme.subtitle
                              .copyWith(
                                fontSize: 28,
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = ui.PaintingStyle.fill;

    final random = math.Random(42); // Fixed seed for consistent pattern

    // Draw subtle dots/stars
    for (int i = 0; i < 50; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = random.nextDouble() * 3 + 1;

      canvas.drawCircle(Offset(x, y), radius, paint);

      // Some stars get a cross pattern
      if (i % 7 == 0) {
        final crossPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.05)
          ..strokeWidth = 1;

        canvas.drawLine(
          Offset(x - radius * 2, y),
          Offset(x + radius * 2, y),
          crossPaint,
        );
        canvas.drawLine(
          Offset(x, y - radius * 2),
          Offset(x, y + radius * 2),
          crossPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
