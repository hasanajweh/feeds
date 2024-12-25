import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String? currentRoute;

  const AppDrawer({Key? key, this.currentRoute}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
              
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'PPU Feeds',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            Icons.home,
            'Home',
            '/home',
            currentRoute == '/home',
          ),
          _buildDrawerItem(
            context,
            Icons.subscriptions,
            'Feeds',
            '/feeds',
            currentRoute == '/feeds',
          ),
          _buildDrawerItem(
            context,
            Icons.logout,
            'Logout',
            '/login',
            false,
          ),
        ],
      ),
    );
  }

  ListTile _buildDrawerItem(
      BuildContext context, IconData icon, String title, String route, bool selected) {
    return ListTile(
      leading: Icon(icon, color: selected ? Colors.blue : Colors.grey),
      title: Text(title, style: TextStyle(color: selected ? Colors.blue : Colors.black)),
      onTap: () {
        if (!selected) {
          Navigator.pop(context); 
          Navigator.pushReplacementNamed(context, route);
        }
      },
    );
  }
}
