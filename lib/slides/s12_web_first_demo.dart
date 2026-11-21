import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_intro_talk/core/theme/kaigi_theme.dart';
import 'package:flutter_intro_talk/core/widgets/phone_frame.dart';

// ─────────────────────────────────────────────────────────────────────────────
// /ai-web-first — the speaker's solo-dev loop, played as a short film:
//
//   Claude chat builds the app as a web app and shows a screenshot
//   → the CI "Release" button is pressed → build → TestFlight (~20 min)
//   → the exact same build opens on the phone
//   → feedback typed on the phone goes back to Claude → round two.
//
// One 18-second timeline drives everything; ↺ replays it.
// ─────────────────────────────────────────────────────────────────────────────

const _total = 18.0;

/// When each beat of one round happens, relative to the round's start.
abstract final class _Beat {
  static const userMsg = 0.0;
  static const typing = 0.4;
  static const reply = 1.2;
  static const toCi = 1.8; // dot travels chat → CI
  static const press = 2.6;
  static const build = 2.8;
  static const test = 3.8;
  static const upload = 4.6;
  static const done = 5.5;
  static const toPhone = 5.5; // dot travels CI → phone
  static const notify = 6.0;
  static const open = 6.8;
}

/// Round 1 starts at 0.3s, round 2 (after the phone feedback) at 9.8s.
const _rounds = [0.3, 9.8];
const _feedbackAt = 8.0; // bubble appears on the phone
const _feedbackTravel = (9.0, 9.8); // dot travels phone → chat
const _finishedAt = 17.2;

class WebFirstDemo extends StatefulWidget {
  const WebFirstDemo({super.key});

  @override
  State<WebFirstDemo> createState() => _WebFirstDemoState();
}

class _WebFirstDemoState extends State<WebFirstDemo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 18000),
  );

  @override
  void initState() {
    super.initState();
    _clock.forward();
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _clock,
      builder: (context, _) {
        final t = _clock.value * _total;
        return Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 11, child: _ChatPanel(t: t)),
                  _Link(
                    progress: _travel(t, [
                      for (final r in _rounds)
                        (r + _Beat.toCi, r + _Beat.press - 0.1),
                    ]),
                    color: DeckColors.purple,
                  ),
                  Expanded(flex: 9, child: _CiPanel(t: t)),
                  _Link(
                    progress: _travel(t, [
                      for (final r in _rounds)
                        (r + _Beat.toPhone, r + _Beat.notify),
                    ]),
                    color: DeckColors.orange,
                  ),
                  _PhonePanel(t: t),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _FeedbackTrack(t: t, onReplay: () => _clock.forward(from: 0)),
          ],
        );
      },
    );
  }
}

/// 0..1 while inside one of [windows], null otherwise.
double? _travel(double t, List<(double, double)> windows) {
  for (final (a, b) in windows) {
    if (t >= a && t <= b) return (t - a) / (b - a);
  }
  return null;
}

/// Which round is visible at time [t] (0 or 1), and its local time.
(int, double) _round(double t) {
  final i = t >= _rounds[1] ? 1 : 0;
  return (i, t - _rounds[i]);
}

// ── The app that gets built ─────────────────────────────────────────────────

/// A tiny café-booking app. v1 has a small blue button; after the feedback
/// v2 has a big orange one. The chat screenshot and the phone render the
/// exact same widget at a fixed design size — same code, same pixels.
class _CafeApp extends StatelessWidget {
  const _CafeApp({required this.version});

  final int version;

  static const designSize = Size(300, 650);

  @override
  Widget build(BuildContext context) {
    final v2 = version >= 2;
    final accent = v2 ? const Color(0xFFFF8A00) : const Color(0xFF2F6BFF);
    return SizedBox.fromSize(
      size: designSize,
      child: ColoredBox(
        color: const Color(0xFFFFF8F0),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KISSA',
                style: TextStyle(
                  fontSize: 13,
                  letterSpacing: 3,
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'おはよう、\nLucas さん',
                style: TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2A1A10),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                height: 170,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB36B), Color(0xFFE8566C)],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                alignment: Alignment.bottomLeft,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '今日のおすすめ',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                    Text(
                      '黒糖ラテ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              for (final (time, seats) in const [
                ('10:00', '残り 2 席'),
                ('13:30', '残り 5 席'),
              ])
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        time,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2A1A10),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        seats,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Align(
                alignment: v2 ? Alignment.center : Alignment.centerRight,
                child: Container(
                  width: v2 ? double.infinity : 120,
                  height: v2 ? 58 : 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(v2 ? 18 : 10),
                  ),
                  child: Text(
                    '予約する',
                    style: TextStyle(
                      fontSize: v2 ? 20 : 14,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Scales [_CafeApp] to whatever box it is given, keeping its proportions.
class _ScaledApp extends StatelessWidget {
  const _ScaledApp({required this.version});

  final int version;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      child: _CafeApp(version: version),
    );
  }
}

// ── Panel chrome ────────────────────────────────────────────────────────────

class _Panel extends StatelessWidget {
  const _Panel({
    required this.icon,
    required this.label,
    required this.step,
    required this.accent,
    required this.child,
  });

  final IconData icon;
  final String label;
  final String step;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF111118),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.14),
            blurRadius: 50,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              border: Border(
                bottom: BorderSide(color: accent.withValues(alpha: 0.25)),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: accent, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: DeckText.body.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: accent,
                    height: 1,
                  ),
                ),
                const Spacer(),
                Text(
                  step,
                  style: DeckText.caption.copyWith(fontSize: 17, height: 1),
                ),
              ],
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── ① Claude chat ───────────────────────────────────────────────────────────

