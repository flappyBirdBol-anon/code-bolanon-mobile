import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';

import 'menu_viewmodel.dart';

class MenuView extends StackedView<MenuViewModel> {
  const MenuView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    MenuViewModel viewModel,
    Widget? child,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: const CustomAppBar(
        title: 'Menu',
        showNotificationButton: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section with refined proportions
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: InkWell(
                onTap: () => viewModel.profile(),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 30, // Reduced from 35
                          backgroundColor: Colors.white.withOpacity(0.2),
                          backgroundImage: viewModel.userImage.isNotEmpty
                              ? NetworkImage(viewModel.userImage)
                              : null,
                          child: viewModel.userImage.isEmpty
                              ? Icon(Icons.person,
                                  size: 30,
                                  color: Colors.white.withOpacity(0.7))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              viewModel.userName,
                              style: GoogleFonts.figtree(
                                fontSize: 19, // Reduced from 24
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                viewModel.userRole.toUpperCase(),
                                style: GoogleFonts.figtree(
                                  fontSize: 11, // Reduced from 12
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.chevron_right,
                          color: Colors.white.withOpacity(0.9),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Section with refined styling
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    offset: const Offset(0, 4),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.dark_mode,
                    iconColor: const Color(0xFF818CF8),
                    title: 'Dark Mode',
                    isDark: isDark,
                    trailing: Switch.adaptive(
                      value: viewModel.isDarkMode,
                      onChanged: viewModel.toggleDarkMode,
                      activeColor: AppColors.primary,
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.settings,
                    iconColor: const Color(0xFF14B8A6),
                    title: 'Settings',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.analytics,
                    iconColor: const Color(0xFFFACC15),
                    title: 'Analytics',
                    isDark: isDark,
                    onTap: () => viewModel.navigateToAnalytics(),
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.description,
                    iconColor: const Color(0xFFA855F7),
                    title: 'Terms and Conditions',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.help,
                    iconColor: const Color(0xFF22C55E),
                    title: 'Help Center',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _buildDivider(isDark),
                  _buildSettingsTile(
                    icon: Icons.info,
                    iconColor: const Color(0xFF3B82F6),
                    title: 'About',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // Logout Section with improved styling
            Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showLogoutConfirmation(context, viewModel),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.red.withOpacity(0.1)
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.logout_rounded,
                                color: Colors.red[600],
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Logout',
                              style: GoogleFonts.figtree(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.red[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.figtree(
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                      fontSize: 12,
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

  Future<void> _showLogoutConfirmation(
      BuildContext context, MenuViewModel viewModel) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Logout',
            style: GoogleFonts.figtree(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: GoogleFonts.figtree(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.figtree(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                viewModel.logout();
              },
              child: Text(
                'Logout',
                style: GoogleFonts.figtree(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: GoogleFonts.figtree(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.grey[300] : Colors.grey[800],
        ),
      ),
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
      onTap: onTap,
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      color: isDark ? Colors.grey[800] : Colors.grey[100],
      indent: 20,
      endIndent: 20,
    );
  }

  @override
  MenuViewModel viewModelBuilder(BuildContext context) => MenuViewModel();
}
