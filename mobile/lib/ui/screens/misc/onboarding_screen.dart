import 'package:flutter/material.dart';

import '../../../core/storage/app_prefs.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../routes.dart';
import '../../widgets/app_button.dart';

class _Slide {
  const _Slide(this.icon, this.title, this.body, this.gradient);
  final IconData icon;
  final String title;
  final String body;
  final String gradient;
}

const List<_Slide> _slides = <_Slide>[
  _Slide(
    Icons.school_outlined,
    'Learn skills that pay',
    'Certificate-backed ICT courses in web development, design, data, '
        'networking and productivity - taught by people who do the work.',
    'sky',
  ),
  _Slide(
    Icons.desktop_windows_outlined,
    'Book a workstation',
    'Reserve a computer, gaming or research station with fast internet. '
        'Pick your date, time and how long you need it.',
    'mint',
  ),
  _Slide(
    Icons.print_outlined,
    'Print from your phone',
    'Documents, posters, banners, business cards and photos - submit an '
        'order, see the price up front, collect when it is ready.',
    'peach',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.onDone});

  /// Called when the last slide is finished, so [RootGate] can rebuild and
  /// decide what comes next. Null when the screen is opened as a named route,
  /// in which case it navigates on its own.
  final VoidCallback? onDone;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await AppPrefs.instance.setOnboarded(true);
    if (!mounted) return;
    final VoidCallback? onDone = widget.onDone;
    if (onDone != null) {
      onDone();
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil(
      Routes.login,
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLast = _index == _slides.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finish,
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (int i) => setState(() => _index = i),
                itemBuilder: (BuildContext context, int i) {
                  final _Slide slide = _slides[i];
                  final List<Color> colors = AppColors.coverFor(slide.gradient);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    // The artwork scales with the space actually available.
                    // At a fixed 190 the slide overflows on a short screen
                    // (a 320x640 phone) once the body text wraps to four lines.
                    child: LayoutBuilder(
                      builder: (
                        BuildContext context,
                        BoxConstraints constraints,
                      ) {
                        final double art =
                            (constraints.maxHeight * 0.40).clamp(110.0, 190.0);
                        final double gap =
                            (constraints.maxHeight * 0.09).clamp(16.0, 44.0);
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              height: art,
                              width: art,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: colors,
                                ),
                              ),
                              child: Icon(
                                slide.icon,
                                size: art * 0.39,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: gap),
                            Text(
                              slide.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -0.7,
                                color: context.inkColor,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Flexible(
                              child: Text(
                                slide.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 15,
                                  height: 1.55,
                                  color: context.mutedColor,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List<Widget>.generate(
                _slides.length,
                (int i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 7,
                  width: i == _index ? 22 : 7,
                  decoration: BoxDecoration(
                    color:
                        i == _index ? AppColors.primary : context.hairlineColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                children: <Widget>[
                  AppButton(
                    label: isLast ? 'Get started' : 'Next',
                    onPressed: () {
                      if (isLast) {
                        _finish();
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () async {
                      await AppPrefs.instance.setOnboarded(true);
                      if (!context.mounted) return;
                      Navigator.of(context).pushNamed(Routes.signup);
                    },
                    child: const Text('Create an account'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
