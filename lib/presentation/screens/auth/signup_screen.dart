import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_service.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _SignupScreen();
  }
}

class _SignupScreen extends StatefulWidget {
  const _SignupScreen();

  @override
  State<_SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<_SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _churchController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _supabaseService = SupabaseService.instance;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agree = false;

  String? _selectedGender;
  DateTime? _selectedBirthDate;

  // Get theme colors dynamically
  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _navy => Theme.of(context).colorScheme.onSurface;
  Color get _orange => Theme.of(context).colorScheme.primary;
  Color get _fieldFill => Theme.of(context).colorScheme.surface;
  Color get _border => Theme.of(context).colorScheme.outline.withOpacity(0.3);
  Color get _muted => Theme.of(context).colorScheme.onSurface.withOpacity(0.7);

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _churchController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onBack() => context.go('/login');
  void _onLogin() => context.go('/login');

  Future<void> _signUp() async {
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to Terms of Service and Privacy Policy.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // ✅ IMPORTANT:
      // Do NOT write to "profiles" here (RLS will block because no session yet if email confirmation is ON).
      // Store extra fields in user_metadata, then create/ensure profile AFTER login.
      final response = await _supabaseService.signUpWithEmail(
        email,
        password,
        data: {
          'full_name': _fullNameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'church': _churchController.text.trim(),
          'gender': _selectedGender,
          'birth_date': _selectedBirthDate?.toIso8601String(),
        },
      );

      if (!mounted) return;

      if (response.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Account created successfully! Please check your email to verify your account, then login.',
            ),
            backgroundColor: Colors.green,
          ),
        );

        context.go('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage = 'Signup failed';
      final s = e.toString();

      if (s.contains('User already registered')) {
        errorMessage = 'An account with this email already exists';
      } else if (s.toLowerCase().contains('weak password')) {
        errorMessage = 'Password is too weak. Please choose a stronger password.';
      } else if (s.toLowerCase().contains('invalid email')) {
        errorMessage = 'Please enter a valid email address';
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

  Future<void> _signInWithGoogle() async {
    // TODO
    debugPrint('Sign up with Google');
  }

  Future<void> _signInWithApple() async {
    // TODO
    debugPrint('Sign up with Apple');
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          color: _navy.withOpacity(0.75),
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _pillDecoration({
    required String hint,
    required IconData prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFB6BECB),
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefix, color: const Color(0xFFA7B0C0), size: 20.sp),
      suffixIcon: suffix,
      filled: true,
      fillColor: _fieldFill,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: BorderSide(color: _fieldFill, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: BorderSide(color: _fieldFill, width: 1),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.2),
      ),
    );
  }

  Widget _socialButton({
    required VoidCallback onTap,
    required Widget leading,
    required String text,
  }) {
    return SizedBox(
      height: 50.h,
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
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _termsRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 22.w,
          height: 22.w,
          child: Checkbox(
            value: _agree,
            onChanged: (v) => setState(() => _agree = v ?? false),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
            side: BorderSide(color: _border, width: 1.2),
            activeColor: _orange,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                color: _muted,
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
              children: [
                const TextSpan(text: 'I agree to the '),
                TextSpan(
                  text: 'Terms of Service',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy\nPolicy.',
                  style: TextStyle(color: _orange, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
      ],
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 18.h),

                // Back button (circle)
                InkWell(
                  onTap: _onBack,
                  borderRadius: BorderRadius.circular(22.r),
                  child: Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF3F5F7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: _navy),
                  ),
                ).animate().fadeIn(duration: 250.ms),

                SizedBox(height: 20.h),

                Text(
                  'Create Account',
                  style: TextStyle(
                    color: _navy,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ).animate().fadeIn(delay: 120.ms, duration: 300.ms),

                SizedBox(height: 8.h),

                Text(
                  'Join our religious community of music lovers',
                  style: TextStyle(
                    color: const Color(0xFF7E8798),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ).animate().fadeIn(delay: 220.ms, duration: 300.ms),

                SizedBox(height: 20.h),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _fieldLabel('Full Name'),
                      TextFormField(
                        controller: _fullNameController,
                        autofocus: true,
                        decoration: _pillDecoration(
                          hint: 'John Doe',
                          prefix: Icons.person_outline,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your full name';
                          return null;
                        },
                      ),

                      SizedBox(height: 10.h),

                      _fieldLabel('Email Address'),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _pillDecoration(
                          hint: 'hello@example.com',
                          prefix: Icons.email_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter your email address';
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      _fieldLabel('Phone Number'),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _pillDecoration(
                          hint: '+1 (555) 000-0000',
                          prefix: Icons.call_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your phone number';
                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      _fieldLabel('Church Name'),
                      TextFormField(
                        controller: _churchController,
                        decoration: _pillDecoration(
                          hint: 'Grace Community Church',
                          prefix: Icons.church_outlined,
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter your church name';
                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Gender'),
                                DropdownButtonFormField<String>(
                                  value: _selectedGender,
                                  items: ['male', 'female']
                                      .map((g) => DropdownMenuItem(
                                            value: g,
                                            child: Text(g[0].toUpperCase() + g.substring(1)),
                                          ))
                                      .toList(),
                                  onChanged: (v) => setState(() => _selectedGender = v),
                                  decoration: _pillDecoration(
                                    hint: 'Select',
                                    prefix: Icons.transgender,
                                  ),
                                  validator: (v) => v == null ? 'Required' : null,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _fieldLabel('Birth Date'),
                                InkWell(
                                  onTap: () async {
                                    final picked = await showDatePicker(
                                      context: context,
                                      initialDate: _selectedBirthDate ?? DateTime(2000),
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime.now(),
                                    );
                                    if (picked != null) {
                                      setState(() => _selectedBirthDate = picked);
                                    }
                                  },
                                  child: Container(
                                    height: 50.h,
                                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                                    decoration: BoxDecoration(
                                      color: _fieldFill,
                                      borderRadius: BorderRadius.circular(22.r),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: const Color(0xFFA7B0C0), size: 20.sp),
                                        SizedBox(width: 10.w),
                                        Text(
                                          _selectedBirthDate == null
                                              ? 'Pick Date'
                                              : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                                          style: TextStyle(
                                            color: _selectedBirthDate == null ? const Color(0xFFB6BECB) : _navy,
                                            fontSize: 14.sp,
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
                      ),

                      SizedBox(height: 10.h),

                      _fieldLabel('Password'),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: _pillDecoration(
                          hint: '•••••••••',
                          prefix: Icons.lock_outline,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFFA7B0C0),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please enter your password';
                          if (v.length < 6) return 'Password must be at least 6 characters';
                          return null;
                        },
                      ),

                      SizedBox(height: 14.h),

                      _fieldLabel('Confirm Password'),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: _pillDecoration(
                          hint: '•••••••••',
                          prefix: Icons.lock_reset_outlined,
                          suffix: IconButton(
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFFA7B0C0),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Please confirm your password';
                          return null;
                        },
                      ),

                      SizedBox(height: 10.h),

                      _termsRow(),

                      SizedBox(height: 10.h),

                      // Sign Up button
                      SizedBox(
                        height: 50.h,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
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
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 22.h),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Container(height: 1.h, color: _border)),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 14.w),
                            child: Text(
                              'OR SIGN UP WITH',
                              style: TextStyle(
                                color: const Color(0xFFB0B7C4),
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(child: Container(height: 1.h, color: _border)),
                        ],
                      ),

                      SizedBox(height: 18.h),

                      Row(
                        children: [
                          Expanded(
                            child: _socialButton(
                              onTap: _signInWithGoogle,
                              leading: Image.asset(
                                'assets/images/google-color-svgrepo-com.png',
                                width: 22.w,
                                height: 22.w,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.g_mobiledata, size: 26.sp, color: _navy),
                              ),
                              text: 'Google',
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: _socialButton(
                              onTap: _signInWithApple,
                              leading: Image.asset(
                                'assets/images/apple-svgrepo-com.png',
                                width: 22.w,
                                height: 22.w,
                                errorBuilder: (_, __, ___) =>
                                    Icon(Icons.apple, color: Colors.black, size: 22.sp),
                              ),
                              text: 'Apple',
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              color: _muted,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                            onTap: _onLogin,
                            borderRadius: BorderRadius.circular(8.r),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: _orange,
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 15.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}