import 'package:flutter/material.dart';
import 'package:gp_express_application/features/gp/screens/gp_profile_screen.dart';
import '../../features/gp/screens/gp_home_screen.dart';
import '../../features/gp/screens/my_missions_screen.dart';
import '../widgets/gp_bottom_navbar.dart';
import '../widgets/add_mission_fab.dart';
import '../../features/gp/screens/add_mission_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 1;
  final PageController _pageController = PageController(initialPage: 1);

  final List<Widget> _screens = [
    const MyMissionsScreen(),
    const GPHomeScreen(),
    const GPProfileScreen(),
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

  void _onAddMissionPressed() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AddMissionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeOutCubic;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          // Add fade transition
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      ),
    ).then((missionAdded) {
      if (missionAdded == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mission added successfully!'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
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
      bottomNavigationBar: GPBottomNavBar(
        selectedIndex: _currentIndex,
        onIndexChanged: _onItemTapped,
      ),
      floatingActionButton: _currentIndex != 2 ? Padding(
        padding: const EdgeInsets.only(bottom: 0, right: 25),
        child: AddMissionFAB(
          onPressed: _onAddMissionPressed,
        ),
      ) : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}