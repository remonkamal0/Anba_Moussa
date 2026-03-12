import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../domain/entities/notification.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/notifications_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
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

  /// Handles navigation when a notification is tapped.
  /// Supports: internal routes (with optional ID), external URLs, and no-action.
  Future<void> _handleNotificationTap(AppNotification n) async {
    // 1. Mark as read
    if (!n.isRead) {
      // Optimistic update
      setState(() {
        final index = _notifications.indexWhere(
          (element) => element.id == n.id,
        );
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });

      try {
        await sl.notificationRepository.markAsRead(n.id);
        ref.invalidate(unreadNotificationsCountProvider);
      } catch (e) {
        // Rollback if needed
        _fetchNotifications();
      }
    }

    if (!mounted) return;
    final actionType = n.actionType ?? 'none';

    // 2. Handle external URL
    if (actionType == 'external' && n.externalUrl != null) {
      final uri = Uri.tryParse(n.externalUrl!);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // 3. Handle internal route
    if (actionType == 'internal' && n.internalRoute != null) {
      final route = _buildInternalRoute(n.internalRoute!, n.internalId);
      if (route != null) {
        context.push(route);
      }
    }
  }

  /// Builds the correct GoRouter path from the stored route pattern + optional ID.
  ///
  /// Supported patterns in `internal_route` column:
  ///   /home, /library, /search, /favorites, /downloads,
  ///   /photo-gallery, /video-gallery,
  ///   /album/:id       → needs internal_id
  ///   /playlist/:id    → needs internal_id
  ///   /player          → needs internal_id (used as trackId query param)
  String? _buildInternalRoute(String routePattern, String? id) {
    switch (routePattern) {
      // Simple routes — no ID needed
      case '/home':
      case '/library':
      case '/search':
      case '/favorites':
      case '/downloads':
      case '/photo-gallery':
      case '/video-gallery':
      case '/notifications':
        return routePattern;

      // Routes that require an ID
      case '/album/:id':
        return id != null ? '/album/$id' : null;
      case '/photo-album/:id':
        return id != null ? '/photo-album/$id' : null;
      case '/video-album/:id':
        return id != null ? '/video-album/$id' : null;
      case '/playlist/:id':
        return id != null ? '/playlist/$id' : null;
      case '/player':
        return id != null ? '/player?trackId=$id' : null;

      default:
        // Fallback: try using the route as-is (for future routes)
        return routePattern;
    }
  }

  Future<void> _markAllAsRead() async {
    // Optimistic update
    setState(() {
      _notifications = _notifications
          .map((n) => n.copyWith(isRead: true))
          .toList();
    });

    try {
      await sl.notificationRepository.markAllAsRead();
      ref.invalidate(unreadNotificationsCountProvider);
    } catch (e) {
      _fetchNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.drawerNotifications.toUpperCase(),
          style: TextStyle(
            fontSize: 12.sp,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
            color: cs.onSurface.withValues(alpha: 0.7),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.done_all_rounded, color: cs.primary),
            onPressed: _markAllAsRead,
            tooltip: AppLocalizations.of(context)!.markAllAsRead,
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
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        size: 64.w,
                        color: cs.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppLocalizations.of(context)!.noNotificationsFound,
                      style: AppTextStyles.getTitleMedium(context).copyWith(
                        color: cs.onSurface.withValues(alpha: 0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _fetchNotifications,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 24.h,
                    thickness: 0.5,
                    color: cs.outlineVariant,
                  ),
                  itemBuilder: (context, index) {
                    final n = _notifications[index];
                    return NotificationTile(
                          notification: n,
                          onTap: () => _handleNotificationTap(n),
                        )
                        .animate()
                        .fadeIn(delay: Duration(milliseconds: index * 50))
                        .slideX(begin: -0.05);
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
              AppLocalizations.of(context)!.viewAll,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: cs.primary),
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
                color: notification.isRead
                    ? cs.onSurface.withValues(alpha: 0.05)
                    : cs.primary.withValues(alpha: 0.1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: notification.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: notification.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Icon(
                          Icons.notifications,
                          color: cs.primary.withValues(alpha: 0.5),
                        ),
                        errorWidget: (_, __, ___) =>
                            Icon(Icons.notifications, color: cs.primary),
                      )
                    : Icon(
                        _getIconForKind(notification.kind),
                        color: notification.isRead
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : cs.primary,
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
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.w800,
                            color: notification.isRead
                                ? cs.onSurface.withValues(alpha: 0.7)
                                : cs.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
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
                    _formatDateTime(notification.sentAt, context),
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
      case 'new_track':
        return Icons.music_note_rounded;
      case 'new_category':
        return Icons.category_rounded;
      case 'system':
        return Icons.settings_suggest_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  String _formatDateTime(DateTime dt, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    final l10n = AppLocalizations.of(context)!;

    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// These are no longer needed
// class NotificationItem ...
// enum NotificationType ...
