import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../services/analytics_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPage> _pages = [
    _OnboardingPage(
      gradient: const [AppTheme.primaryDark, AppTheme.primaryLight],
      icon: Icons.document_scanner_rounded,
      titleKey: 'onboarding_scan_title',
      subtitleKey: 'onboarding_scan_subtitle',
      featureKeys: [
        'onboarding_scan_f1',
        'onboarding_scan_f2',
        'onboarding_scan_f3',
      ],
    ),
    _OnboardingPage(
      gradient: const [Color(0xFF6A1B9A), Color(0xFFCE93D8)],
      icon: Icons.auto_fix_high_rounded,
      titleKey: 'onboarding_enhance_title',
      subtitleKey: 'onboarding_enhance_subtitle',
      featureKeys: [
        'onboarding_enhance_f1',
        'onboarding_enhance_f2',
        'onboarding_enhance_f3',
      ],
    ),
    _OnboardingPage(
      gradient: const [Color(0xFF1B5E20), Color(0xFF66BB6A)],
      icon: Icons.qr_code_scanner_rounded,
      titleKey: 'onboarding_tools_title',
      subtitleKey: 'onboarding_tools_subtitle',
      featureKeys: [
        'onboarding_tools_f1',
        'onboarding_tools_f2',
        'onboarding_tools_f3',
      ],
    ),
    _OnboardingPage(
      gradient: const [Color(0xFFE65100), Color(0xFFFFB74D)],
      icon: Icons.celebration_rounded,
      titleKey: 'onboarding_free_title',
      subtitleKey: 'onboarding_free_subtitle',
      featureKeys: [
        'onboarding_free_f1',
        'onboarding_free_f2',
        'onboarding_free_f3',
      ],
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() {
    Get.find<StorageService>().setOnboardingComplete(true);
    if (Get.isRegistered<AnalyticsService>()) {
      Get.find<AnalyticsService>().logOnboardingCompleted();
    }
    Get.offAllNamed(AppConstants.homeRoute);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) =>
                _buildPage(context, _pages[index], index),
          ),
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildPage(
      BuildContext context, _OnboardingPage page, int pageIndex) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: Text(
                    'onboarding_skip'.tr,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Icon
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: Icon(page.icon, color: Colors.white, size: 72),
              )
                  .animate(key: ValueKey(pageIndex))
                  .fadeIn(duration: 500.ms)
                  .scale(begin: const Offset(0.7, 0.7), duration: 500.ms),
              const SizedBox(height: 40),
              // Title
              Text(
                page.titleKey.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(key: ValueKey('t$pageIndex'))
                  .fadeIn(delay: 150.ms, duration: 450.ms)
                  .slideY(begin: 0.2, duration: 450.ms),
              const SizedBox(height: 16),
              // Subtitle
              Text(
                page.subtitleKey.tr,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.55,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(key: ValueKey('s$pageIndex'))
                  .fadeIn(delay: 250.ms, duration: 450.ms),
              const SizedBox(height: 32),
              // Features
              ...page.featureKeys.map(
                (key) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check, color: Colors.white,
                            size: 16),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        key.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          bottom: MediaQuery.of(context).padding.bottom + 24,
          top: 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withAlpha(40),
            ],
          ),
        ),
        child: Row(
          children: [
            // Page dots
            Row(
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(right: 6),
                  width: i == _currentPage ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == _currentPage
                        ? Colors.white
                        : Colors.white.withAlpha(80),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Next / Get Started button
            ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: Text(
                isLast ? 'onboarding_get_started'.tr : 'onboarding_next'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final List<Color> gradient;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  final List<String> featureKeys;

  const _OnboardingPage({
    required this.gradient,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
    required this.featureKeys,
  });
}
