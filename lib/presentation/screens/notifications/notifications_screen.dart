import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:anba_moussa/l10n/app_localizations.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
          'Notifications',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: cs.onSurface),
            onPressed: () {
              // TODO: Show more options
              print('More options');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              // Today's notifications
              _buildNotificationSection(
                title: 'TODAY',
                notifications: [
                  NotificationItem(
                    id: '1',
                    type: NotificationType.newRelease,
                    title: 'New Release: "After Hours" by The Weeknd',
                    time: '2h ago',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/album-cover/100/100',
                    isRead: false,
                  ),
                  NotificationItem(
                    id: '2',
                    type: NotificationType.likedPlaylist,
                    title: 'Sarah L. liked your Summer Vibes playlist',
                    time: '5h ago',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/profile-sarah/100/100',
                    isRead: false,
                  ),
                  NotificationItem(
                    id: '3',
                    type: NotificationType.discoverWeekly,
                    title: 'Your Discover Weekly is ready! Dive into your personalized mix for the week.',
                    time: '8h ago',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/discover-mix/100/100',
                    isRead: false,
                  ),
                ],
              ),
  
              // Orange separator line
              Container(
                height: 1.h,
                color: cs.primary,
                margin: EdgeInsets.symmetric(vertical: 8.h),
              ),
  
              // Earlier notifications
              _buildNotificationSection(
                title: 'EARLIER',
                notifications: [
                  NotificationItem(
                    id: '4',
                    type: NotificationType.tourAnnouncement,
                    title: 'Arctic Monkeys just announced a new tour date in your city!',
                    time: 'Yesterday',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/band-performing/100/100',
                    isRead: true,
                    actionText: 'Get Tickets',
                    actionColor: cs.primary,
                  ),
                  NotificationItem(
                    id: '5',
                    type: NotificationType.newFollower,
                    title: 'David Chen followed you. Check out their shared playlists.',
                    time: '2 days ago',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/david-chen/100/100',
                    isRead: false,
                  ),
                  NotificationItem(
                    id: '6',
                    type: NotificationType.playlistMilestone,
                    title: 'Your playlist Midnight Jazz reached 100 followers! 🎉',
                    time: '3 days ago',
                    hasImage: true,
                    imageUrl: 'https://picsum.photos/seed/playlist-milestone/100/100',
                    isRead: false,
                  ),
                ],
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required List<NotificationItem> notifications,
  }) {
    final cs = Theme.of(context).colorScheme;
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
                print('Tapped: ${notification.title}');
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
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(AppConstants.mediumSpacing.r),
      leading: Container(
        width: 48.w,
        height: 48.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
          color: _getNotificationColor(notification.type),
        ),
        child: notification.hasImage && notification.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
                child: Image.network(
                  notification.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.image,
                    size: 24.w,
                    color: Colors.grey[400],
                  ),
                ),
              )
            : Icon(
                _getNotificationIcon(notification.type),
                color: Colors.white,
                size: 24.w,
              ),
      ),
      title: Text(
        notification.title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        notification.time,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (notification.actionText != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppConstants.smallSpacing.w,
                vertical: AppConstants.extraSmallSpacing.h,
              ),
              decoration: BoxDecoration(
                color: notification.actionColor ?? const Color(0xFFFF6B35),
                borderRadius: BorderRadius.circular(AppConstants.smallBorderRadius.r),
              ),
              child: Text(
                notification.actionText!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: notification.actionColor != null ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          IconButton(
            onPressed: () {
              // TODO: Handle notification action
              if (notification.type == NotificationType.newRelease ||
                  notification.type == NotificationType.likedPlaylist ||
                  notification.type == NotificationType.discoverWeekly) {
                // Mark as read
              }
            },
            icon: Icon(
              notification.type == NotificationType.newRelease ||
                      notification.type == NotificationType.likedPlaylist ||
                      notification.type == NotificationType.discoverWeekly
                  ? Icons.close
                  : Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            iconSize: 20.w,
          ),
        ],
      ),
      onTap: onTap,
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.newRelease:
      case NotificationType.likedPlaylist:
        return Colors.orange;
      case NotificationType.discoverWeekly:
        return Colors.green;
      case NotificationType.tourAnnouncement:
        return Colors.purple;
      case NotificationType.newFollower:
        return Colors.blue;
      case NotificationType.playlistMilestone:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.newRelease:
        return Icons.album;
      case NotificationType.likedPlaylist:
        return Icons.favorite;
      case NotificationType.discoverWeekly:
        return Icons.explore;
      case NotificationType.tourAnnouncement:
        return Icons.music_note;
      case NotificationType.newFollower:
        return Icons.person_add;
      case NotificationType.playlistMilestone:
        return Icons.playlist_play;
      default:
        return Icons.notifications;
    }
  }
}

class NotificationItem {
  final String id;
  final NotificationType type;
  final String title;
  final String time;
  final String? imageUrl;
  final bool hasImage;
  final bool isRead;
  final String? actionText;
  final Color? actionColor;

  NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    this.imageUrl,
    this.hasImage = false,
    this.isRead = false,
    this.actionText,
    this.actionColor,
  });
}

enum NotificationType {
  newRelease,
  likedPlaylist,
  discoverWeekly,
  tourAnnouncement,
  newFollower,
  playlistMilestone,
}
