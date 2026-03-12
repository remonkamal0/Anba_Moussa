import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class AccentColorSelector extends ConsumerWidget {
  const AccentColorSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentAccentColor = ref.watch(accentColorProvider);
    final accentColorNotifier = ref.read(accentColorProvider.notifier);

    final List<({String name, Color color})> accentColors = [
      (name: 'orange', color: AppTheme.accentColors['orange']!),
      (name: 'purple', color: AppTheme.accentColors['purple']!),
      (name: 'green', color: AppTheme.accentColors['green']!),
      (name: 'blue', color: AppTheme.accentColors['blue']!),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'ACCENT',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: accentColors.map((accentColor) {
            final isSelected =
                currentAccentColor.value == accentColor.color.value;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: GestureDetector(
                onTap: () =>
                    accentColorNotifier.changeAccentColor(accentColor.name),
                child: AnimatedContainer(
                  duration: AppConstants.defaultAnimationDuration,
                  width: isSelected ? 36.w : 28.w,
                  height: isSelected ? 36.w : 28.w,
                  decoration: BoxDecoration(
                    color: accentColor.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.surface
                          : Colors.transparent,
                      width: isSelected ? 3.w : 0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 3,
                              spreadRadius: 0.5,
                            ),
                          ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.surface,
                          size: 18.w,
                        )
                      : null,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
