import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSearchButton;
  final bool showNotificationButton;
  final VoidCallback? onSearchTap;
  final VoidCallback? onNotificationTap;
  final Color backgroundColor;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showSearchButton = false,
    this.showNotificationButton = false,
    this.onSearchTap,
    this.onNotificationTap,
    this.backgroundColor = const Color(0xFFFFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false, // Changed to false for left alignment
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2D3142),
          fontSize: 24, // Increased font size
          fontWeight: FontWeight.bold, // Made it bold for better emphasis
        ),
      ),
      actions: [
        if (showSearchButton)
          IconButton(
            iconSize: 26, // Increased icon size
            icon: const Icon(Icons.search, color: Color(0xFF4C3575)),
            onPressed: onSearchTap ?? () {},
          ),
        if (showNotificationButton)
          IconButton(
            iconSize: 26, // Increased icon size
            icon:
                const Icon(Icons.notifications_none, color: Color(0xFF4C3575)),
            onPressed: onNotificationTap ?? () {},
          ),
        if (actions != null) ...actions!,
        const SizedBox(width: 8), // Added padding at the end
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
