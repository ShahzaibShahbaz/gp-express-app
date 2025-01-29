// lib/features/customer/navigation/customer_navigation.dart

import 'package:flutter/material.dart';
import '../../../core/widgets/custom_bottom_navbar.dart';
import '../screens/customer_home_screen.dart';
import '../screens/gp_search_screen.dart';

class CustomerNavigation extends StatefulWidget {
  const CustomerNavigation({Key? key}) : super(key: key);

  @override
  State<CustomerNavigation> createState() => _CustomerNavigationState();
}

class _CustomerNavigationState extends State<CustomerNavigation> {
  int _currentIndex = 0;
  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _screens = [
    const CustomerHomeScreen(),
    const GPSearchScreen(),
    const Center(child: Text('Send Package Screen')), // TODO: Implement
    const Center(child: Text('Notifications Screen')), // TODO: Implement
    const Center(child: Text('Profile Screen')), // TODO: Implement
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens,
        physics: const NeverScrollableScrollPhysics(),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: _currentIndex,
        onIndexChanged: _onItemTapped,
        isGP: false,
      ),
    );
  }
}