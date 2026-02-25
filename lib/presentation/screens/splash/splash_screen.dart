import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  void _navigateToOnboarding() async {
    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      context.go(AppConstants.onboardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo container
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF6B35).withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.music_note,
                  color: Colors.white,
                  size: 60.w,
                ),
              ),
            ).animate()
              .scale(
                duration: const Duration(milliseconds: 800),
                curve: Curves.elasticOut,
              )
              .then()
              .shimmer(
                duration: const Duration(milliseconds: 1500),
                color: Colors.white.withOpacity(0.5),
              ),

            SizedBox(height: AppConstants.largeSpacing.h),

            // App name
            Text(
              'Melodix',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 1.2,
              ),
            ).animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 400),
              )
              .slideY(
                duration: AppConstants.defaultAnimationDuration,
                delay: const Duration(milliseconds: 400),
                begin: 0.3,
                curve: Curves.easeOut,
              ),

            SizedBox(height: AppConstants.smallSpacing.h),

            // Tagline
            Text(
              'Your Religious Music Experience',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
                letterSpacing: 0.5,
              ),
            ).animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
              )
              .slideY(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 600),
                begin: 0.2,
                curve: Curves.easeOut,
              ),

            SizedBox(height: AppConstants.extraLargeSpacing.h),

            // Loading indicator
            Container(
              width: 40.w,
              height: 40.w,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFFFF6B35)),
              ),
            ).animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 1000),
              )
              .rotate(
                duration: const Duration(milliseconds: 2000),
                delay: const Duration(milliseconds: 1000),
                curve: Curves.linear,
              ),

            SizedBox(height: AppConstants.mediumSpacing.h),

            // Loading text
            Text(
              'Loading your music...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ).animate()
              .fadeIn(
                duration: const Duration(milliseconds: 800),
                delay: const Duration(milliseconds: 1200),
              ),
          ],
        ),
      ),
    );
  }
}
