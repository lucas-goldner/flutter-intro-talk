import 'package:flutter/material.dart';
import 'package:flutter_deck/flutter_deck.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';

class S02Speaker extends FlutterDeckSlideWidget {
  const S02Speaker({super.key})
      : super(
          configuration: const FlutterDeckSlideConfiguration(
            route: '/speaker',
            header: FlutterDeckHeaderConfiguration(
              title: '自己紹介',
            ),
            steps:
                8, // 8 steps: 1) 10x, 2) bark, 3) 1x, 4) profile image, 5) age/nationality, 6) GDE, 7) Flutter Tokyo, 8) YOUTRUST
          ),
        );

  @override
  FlutterDeckSlide build(BuildContext context) {
    return FlutterDeckSlide.custom(
      builder: (context) {
        return const SizedBox.expand(
          child: _SpeakerRiveWidget(),
        );
      },
    );
  }
}

class _SpeakerRiveWidget extends StatefulWidget {
  const _SpeakerRiveWidget();

  @override
  State<_SpeakerRiveWidget> createState() => _SpeakerRiveWidgetState();
}

class _SpeakerRiveWidgetState extends State<_SpeakerRiveWidget> {
  late File _file;
  RiveWidgetController? _controller;
  StateMachine? _stateMachine;
  bool _isLoading = true;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadRiveFile();
  }

  void _triggerAnimations(int stepNumber) {
    setState(() {
      _currentStep = stepNumber;
    });

    if (_stateMachine == null) return;

    switch (stepNumber) {
      case 1:
        // Step 1: Trigger 10x animation
        _stateMachine!.trigger('10x True')?.fire();
        break;
      case 2:
        // Step 2: Trigger bark (Trigger 1)
        _stateMachine!.trigger('Trigger 1')?.fire();
        break;
      case 3:
        // Step 3: Trigger 1x
        _stateMachine!.trigger('1x True')?.fire();
        break;
      case 4:
      case 5:
      case 6:
      case 7:
      case 8:
        // Steps 4-8: Profile information overlays (handled in build method)
        break;
    }
  }

  Future<void> _loadRiveFile() async {
    try {
      final bytes = await DefaultAssetBundle.of(context)
          .load('assets/lucas_goldner_presentation.riv');
      final file = await File.decode(bytes.buffer.asUint8List(),
          riveFactory: Factory.rive);

      if (file != null) {
        _file = file;

        // Create the controller with the file
        _controller = RiveWidgetController(_file);

        // Get the state machine from the controller's artboard
        // This ensures we're working with the same artboard that's being rendered
        final artboard = _controller?.artboard;
        if (artboard != null) {
          _stateMachine = _controller?.stateMachine;
        }

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FlutterDeckSlideStepsListener(
      listener: (context, stepNumber) {
        _triggerAnimations(stepNumber);
      },
      child: Stack(
        children: [
          // Rive animation background
          RiveWidget(
            controller: _controller!,
            fit: Fit.cover,
          ),
          // Profile information overlay - shows after Rive animations (step 4+)
          _ProfileOverlay(currentStep: _currentStep),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class _ProfileOverlay extends StatelessWidget {
  final int currentStep;

  const _ProfileOverlay({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Profile cloud - step 4 (slides in from left)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          top: 50,
          left: currentStep >= 4 ? 80 : -500,
          child: AnimatedOpacity(
            opacity: currentStep >= 4 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: _CloudWidget(
              width: 400,
              height: 200,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.9),
                    width: 3,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/lucas.jpeg',
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Age/Nationality cloud - step 5 (slides in from right)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          top: 80,
          right: currentStep >= 5 ? 100 : -500,
          child: AnimatedOpacity(
            opacity: currentStep >= 5 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: const _CloudWidget(
              width: 450,
              height: 180,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ドイツ × ブラジル',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '🇩🇪 🇧🇷',
                    style: TextStyle(fontSize: 30),
                  ),
                ],
              ),
            ),
          ),
        ),
        // GDE cloud - step 6 (slides in from left)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          top: 30,
          left: currentStep >= 6 ? 500 : -500,
          child: AnimatedOpacity(
            opacity: currentStep >= 6 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: const _CloudWidget(
              width: 480,
              height: 180,
              child: Text(
                '🚀 Flutter & Dart GDE',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        // Tokyo Meetup cloud - step 7 (slides in from right)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          top: 200,
          right: currentStep >= 7 ? 50 : -600,
          child: AnimatedOpacity(
            opacity: currentStep >= 7 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: const _CloudWidget(
              width: 620,
              height: 280,
              child: Text(
                '🗼 Flutter Tokyo\nMeetupオーガナイザー',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // YOUTRUST cloud - step 8 (slides in from left)
        AnimatedPositioned(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          top: 160,
          left: currentStep >= 8 ? 300 : -500,
          child: AnimatedOpacity(
            opacity: currentStep >= 8 ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            child: _CloudWidget(
              width: 480,
              height: 240,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🏢 所属',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SvgPicture.asset(
                    'assets/youtrust_full_logo.svg',
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CloudWidget extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;

  const _CloudWidget({
    required this.child,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Cloud shape using simple overlapping circles
          Positioned(
            left: width * 0.15,
            top: height * 0.35,
            child: Container(
              width: width * 0.35,
              height: height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: width * 0.15,
            top: height * 0.35,
            child: Container(
              width: width * 0.35,
              height: height * 0.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: width * 0.25,
            top: height * 0.2,
            child: Container(
              width: width * 0.5,
              height: height * 0.6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Bottom part of cloud
          Positioned(
            bottom: height * 0.2,
            child: Container(
              width: width * 0.7,
              height: height * 0.4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(height * 0.2),
              ),
            ),
          ),
          // Content on top
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(child: child),
          ),
        ],
      ),
    );
  }
}
