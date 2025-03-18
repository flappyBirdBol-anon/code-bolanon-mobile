import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showSearchButton;
  final bool showNotificationButton;
  final void Function(String)? onSearchTap;
  final VoidCallback? onNotificationTap;
  final Color? backgroundColor;
  final TextEditingController? searchController;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showSearchButton = true,
    this.showNotificationButton = true,
    this.onSearchTap,
    this.onNotificationTap,
    this.backgroundColor,
    this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,
      elevation: 0,
      centerTitle: false, // Changed to false for left alignment
      title: Text(
        title,
        style: GoogleFonts.figtree(
          color: Color(0xFF2D3142),
          fontSize: 24, // Increased font size
          fontWeight: FontWeight.bold, // Made it bold for better emphasis
        ),
      ),
      actions: [
        if (showSearchButton)
          IconButton(
            iconSize: 26, // Increased icon size
            icon: const Icon(Icons.search, color: AppColors.primary),
            onPressed: () {
              _showSearchBottomSheet(context);
            },
          ),
        if (showNotificationButton)
          IconButton(
            iconSize: 26, // Increased icon size
            icon:
                const Icon(Icons.notifications_none, color: AppColors.primary),
            onPressed: onNotificationTap ?? () {},
          ),
        if (actions != null) ...actions!,
        const SizedBox(height: 8), // Added padding at the end
      ],
    );
  }

  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Search $title...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: onSearchTap,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
