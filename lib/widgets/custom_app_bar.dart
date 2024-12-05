import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({Key? key, required this.title}) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          Theme.of(context).primaryColor, // Make app bar background transparent
      elevation: 0, // Remove shadow
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white, // White color for title
        ),
      ),
      centerTitle: true, // Center the title
      actions: [
        IconButton(
          icon:
              Icon(Icons.exit_to_app, color: Colors.white), // White logout icon
          onPressed: () {
            // Logout logic
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ],
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.white), // White Hamburger icon
        onPressed: () {
          // Open the drawer
          Scaffold.of(context).openDrawer();
        },
      ),
    );
  }
}
