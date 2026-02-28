import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/supabase_service.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _LoginScreen();
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabaseService = SupabaseService.instance;

  bool _obscurePassword = true;
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
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Sign in with Supabase
      final response = await _supabaseService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.user != null) {
        // Navigate to home screen on successful login
        context.go(AppConstants.homeRoute);
      } else {
        // Show error if login failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login failed. Please check your credentials.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Login failed';
      if (e.toString().contains('Invalid login')) {
        errorMessage = 'Invalid email or password';
      } else if (e.toString().contains('Email not confirmed')) {
        errorMessage = 'Please confirm your email address';
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

  void _onForgotPassword() => context.push('/forgot-password');
  void _onSignUp() => context.go('/signup');

  Future<void> _signInWithGoogle() async {
    // TODO: Implement Google Sign-In
    debugPrint('Sign in with Google');
  }

  Future<void> _signInWithApple() async {
    // TODO: Implement Apple Sign-In
    debugPrint('Sign in with Apple');
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFB3BBC8),
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefix, color: const Color(0xFFA7B0C0), size: 22.sp),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldFill,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: _border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18.r),
        borderSide: BorderSide(color: _orange, width: 1.5),
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

  Widget _socialButton({
    required VoidCallback onTap,
    required Widget leading,
    required String text,
  }) {
    return SizedBox(
      height: 56.h,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(color: _border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            SizedBox(width: 10.w),
            Text(
              text,
              style: TextStyle(
                color: _navy,
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: _bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final h = constraints.maxHeight;
            final isSmall  = h < 680;
            final isTablet = constraints.maxWidth >= 600;
            final hPad     = isTablet ? 64.w : 24.w;
            final vTop     = isSmall  ? 24.h  : 48.h;
            final vGap     = isSmall  ? 12.h  : 22.h;
            final logoSize = isSmall  ? 56.w  : 72.w;
            final titleSz  = isSmall  ? 26.sp : 34.sp;

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: h),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Column(
                      children: [
                        SizedBox(height: vTop),

                        // ── Logo ──────────────────────────────────────────
                        Container(
                          width: logoSize,
                          height: logoSize,
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

                        SizedBox(height: vGap),

                        Text(
                          'Welcome Back',
                          style: TextStyle(color: _navy, fontSize: titleSz, fontWeight: FontWeight.w900),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 120.ms, duration: 350.ms),

                        SizedBox(height: 8.h),

                        Text(
                          'Discover and stream your favorite hits',
                          style: TextStyle(color: const Color(0xFF7E8798), fontSize: 15.sp, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

                        SizedBox(height: vGap),

                        // ── Form ──────────────────────────────────────────
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _fieldLabel('EMAIL ADDRESS'),
                              TextFormField(
                                controller: _emailController,
                                autofocus: true,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _inputDecoration(hint: 'hello@example.com', prefix: Icons.email_outlined),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Please enter your email address';
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Please enter a valid email address';
                                  return null;
                                },
                              ).animate().slideX(begin: -0.08, duration: 350.ms),

                              SizedBox(height: vGap),

                              _fieldLabel('PASSWORD'),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: _inputDecoration(
                                  hint: '••••••••',
                                  prefix: Icons.lock_outline,
                                  suffix: IconButton(
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: const Color(0xFFA7B0C0)),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
                              ).animate().slideX(begin: -0.08, duration: 350.ms, delay: 90.ms),

                              SizedBox(height: 10.h),

                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: _onForgotPassword,
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                    child: Text('Forgot Password?', style: TextStyle(color: _orange, fontSize: 14.sp, fontWeight: FontWeight.w800)),
                                  ),
                                ),
                              ),

                              SizedBox(height: vGap),

                              // Login button
                              SizedBox(
                                height: 56.h,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _orange,
                                    disabledBackgroundColor: _orange.withOpacity(0.7),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
                                  ).copyWith(shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.12))),
                                  child: _isLoading
                                      ? SizedBox(width: 22.w, height: 22.w, child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                                      : Text('Login', style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: FontWeight.w900)),
                                ),
                              ).animate().fadeIn(delay: 220.ms, duration: 350.ms),

                              SizedBox(height: 14.h),

                              // Skip
                              Center(
                                child: InkWell(
                                  onTap: () => context.go('/home'),
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                                    child: Text('Skip', style: TextStyle(color: _muted, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                  ),
                                ),
                              ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

                              SizedBox(height: 14.h),

                              // OR divider
                              Row(
                                children: [
                                  Expanded(child: Container(height: 1.h, color: _border)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                                    child: Text('OR CONTINUE WITH', style: TextStyle(color: const Color(0xFFB0B7C4), fontSize: 12.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                                  ),
                                  Expanded(child: Container(height: 1.h, color: _border)),
                                ],
                              ),

                              SizedBox(height: 14.h),

                              Row(
                                children: [
                                  Expanded(
                                    child: _socialButton(
                                      onTap: _signInWithGoogle,
                                      leading: Image.asset('assets/images/google-color-svgrepo-com.png', width: 22.w, height: 22.w, errorBuilder: (_, __, ___) => Icon(Icons.g_mobiledata, size: 26.sp, color: _navy)),
                                      text: 'Google',
                                    ).animate().slideX(begin: -0.08, duration: 350.ms),
                                  ),
                                  SizedBox(width: 14.w),
                                  Expanded(
                                    child: _socialButton(
                                      onTap: _signInWithApple,
                                      leading: Image.asset('assets/images/apple-svgrepo-com.png', width: 22.w, height: 22.w, errorBuilder: (_, __, ___) => Icon(Icons.apple, color: Colors.black, size: 22.sp)),
                                      text: 'Apple',
                                    ).animate().slideX(begin: 0.08, duration: 350.ms),
                                  ),
                                ],
                              ),

                              SizedBox(height: 20.h),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Don't have an account? ", style: TextStyle(color: const Color(0xFF8A93A3), fontSize: 14.sp, fontWeight: FontWeight.w600)),
                                  InkWell(
                                    onTap: _onSignUp,
                                    borderRadius: BorderRadius.circular(8.r),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                      child: Text('Sign Up', style: TextStyle(color: _orange, fontSize: 14.sp, fontWeight: FontWeight.w900)),
                                    ),
                                  ),
                                ],
                              ),

                              SizedBox(height: 24.h),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}