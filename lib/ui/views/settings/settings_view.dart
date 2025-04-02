import 'package:code_bolanon/ui/common/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'settings_viewmodel.dart';

class SettingsView extends StackedView<SettingsViewModel> {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    SettingsViewModel viewModel,
    Widget? child,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Settings',
          style: GoogleFonts.figtree(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // App Theme
                    _buildSettingsCard(
                      context,
                      cardColor: cardColor,
                      title: 'Display',
                      icon: Icons.color_lens_outlined,
                      iconColor: Colors.purple,
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Dark Mode',
                          subtitle: 'Enable dark theme for the app',
                          value: viewModel.isDarkMode,
                          onChanged: (value) => viewModel.toggleTheme(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Notifications
                    _buildSettingsCard(
                      context,
                      cardColor: cardColor,
                      title: 'Notifications',
                      icon: Icons.notifications_none_outlined,
                      iconColor: Colors.amber,
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Push Notifications',
                          subtitle:
                              'Receive notifications about course updates and messages',
                          value: viewModel.notificationsEnabled,
                          onChanged: (value) =>
                              viewModel.toggleNotifications(value),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Data & Storage
                    _buildSettingsCard(
                      context,
                      cardColor: cardColor,
                      title: 'Data & Storage',
                      icon: Icons.storage_outlined,
                      iconColor: Colors.blue,
                      children: [
                        _buildSwitchTile(
                          context,
                          title: 'Auto-download Lessons',
                          subtitle:
                              'Automatically download lesson content when on Wi-Fi',
                          value: viewModel.autoDownloadEnabled,
                          onChanged: (value) =>
                              viewModel.toggleAutoDownload(value),
                        ),
                        const Divider(),
                        _buildDropdownTile(
                          context,
                          title: 'Data Saving Mode',
                          subtitle: 'Control how much data the app uses',
                          value: viewModel.dataSavingMode,
                          options: const ['Off', 'Standard', 'High'],
                          onChanged: (value) =>
                              viewModel.setDataSavingMode(value!),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Cache Management
                    _buildSettingsCard(
                      context,
                      cardColor: cardColor,
                      title: 'Cache Management',
                      icon: Icons.cleaning_services_outlined,
                      iconColor: Colors.green,
                      children: [
                        ListTile(
                          title: Text(
                            'Image Cache',
                            style: GoogleFonts.figtree(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            viewModel.imageCacheSize,
                            style: GoogleFonts.figtree(
                              color: subtitleColor,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => viewModel.clearImageCache(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.8),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.figtree(),
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(
                            'Lesson Cache',
                            style: GoogleFonts.figtree(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            viewModel.lessonCacheSize,
                            style: GoogleFonts.figtree(
                              color: subtitleColor,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => viewModel.clearLessonCache(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.8),
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Clear',
                              style: GoogleFonts.figtree(),
                            ),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          title: Text(
                            'All Cache',
                            style: GoogleFonts.figtree(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            'Total: ${viewModel.totalCacheSize}',
                            style: GoogleFonts.figtree(
                              color: subtitleColor,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: viewModel.isLoading
                                ? null
                                : () => viewModel.clearAllCache(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade700,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(
                              'Clear All',
                              style: GoogleFonts.figtree(),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // About
                    _buildSettingsCard(
                      context,
                      cardColor: cardColor,
                      title: 'About',
                      icon: Icons.info_outline,
                      iconColor: Colors.indigo,
                      children: [
                        ListTile(
                          title: Text(
                            'App Version',
                            style: GoogleFonts.figtree(
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            viewModel.appVersion,
                            style: GoogleFonts.figtree(
                              color: subtitleColor,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Additional padding at the bottom
                    const SizedBox(height: 40),
                  ],
                ),

                // Loading Overlay
                if (viewModel.isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required Color cardColor,
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<Widget> children,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.figtree(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return SwitchListTile.adaptive(
      title: Text(
        title,
        style: GoogleFonts.figtree(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.figtree(
          color: subtitleColor,
          fontSize: 12,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.primary,
    );
  }

  Widget _buildDropdownTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;

    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.figtree(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.figtree(
          color: subtitleColor,
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        underline: const SizedBox(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(
              option,
              style: GoogleFonts.figtree(
                color: textColor,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  SettingsViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      SettingsViewModel();
}
