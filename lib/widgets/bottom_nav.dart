import 'package:flutter/material.dart';
import 'package:postman/models/user_login.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final UserLogin userLogin = UserLogin();
  String? role;

  @override
  void initState() {
    super.initState();
    getDataLogin();
  }

  Future<void> getDataLogin() async {
    var user = await userLogin.getUserLogin();
    if (!mounted) return;

    if (user != null && user.status != false) {
      setState(() => role = user.role);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _go(int index) {
    if (index == widget.activePage) return;

    // ADMIN
    if (role == 'admin') {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/kelola');
          break;
      }
      return;
    }

    // USER (default)
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/dashboard');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/pesan');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == null) return const SizedBox(height: 0);

    // Items navbar (selalu 2 item)
    final List<BottomNavigationBarItem> items =
        role == 'admin'
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.manage_accounts),
                  label: 'Kelola',
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_bag),
                  label: 'Pesan',
                ),
              ];

    // pengaman currentIndex
    int safeIndex = widget.activePage;
    if (safeIndex < 0 || safeIndex >= items.length) safeIndex = 0;

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.green.shade700,
      unselectedItemColor: Colors.grey,
      currentIndex: safeIndex,
      onTap: _go,
      items: items,
    );
  }
}
