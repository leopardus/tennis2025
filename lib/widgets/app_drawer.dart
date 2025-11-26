
import 'package:flutter/material.dart';
import 'package:padel_one/app_styles.dart';
import 'package:padel_one/auth_service.dart';
import 'package:padel_one/login_page.dart';
import 'package:padel_one/padel_time_page.dart';
import 'package:padel_one/reports_page.dart';
import 'package:padel_one/settings_page.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthService>(
        builder: (context, authService, child) {
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (authService.isLoggedIn)
                UserAccountsDrawerHeader(
                  accountName: Text(authService.displayName ?? 'Guest', style: const TextStyle(color: AppStyles.drawerTextColor)),
                  accountEmail: Text(authService.userEmail ?? '', style: const TextStyle(color: AppStyles.drawerTextColor)),
                  decoration: const BoxDecoration(
                    color: AppStyles.drawerHeaderBackground,
                  ),
                )
              else
                const DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppStyles.drawerHeaderBackground,
                  ),
                  child: Text(
                    'Menu',
                    style: TextStyle(color: AppStyles.drawerTextColor, fontSize: AppStyles.fontSizeLarge),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.calendar_today, color: AppStyles.drawerIconColor),
                title: const Text('Programari', style: TextStyle(color: AppStyles.drawerIconColor)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.pushReplacement( // Go back to the original page
                    context,
                    MaterialPageRoute(builder: (context) => const PadelTimePage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.design_services, color: AppStyles.drawerIconColor),
                title: const Text('Programari UX', style: TextStyle(color: AppStyles.drawerIconColor)),
                onTap: () {
                  Navigator.pop(context); // Already on this page, just close drawer
                },
              ),
              ListTile(
                leading: const Icon(Icons.assessment, color: AppStyles.drawerIconColor),
                title: const Text('Rapoarte', style: TextStyle(color: AppStyles.drawerIconColor)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ReportsPage()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: AppStyles.drawerIconColor),
                title: const Text('Setari', style: TextStyle(color: AppStyles.drawerIconColor)),
                onTap: () {
                  Navigator.pop(context); // Close the drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsPage()),
                  );
                },
              ),
              const Divider(),
              if (authService.isLoggedIn)
                ListTile(
                  leading: const Icon(Icons.logout, color: AppStyles.drawerIconColor),
                  title: const Text('Logout', style: TextStyle(color: AppStyles.drawerIconColor)),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    authService.signOut();
                  },
                )
              else
                ListTile(
                  leading: const Icon(Icons.login, color: AppStyles.drawerIconColor),
                  title: const Text('Login', style: TextStyle(color: AppStyles.drawerIconColor)),
                  onTap: () {
                    Navigator.pop(context); // Close the drawer
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginPage()),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
