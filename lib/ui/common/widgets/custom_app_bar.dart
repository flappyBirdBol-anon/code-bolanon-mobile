import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchButton;
  final bool showNotificationButton;
  final Function(String)? onSearchTap;
  final Color? backgroundColor;
  final List<Widget>? actions;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showSearchButton = false,
    this.showNotificationButton = true,
    this.onSearchTap,
    this.backgroundColor,
    this.actions,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
    _animationController.forward();
  }

  void _stopSearch() {
    _animationController.reverse().then((_) {
      setState(() {
        _isSearching = false;
        _searchController.clear();
      });
      // Call onSearchTap with empty string to reset search
      widget.onSearchTap?.call('');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBar(
      backgroundColor: widget.backgroundColor,
      elevation: 0,
      titleSpacing: _isSearching ? 0 : NavigationToolbar.kMiddleSpacing,
      leading: _isSearching
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _stopSearch,
            )
          : null,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _isSearching
            ? Container(
                height: kToolbarHeight,
                alignment: Alignment.center,
                child: TextField(
                  controller: _searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search courses...',
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  onChanged: widget.onSearchTap,
                ),
              )
            : Text(
                widget.title,
                style: GoogleFonts.figtree(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      actions: [
        if (widget.showSearchButton && !_isSearching)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              if (_isSearching) {
                _stopSearch();
              } else {
                _startSearch();
              }
            },
          ),
        if (!_isSearching && widget.showNotificationButton)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notification tap
            },
          ),
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }
}
