import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class ThemeSelector extends ConsumerWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THEME',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _ThemeOption(
              icon: Icons.wb_sunny,
              isSelected: currentTheme == ThemeMode.light,
              onTap: () => themeNotifier.setTheme(ThemeMode.light),
            ),
            SizedBox(width: 12.w),
            _ThemeOption(
              icon: Icons.nightlight_round,
              isSelected: currentTheme == ThemeMode.dark,
              onTap: () => themeNotifier.setTheme(ThemeMode.dark),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final orange = AppTheme.accentColors['orange']!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? orange : Colors.grey[100],
          border: Border.all(
            color: isSelected ? orange : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 24.w,
          color: isSelected ? Colors.white : Colors.grey[600],
        ),
      ),
    );
  }
}
