import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  int selectedThemeIndex = 0;
  String selectedLanguage = "English";

  final List<_PlaylistItem> playlists = const [
    _PlaylistItem(
      title: "Vibe Check",
      subtitle: "24 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1526481280695-3c687fd5432c?w=800&q=80",
    ),
    _PlaylistItem(
      title: "Sunset Beats",
      subtitle: "18 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1520975958225-84ea3e1aa7a5?w=800&q=80",
    ),
    _PlaylistItem(
      title: "Deep Focus",
      subtitle: "42 songs",
      imageUrl:
          "https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&q=80",
    ),
  ];

  final List<Color> themeColors = const [
    Color(0xFFFF6B35), // orange
    Color(0xFF2F80ED), // blue
    Color(0xFF27AE60), // green
    Color(0xFF9B51E0), // purple
    Color(0xFFEB5757), // red
  ];

  Color get accent => themeColors[selectedThemeIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      body: Stack(
        children: [
          // soft gradient header background
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 260.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFF4EE),
                    Color(0xFFF7F7FA),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header row: drawer toggle + title (auto RTL-aware)
                  Row(
                    children: [
                      InkWell(
                        borderRadius: BorderRadius.circular(999),
                        onTap: () => ZoomDrawer.of(context)?.toggle(),
                        child: Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.05),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.menu_rounded,
                            size: 22.w,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          "Settings",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF111827),
                          ),
                        ),
                      ),
                      // Spacer to balance the menu button and keep title centered
                      SizedBox(width: 42.w),
                    ],
                  ),

                  SizedBox(height: 18.h),

                  // Avatar + edit icon
                  _AvatarWithEdit(
                    accent: accent,
                    imageUrl:
                        "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=800&q=80",
                    onEdit: () {
                      // TODO: change avatar
                    },
                  ),

                  SizedBox(height: 14.h),

                  Text(
                    "Alex Rivera",
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "alex.rivera@example.com",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Edit Profile button
                  _PrimarySoftButton(
                    text: "Edit Profile",
                    onTap: () {
                      // TODO: go to edit profile
                    },
                  ),

                  SizedBox(height: 22.h),

                  // MY PLAYLISTS header row
                  _SectionHeaderRow(
                    leftText: "MY PLAYLISTS",
                    rightText: "See All",
                    accent: accent,
                    onAdd: () {
                      // TODO: add playlist
                    },
                    onSeeAll: () {
                      // TODO: see all
                    },
                  ),

                  SizedBox(height: 10.h),

                  SizedBox(
                    height: 145.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: playlists.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12.w),
                      itemBuilder: (context, index) {
                        final p = playlists[index];
                        return _PlaylistCard(item: p);
                      },
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("PREFERENCES"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.translate,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Language",
                          trailingText: selectedLanguage,
                          onTap: () async {
                            final value = await _showLanguageSheet(context);
                            if (value != null) {
                              setState(() => selectedLanguage = value);
                            }
                          },
                        ),
                        _DividerIndent(),
                        _RowTile(
                          icon: Icons.dark_mode_outlined,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Dark Mode",
                          trailing: Switch(
                            value: darkMode,
                            onChanged: (v) => setState(() => darkMode = v),
                            activeColor: accent,
                          ),
                          onTap: () => setState(() => darkMode = !darkMode),
                        ),
                        _DividerIndent(),
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 14.h,
                          ),
                          child: Row(
                            children: [
                              _IconBadge(
                                icon: Icons.palette_outlined,
                                bg: accent.withOpacity(.12),
                                color: accent,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  "Theme Customization",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              Text(
                                _themeName(selectedThemeIndex),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: accent,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                            left: 14.w,
                            right: 14.w,
                            bottom: 14.h,
                          ),
                          child: Row(
                            children: List.generate(themeColors.length, (i) {
                              final c = themeColors[i];
                              final selected = i == selectedThemeIndex;
                              return GestureDetector(
                                onTap: () => setState(() => selectedThemeIndex = i),
                                child: Container(
                                  margin: EdgeInsets.only(right: 10.w),
                                  width: 26.w,
                                  height: 26.w,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected ? const Color(0xFF111827) : Colors.transparent,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.06),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("MY LIBRARY"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.favorite_border,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Favorites",
                          onTap: () {
                            // TODO: go favorites
                          },
                        ),
                        _DividerIndent(),
                        _RowTile(
                          icon: Icons.download_outlined,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Downloads",
                          onTap: () {
                            // TODO: go downloads
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 18.h),

                  _SectionTitle("SECURITY & ALERTS"),
                  SizedBox(height: 10.h),

                  _CardContainer(
                    child: Column(
                      children: [
                        _RowTile(
                          icon: Icons.notifications_none,
                          iconBg: accent.withOpacity(.12),
                          iconColor: accent,
                          title: "Notifications",
                          onTap: () {
                            // TODO: go notifications
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 22.h),

                  // Log out
                  TextButton.icon(
                    onPressed: () {
                      // TODO: logout
                    },
                    icon: Icon(Icons.logout, color: accent),
                    label: Text(
                      "Log Out",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Delete account button
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: delete account confirm
                      },
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFEB5757)),
                      label: Text(
                        "Delete Account",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEB5757),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFEB5757).withOpacity(.25),
                          width: 1.2,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        backgroundColor: const Color(0xFFFFF1F1),
                      ),
                    ),
                  ),

                  SizedBox(height: 28.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeName(int i) {
    switch (i) {
      case 0:
        return "Orange";
      case 1:
        return "Blue";
      case 2:
        return "Green";
      case 3:
        return "Purple";
      case 4:
        return "Red";
      default:
        return "Custom";
    }
  }

  Future<String?> _showLanguageSheet(BuildContext context) async {
    final langs = ["English", "Arabic", "French", "Spanish"];
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(.12),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                "Language",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 10.h),
              ...langs.map((l) {
                final selected = l == selectedLanguage;
                return ListTile(
                  title: Text(
                    l,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: selected ? accent : const Color(0xFF111827),
                    ),
                  ),
                  trailing: selected ? Icon(Icons.check, color: accent) : null,
                  onTap: () => Navigator.of(ctx).pop(l),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onSettings;

  const _TopBar({
    required this.title,
    required this.onBack,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back,
          onTap: onBack,
        ),
        Expanded(
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF111827),
              ),
            ),
          ),
        ),
        _CircleIconButton(
          icon: Icons.settings_outlined,
          onTap: onSettings,
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.75),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Icon(icon, size: 20.w, color: const Color(0xFF111827)),
      ),
    );
  }
}

class _AvatarWithEdit extends StatelessWidget {
  final Color accent;
  final String imageUrl;
  final VoidCallback onEdit;

  const _AvatarWithEdit({
    required this.accent,
    required this.imageUrl,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 108.w,
          height: 108.w,
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.black12),
              errorWidget: (_, __, ___) => Container(
                color: Colors.black12,
                child: Icon(Icons.person, size: 40.w, color: Colors.white),
              ),
            ),
          ),
        ),
        Positioned(
          right: 2.w,
          bottom: 2.w,
          child: InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.12),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.edit, color: Colors.white, size: 16.w),
            ),
          ),
        ),
      ],
    );
  }
}