class _ChatPanel extends StatelessWidget {
  const _ChatPanel({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final messages = <Widget>[];
    for (var i = 0; i < _rounds.length; i++) {
      final r = _rounds[i];
      if (t >= r + _Beat.userMsg) {
        messages.add(
          _Bubble.user(
            i == 0 ? 'カフェの予約アプリを作って' : 'ボタンをもっと大きく、オレンジに',
            fromPhone: i == 1,
          ),
        );
      }
      if (t >= r + _Beat.typing && t < r + _Beat.reply) {
        messages.add(const _Typing());
      }
      if (t >= r + _Beat.reply) {
        messages.add(
          _Bubble.claude(
            i == 0 ? 'Web 版を起動して確認しました。スクショです 👇' : '直しました。Web 版のスクショです 👇',
            shot: _BrowserShot(version: i + 1),
          ),
        );
      }
    }

    return _Panel(
      icon: Icons.auto_awesome,
      label: 'Claude',
      step: '① 実装 → ② Web でスクショ確認',
      accent: DeckColors.purple,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
        // Anchored to the bottom like a real chat: older messages scroll off.
        child: SingleChildScrollView(
          reverse: true,
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final m in messages)
                Padding(padding: const EdgeInsets.only(top: 14), child: m),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble.user(this.text, {this.fromPhone = false})
    : isUser = true,
      shot = null;

  const _Bubble.claude(this.text, {this.shot})
    : isUser = false,
      fromPhone = false;

  final String text;
  final bool isUser;
  final bool fromPhone;
  final Widget? shot;

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isUser
            ? DeckColors.purple.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fromPhone)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '📱 スマホから',
                style: DeckText.caption.copyWith(
                  fontSize: 15,
                  color: DeckColors.green,
                ),
              ),
            ),
          if (shot == null)
            Text(text, style: DeckText.body.copyWith(fontSize: 20, height: 1.4))
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 190,
                  child: Text(
                    text,
                    style: DeckText.body.copyWith(fontSize: 20, height: 1.4),
                  ),
                ),
                const SizedBox(width: 14),
                shot!,
              ],
            ),
        ],
      ),
    );
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      builder: (context, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, (1 - v) * 14),
          child: child,
        ),
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: bubble,
      ),
    );
  }
}

