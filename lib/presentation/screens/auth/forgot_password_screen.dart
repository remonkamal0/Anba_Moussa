import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../presentation/providers/theme_provider.dart';
import '../../../core/network/supabase_service.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ForgotPasswordScreen();
  }
}

class _ForgotPasswordScreen extends StatefulWidget {
  const _ForgotPasswordScreen();

  @override
  State<_ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<_ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService.instance;
  bool _isLoading = false;

  // Get theme colors dynamically
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _navy => Theme.of(context).colorScheme.onSurface;
  Color get _orange => Theme.of(context).colorScheme.primary;
  Color get _fieldFill => Theme.of(context).colorScheme.surface;
  Color get _border => Theme.of(context).colorScheme.outline.withOpacity(0.3);
  Color get _muted => Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Send password reset email with Supabase
      await _supabaseService.resetPassword(_emailController.text.trim());

      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset link sent! Please check your email.'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Navigate back to login
      context.go('/login');
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Failed to send reset link';
      if (e.toString().contains('User not found')) {
        errorMessage = 'No account found with this email address';
      } else if (e.toString().contains('rate limit')) {
        errorMessage = 'Too many requests. Please try again later.';
      } else {
        errorMessage = 'An error occurred: $e';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      hintText: 'hello@example.com',
      hintStyle: TextStyle(
        color: const Color(0xFFB3BBC8),
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(Icons.email_outlined, color: const Color(0xFFA7B0C0), size: 22.sp),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: _border, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, bottom: 10.h),
      child: Text(
        text,
        style: TextStyle(
          color: _muted,
          fontSize: 13.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 70.h),

                // Logo square (orange + shadow)
                Container(
                  width: 72.w,
                  height: 72.w,
                  decoration: BoxDecoration(
                    color: _orange,
                    borderRadius: BorderRadius.circular(18.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Icon(Icons.headphones, color: Colors.white, size: 34.sp),
                ).animate().fadeIn(duration: 350.ms).scale(begin: const Offset(0.95, 0.95)),

                SizedBox(height: 28.h),

                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 34.sp,
                    fontWeight: FontWeight.w900,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 120.ms, duration: 350.ms),

                SizedBox(height: 14.h),

                // Subtitle split in lines like the mock
                Text(
                  'Enter your email address and we will\nsend you a link to reset your\npassword.',
                  style: TextStyle(
                    color: const Color(0xFF7E8798),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

                SizedBox(height: 42.h),

                // Email
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _fieldLabel('EMAIL ADDRESS'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDecoration(),
                        validator: (value) {
                          if (value == null || value.isEmpty) return 'Please enter your email address';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ).animate().fadeIn(delay: 320.ms, duration: 350.ms),
                    ],
                  ),
                ),

                SizedBox(height: 26.h),

                // Send Link button
                SizedBox(
                  width: double.infinity,
                  height: 58.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetLink,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orange,
                      disabledBackgroundColor: _orange.withOpacity(0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18.r),
                      ),
                    ).copyWith(
                      shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.12)),
                    ),
                    child: _isLoading
                        ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      'Send Link',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 420.ms, duration: 350.ms),

                SizedBox(height: 140.h),

                // Back to Login
                GestureDetector(
                  onTap: () => context.pop(),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: _muted,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      children: [
                        const TextSpan(text: 'Back to '),
                        TextSpan(
                          text: 'Login',
                          style: TextStyle(
                            color: _orange,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 520.ms, duration: 350.ms),

                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}