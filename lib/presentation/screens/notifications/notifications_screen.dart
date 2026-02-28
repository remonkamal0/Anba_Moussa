import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../domain/entities/notification.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final notifications = await sl.getNotificationsUseCase.execute();
      if (mounted) {
        setState(() {
          _notifications = notifications;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await sl.notificationRepository.markAllAsRead();
      _fetchNotifications();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: cs.primary),
            onPressed: _markAllAsRead,
            tooltip: 'Mark all as read',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!))
                : _notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_none, size: 64.w, color: cs.onSurface.withValues(alpha: 0.1)),
                            SizedBox(height: 16.h),
                            Text('No notifications found', 
                              style: AppTextStyles.getBodyLarge(context).copyWith(color: cs.onSurface.withValues(alpha: 0.5))),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchNotifications,
                        child: ListView.separated(
                          padding: EdgeInsets.all(16.w),
                          itemCount: _notifications.length,
                          separatorBuilder: (_, __) => Divider(height: 24.h, thickness: 0.5, color: cs.outlineVariant),
                          itemBuilder: (context, index) {
                            final n = _notifications[index];
                            return NotificationTile(
                              notification: n,
                              onTap: () {
                                if (!n.isRead) {
                                  sl.notificationRepository.markAsRead(n.id);
                                }
                                // Handle deep link if any
                                if (n.internalRoute != null) {
                                  context.push(n.internalRoute!);
                                }
                              },
                            ).animate().fadeIn(delay: Duration(milliseconds: index * 50)).slideX(begin: -0.05);
                          },
                        ),
                      ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required List<AppNotification> notifications,
  }) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: AppConstants.mediumSpacing.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            Text(
              'View all',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: cs.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: AppConstants.mediumSpacing.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            final notification = notifications[index];
            return NotificationTile(
              notification: notification,
              onTap: () {
                // TODO: Handle notification tap
                print('Tapped: ${notification.getLocalizedTitle(locale)}');
              },
            ).animate().slideX(
              duration: AppConstants.defaultAnimationDuration,
              delay: Duration(milliseconds: index * 100),
              begin: -0.2,
              curve: Curves.easeOut,
            );
          },
        ),
      ],
    );
  }
}

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon or Image
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: notification.isRead ? cs.onSurface.withValues(alpha: 0.05) : cs.primary.withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: notification.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: notification.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Icon(Icons.notifications, color: cs.primary.withValues(alpha: 0.5)),
                        errorWidget: (_, __, ___) => Icon(Icons.notifications, color: cs.primary),
                      )
                    : Icon(
                        _getIconForKind(notification.kind),
                        color: notification.isRead ? cs.onSurface.withValues(alpha: 0.4) : cs.primary,
                        size: 24.w,
                      ),
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.getLocalizedTitle(locale),
                          style: AppTextStyles.getBodyLarge(context).copyWith(
                            fontWeight: notification.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: notification.isRead ? cs.onSurface.withValues(alpha: 0.7) : cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.getLocalizedBody(locale),
                    style: AppTextStyles.getBodySmall(context).copyWith(
                      color: cs.onSurface.withValues(alpha: 0.6),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    _formatDateTime(notification.sentAt),
                    style: AppTextStyles.getLabelSmall(context).copyWith(
                      color: cs.onSurface.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForKind(String kind) {
    switch (kind) {
      case 'new_track': return Icons.music_note_rounded;
      case 'new_category': return Icons.category_rounded;
      case 'system': return Icons.settings_suggest_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// These are no longer needed
// class NotificationItem ...
// enum NotificationType ...

