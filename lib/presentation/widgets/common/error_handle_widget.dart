import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/errors/exceptions.dart';
import 'no_internet_widget.dart';

class ErrorHandleWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const ErrorHandleWidget({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (error is NoInternetException) {
      return NoInternetWidget(onRetry: onRetry);
    }

    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception') || errorStr.contains('failed host lookup') || errorStr.contains('network_error')) {
      return NoInternetWidget(onRetry: onRetry);
    }

    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: cs.error, size: 48.w),
            SizedBox(height: 16.h),
            Text(
              error.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurface.withOpacity(0.7),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
