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
      (name: 'orange', color: const Color(0xFFFF6B35)),
      (name: 'purple', color: const Color(0xFF9B59B6)),
      (name: 'green', color: const Color(0xFF27AE60)),
      (name: 'blue', color: const Color(0xFF3498DB)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACCENT',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[400],
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: accentColors.map((accentColor) {
            final isSelected = currentAccentColor.value == accentColor.color.value;
            return Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: GestureDetector(
                onTap: () => accentColorNotifier.changeAccentColor(accentColor.name),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: accentColor.color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 3.w,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: accentColor.color.withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20.w,
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
