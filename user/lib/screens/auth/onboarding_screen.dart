import 'package:flutter/material.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _onboardingController = PageController();
  int _currentOnboardingPage = 0;

  static const List<_OnboardingSlide> _onboardingSlides = <_OnboardingSlide>[
    _OnboardingSlide(
      imageAsset: 'assets/images/buk_senate.jpg',
      title: 'Smart Campus Experience',
      subtitle: 'Access courses, results, payments, timetable, and campus updates all in one place.',
    ),
    _OnboardingSlide(
      imageAsset: 'assets/images/buk_student.jpg',
      title: 'Easy Course Registration',
      subtitle: 'Register courses and manage your academic activities seamlessly.',
    ),
    _OnboardingSlide(
      imageAsset: 'assets/images/buk_square.jpg',
      title: 'Stay Connected',
      subtitle: 'Get announcements, schedules, and important university updates instantly.',
    ),
  ];

  @override
  void dispose() {
    _onboardingController.dispose();
    super.dispose();
  }

  void _showHelpMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact the smartBUK support desk for account or access help.')),
    );
  }

  void _openLogin() {
    Navigator.of(context).pushNamed(AppRoutes.login);
  }

  void _openRegister() {
    Navigator.of(context).pushNamed(AppRoutes.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF061527),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 420),
              child: Image.asset(
                _onboardingSlides[_currentOnboardingPage].imageAsset,
                key: ValueKey(
                  '$_currentOnboardingPage-${_onboardingSlides[_currentOnboardingPage].imageAsset}',
                ),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          Positioned.fill(
            child: PageView.builder(
              controller: _onboardingController,
              onPageChanged: (index) => setState(() => _currentOnboardingPage = index),
              itemCount: _onboardingSlides.length,
              itemBuilder: (context, index) {
                return const SizedBox.expand();
              },
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.04),
                    Colors.black.withOpacity(0.18),
                    const Color(0xFF02060C).withOpacity(0.72),
                    Colors.black,
                  ],
                  stops: const [0, 0.42, 0.68, 1],
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.85, -0.55),
                  radius: 1,
                  colors: [
                    const Color(AppColors.primary).withOpacity(0.28),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
              child: Column(
                children: [
                  const Spacer(),
                  SizedBox(
                    height: 162,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: Column(
                        key: ValueKey(_onboardingSlides[_currentOnboardingPage].title),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _onboardingSlides[_currentOnboardingPage].title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              height: 1.04,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            _onboardingSlides[_currentOnboardingPage].subtitle,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xE6FFFFFF),
                              fontSize: 15,
                              height: 1.45,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_onboardingSlides.length, (index) {
                      final active = index == _currentOnboardingPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutCubic,
                        width: active ? 26 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: active ? Colors.white : Colors.white.withOpacity(0.36),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(AppColors.primary).withOpacity(0.44),
                          blurRadius: 28,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _openRegister,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(AppColors.primary),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _openLogin,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                    ),
                    child: const Text(
                      'Log In',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Built for Bayero University Kano Students',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xB3FFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextButton(
                    onPressed: _showHelpMessage,
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xE6FFFFFF),
                      minimumSize: const Size.fromHeight(38),
                    ),
                    child: const Text('Need Help?'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
}