class _PrimarySoftButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _PrimarySoftButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170.w,
      height: 42.h,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: Colors.black.withOpacity(.06)),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF111827),
          ),
        ),
      ),
    );
  }
}

class _SectionHeaderRow extends StatelessWidget {
  final String leftText;
  final String rightText;
  final Color accent;
  final VoidCallback onAdd;
  final VoidCallback onSeeAll;

  const _SectionHeaderRow({
    required this.leftText,
    required this.rightText,
    required this.accent,
    required this.onAdd,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          leftText,
          style: TextStyle(
            letterSpacing: 1.2,
            fontSize: 12.sp,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        SizedBox(width: 10.w),
        InkWell(
          onTap: onAdd,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(
              color: accent,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.add, color: Colors.white, size: 16.w),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onSeeAll,
          child: Text(
            rightText,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          letterSpacing: 1.2,
          fontSize: 12.sp,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF9CA3AF),
        ),
      ),
    );
  }
}

class _CardContainer extends StatelessWidget {
  final Widget child;
  const _CardContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailingText;
  final Widget? trailing;
  final VoidCallback onTap;

  const _RowTile({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailingText,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        child: Row(
          children: [
            _IconBadge(icon: icon, bg: iconBg, color: iconColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText!,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF6B7280),
                ),
              ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(Icons.chevron_right, color: const Color(0xFF9CA3AF), size: 22.w),
          ],
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color color;

  const _IconBadge({
    required this.icon,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Icon(icon, color: color, size: 20.w),
    );
  }
}

class _DividerIndent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFF1F5F9),
      indent: 66.w,
      endIndent: 0,
    );
  }
}

class _PlaylistItem {
  final String title;
  final String subtitle;
  final String imageUrl;

  const _PlaylistItem({
    required this.title,
    required this.subtitle,
    required this.imageUrl,
  });
}

class _PlaylistCard extends StatelessWidget {
  final _PlaylistItem item;
  const _PlaylistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: EdgeInsets.all(10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.r),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.black12),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.black12,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            item.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            item.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}