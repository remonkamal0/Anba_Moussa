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
    final cs = Theme.of(context).colorScheme;

    final languages = [
      {
        'code': 'en',
        'name': currentLocale.languageCode == 'ar' ? 'الإنجليزية' : 'English',
      },
      {
        'code': 'ar',
        'name': currentLocale.languageCode == 'ar' ? 'العربية' : 'العربية',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'LANGUAGE',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: languages.map((language) {
            final isSelected = currentLocale.languageCode == language['code'];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: () => localeNotifier.changeLocale(language['code']!),
                child: AnimatedContainer(
                  duration: AppConstants.defaultAnimationDuration,
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? cs.primary.withOpacity(0.1)
                        : cs.surface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? cs.primary
                          : cs.outline.withOpacity(0.3),
                      width: 1.2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: cs.primary.withOpacity(0.1),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Icon(
                          Icons.check_circle_rounded,
                          color: cs.primary,
                          size: 16.sp,
                        ),
                        SizedBox(width: 6.w),
                      ],
                      Text(
                        language['name']!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isSelected
                              ? cs.primary
                              : cs.onSurface.withOpacity(0.7),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ],
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
