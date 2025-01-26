import 'package:flutter/material.dart';

import '../constants/color_constants.dart';

class AddMissionFAB extends StatelessWidget {
  final VoidCallback onPressed;

  const AddMissionFAB({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: 4,
      backgroundColor:  AppColors.primaryBlue,
      shape: const CircleBorder(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(
            Icons.flight_takeoff,
            color: Colors.white,
            size: 24,
          ),
          Positioned(
            bottom: 8,
            child: Container(
              height: 2,
              width: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}