import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/supabase_service.dart';
import '../../providers/user_profile_provider.dart';
import '../../../l10n/app_localizations.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _churchController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  String? _selectedGender;
  DateTime? _selectedBirthDate;

  bool _isLoading = false;
  bool _isInitialized = false;

  Color get _bg => Theme.of(context).scaffoldBackgroundColor;
  Color get _navy => Theme.of(context).colorScheme.onSurface;
  Color get _orange => Theme.of(context).colorScheme.primary;
  Color get _fieldFill => Theme.of(context).colorScheme.surface;
  Color get _border =>
      Theme.of(context).colorScheme.outline.withValues(alpha: 0.3);

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _churchController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

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

  void _initFields() {
    if (_isInitialized) return;
    final profileState = ref.read(userProfileProvider);
    final data = profileState.profile;

    _fullNameController.text = data?['full_name'] as String? ?? '';
    _emailController.text = profileState.email;
    _phoneController.text = data?['phone'] as String? ?? '';
    _churchController.text = data?['church'] as String? ?? '';

    final gender = data?['gender'] as String?;
    if (gender == 'male' || gender == 'female') {
      _selectedGender = gender;
    }

    final birthStr = data?['birth_date'] as String?;
    if (birthStr != null && birthStr.isNotEmpty) {
      _selectedBirthDate = DateTime.tryParse(birthStr);
    }

    _isInitialized = true;
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    final newPassword = _passwordController.text;
    if (newPassword.isNotEmpty &&
        newPassword != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.passwordsNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (newPassword.isNotEmpty) {
        await SupabaseService.instance.updateUserPassword(newPassword);
      }

      await SupabaseService.instance.updateMyProfile(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        church: _churchController.text.trim(),
        gender: _selectedGender,
        birthDate: _selectedBirthDate,
      );

      // Refresh global profile state
      await ref.read(userProfileProvider.notifier).fetchProfile();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newPassword.isNotEmpty
                  ? AppLocalizations.of(context)!.profileAndPasswordUpdated
                  : AppLocalizations.of(context)!.profileUpdated,
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context)!.profileUpdateError}: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(left: 6.w, bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          color: _navy.withValues(alpha: 0.75),
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  InputDecoration _pillDecoration({
    required String hint,
    required IconData prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: const Color(0xFFB6BECB),
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(prefix, color: const Color(0xFFA7B0C0), size: 20.sp),
      filled: true,
      fillColor: _fieldFill,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: BorderSide(color: _fieldFill, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(22.r),
        borderSide: BorderSide(color: _orange, width: 1.5),
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

  @override
  Widget build(BuildContext context) {
    _initFields();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: _navy),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.editProfile,
          style: TextStyle(
            color: _navy,
            fontSize: 20.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        backgroundColor: _bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 18.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _fieldLabel(AppLocalizations.of(context)!.fullName),
                  TextFormField(
                    controller: _fullNameController,
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(context)!.fullNameHint,
                      prefix: Icons.person_outline,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return AppLocalizations.of(context)!.emptyName;
                      return null;
                    },
                  ),

                  SizedBox(height: 14.h),

                  _fieldLabel(
                    AppLocalizations.of(context)!.emailCannotBeChanged,
                  ),
                  TextFormField(
                    controller: _emailController,
                    enabled: false,
                    style: TextStyle(color: _navy.withValues(alpha: 0.5)),
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(context)!.emailHint,
                      prefix: Icons.email_outlined,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  _fieldLabel(AppLocalizations.of(context)!.phoneNumber),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(context)!.phoneHint,
                      prefix: Icons.call_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return AppLocalizations.of(context)!.required;
                      return null;
                    },
                  ),

                  SizedBox(height: 14.h),

                  _fieldLabel(AppLocalizations.of(context)!.churchName),
                  TextFormField(
                    controller: _churchController,
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(context)!.churchHint,
                      prefix: Icons.church_outlined,
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return AppLocalizations.of(context)!.required;
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
                            _fieldLabel(AppLocalizations.of(context)!.gender),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              items: ['male', 'female']
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(
                                        g == 'male'
                                            ? AppLocalizations.of(
                                                context,
                                              )!.genderMale
                                            : AppLocalizations.of(
                                                context,
                                              )!.genderFemale,
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedGender = v),
                              decoration: _pillDecoration(
                                hint: AppLocalizations.of(context)!.select,
                                prefix: Icons.transgender,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fieldLabel(
                              AppLocalizations.of(context)!.birthDate,
                            ),
                            InkWell(
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate:
                                      _selectedBirthDate ?? DateTime(2000),
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
                                    Icon(
                                      Icons.calendar_today,
                                      color: const Color(0xFFA7B0C0),
                                      size: 20.sp,
                                    ),
                                    SizedBox(width: 10.w),
                                    Text(
                                      _selectedBirthDate == null
                                          ? AppLocalizations.of(
                                              context,
                                            )!.pickDate
                                          : '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}',
                                      style: TextStyle(
                                        color: _selectedBirthDate == null
                                            ? const Color(0xFFB6BECB)
                                            : _navy,
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

                  SizedBox(height: 14.h),

                  // Optional Password Change Section
                  Divider(color: _border),
                  SizedBox(height: 8.h),

                  Text(
                    AppLocalizations.of(context)!.changePasswordOptional,
                    style: TextStyle(
                      color: _navy,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  _fieldLabel(AppLocalizations.of(context)!.newPassword),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(context)!.leaveBlankToKeep,
                      prefix: Icons.lock_outline,
                    ),
                    validator: (v) {
                      if (v != null && v.isNotEmpty && v.length < 6)
                        return AppLocalizations.of(
                          context,
                        )!.signupPasswordLength;
                      return null;
                    },
                  ),

                  SizedBox(height: 14.h),

                  _fieldLabel(AppLocalizations.of(context)!.confirmNewPassword),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: _pillDecoration(
                      hint: AppLocalizations.of(
                        context,
                      )!.confirmNewPasswordHint,
                      prefix: Icons.lock_reset_outlined,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Save button
                  SizedBox(
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveChanges,
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: _orange,
                            disabledBackgroundColor: _orange.withValues(
                              alpha: 0.7,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18.r),
                            ),
                          ).copyWith(
                            shadowColor: WidgetStatePropertyAll(
                              Colors.black.withValues(alpha: 0.12),
                            ),
                          ),
                      child: _isLoading
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              AppLocalizations.of(context)!.saveChanges,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),

                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
