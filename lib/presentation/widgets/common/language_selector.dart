import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);

    final languages = [
      {'code': 'en', 'name': currentLocale.languageCode == 'ar' ? 'الإنجليزية' : 'English'},
      {'code': 'ar', 'name': currentLocale.languageCode == 'ar' ? 'العربية' : 'العربية'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LANGUAGE',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: languages.map((language) {
            final isSelected = currentLocale.languageCode == language['code'];
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => localeNotifier.changeLocale(language['code']!),
                child: AnimatedContainer(
                  duration: AppConstants.defaultAnimationDuration,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF6B35)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF6B35)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    language['name']!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
