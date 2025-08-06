import 'package:flutter/material.dart';
import 'package:frontend/screens/donor_dashboard.dart';
import 'package:frontend/screens/impact_screen.dart';
import 'package:frontend/screens/patient_dashboard.dart';
import 'package:frontend/screens/profile_screen.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class MainShell extends StatefulWidget {
  final Map<String, dynamic> user;
  const MainShell({Key? key, required this.user}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Define the pages based on the user's role
    _pages = widget.user['role'] == 'patient'
        ? [
            PatientDashboard(user: widget.user),
            ImpactScreen(user: widget.user), // Gamification Screen
            ProfileScreen(user: widget.user),   // Profile Screen
          ]
        : [
            DonorDashboard(user: widget.user),
            ImpactScreen(user: widget.user),
            ProfileScreen(user: widget.user),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to keep page state
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              blurRadius: 20,
              color: Colors.black.withOpacity(.1),
            )
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: GNav(
              rippleColor: Colors.red[100]!,
              hoverColor: Colors.red[50]!,
              gap: 8,
              activeColor: Colors.white,
              iconSize: 24,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              duration: Duration(milliseconds: 400),
              tabBackgroundColor: Colors.redAccent,
              color: Colors.black54,
              tabs: [
                GButton(
                  icon: Icons.dashboard_rounded,
                  text: 'Dashboard',
                ),
                GButton(
                  icon: Icons.military_tech_rounded,
                  text: 'Impact',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'Profile',
                ),
              ],
              selectedIndex: _selectedIndex,
              onTabChange: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}