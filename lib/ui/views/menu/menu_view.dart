import 'package:code_bolanon/ui/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Menu',
        showNotificationButton: true,
        backgroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          // Profile Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: InkWell(
              onTap: () => viewModel.profile(),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: viewModel.userImage.isNotEmpty
                        ? NetworkImage(viewModel.userImage)
                        : null,
                    child: viewModel.userImage.isEmpty
                        ? const Icon(Icons.person, size: 30)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        viewModel.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        viewModel.userRole,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Dark Mode Switch
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.dark_mode, color: Colors.white, size: 20),
            ),
            title: const Text('Dark Mode'),
            trailing: Switch(
              value: viewModel.isDarkMode,
              onChanged: viewModel.toggleDarkMode,
            ),
          ),

          // Other Settings Options
          _buildSettingsTile(
            icon: Icons.settings,
            iconColor: Colors.green,
            title: 'Settings',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.info,
            iconColor: Colors.teal,
            title: 'About',
            onTap: () {},
          ),
          _buildSettingsTile(
            icon: Icons.help,
            iconColor: Colors.red,
            title: 'Help Center',
            onTap: () {},
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextButton(
              onPressed: () => viewModel.logout(),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }

  @override
  MenuViewModel viewModelBuilder(BuildContext context) => MenuViewModel();
}
