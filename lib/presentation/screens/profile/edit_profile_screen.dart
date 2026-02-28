import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'John Doe');
  final _emailController = TextEditingController(text: 'john.doe@example.com');
  final _phoneController = TextEditingController(text: '+1 (555) 000-0000');
  final _churchController = TextEditingController(text: 'Grace Community Church');
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _churchController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement profile update logic with Supabase
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _changePhoto() {
    // TODO: Implement photo picker
    print('Change photo');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Profile',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppConstants.mediumSpacing.r),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile picture section
                Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        // Profile picture
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(
                                'https://picsum.photos/seed/female-avatar/120/120',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ).animate().scale(
                          duration: AppConstants.defaultAnimationDuration,
                          curve: Curves.easeOut,
                        ),

                        // Camera icon
                        GestureDetector(
                          onTap: _changePhoto,
                          child: Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16.w,
                            ),
                          ).animate().fadeIn(
                            duration: AppConstants.defaultAnimationDuration,
                            delay: const Duration(milliseconds: 400),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: AppConstants.smallSpacing.h),

                    Text(
                      'CHANGE PHOTO',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ).animate().fadeIn(
                      duration: AppConstants.defaultAnimationDuration,
                      delay: const Duration(milliseconds: 600),
                    ),
                  ],
                ),

                SizedBox(height: AppConstants.largeSpacing.h),

                // Form fields
                _buildTextField(
                  controller: _nameController,
                  label: 'FULL NAME',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                  delay: const Duration(milliseconds: 800),
                ),

                SizedBox(height: AppConstants.mediumSpacing.h),

                _buildTextField(
                  controller: _emailController,
                  label: 'EMAIL ADDRESS',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email address';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  delay: const Duration(milliseconds: 1000),
                ),

                SizedBox(height: AppConstants.mediumSpacing.h),

                _buildTextField(
                  controller: _phoneController,
                  label: 'PHONE NUMBER',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                  delay: const Duration(milliseconds: 1200),
                ),

                SizedBox(height: AppConstants.mediumSpacing.h),

                _buildTextField(
                  controller: _churchController,
                  label: 'CHURCH NAME',
                  icon: Icons.church,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your church name';
                    }
                    return null;
                  },
                  delay: const Duration(milliseconds: 1400),
                ),

                SizedBox(height: AppConstants.extraLargeSpacing.h),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cs.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24.w,
                            height: 24.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.save,
                                size: 20.w,
                              ),
                              SizedBox(width: AppConstants.smallSpacing.w),
                              Text(
                                'Save Changes',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ).animate().fadeIn(
                    duration: AppConstants.defaultAnimationDuration,
                    delay: const Duration(milliseconds: 1600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    Duration? delay,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: AppConstants.smallSpacing.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.mediumBorderRadius.r),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
        ).animate().slideX(
          duration: AppConstants.defaultAnimationDuration,
          delay: delay ?? Duration.zero,
          begin: -0.2,
          curve: Curves.easeOut,
        ),
      ],
    );
  }
}
