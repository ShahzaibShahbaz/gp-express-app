import 'package:flutter/material.dart';
import '../constants/color_constants.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onIndexChanged;
  final bool isGP;

  const CustomBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
    required this.isGP,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                label: 'Home',
                isSelected: selectedIndex == 0,
                onTap: () => onIndexChanged(0),
              ),
              _NavBarItem(
                icon: isGP ? Icons.list_alt_outlined : Icons.local_shipping_outlined,
                label: isGP ? 'Missions' : 'Tracking',
                isSelected: selectedIndex == 1,
                onTap: () => onIndexChanged(1),
              ),
              _NavBarItem(
                icon: Icons.add_box_outlined,
                label: isGP ? 'Add Mission' : 'Send',
                isSelected: selectedIndex == 2,
                onTap: () => onIndexChanged(2),
              ),
              _NavBarItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                isSelected: selectedIndex == 3,
                onTap: () => onIndexChanged(3),
              ),
              _NavBarItem(
                icon: Icons.person_outline,
                label: 'Profile',
                isSelected: selectedIndex == 4,
                onTap: () => onIndexChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : Colors.grey,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppColors.primaryBlue : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}