class _Typing extends StatelessWidget {
  const _Typing();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          '実装中… flutter run -d web-server',
          style: DeckText.monoSmall.copyWith(
            fontSize: 16,
            color: DeckColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

/// The web build, screenshotted by Claude inside its sandbox.
class _BrowserShot extends StatelessWidget {
  const _BrowserShot({required this.version});

  final int version;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            color: const Color(0xFF2A2A33),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            child: Row(
              children: [
                for (final c in const [
                  Color(0xFFFF5F57),
                  Color(0xFFFEBC2E),
                  Color(0xFF28C840),
                ])
                  Container(
                    width: 7,
                    height: 7,
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                const SizedBox(width: 6),
                Text(
                  'localhost:8080',
                  style: DeckText.monoSmall.copyWith(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 170,
            height: 170 / _CafeApp.designSize.aspectRatio,
            child: _ScaledApp(version: version),
          ),
        ],
      ),
    );
  }
}

// ── ③ CI/CD ─────────────────────────────────────────────────────────────────

class _CiPanel extends StatelessWidget {
  const _CiPanel({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final (i, local) = _round(t);
    final started = local >= _Beat.press;
    final pressing = local >= _Beat.press - 0.7 && local < _Beat.press + 0.25;
    final pressed = local >= _Beat.press && local < _Beat.press + 0.25;
    final done = local >= _Beat.done;
    final buildNumber = i + 1;

    final pipeline = [
      ('flutter build ipa', _Beat.build, _Beat.test),
      ('テスト', _Beat.test, _Beat.upload),
      ('TestFlight へアップロード', _Beat.upload, _Beat.done),
    ];
    final progress = ((local - _Beat.build) / (_Beat.done - _Beat.build)).clamp(
      0.0,
      1.0,
    );
    final minutes = (progress * 20).round();

    return _Panel(
      icon: Icons.rocket_launch_rounded,
      label: 'CI/CD',
      step: '③ Release → TestFlight',
      accent: DeckColors.orange,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The big button, with a hand that comes to press it.
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedScale(
                  scale: pressed ? 0.94 : 1,
                  duration: const Duration(milliseconds: 120),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 78,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [DeckColors.orange, DeckColors.pink],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: DeckColors.orange.withValues(
                            alpha: pressed ? 0.7 : 0.25,
                          ),
                          blurRadius: pressed ? 40 : 18,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 34,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Release  build $buildNumber',
                          style: DeckText.heading.copyWith(
                            fontSize: 28,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 26,
                  bottom: -26,
                  child: AnimatedOpacity(
                    opacity: pressing ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedSlide(
                      offset: pressing ? Offset.zero : const Offset(0.6, 0.6),
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      child: const Icon(
                        Icons.touch_app_rounded,
                        size: 54,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            for (final (label, from, to) in pipeline)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _PipelineRow(
                  label: label,
                  state: !started || local < from
                      ? _StepState.waiting
                      : local < to
                      ? _StepState.running
                      : _StepState.done,
                ),
              ),
            const SizedBox(height: 6),
            Expanded(
              child: _CiLog(local: local, buildNumber: buildNumber),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: started ? progress : 0,
                minHeight: 10,
                backgroundColor: Colors.white10,
                color: done ? DeckColors.green : DeckColors.orange,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  done ? Icons.check_circle_rounded : Icons.schedule_rounded,
                  color: done ? DeckColors.green : DeckColors.textSecondary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  done
                      ? '約 20 分で配信完了'
                      : started
                      ? '経過 $minutes 分'
                      : 'ボタンを押すだけ',
                  style: DeckText.body.copyWith(
                    fontSize: 22,
                    color: done ? DeckColors.green : DeckColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A few terminal lines that stream in while the pipeline runs.
class _CiLog extends StatelessWidget {
  const _CiLog({required this.local, required this.buildNumber});

  final double local;
  final int buildNumber;

  @override
  Widget build(BuildContext context) {
    final lines = [
      (_Beat.build, '\$ flutter build ipa --release'),
      (_Beat.build + 0.5, '✓ Built Runner.ipa (1.0.0+$buildNumber)'),
      (_Beat.test, '\$ flutter test   → All tests passed!'),
      (_Beat.upload, '\$ fastlane pilot upload'),
      (_Beat.upload + 0.5, '✓ Processing on App Store Connect…'),
      (_Beat.done, '🚀 TestFlight に配信しました'),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (at, line) in lines)
            if (local >= at)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: DeckText.monoSmall.copyWith(
                    fontSize: 15,
                    color: line.startsWith('\$')
                        ? DeckColors.textSecondary
                        : DeckColors.green,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

enum _StepState { waiting, running, done }

class _PipelineRow extends StatelessWidget {
  const _PipelineRow({required this.label, required this.state});

  final String label;
  final _StepState state;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _StepState.waiting => DeckColors.textTertiary,
      _StepState.running => DeckColors.orange,
      _StepState.done => DeckColors.green,
    };
    return Row(
      children: [
        SizedBox(
          width: 26,
          height: 26,
          child: switch (state) {
            _StepState.waiting => Icon(
              Icons.radio_button_unchecked,
              color: color,
              size: 24,
            ),
            _StepState.running => const Padding(
              padding: EdgeInsets.all(3),
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: DeckColors.orange,
              ),
            ),
            _StepState.done => Icon(
              Icons.check_circle_rounded,
              color: color,
              size: 26,
            ),
          },
        ),
        const SizedBox(width: 14),
        Text(label, style: DeckText.mono.copyWith(fontSize: 20, color: color)),
      ],
    );
  }
}

// ── ④ The phone ─────────────────────────────────────────────────────────────

class _PhonePanel extends StatelessWidget {
  const _PhonePanel({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final (i, local) = _round(t);
    // Which build is installed right now (0 = nothing yet).
    final installed = local >= _Beat.open ? i + 1 : i;
    final notifying = local >= _Beat.notify && local < _Beat.open + 0.4;
    final feedback = t >= _feedbackAt && t < _rounds[1] + 1.2;
    final finished = t >= _finishedAt;

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(
          330.0,
          (constraints.maxHeight - 40) * PhoneFrame.aspect,
        );
        return SizedBox(
          width: width + 20,
          child: Column(
            children: [
              Text(
                '④ 実機で触る',
                style: DeckText.caption.copyWith(
                  fontSize: 18,
                  color: DeckColors.green,
                ),
              ),
              const SizedBox(height: 10),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  PhoneFrame(
                    width: width,
                    accent: finished ? DeckColors.green : DeckColors.dart,
                    screenColor: installed == 0
                        ? const Color(0xFF3A4A8C)
                        : const Color(0xFFFFF8F0),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 450),
                          layoutBuilder: (current, previous) => Stack(
                            fit: StackFit.expand,
                            children: [...previous, ?current],
                          ),
                          child: installed == 0
                              ? const _HomeScreen(key: ValueKey('home'))
                              : KeyedSubtree(
                                  key: ValueKey('app$installed'),
                                  child: _ScaledApp(version: installed),
                                ),
                        ),
                        // TestFlight banner slides down from the top.
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 380),
                          curve: Curves.easeOutCubic,
                          top: notifying ? 8 : -110,
                          left: 8,
                          right: 8,
                          child: _TestFlightBanner(buildNumber: i + 1),
                        ),
                      ],
                    ),
                  ),
                  // Feedback typed on the phone, on its way back to Claude.
                  Positioned(
                    left: -30,
                    right: -10,
                    bottom: 70,
                    child: AnimatedOpacity(
                      opacity: feedback ? 1 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedSlide(
                        offset: feedback ? Offset.zero : const Offset(0, 0.3),
                        duration: const Duration(milliseconds: 350),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2A22),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: DeckColors.green),
                            boxShadow: const [
                              BoxShadow(color: Colors.black54, blurRadius: 20),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: DeckColors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'ボタンをもっと大きく、オレンジに',
                                  style: DeckText.body.copyWith(
                                    fontSize: 17,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.send_rounded,
                                color: DeckColors.green,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HomeScreen extends StatelessWidget {
  const _HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xFF5AC8FA),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFFFF2D55),
      Color(0xFFAF52DE),
      Color(0xFF007AFF),
      Color(0xFFFFCC00),
      Color(0xFF8E8E93),
    ];
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A4A8C), Color(0xFF7A4A8C)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 40, 22, 20),
        child: GridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 18,
          crossAxisSpacing: 16,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final c in colors)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TestFlightBanner extends StatelessWidget {
  const _TestFlightBanner({required this.buildNumber});

  final int buildNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF1E88E5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.flight_takeoff_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'TestFlight',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'KISSA build $buildNumber をインストールできます',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Links between the panels ────────────────────────────────────────────────

/// A short connector with a glowing dot while [progress] is non-null.
class _Link extends StatelessWidget {
  const _Link({required this.progress, required this.color});

  final double? progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = progress;
    return SizedBox(
      width: 64,
      child: Center(
        child: SizedBox(
          height: 40,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                color: (p == null ? Colors.white : color).withValues(
                  alpha: p == null ? 0.15 : 0.6,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: p == null ? Colors.white24 : color,
                  size: 28,
                ),
              ),
              if (p != null)
                Positioned(
                  left: 4 + p * 40,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color, blurRadius: 14)],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The return path under all three panels: phone → Claude. Also hosts the
/// replay button.
class _FeedbackTrack extends StatelessWidget {
  const _FeedbackTrack({required this.t, required this.onReplay});

  final double t;
  final VoidCallback onReplay;

  @override
  Widget build(BuildContext context) {
    final p = _travel(t, [_feedbackTravel]);
    final active = p != null;
    final finished = t >= _finishedAt;
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Icon(
            Icons.replay_rounded,
            color: active ? DeckColors.green : Colors.white38,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(
            finished ? '完成！ あとはこれを繰り返すだけ' : 'スマホから Claude へフィードバック',
            style: DeckText.body.copyWith(
              fontSize: 20,
              color: active || finished ? DeckColors.green : Colors.white38,
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) => Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: 2,
                    color: (active ? DeckColors.green : Colors.white)
                        .withValues(alpha: active ? 0.6 : 0.12),
                  ),
                  if (p != null)
                    // Travels right → left: from the phone back to the chat.
                    Positioned(
                      left: (1 - p) * (c.maxWidth - 14),
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(
                          color: DeckColors.green,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: DeckColors.green, blurRadius: 14),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onReplay,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white38),
                ),
                child: Text(
                  '↺ もう一度',
                  style: DeckText.body.copyWith(fontSize: 18, height: 1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
