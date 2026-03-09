import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';

class NoInternetWidget extends StatelessWidget {
  final VoidCallback onRetry;

  const NoInternetWidget({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
            : [const Color(0xFFF8F9FA), const Color(0xFFE9ECEF)],
        ),
      ),
      child: Stack(
        children: [
          // Background Decorative Elements (Animated Circles)
          Positioned(
            top: -100.h,
            right: -50.w,
            child: _CircleBlur(color: cs.primary.withOpacity(0.15), size: 300.w),
          ),
          Positioned(
            bottom: -50.h,
            left: -50.w,
            child: _CircleBlur(color: cs.secondary.withOpacity(0.1), size: 250.w),
          ),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.03),
                      borderRadius: BorderRadius.circular(32.r),
                      border: Border.all(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated Icon with Pulse Effect
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 120.w,
                              height: 120.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    cs.primary.withOpacity(0.2),
                                    cs.primary.withOpacity(0),
                                  ],
                                ),
                              ),
                            ).animate(onPlay: (controller) => controller.repeat())
                             .scale(duration: 2.seconds, begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), curve: Curves.easeInOut)
                             .fadeOut(duration: 2.seconds),
                            
                            Container(
                              padding: EdgeInsets.all(24.w),
                              decoration: BoxDecoration(
                                color: cs.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: cs.primary.withOpacity(0.4),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.wifi_off_rounded,
                                size: 48.w,
                                color: Colors.white,
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                          ],
                        ),
                        
                        SizedBox(height: 32.h),
                        
                        // Text Elements
                        Text(
                          'عذراً، الاتصال مفقود',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            fontFamily: 'Cairo',
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),
                        
                        SizedBox(height: 12.h),
                        
                        Text(
                          'ارجو الاتصال بالانترنت لكى ترى الداتا',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface.withOpacity(0.6),
                            fontFamily: 'Cairo',
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),
                        
                        SizedBox(height: 40.h),
                        
                        // Action Button
                        GestureDetector(
                          onTap: onRetry,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [cs.primary, cs.primary.withOpacity(0.8)],
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: cs.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'إعادة المحاولة',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                  fontFamily: 'Cairo',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.9, 0.9)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleBlur extends StatelessWidget {
  final Color color;
  final double size;
  const _CircleBlur({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .moveY(begin: -20, end: 20, duration: 4.seconds, curve: Curves.easeInOut);
  }
}
